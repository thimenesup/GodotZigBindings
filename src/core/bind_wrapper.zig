const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const Variant = @import("../core/variant.zig").Variant;

inline fn callFunction(comptime function: anytype, args: [*]const gi.GDExtensionConstTypePtr, r_return: gi.GDExtensionTypePtr) void {
    const fn_info = @typeInfo(@TypeOf(function)).Fn;

    const r_variant: *Variant = @ptrCast(r_return);

    switch(fn_info.params.len) { //TODO: Find if its possible to this automatically
        0 => {
            const result = @call(.auto, function, .{
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        1 => {
            const result = @call(.auto, function, .{
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        2 => {
            const result = @call(.auto, function, .{
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
                Variant.variantAsType(fn_info.params[2].type.?)(@ptrCast(args[1])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        3 => {
            const result = @call(.auto, function, .{
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
                Variant.variantAsType(fn_info.params[2].type.?)(@ptrCast(args[1])),
                Variant.variantAsType(fn_info.params[3].type.?)(@ptrCast(args[2])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        4 => {
            const result = @call(.auto, function, .{
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
                Variant.variantAsType(fn_info.params[2].type.?)(@ptrCast(args[1])),
                Variant.variantAsType(fn_info.params[3].type.?)(@ptrCast(args[2])),
                Variant.variantAsType(fn_info.params[4].type.?)(@ptrCast(args[3])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        else => {
            @compileError("Unsupported arg count");
        },
    }
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

    switch(fn_info.params.len) { //TODO: Find if its possible to this automatically
        1 => {
            const result = @call(.auto, function, .{
                struct_instance,
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        2 => {
            const result = @call(.auto, function, .{
                struct_instance,
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        3 => {
            const result = @call(.auto, function, .{
                struct_instance,
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
                Variant.variantAsType(fn_info.params[2].type.?)(@ptrCast(args[1])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        4 => {
            const result = @call(.auto, function, .{
                struct_instance,
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
                Variant.variantAsType(fn_info.params[2].type.?)(@ptrCast(args[1])),
                Variant.variantAsType(fn_info.params[3].type.?)(@ptrCast(args[2])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        5 => {
            const result = @call(.auto, function, .{
                struct_instance,
                Variant.variantAsType(fn_info.params[1].type.?)(@ptrCast(args[0])),
                Variant.variantAsType(fn_info.params[2].type.?)(@ptrCast(args[1])),
                Variant.variantAsType(fn_info.params[3].type.?)(@ptrCast(args[2])),
                Variant.variantAsType(fn_info.params[4].type.?)(@ptrCast(args[3])),
            });
            r_variant.* = Variant.typeAsVariant(fn_info.return_type.?)(result);
        },
        else => {
            @compileError("Unsupported arg count");
        },
    }
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
