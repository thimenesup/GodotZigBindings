const std = @import("std");

const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");
const type_utils = @import("type_utils.zig");

const Variant = @import("../variant/variant.zig").Variant;

inline fn ptrCall(comptime class: type, comptime function: anytype, comptime is_method: bool, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    const struct_instance: ?*class = @ptrCast(@alignCast(instance));

    // Pass call arguments as either dereferenced value or the pointer itself, matching the signature
    comptime var arg_types: [fn_info.params.len]type = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }

    const TupleType = std.meta.Tuple(&arg_types);
    var arg_tuple: TupleType = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        if (is_method and i == 0) {
            arg_tuple[i] = @ptrCast(struct_instance);
        } else {
            const arg_index = if (is_method) i - 1 else i; // Minus 1 to offset struct
            const base_type = type_utils.BaseType(param.type.?);
            const arg_typed_ptr: *base_type = @alignCast(@constCast(@ptrCast(args[arg_index])));
            if (type_utils.isPointerType(param.type.?)) {
                arg_tuple[i] = arg_typed_ptr;
            } else {
                arg_tuple[i] = arg_typed_ptr.*;
            }
        }
    }

    const result = @call(.auto, function, arg_tuple);
    const r_variant: ?*Variant = @ptrCast(r_return);
    if (r_variant != null) {
        r_variant.?.* = Variant.typeAsVariant(fn_info.return_type.?)(&result);
    }
}

inline fn ptrCallFunction(comptime function: anytype, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    ptrCall(void, function, false, null, args, r_return);
}

inline fn ptrCallMethod(comptime class: type, comptime function: anytype, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    comptime if (fn_info.params.len == 0) {
        @compileError("A method needs to take atleast the struct parameter");
    };
    comptime if (fn_info.params[0].type.? != *class and fn_info.params[0].type.? != *const class) {
        @compileError("The first parameter of a method should be the struct");
    };

    ptrCall(class, function, true, instance, args, r_return);
}


inline fn variantCall(comptime class: type, comptime function: anytype, comptime is_method: bool, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    const struct_instance: ?*class = @ptrCast(@alignCast(instance));

    // Need to store the value of every converted variant
    comptime var arg_base_types: [fn_info.params.len]type = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        if (is_method and i == 0) {
            arg_base_types[i] = param.type.?;
        } else {
            arg_base_types[i] = type_utils.BaseType(param.type.?);
        }
    }

    const StorageTupleType = std.meta.Tuple(&arg_base_types);
    var arg_storage: StorageTupleType = undefined;
    inline for (arg_base_types, 0..) |arg_base_type, i| {
        if (is_method and i == 0) {
            continue;
        } else {
            const arg_index = if (is_method) i - 1 else i; // Minus 1 to offset struct
            const conversion_fn = Variant.variantAsType(arg_base_type);
            arg_storage[i] = conversion_fn(@ptrCast(args[arg_index]));
        }
    }

    // Pass call arguments as either the stored value or a pointer to it, matching the signature
    // NOTE: C++ GDExtension won't compile if using non const ptrs in variant calls
    // The reason is likely that since the variant gets converted to a copy, the passed value won't get actually mutated, which can lead to confusion, but we will allow it
    comptime var arg_types: [fn_info.params.len]type = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }

    const TupleType = std.meta.Tuple(&arg_types);
    var arg_tuple: TupleType = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        if (is_method and i == 0) {
            arg_tuple[i] = @ptrCast(struct_instance);
        } else {
            if (type_utils.isPointerType(param.type.?)) {
                arg_tuple[i] = &arg_storage[i];
            } else {
                arg_tuple[i] = arg_storage[i];
            }
        }
    }

    const result = @call(.auto, function, arg_tuple);
    const r_variant: ?*Variant = @ptrCast(r_return);
    if (r_variant != null) {
        r_variant.?.* = Variant.typeAsVariant(fn_info.return_type.?)(&result);
    }
}

