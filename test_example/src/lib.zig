const gdextension = @import("gdextension");
const gi = gdextension.gdextension_interface;
const godot = gdextension.godot;

const ClassDB = gdextension.class_db.ClassDB;

const TestNode2D = @import("test_node2d.zig").TestNode2D;

fn gdextension_initialize(p_level: gi.GDExtensionInitializationLevel) callconv(.C) void {
    if (p_level == gi.GDExtensionInitializationLevel.GDEXTENSION_INITIALIZATION_SCENE) {
        ClassDB.registerClass(TestNode2D, false, false);
    }
}

fn gdextension_terminate(p_level: gi.GDExtensionInitializationLevel) callconv(.C) void {
    _ = p_level;
}

pub export fn gdextension_entry_point(p_interface: *const gi.GDExtensionInterface, p_library: gi.GDExtensionClassLibraryPtr, r_initialization: *gi.GDExtensionInitialization) callconv(.C) gi.GDExtensionBool {
    godot.register_initializer(gdextension_initialize);
    godot.register_terminator(gdextension_terminate);
    godot.set_minimum_library_initialization_level(gi.GDExtensionInitializationLevel.GDEXTENSION_INITIALIZATION_SERVERS);
    return godot.init(p_interface, p_library, r_initialization);
}
