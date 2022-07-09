const gdapi = @import("core/api.zig");
const c = gdapi.c;

const TestNode2D = @import("test_node2d.zig").TestNode2D;

export fn godot_gdnative_init(p_options: [*c]c.godot_gdnative_init_options) callconv(.C) void {
    gdapi.gdnative_init(p_options);
}

export fn godot_gdnative_terminate(p_options: [*c]c.godot_gdnative_terminate_options) callconv(.C) void {
    gdapi.gdnative_terminate(p_options);
}

export fn godot_nativescript_init(p_handle: ?*anyopaque) callconv(.C) void {
    // Register classes
    TestNode2D.registerClass(gdapi.nativescript_api, p_handle);
}
