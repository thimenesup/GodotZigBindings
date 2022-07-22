const gd = @import("api.zig");
const c = gd.c;

const typeId = @import("typeid.zig").typeId;

pub const Wrapped = struct {
    owner: ?*c.godot_object,
    type_tag: usize,
};


pub fn GenGodotClass(comptime class: type, comptime instanciable: bool, comptime singleton: bool) type {
    return struct {

        pub inline fn isClassScript() bool {
            return false;
        }

        pub inline fn getClassName() [*:0]const u8 {
            return @typeName(class);
        }

        pub inline fn getGodotClassName() [*:0]const u8 {
            return @typeName(class);
        }

        pub inline fn getId() usize {
            return typeId(class);
        }

        pub inline fn memnew() *class {
            comptime if (!instanciable) {
                @compileError("This class isn't instanciable");
            };

            const class_constructor = gd.api.*.godot_get_class_constructor.?(@typeName(class));
            const class_instance = class_constructor.?();
            const instance_data = gd.nativescript_1_1_api.*.godot_nativescript_get_instance_binding_data.?(gd.language_index, class_instance);
            return @ptrCast(*class, @alignCast(@alignOf(*class), instance_data));
        }

        pub inline fn getSingleton() *class {
            comptime if (!singleton) {
                @compileError("This class isn't a singleton");
            };

            const class_instance = gd.api.*.godot_global_get_singleton.?(@intToPtr(*u8, @ptrToInt(@typeName(class))));
            const instance_data = gd.nativescript_1_1_api.*.godot_nativescript_get_instance_binding_data.?(gd.language_index, class_instance);
            return @ptrCast(*class, @alignCast(@alignOf(*class), instance_data));
        }

    };
}
