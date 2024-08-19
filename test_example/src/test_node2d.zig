const gdextension = @import("gdextension");
const ClassDB = gdextension.class_db.ClassDB;
const Wrapped = gdextension.wrapped.Wrapped;
const GDClass = gdextension.wrapped.GDClass;

const Node2D = gdextension.classes.node2d.Node2D;

const std = @import("std");

pub const TestNode2D = struct {

    base: Node2D, // The inherited class must be defined
    data: i64,
    test_property: f32,
    setget_property: u16,

    pub const GodotClass = GDClass(TestNode2D, Node2D); // This must be defined with the type class and inherited one, the name has to always be "GodotClass"
    pub usingnamespace GodotClass; // This is a must too

    const Self = @This();

    pub fn init() Self { // This must be defined
        var self = std.mem.zeroes(Self);
        self.data = 42;
        self.test_property = 1.23;
        self.setget_property = 1;
        return self;
    }

    pub fn deinit(self: *Self) void { // This must be defined
        _ = self;
    }

    pub fn _bindMembers() callconv(.C) void { // This must be defined, you register your custom class methods, functions, properties, and signals here
        ClassDB.bindMethod(Self, testMethod, "test_method", .{ "a", "b" });
        ClassDB.bindStaticMethod(Self, testStaticMethod, "test_static_method", .{ "a", "b" });
        ClassDB.bindProperty(Self, "test_property", "test_property", null, null);
        ClassDB.bindProperty(Self, "setget_property", "setget_property", setSetgetProperty, getSetgetProperty);
        ClassDB.bindSignal(Self, "test_signal", .{ i32, f32 }, .{ "a", "b" });
        ClassDB.bindVirtualMethod(Self, _ready, "_ready", .{});
        ClassDB.bindVirtualMethod(Self, _process, "_process", .{ "delta" });
    }

    pub fn _ready(self: *Self) void {
        _ = self;
        std.debug.print("_ready\n", .{});
    }

    pub fn _process(self: *Self, delta: f64) void {
        self.base.rotate(delta);
    }

    pub fn testMethod(self: *const Self, a: i32, b: bool) f32 {
        std.debug.print("testMethod a:{} b:{}\n", .{a + self.data, b});
        return -42.24;
    }

    pub fn testStaticMethod(a: i32, b: bool) void {
        std.debug.print("testStaticMethod a:{} b:{}\n", .{a, b});
    }

    pub fn setSetgetProperty(self: *Self, value: u16) void {
        self.setget_property = value * 2;
    }

    pub fn getSetgetProperty(self: *const Self) u16 {
        return self.setget_property + 1;
    }

};
