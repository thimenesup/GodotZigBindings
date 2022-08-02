const api = @import("core/api.zig");
const gd = @import("core/gdnative_types.zig");

const Classes = @import("core/classes.zig");
const TestNode2D = @import("test_node2d.zig").TestNode2D;

export fn godot_gdnative_init(p_options: [*c]gd.godot_gdnative_init_options) callconv(.C) void {
    api.gdnativeInit(p_options);
}

export fn godot_gdnative_terminate(p_options: [*c]gd.godot_gdnative_terminate_options) callconv(.C) void {
    api.gdnativeTerminate(p_options);
}

export fn godot_nativescript_init(p_handle: ?*anyopaque) callconv(.C) void {
    api.nativescriptInit(p_handle);

    // Register custom classes
    Classes.registerClass(TestNode2D);
}

export fn godot_nativescript_terminate(p_handle: ?*anyopaque) callconv(.C) void {
    api.nativescriptTerminate(p_handle);
}
