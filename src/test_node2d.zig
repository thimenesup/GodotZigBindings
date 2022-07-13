const gd = @import("core/api.zig");
const c = gd.c;

const ClassDB = @import("core/class_db.zig");
const Godot = @import("core/godot_global.zig").Godot;
const String = @import("core/string.zig").String;

const std = @import("std");

pub const TestNode2D = struct {

    data: i64,

    const Node2D = struct {};
    pub const GodotClass = ClassDB.defineGodotClass(TestNode2D, Node2D);

    const Self = @This();

    pub fn constructor(p_instance: ?*c.godot_object, p_method_data: ?*anyopaque) callconv(.C) ?*anyopaque {
        _ = p_instance;
        _ = p_method_data;

        var user_data = gd.api.*.godot_alloc.?(@sizeOf(@This()));

        var self = @ptrCast(*Self, @alignCast(@alignOf(*Self), user_data));
        self.data = 0;

        return user_data;
    }

    pub fn destructor(p_instance: ?*c.godot_object, p_method_data: ?*anyopaque, p_user_data: ?*anyopaque) callconv(.C) void {
        _ = p_instance;
        _ = p_method_data;

        gd.api.*.godot_free.?(p_user_data);
    }

    pub fn registerMembers(handle: ?*anyopaque) void {
        ClassDB.registerMethod(handle, Self, "_process", _process, c.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassDB.registerMethod(handle, Self, "test_method", test_method, c.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassDB.registerMethod(handle, Self, "test_return", test_return, c.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassDB.registerFunction(handle, Self, "test_static_function", test_static_function, c.GODOT_METHOD_RPC_MODE_DISABLED);
    }

    pub fn _process(self: *const Self, delta: f64) void {
        _ = self;
        _ = delta;
    }

    pub fn test_method(self: *const Self, a: i64, b: bool) void {
        _ = self;
        std.debug.print("test_method a:{} b:{}\n", .{a, b});
    }

    pub fn test_return(self: *Self, a: i64) i64 {
        self.data += a;
        return self.data;
    }

    pub fn test_static_function(a: i64) void {
        std.debug.print("static_function:{}\n", .{a});
    }

};
