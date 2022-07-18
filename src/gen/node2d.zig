const gd = @import("../core/api.zig");
const c = gd.c;

const GenGodotClass = @import("../core/wrapped.zig").GenGodotClass;
const Node = @import("node.zig").Node;

pub const Node2D = struct { // This is a template of what the auto generated classes should look like

    base: Node, //Ackshually, it inherits CanvasItem, but good enough for testing

    const Self = @This();

    pub const GodotClass = GenGodotClass(Self);
    
    const Binds = struct {

        pub var rotate: [*c]c.godot_method_bind = null;
        pub var get_z_index: [*c]c.godot_method_bind = null;

    };

    pub fn initBindings() void {
        Binds.rotate = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), "rotate");
        Binds.get_z_index = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), "get_z_index");
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
