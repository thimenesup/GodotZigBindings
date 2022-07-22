const gdapi = @import("core/api.zig");
const c = gdapi.c;

const Classes = @import("core/classes.zig");
const TestNode2D = @import("test_node2d.zig").TestNode2D;

export fn godot_gdnative_init(p_options: [*c]c.godot_gdnative_init_options) callconv(.C) void {
    gdapi.gdnativeInit(p_options);
}

export fn godot_gdnative_terminate(p_options: [*c]c.godot_gdnative_terminate_options) callconv(.C) void {
    gdapi.gdnativeTerminate(p_options);
}

export fn godot_nativescript_init(p_handle: ?*anyopaque) callconv(.C) void {
    gdapi.nativescriptInit(p_handle);

    // Register custom classes
    Classes.registerClass(TestNode2D);
}

export fn godot_nativescript_terminate(p_handle: ?*anyopaque) callconv(.C) void {
    gdapi.nativescriptTerminate(p_handle);
}
