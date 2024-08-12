const gdextension = @import("gdextension");
const ClassDB = gdextension.class_db.ClassDB;
const Wrapped = gdextension.wrapped.Wrapped;
const GDClass = gdextension.wrapped.GDClass;

const Node2D = gdextension.classes.node2d.Node2D;

const std = @import("std");

pub const TestNode2D = struct {

    base: Node2D, // The inherited class must be defined
    data: i64,

    pub const GodotClass = GDClass(TestNode2D, Node2D); // This must be defined with the type class and inherited one, the name has to always be "GodotClass"
    pub usingnamespace GodotClass; // This is a must too

    const Self = @This();

    pub fn init() Self { // This must be defined
        var self = std.mem.zeroes(Self);
        self.data = 42;
        return self;
    }

    pub fn deinit(self: *Self) void { // This must be defined
        _ = self;
    }

    pub fn _bindMembers() callconv(.C) void { // This must be defined, you register your custom class methods, functions, properties, and signals here
        ClassDB.bindMethod(Self, testMethod, "testMethod", .{ "a", "b" });
        ClassDB.bindStaticMethod(Self, testStaticMethod, "testStaticMethod", .{ "a", "b" });
    }

    pub fn testMethod(self: *const Self, a: i32, b: bool) void {
        std.debug.print("testMethod a:{} b:{}\n", .{a + self.data, b});
    }

    pub fn testStaticMethod(a: i32, b: bool) void {
        std.debug.print("testStaticMethod a:{} b:{}\n", .{a, b});
    }

};
