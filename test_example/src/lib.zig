const gdnative = @import("gdnative");

const api = gdnative.api;
const gd = gdnative.gdnative_types;
const ClassRegistry = gdnative.class_registry;

// Import your custom classes
const TestNode2D = @import("test_node2d.zig").TestNode2D;

export fn godot_gdnative_init(p_options: [*c]gd.godot_gdnative_init_options) callconv(.C) void {
    api.gdnativeInit(p_options);
}

export fn godot_gdnative_terminate(p_options: [*c]gd.godot_gdnative_terminate_options) callconv(.C) void {
    api.gdnativeTerminate(p_options);
}

export fn godot_nativescript_init(p_handle: ?*anyopaque) callconv(.C) void {
    api.nativescriptInit(p_handle);

    // Register your custom classes
    ClassRegistry.registerClass(TestNode2D);
}

export fn godot_nativescript_terminate(p_handle: ?*anyopaque) callconv(.C) void {
    api.nativescriptTerminate(p_handle);
}
