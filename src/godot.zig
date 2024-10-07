const std = @import("std");

const gi = @import("gdextension_interface.zig");
const type_utils = @import("core/type_utils.zig");

const ClassDB = @import("core/class_db.zig").ClassDB;
const Variant = @import("variant/variant.zig").Variant;

pub var interface: ?*const gi.GDExtensionInterface = null;
pub var library: gi.GDExtensionClassLibraryPtr = null;
pub var token: ?*anyopaque = null;

const Callback = ?*const fn (gi.GDExtensionInitializationLevel) callconv(.C) void;
var init_callback: Callback = null;
var terminate_callback: Callback = null;
var minimum_initialization_level: gi.GDExtensionInitializationLevel = gi.GDExtensionInitializationLevel.GDEXTENSION_INITIALIZATION_CORE;

fn initialize_level(userdata: ?*anyopaque, p_level: gi.GDExtensionInitializationLevel) callconv(.C) void {
    _ = userdata;
    ClassDB.current_level = p_level;
    if (init_callback != null) {
        init_callback.?(p_level);
    }
    ClassDB.initialize(p_level);
}

fn deinitialize_level(userdata: ?*anyopaque, p_level: gi.GDExtensionInitializationLevel) callconv(.C) void {
    _ = userdata;
    ClassDB.current_level = p_level;
    if (terminate_callback != null) {
        terminate_callback.?(p_level);
    }
    ClassDB.deinitialize(p_level);
}

pub fn register_initializer(p_init: Callback) void {
    init_callback = p_init;
}

pub fn register_terminator(p_terminate: Callback) void {
    terminate_callback = p_terminate;
}

pub fn set_minimum_library_initialization_level(p_level: gi.GDExtensionInitializationLevel) void {
    minimum_initialization_level = p_level;
}

pub fn init(p_interface: *const gi.GDExtensionInterface, p_library: gi.GDExtensionClassLibraryPtr, r_initialization: *gi.GDExtensionInitialization) gi.GDExtensionBool {
    interface = p_interface;
    library = p_library;
    token = p_library;

    r_initialization.initialize = initialize_level;
    r_initialization.deinitialize = deinitialize_level;
    r_initialization.minimum_initialization_level = minimum_initialization_level;

    Variant.initBindings();

    return true;
}


pub fn callBuiltinConstructor(constructor: gi.GDExtensionPtrConstructor, base: gi.GDExtensionTypePtr, args: anytype) void {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }
    constructor.?(base, &payload);
}

pub fn callBuiltinMbNoRet(method: gi.GDExtensionPtrBuiltInMethod, base: gi.GDExtensionTypePtr, args: anytype) void {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }
    method.?(base, &payload, null, payload.len);
}

pub fn callBuiltinMbRet(comptime T: type, method: gi.GDExtensionPtrBuiltInMethod, base: gi.GDExtensionTypePtr, args: anytype) T {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }

    // Godot calling convention handles all integers, floats and bool to have certain size, so we must handle conversion...
    const type_info = @typeInfo(T);
    const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
    switch (type_info) {
        type_tag.Bool => {
            var ret: u8 = undefined;
            method.?(base, &payload, &ret, payload.len);
            return @as(bool, ret != 0);
        },
        type_tag.Int => {
            const Int = if (type_info.Int.signedness == .unsigned) u64 else i64;
            var ret: Int = undefined;
            method.?(base, &payload, &ret, payload.len);
            return @truncate(ret);
        },
        type_tag.Float => {
            var ret: f64 = undefined;
            method.?(base, &payload, &ret, payload.len);
            return @floatCast(ret);
        },
        else => {
            var ret: T = Variant.defaultConstruct(T);
            method.?(base, &payload, &ret, payload.len);
            return ret;
        }
    }
}

pub fn callBuiltinOperatorPtr(comptime T: type, op: gi.GDExtensionPtrOperatorEvaluator, left: gi.GDExtensionConstTypePtr, right: gi.GDExtensionConstTypePtr) T {
    var ret: T = Variant.defaultConstruct(T);
    op.?(left, right, &ret);
    return ret;
}

pub fn callBuiltinPtrGetter(comptime T: type, getter: gi.GDExtensionPtrGetter, base: gi.GDExtensionConstTypePtr) T {
    var ret: T = Variant.defaultConstruct(T);
    getter.?(base, &ret);
    return ret;
}


