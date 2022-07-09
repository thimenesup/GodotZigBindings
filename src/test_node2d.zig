const gd = @import("core/api.zig");
const c = gd.c;

const Godot = @import("core/godot_global.zig").Godot;
const String = @import("core/string.zig").String;

const PoolByteArray = @import("core/pool_arrays.zig").PoolByteArray;

pub const TestNode2D = struct {

    data: u32,

    const InheritedClassName = "Node2D";
    const ClassName = "TestNode2D";

    pub fn constructor(p_instance: ?*c.godot_object, p_method_data: ?*anyopaque) callconv(.C) ?*anyopaque {
        _ = p_instance;
        _ = p_method_data;

        var user_data = gd.api.*.godot_alloc.?(@sizeOf(@This()));

        return user_data;
    }

    pub fn destructor(p_instance: ?*c.godot_object, p_method_data: ?*anyopaque, p_user_data: ?*anyopaque) callconv(.C) void {
        _ = p_instance;
        _ = p_method_data;

        gd.api.*.godot_free.?(p_user_data);
    }

    pub fn process(obj: ?*c.godot_object, method_data: ?*anyopaque, user_data: ?*anyopaque, num_args: c_int, args: [*c][*c]c.godot_variant) callconv(.C) c.godot_variant {
        _ = obj;
        _ = method_data;
        _ = user_data;
        _ = num_args;
        _ = args;

        var string = String.initUtf8("Hello from TestNode2D zig");
        defer string.deinit();
        Godot.print(&string);

        var ret: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_nil.?(&ret);
        return ret;
    }

    pub fn registerClass(nativescript_api: [*c]const c.godot_gdnative_ext_nativescript_api_struct, p_handle: ?*anyopaque) void {
        var create = c.godot_instance_create_func {
            .create_func = constructor,
            .method_data = null,
            .free_func = null,
        };
        
        var destroy = c.godot_instance_destroy_func {
            .destroy_func = destructor,
            .method_data = null,
            .free_func = null,
        };

        nativescript_api.*.godot_nativescript_register_class.?(p_handle, ClassName, InheritedClassName, create, destroy);

        var method_attributes = c.godot_method_attributes {
            .rpc_type = c.GODOT_METHOD_RPC_MODE_DISABLED,
        };

        var process_method = c.godot_instance_method {
            .method = process,
            .method_data = null,
            .free_func = null,
        };

        nativescript_api.*.godot_nativescript_register_method.?(p_handle, ClassName, "_process", method_attributes, process_method);
    }

};
