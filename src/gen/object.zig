const gd = @import("../core/api.zig");
const c = gd.c;

const GenGodotClass = @import("../core/wrapped.zig").GenGodotClass;
const Wrapped = @import("../core/wrapped.zig").Wrapped;

pub const Object = struct { // This is a template of what the auto generated classes should look like

    base: Wrapped,

    const Self = @This();

    pub const GodotClass = GenGodotClass(Self);

    const Binds = struct {

        pub var get_instance_id: [*c]c.godot_method_bind = null;

    };

    pub fn initBindings() void {
        Binds.get_instance_id = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), "get_instance_id");
    }

    pub fn getInstanceId(self: *const Self) i64 {
        var ret: i64 = undefined;
        var args = [_]?*const anyopaque { null };
        gd.api.*.godot_method_bind_ptrcall.?(Binds.get_instance_id, self.base.owner, &args, &ret);
        return ret;
    }

};
