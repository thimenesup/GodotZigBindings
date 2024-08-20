const std = @import("std");

const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const Variant = @import("../core/variant.zig").Variant;

inline fn ptrCallFunction(comptime function: anytype, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;

    comptime var arg_types: [fn_info.params.len]type = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }

    const TupleType = std.meta.Tuple(&arg_types);
    var arg_tuple: TupleType = undefined;
    inline for (fn_info.params, 0..) |param, i| {
        arg_tuple[i] = @as(*const param.type.?, @alignCast(@ptrCast(args[i]))).*;
    }

    const result = @call(.auto, function, arg_tuple);
    if (r_return != null) {
        @as(*fn_info.return_type.?, @alignCast(@ptrCast(r_return))).* = result;
    }
}

inline fn ptrCallMethod(comptime class: type, comptime function: anytype, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    const struct_instance: *class = @ptrCast(@alignCast(instance));

    comptime if (fn_info.params.len == 0) {
        @compileError("A method needs to take atleast the struct parameter");
    };

    comptime if (fn_info.params[0].type.? != *class and fn_info.params[0].type.? != *const class) {
        @compileError("The first parameter of a method should be the struct");
    };

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
            arg_tuple[i] = @as(*const param.type.?, @alignCast(@ptrCast(args[i - 1]))).*; // Minus 1 to offset struct
        }
    }

    const result = @call(.auto, function, arg_tuple);
    if (r_return != null) {
        @as(*fn_info.return_type.?, @alignCast(@ptrCast(r_return))).* = result;
    }
}

inline fn variantCallFunction(comptime function: anytype, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;

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
    const r_variant: ?*Variant = @ptrCast(r_return);
    if (r_variant != null) {
        r_variant.?.* = Variant.typeAsVariant(fn_info.return_type.?)(&result);
    }
}

inline fn variantCallMethod(comptime class: type, comptime function: anytype, instance: gi.GDExtensionClassInstancePtr, args: [*c]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;
    const struct_instance: *class = @ptrCast(@alignCast(instance));

    comptime if (fn_info.params.len == 0) {
        @compileError("A method needs to take atleast the struct parameter");
    };

    comptime if (fn_info.params[0].type.? != *class and fn_info.params[0].type.? != *const class) {
        @compileError("The first parameter of a method should be the struct");
    };

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
    const r_variant: ?*Variant = @ptrCast(r_return);
    if (r_variant != null) {
        r_variant.?.* = Variant.typeAsVariant(fn_info.return_type.?)(&result);
    }
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
        const expected_variant_type = Variant.typeToVariantType(param.type.?);
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
