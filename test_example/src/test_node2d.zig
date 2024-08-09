const gdextension = @import("gdextension");
const ClassDB = gdextension.class_db.ClassDB;
const Wrapped = gdextension.wrapped.Wrapped;
const GDClass = gdextension.wrapped.GDClass;

const Node2D = gdextension.classes.node2d.Node2D;

const std = @import("std");

pub const TestNode2D = struct {

    base: Node2D, // The inherited class
    data: i64,
    test_property: f32,
    setget_property: u16,

    // This must be defined for every custom class you make, yes, the name has to always be "GodotClass"
    pub const GodotClass = GDClass(TestNode2D, Node2D); // Must call this with your class type and the inherited one
    pub usingnamespace GodotClass; // This is a must too

    const Self = @This();

    pub fn deinit(self: *Self) void { // This must be defined
        _ = self;
    }

    pub fn _bindMethods() callconv(.C) void { // This must be defined, you register your custom class methods, functions, properties, and signals here

    }

};
