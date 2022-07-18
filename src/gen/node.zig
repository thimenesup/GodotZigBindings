const gd = @import("../core/api.zig");
const c = gd.c;

const GenGodotClass = @import("../core/wrapped.zig").GenGodotClass;
const Object = @import("object.zig").Object;

pub const Node = struct { // This is a template of what the auto generated classes should look like

    base: Object,

    const Self = @This();

    pub const GodotClass = GenGodotClass(Self);

    const Binds = struct {

        pub var get_child: [*c]c.godot_method_bind = null;

    };

    pub fn initBindings() void {
        Binds.get_child = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), "get_child");
    }

    pub fn getChild(self: *const Self, index: i64) ?*Node {
        var ret: ?*Node = undefined;
        var args = [_]?*const anyopaque { &index };
        gd.api.*.godot_method_bind_ptrcall.?(Binds.get_child, self.base.base.owner, &args, &ret);

        if (ret != null) {
            const instance_data = gd.nativescript_1_1_api.*.godot_nativescript_get_instance_binding_data.?(gd.language_index, ret);
            ret = @ptrCast(?*Node, @alignCast(@alignOf(?*Node), instance_data));
        }

        return ret;
    }

};