inline fn variantCallFunction(comptime function: anytype, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    variantCall(void, function, false, null, args, r_return);
}

inline fn variantCallMethod(comptime class: type, comptime function: anytype, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    comptime if (fn_info.params.len == 0) {
        @compileError("A method needs to take atleast the struct parameter");
    };
    comptime if (fn_info.params[0].type.? != *class and fn_info.params[0].type.? != *const class) {
        @compileError("The first parameter of a method should be the struct");
    };

    variantCall(class, function, true, instance, args, r_return);
}


inline fn variantCallValidate(comptime function: anytype, comptime is_method: bool, args: [*c]const gi.GDExtensionConstTypePtr, argument_count: gi.GDExtensionInt, r_error: *gi.GDExtensionCallError) bool {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    const variant_arg_count = if (is_method) fn_info.params.len - 1 else fn_info.params.len;
    if (argument_count < variant_arg_count) {
        r_error._error = gi.GDExtensionCallErrorType.GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS;
        r_error.argument = variant_arg_count;
        return false;
    }
    if (argument_count > variant_arg_count) {
        r_error._error = gi.GDExtensionCallErrorType.GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS;
        r_error.argument = variant_arg_count;
        return false;
    }

    inline for (fn_info.params, 0..) |param, i| {
        if (is_method and i == 0) { // Skip instance struct
            continue;
        }
        const variant_arg_index = if (is_method) i - 1 else i;

        const variant_arg: *const Variant = @ptrCast(args[variant_arg_index]);
        const param_base_type = type_utils.BaseType(param.type.?);
        const expected_variant_type = Variant.typeToVariantType(param_base_type);
        const gi_variant_type: gi.GDExtensionVariantType = @enumFromInt(@intFromEnum(variant_arg.getType()));
        const gi_expected_type: gi.GDExtensionVariantType = @enumFromInt(@intFromEnum(expected_variant_type));
        if (!gd.interface.?.variant_can_convert_strict.?(gi_variant_type, gi_expected_type)) {
            r_error._error = gi.GDExtensionCallErrorType.GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT;
            r_error.argument = variant_arg_index;
            r_error.expected = @bitCast(@intFromEnum(gi_expected_type));
            return false;
        }
    }

    r_error._error = gi.GDExtensionCallErrorType.GDEXTENSION_CALL_OK;
    return true;
}


pub fn FunctionPtrCall(comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) callconv(.C) void {
            _ = method_userdata;
            _ = instance;

            ptrCallFunction(function, args, r_return);
        }

    };
}

pub fn FunctionCall(comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, argument_count: gi.GDExtensionInt, r_return: gi.GDExtensionVariantPtr, r_error: [*c]gi.GDExtensionCallError) callconv(.C) void {
            _ = method_userdata;
            _ = instance;

            if (!variantCallValidate(function, false, args, argument_count, r_error)) {
                return;
            }
            variantCallFunction(function, args, r_return);
        }

    };
}


pub fn MethodPtrCall(comptime class: type, comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) callconv(.C) void {
            _ = method_userdata;

            ptrCallMethod(class, function, instance, args, r_return);
        }

    };
}

pub fn MethodCall(comptime class: type, comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(method_userdata: ?*anyopaque, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, argument_count: gi.GDExtensionInt, r_return: gi.GDExtensionVariantPtr, r_error: [*c]gi.GDExtensionCallError) callconv(.C) void {
            _ = method_userdata;

            if (!variantCallValidate(function, true, args, argument_count, r_error)) {
                return;
            }
            variantCallMethod(class, function, instance, args, r_return);
        }

    };
}

pub fn VirtualMethodCall(comptime class: type, comptime function: anytype) type {
    return extern struct {

        pub fn functionWrap(instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) callconv(.C) void {
            ptrCallMethod(class, function, instance, args, r_return);
        }

    };
}
