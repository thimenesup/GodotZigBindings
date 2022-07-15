const gd = @import("api.zig");
const c = gd.c;

const Variant = @import("variant.zig").Variant;

// This is used to declare your Godot Class like this: const GodotClass = DefineGodotClass(MyNode, Node);
pub fn DefineGodotClass(comptime class: type, comptime base: type) type {
    return struct {

        inline fn isClassScript() bool {
            return true;
        }

        inline fn getClassName() [*:0]const u8 {
            return @typeName(class);
        }

        inline fn getBaseClassName() [*:0]const u8 {
            return @typeName(base); //base.getClassName();
        }

        inline fn getGodotBaseClassName() [*:0]const u8 {
            return ""; //base.getGodotClassName();
        }

        inline fn getId() usize {
            return 0; //TODO: Figure out how to do it
        }

        inline fn getBaseId() usize {
            return 0; //base.getId();
        }

    };
}


pub fn registerClass(comptime class: type, handle: ?*anyopaque) void {
    comptime if (!class.GodotClass.isClassScript()) {
        @compileError("This function must only be used on custom classes");
    };

    const create = c.godot_instance_create_func {
        .create_func = class.constructor,
        .method_data = null,
        .free_func = null,
    };

    const destroy = c.godot_instance_destroy_func {
        .destroy_func = class.destructor,
        .method_data = null,
        .free_func = null,
    };

    gd.nativescript_api.*.godot_nativescript_register_class.?(handle, class.GodotClass.getClassName(), class.GodotClass.getBaseClassName(), create, destroy);

    class.registerMembers(handle);
}


