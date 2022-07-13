const gd = @import("api.zig");
const c = gd.c;

// This is used to declare your Godot Class like this: const GodotClass = defineGodotClass(MyNode, Node);
pub fn defineGodotClass(comptime class: type, comptime base: type) type {
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

inline fn godotVariantAsBool(variant: [*c]c.godot_variant) bool {
    return gd.api.*.godot_variant_as_bool.?(variant);
}

inline fn godotVariantAsI64(variant: [*c]c.godot_variant) i64 {
    return gd.api.*.godot_variant_as_int.?(variant);
}

inline fn godotVariantAsF64(variant: [*c]c.godot_variant) f64 {
    return gd.api.*.godot_variant_as_real.?(variant);
}

fn typeArgAsVariant(comptime T: type) (fn([*c]c.godot_variant) callconv(.Inline) T) {
    switch (T) {
        bool => {
            return godotVariantAsBool;
        },
        i64 => {
            return godotVariantAsI64;
        },
        f64 => {
            return godotVariantAsF64;
        },
        else => {
            @compileError("Variant can't be converted as that type");
        },
    }

    return null;
}


inline fn voidAsGodotVariant(value: void) c.godot_variant {
    _ = value;
    var variant: c.godot_variant = undefined;
    gd.api.*.godot_variant_new_nil.?(&variant);
    return variant;
}

inline fn boolAsGodotVariant(value: bool) c.godot_variant {
    var variant: c.godot_variant = undefined;
    gd.api.*.godot_variant_new_bool.?(&variant, value);
    return variant;
}

inline fn i64AsGodotVariant(value: i64) c.godot_variant {
    var variant: c.godot_variant = undefined;
    gd.api.*.godot_variant_new_int.?(&variant, value);
    return variant;
}

inline fn f64AsGodotVariant(value: f64) c.godot_variant {
    var variant: c.godot_variant = undefined;
    gd.api.*.godot_variant_new_real.?(&variant, value);
    return variant;
}

fn typeReturnAsVariant(comptime T: type) (fn(T) callconv(.Inline) c.godot_variant) {
    switch (T) {
        void => {
            return voidAsGodotVariant;
        },
        bool => {
            return boolAsGodotVariant;
        },
        i64 => {
            return i64AsGodotVariant;
        },
        f64 => {
            return f64AsGodotVariant;
        },
        else => {
            @compileError("Unsupported return type");
        },
    }

    return null;
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
                        typeArgAsVariant(fn_info.args[0].arg_type.?)(args[0]),
                    });
                    
                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                2 => {
                    const result = @call(.{}, function, .{
                        typeArgAsVariant(fn_info.args[0].arg_type.?)(args[0]),
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[1]),
                    });
                    
                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                3 => {
                    const result = @call(.{}, function, .{
                        typeArgAsVariant(fn_info.args[0].arg_type.?)(args[0]),
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[1]),
                        typeArgAsVariant(fn_info.args[2].arg_type.?)(args[2]),
                    });
                    
                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                4 => {
                    const result = @call(.{}, function, .{
                        typeArgAsVariant(fn_info.args[0].arg_type.?)(args[0]),
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[1]),
                        typeArgAsVariant(fn_info.args[2].arg_type.?)(args[2]),
                        typeArgAsVariant(fn_info.args[3].arg_type.?)(args[3]),
                    });

                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                5 => {
                    const result = @call(.{}, function, .{
                        typeArgAsVariant(fn_info.args[0].arg_type.?)(args[0]),
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[1]),
                        typeArgAsVariant(fn_info.args[2].arg_type.?)(args[2]),
                        typeArgAsVariant(fn_info.args[3].arg_type.?)(args[3]),
                        typeArgAsVariant(fn_info.args[4].arg_type.?)(args[4]),
                    });

                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                else => {
                    @compileError("Unsupported arg count");
                },
            }
        }

    };
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
                    
                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                2 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[0]),
                    });
                    
                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                3 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[0]),
                        typeArgAsVariant(fn_info.args[2].arg_type.?)(args[1]),
                    });
                    
                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                4 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[0]),
                        typeArgAsVariant(fn_info.args[2].arg_type.?)(args[1]),
                        typeArgAsVariant(fn_info.args[3].arg_type.?)(args[2]),
                    });

                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                5 => {
                    const result = @call(.{}, function, .{
                        struct_instance,
                        typeArgAsVariant(fn_info.args[1].arg_type.?)(args[0]),
                        typeArgAsVariant(fn_info.args[2].arg_type.?)(args[1]),
                        typeArgAsVariant(fn_info.args[3].arg_type.?)(args[2]),
                        typeArgAsVariant(fn_info.args[4].arg_type.?)(args[3]),
                    });

                    return typeReturnAsVariant(fn_info.return_type.?)(result);
                },
                else => {
                    @compileError("Unsupported arg count");
                },
            }
        }

    };
}


pub fn registerClass(comptime class: type, handle: ?*anyopaque) void {
    comptime if (!class.GodotClass.isClassScript()) {
        @compileError("This function must only be used on custom classes");
    };

    const create = c.godot_instance_create_func {
        .create_func = class.constructor, //godotClassInstanceFunc(class),
        .method_data = null,
        .free_func = null,
    };

    const destroy = c.godot_instance_destroy_func {
        .destroy_func = class.destructor, //godotClassDestroyFunc(class),
        .method_data = null,
        .free_func = null,
    };

    gd.nativescript_api.*.godot_nativescript_register_class.?(handle, class.GodotClass.getClassName(), class.GodotClass.getBaseClassName(), create, destroy);

    class.registerMembers(handle);
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
