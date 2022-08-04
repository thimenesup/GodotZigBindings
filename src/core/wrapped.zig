const gd = @import("gdnative_types.zig");
const api = @import("api.zig");

const typeId = @import("typeid.zig").typeId;

pub const Wrapped = struct {
    owner: ?*gd.godot_object,
    type_tag: usize,
};


// Functions start with _underscore to avoid conflicting with other godot class body functions to allow usingnamespace to make calling them less verbose
pub fn GenGodotClass(comptime class: type, comptime instanciable: bool, comptime singleton: bool) type {
    return struct {

        pub inline fn _isClassScript() bool {
            return false;
        }

        pub inline fn _getClassName() [*:0]const u8 {
            return @typeName(class);
        }

        pub inline fn _getGodotClassName() [*:0]const u8 {
            return @typeName(class);
        }

        pub inline fn _getClassId() usize {
            return typeId(class);
        }

        pub inline fn _memnew() *class {
            comptime if (!instanciable) {
                @compileError("This class isn't instanciable");
            };

            const class_constructor = api.core.godot_get_class_constructor.?(@typeName(class));
            const class_instance = class_constructor.?();
            const instance_data = api.nativescript_1_1.godot_nativescript_get_instance_binding_data.?(api.language_index, class_instance);
            return @ptrCast(*class, @alignCast(@alignOf(class), instance_data));
        }

        pub inline fn _getClassSingleton() *class {
            comptime if (!singleton) {
                @compileError("This class isn't a singleton");
            };

            const class_instance = api.core.godot_global_get_singleton.?(@intToPtr(*u8, @ptrToInt(@typeName(class))));
            const instance_data = api.nativescript_1_1.godot_nativescript_get_instance_binding_data.?(api.language_index, class_instance);
            return @ptrCast(*class, @alignCast(@alignOf(class), instance_data));
        }

    };
}
