const gd = @import("../core/api.zig");
const c = gd.c;

const Object = @import("object.zig").Object;

pub const Node = struct { // This is a template of what the auto generated classes should look like

    base: Object,

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

        pub var get_child: [*c]c.godot_method_bind = null;

    };

    pub fn initBindings() void {
        Binds.get_child = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), "get_child");

        var class_name: c.godot_string_name = undefined;
        gd.api.*.godot_string_name_new_data.?(&class_name, @typeName(Self));
        defer gd.api.*.godot_string_name_destroy.?(&class_name);
        GodotClass.detail_class_tag = gd.api_1_2.*.godot_get_class_tag.?(&class_name);
    }

    pub fn getChild(self: *const Self, index: i64) ?*Node {
        var ret: i64 = undefined;
        var args = [_]?*const anyopaque { &index };
        gd.api.*.godot_method_bind_ptrcall.?(Binds.get_child, self, &args, &ret);
        return ret;
    }

};
