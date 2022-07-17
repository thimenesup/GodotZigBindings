const gd = @import("../core/api.zig");
const c = gd.c;

const Node = @import("node.zig").Node;

pub const Node2D = struct { // This is a template of what the auto generated classes should look like

    base: Node, //Ackshually, it inherits CanvasItem, but good enough for testing

    const Self = @This();

    pub const GodotClass = struct {

        pub var detail_class_tag: ?*anyopaque = null;

        pub inline fn isClassScript() bool {
            return false;
        }

        pub inline fn getClassName() [*:0]const u8 {
            return @typeName(Self);
        }

        pub inline fn getGodotClassName() [*:0]const u8 {
            return @typeName(Self);
        }

        pub inline fn getId() usize {
            return @ptrToInt(detail_class_tag);
        }

        // pub inline fn newInstance() *Self {
        //     return null;
        // }

    };

    const Binds = struct {

        pub var rotate: [*c]c.godot_method_bind = null;
        pub var get_z_index: [*c]c.godot_method_bind = null;

    };

    pub fn initBindings() void {
        Binds.rotate = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), "rotate");
        Binds.get_z_index = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), "get_z_index");

        var class_name: c.godot_string_name = undefined;
        gd.api.*.godot_string_name_new_data.?(&class_name, @typeName(Self));
        defer gd.api.*.godot_string_name_destroy.?(&class_name);
        GodotClass.detail_class_tag = gd.api_1_2.*.godot_get_class_tag.?(&class_name);
    }

    pub fn rotate(self: *Self, radians: f64) void {
        var args = [_]?*const anyopaque { &radians };
        gd.api.*.godot_method_bind_ptrcall.?(Binds.rotate, self.base.base.base.owner, &args, null);
    }

    pub fn getZIndex(self: *Self) i64 {
        var ret: i64 = undefined;
        var args = [_]?*const anyopaque { null };
        gd.api.*.godot_method_bind_ptrcall.?(Binds.get_z_index, self.base.base.base.owner, &args, &ret);
        return ret;
    }

};