fn FunctionWrapper(comptime function: anytype) type {
    return extern struct {

        fn functionWrap(godot_object: ?*c.godot_object, method_data: ?*const anyopaque, user_data: ?*anyopaque, arg_count: c_int, args: [*c][*c]c.godot_variant) callconv(.C) c.godot_variant {
            _ = godot_object;
            _ = method_data;
            _ = user_data;
            _ = arg_count;

            const fn_info = @typeInfo(@TypeOf(function)).Fn;

            switch(fn_info.args.len) { //TODO: Find if its possible to this automatically
                1 => {
                    const result = @call(.{}, function, .{
                        Variant.variantAsType(fn_info.args[0].arg_type.?)(args[0]),
                    });
                    
                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                2 => {
                    const result = @call(.{}, function, .{
                        Variant.variantAsType(fn_info.args[0].arg_type.?)(args[0]),
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[1]),
                    });
                    
                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                3 => {
                    const result = @call(.{}, function, .{
                        Variant.variantAsType(fn_info.args[0].arg_type.?)(args[0]),
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[1]),
                        Variant.variantAsType(fn_info.args[2].arg_type.?)(args[2]),
                    });
                    
                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                4 => {
                    const result = @call(.{}, function, .{
                        Variant.variantAsType(fn_info.args[0].arg_type.?)(args[0]),
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[1]),
                        Variant.variantAsType(fn_info.args[2].arg_type.?)(args[2]),
                        Variant.variantAsType(fn_info.args[3].arg_type.?)(args[3]),
                    });

                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                5 => {
                    const result = @call(.{}, function, .{
                        Variant.variantAsType(fn_info.args[0].arg_type.?)(args[0]),
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[1]),
                        Variant.variantAsType(fn_info.args[2].arg_type.?)(args[2]),
                        Variant.variantAsType(fn_info.args[3].arg_type.?)(args[3]),
                        Variant.variantAsType(fn_info.args[4].arg_type.?)(args[4]),
                    });

                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                else => {
                    @compileError("Unsupported arg count");
                },
            }
        }

    };
}

pub fn registerFunction(handle: ?*anyopaque, comptime class: type, name: [*:0]const u8, comptime method: anytype, rpc_type: c.godot_method_rpc_mode) void {
    comptime if (!class.GodotClass.isClassScript()) {
        @compileError("This function must only be used on custom classes");
    };

    const function_wrapper = FunctionWrapper(method);

    const instance = c.godot_instance_method {
        .method = function_wrapper.functionWrap,
        .method_data = null,
        .free_func = null,
    };

    const attributes = c.godot_method_attributes {
        .rpc_type = rpc_type,
    };

    gd.nativescript_api.*.godot_nativescript_register_method.?(handle, class.GodotClass.getClassName(), name, attributes, instance);
}


fn MethodWrapper(comptime class: type, comptime function: anytype) type {
    return extern struct {

        fn functionWrap(godot_object: ?*c.godot_object, method_data: ?*const anyopaque, user_data: ?*anyopaque, arg_count: c_int, args: [*c][*c]c.godot_variant) callconv(.C) c.godot_variant {
            _ = godot_object;
            _ = method_data;
            _ = arg_count;

            const fn_info = @typeInfo(@TypeOf(function)).Fn;
            const struct_instance = @ptrCast(*class, @alignCast(@alignOf(*class), user_data));

            comptime if (fn_info.args.len == 0) {
                @compileError("A method needs to take atleast the struct parameter");
            };

            comptime if (fn_info.args[0].arg_type.? != *class and fn_info.args[0].arg_type.? != *const class) {
                @compileError("The first parameter of a method should be the struct");
            };

            switch(fn_info.args.len) { //TODO: Find if its possible to this automatically
                1 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                    });
                    
                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                2 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[0]),
                    });
                    
                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                3 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[0]),
                        Variant.variantAsType(fn_info.args[2].arg_type.?)(args[1]),
                    });
                    
                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                4 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[0]),
                        Variant.variantAsType(fn_info.args[2].arg_type.?)(args[1]),
                        Variant.variantAsType(fn_info.args[3].arg_type.?)(args[2]),
                    });

                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                5 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        Variant.variantAsType(fn_info.args[1].arg_type.?)(args[0]),
                        Variant.variantAsType(fn_info.args[2].arg_type.?)(args[1]),
                        Variant.variantAsType(fn_info.args[3].arg_type.?)(args[2]),
                        Variant.variantAsType(fn_info.args[4].arg_type.?)(args[3]),
                    });

                    return Variant.typeAsVariant(fn_info.return_type.?)(result);
                },
                else => {
                    @compileError("Unsupported arg count");
                },
            }
        }

    };
}

pub fn registerMethod(handle: ?*anyopaque, comptime class: type, name: [*:0]const u8, comptime method: anytype, rpc_type: c.godot_method_rpc_mode) void {
    comptime if (!class.GodotClass.isClassScript()) {
        @compileError("This function must only be used on custom classes");
    };

    const method_wrapper = MethodWrapper(class, method);

    const instance = c.godot_instance_method {
        .method = method_wrapper.functionWrap,
        .method_data = null,
        .free_func = null,
    };

    const attributes = c.godot_method_attributes {
        .rpc_type = rpc_type,
    };

    gd.nativescript_api.*.godot_nativescript_register_method.?(handle, class.GodotClass.getClassName(), name, attributes, instance);
}


fn PropertyDefaultSetWrapper(comptime class: type, comptime field_name: []const u8) type {
    return extern struct {

        fn functionWrap(godot_object: ?*c.godot_object, method_data: ?*const anyopaque, user_data: ?*anyopaque, variant_value: [*c]c.godot_variant) callconv(.C) void {
            _ = godot_object;
            _ = method_data;

            const struct_instance = @ptrCast(*class, @alignCast(@alignOf(*class), user_data));
            const field_type = @TypeOf(@field(struct_instance, field_name));
            const value = Variant.variantAsType(field_type)(variant_value);
            @field(struct_instance, field_name) = value;
        }

    };
}

