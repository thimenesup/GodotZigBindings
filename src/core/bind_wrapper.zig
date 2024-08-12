const std = @import("std");

const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const Variant = @import("../core/variant.zig").Variant;

inline fn callFunction(comptime function: anytype, args: [*]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;

    const r_variant: *Variant = @ptrCast(r_return);

    comptime var arg_types: [fn_info.params.len]type = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }

    const TupleType = std.meta.Tuple(&arg_types);
    var arg_tuple: TupleType = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        arg_tuple[i] = Variant.variantAsType(param.type.?)(@ptrCast(args[i]));
    }

    const result = @call(.auto, function, arg_tuple);
    r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
}

inline fn callMethod(comptime class: type, comptime function: anytype, instance: gi.GDExtensionClassInstancePtr, args: [*]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    const struct_instance: *class = @ptrCast(@alignCast(instance));

    comptime if (fn_info.params.len == 0) {
        @compileError("A method needs to take atleast the struct parameter");
    };

    comptime if (fn_info.params[0].type.? != *class and fn_info.params[0].type.? != *const class) {
        @compileError("The first parameter of a method should be the struct");
    };

    const r_variant: *Variant = @ptrCast(r_return);

    comptime var arg_types: [fn_info.params.len]type = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }

    const TupleType = std.meta.Tuple(&arg_types);
    var arg_tuple: TupleType = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        if (i == 0) {
            arg_tuple[i] = struct_instance;
        } else {
            arg_tuple[i] = Variant.variantAsType(param.type.?)(@ptrCast(args[i - 1])); // Minus 1 to offset struct
        }
    }

    const result = @call(.auto, function, arg_tuple);
    r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
}


pub fn FunctionPtrCall(comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) callconv(.C) void {
            _ = method_userdata;
            _ = instance;

            callFunction(function, args, r_return);
        }

    };
}

pub fn FunctionCall(comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, argument_count: gi.GDExtensionInt, r_return: gi.GDExtensionVariantPtr, r_error: [*c]gi.GDExtensionCallError) callconv(.C) void {
            _ = method_userdata;
            _ = instance;
            _ = argument_count;
            _ = r_error;

            callFunction(function, args, r_return);
        }

    };
}


pub fn MethodPtrCall(comptime class: type, comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) callconv(.C) void {
            _ = method_userdata;

            callMethod(class, function, instance, args, r_return);
        }

    };
}

pub fn MethodCall(comptime class: type, comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, argument_count: gi.GDExtensionInt, r_return: gi.GDExtensionVariantPtr, r_error: [*c]gi.GDExtensionCallError) callconv(.C) void {
            _ = method_userdata;
            _ = argument_count;
            _ = r_error;

            callMethod(class, function, instance, args, r_return);
        }

    };
}