pub fn callMbRet(mb: gi.GDExtensionMethodBindPtr, instance: ?*anyopaque, args: anytype) Variant {
    var variants: [args.len]Variant = undefined;
    inline for (args, 0..) |arg, i| {
        const arg_type = @TypeOf(arg);
        const base_type = type_utils.BaseType(arg_type);
        const convert_fn = Variant.typeAsVariant(base_type);
        if (type_utils.isPointerType(arg_type)) {
            variants[i] = convert_fn(arg);
        } else {
            variants[i] = convert_fn(&arg);
        }
    }

    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (variants, 0..) |variant, i| {
        payload[i] = @ptrCast(&variant);
    }
    var _error: gi.GDExtensionCallError = undefined;
    var ret: Variant = undefined;
    interface.?.object_method_bind_call.?(mb, instance, &payload, args.len, &ret, &_error);
    return ret;
}

pub fn callNativeMbNoRet(mb: gi.GDExtensionMethodBindPtr, instance: ?*anyopaque, args: anytype) void {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }
    interface.?.object_method_bind_ptrcall.?(mb, instance, &payload, null);
}

pub fn callNativeMbRet(comptime T: type, mb: gi.GDExtensionMethodBindPtr, instance: ?*anyopaque, args: anytype) T {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }

    // Godot calling convention handles all integers, floats and bool to have certain size, so we must handle conversion...
    const type_info = @typeInfo(T);
    const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
    switch (type_info) {
        type_tag.Bool => {
            var ret: u8 = undefined;
            interface.?.object_method_bind_ptrcall.?(mb, instance, &payload, &ret);
            return @as(bool, ret != 0);
        },
        type_tag.Int => {
            const Int = if (type_info.Int.signedness == .unsigned) u64 else i64;
            var ret: Int = undefined;
            interface.?.object_method_bind_ptrcall.?(mb, instance, &payload, &ret);
            return @truncate(ret);
        },
        type_tag.Float => {
            var ret: f64 = undefined;
            interface.?.object_method_bind_ptrcall.?(mb, instance, &payload, &ret);
            return @floatCast(ret);
        },
        else => {
            var ret: T = Variant.defaultConstruct(T);
            interface.?.object_method_bind_ptrcall.?(mb, instance, &payload, &ret);
            return ret;
        }
    }
}

pub fn callNativeMbRetObj(comptime ObjectPtr: type, mb: gi.GDExtensionMethodBindPtr, instance: ?*anyopaque, args: anytype) ObjectPtr {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }
    var ret: ?*anyopaque = null;
    interface.?.object_method_bind_ptrcall.?(mb, instance, &payload, @ptrCast(&ret));
    if (ret == null) {
        return null;
    }
    const ObjectType = type_utils.BaseType(ObjectPtr);
    return @alignCast(@ptrCast(interface.?.object_get_instance_binding.?(ret, token, ObjectType._getBindingCallbacks())));
}


pub fn callUtilityNoRet(func: gi.GDExtensionPtrUtilityFunction, args: anytype) void {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }
    func.?(null, &payload, payload.len);
}

pub fn callUtilityRet(comptime T: type, func: gi.GDExtensionPtrUtilityFunction, args: anytype) T {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }

    // Godot calling convention handles all integers, floats and bool to have certain size, so we must handle conversion...
    const type_info = @typeInfo(T);
    const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
    switch (type_info) {
        type_tag.Bool => {
            var ret: u8 = undefined;
            func.?(&ret, &payload, payload.len);
            return @as(bool, ret != 0);
        },
        type_tag.Int => {
            const Int = if (type_info.Int.signedness == .unsigned) u64 else i64;
            var ret: Int = undefined;
            func.?(&ret, &payload, payload.len);
            return @truncate(ret);
        },
        type_tag.Float => {
            var ret: f64 = undefined;
            func.?(&ret, &payload, payload.len);
            return @floatCast(ret);
        },
        else => {
            var ret: T = Variant.defaultConstruct(T);
            func.?(&ret, &payload, payload.len);
            return ret;
        }
    }
}

pub fn callUtilityRetObj(comptime ObjectPtr: type, func: gi.GDExtensionPtrUtilityFunction, args: anytype) ObjectPtr {
    var payload: [args.len]gi.GDExtensionConstTypePtr = undefined;
    inline for (args, 0..) |arg, i| {
        payload[i] = @ptrCast(arg);
    }
    var ret: ?*anyopaque = null;
    func.?(@ptrCast(&ret), &payload, payload.len);
    if (ret == null) {
        return null;
    }
    const ObjectType = type_utils.BaseType(ObjectPtr);
    return @alignCast(@ptrCast(interface.?.object_get_instance_binding(ret, token, ObjectType._getBindingCallBacks())));
}