fn PropertyDefaultGetWrapper(comptime class: type, comptime field_name: []const u8) type {
    return extern struct {
        
        fn functionWrap(godot_object: ?*c.godot_object, method_data: ?*const anyopaque, user_data: ?*anyopaque) callconv(.C) c.godot_variant {
            _ = godot_object;
            _ = method_data;

            const struct_instance = @ptrCast(*class, @alignCast(@alignOf(*class), user_data));
            const field_type = @TypeOf(@field(struct_instance, field_name));
            const value = @field(struct_instance, field_name);
            return Variant.typeAsVariant(field_type)(value);
        }

    };
}

fn PropertySetWrapper(comptime class: type, comptime function: anytype) type {
    return extern struct {

        fn functionWrap(godot_object: ?*c.godot_object, method_data: ?*const anyopaque, user_data: ?*anyopaque, variant_value: [*c]c.godot_variant) callconv(.C) void {
            _ = godot_object;
            _ = method_data;

            const fn_info = @typeInfo(@TypeOf(function)).Fn;
            const struct_instance = @ptrCast(*class, @alignCast(@alignOf(*class), user_data));

            _ = @call(.{}, function, .{ struct_instance, Variant.variantAsType(fn_info.args[1].arg_type.?)(variant_value) });
        }

    };
}

fn PropertyGetWrapper(comptime class: type, comptime function: anytype) type {
    return extern struct {

        fn functionWrap(godot_object: ?*c.godot_object, method_data: ?*const anyopaque, user_data: ?*anyopaque) callconv(.C) c.godot_variant {
            _ = godot_object;
            _ = method_data;

            const fn_info = @typeInfo(@TypeOf(function)).Fn;
            const struct_instance = @ptrCast(*class, @alignCast(@alignOf(*class), user_data));

            const result = @call(.{}, function, .{ struct_instance });
            return Variant.typeAsVariant(fn_info.return_type.?)(result);
        }

    };
}

pub fn registerProperty(handle: ?*anyopaque, comptime class: type, name: [*:0]const u8, comptime field_name: []const u8, default_value: anytype, comptime setter: anytype, comptime getter: anytype, rpc_mode: c.godot_method_rpc_mode, usage: c.godot_property_usage_flags, hint: c.godot_property_hint, hint_string: [*:0]const u8) void {
    comptime if (!class.GodotClass.isClassScript()) {
        @compileError("This function must only be used on custom classes");
    };

    const godot_variant = Variant.typeAsVariant(@TypeOf(default_value))(default_value);

    var godot_string_hint: c.godot_string = undefined;
    gd.api.*.godot_string_new.?(&godot_string_hint);
    _ = gd.api.*.godot_string_parse_utf8.?(&godot_string_hint, hint_string);
    defer gd.api.*.godot_string_destroy.?(&godot_string_hint);

    var attributes: c.godot_property_attributes = undefined;
    attributes.type = @intCast(c_int, gd.api.*.godot_variant_get_type.?(&godot_variant));
    attributes.default_value = godot_variant;
    attributes.hint = hint;
    attributes.rset_type = rpc_mode;
    attributes.usage = usage;
    attributes.hint_string = godot_string_hint;

    const set_wrapper = if (@TypeOf(setter) == @TypeOf(null)) PropertyDefaultSetWrapper(class, field_name) else PropertySetWrapper(class, setter);

    var set_func: c.godot_property_set_func = undefined;
    set_func.set_func = set_wrapper.functionWrap;
    set_func.method_data = null;
    set_func.free_func = null;

    const get_wrapper = if (@TypeOf(getter) == @TypeOf(null)) PropertyDefaultGetWrapper(class, field_name) else PropertyGetWrapper(class, getter);

    var get_func: c.godot_property_get_func = undefined;
    get_func.get_func = get_wrapper.functionWrap;
    get_func.method_data = null;
    get_func.free_func = null;

    gd.nativescript_api.*.godot_nativescript_register_property.?(handle, class.GodotClass.getClassName(), name, &attributes, set_func, get_func);
}
