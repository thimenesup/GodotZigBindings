const gdnative = @import("gdnative");

const api = gdnative.api;
const gd = gdnative.gdnative_types;

const ClassRegistry = gdnative.class_registry;
const Godot = gdnative.godot_global.Godot;

const Node = gdnative.classes.node.Node;
const Node2D = gdnative.classes.node2d.Node2D;

const String = gdnative.string.String;
const Array = gdnative.array.Array;
const Variant = gdnative.variant.Variant;

const std = @import("std");

pub const TestNode2D = struct {

    base: Node2D, // The inherited class
    data: i64,
    test_property: f32,
    setget_property: u16,

    // This must be defined for every custom class you make, yes, the name has to always be "GodotClass"
    pub const GodotClass = ClassRegistry.DefineGodotClass(TestNode2D, Node2D); // Must call this with your class type and the inherited one
    pub usingnamespace GodotClass; // This is recommended too

    const Self = @This();

    pub fn constructor(self: *Self) void { // This must be defined
        self.data = 0;
        self.test_property = 0;
        self.setget_property = 0;
    }

    pub fn destructor(self: *Self) void { // This must be defined
        _ = self;
    }

    pub fn registerMembers() void { // This must be defined, you register your custom class methods, functions, properties, and signals here
        ClassRegistry.registerMethod(Self, "_process", _process, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassRegistry.registerMethod(Self, "test_method", test_method, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassRegistry.registerMethod(Self, "test_return", test_return, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassRegistry.registerMethod(Self, "test_return_string", test_return_string, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassRegistry.registerMethod(Self, "test_return_array", test_return_array, gd.GODOT_METHOD_RPC_MODE_DISABLED);
        ClassRegistry.registerMethod(Self, "test_memnew_and_cast", test_memnew_and_cast, gd.GODOT_METHOD_RPC_MODE_DISABLED);

        ClassRegistry.registerFunction(Self, "test_static_function", test_static_function, gd.GODOT_METHOD_RPC_MODE_DISABLED);

        ClassRegistry.registerProperty(Self, "test_property", "test_property", @as(f32, 0), null, null,
            gd.GODOT_METHOD_RPC_MODE_DISABLED, gd.GODOT_PROPERTY_USAGE_DEFAULT, gd.GODOT_PROPERTY_HINT_NONE, ""
        );
        ClassRegistry.registerProperty(Self, "setget_property", "setget_property", @as(u16, 0), set_setget_property, get_setget_property,
            gd.GODOT_METHOD_RPC_MODE_DISABLED, gd.GODOT_PROPERTY_USAGE_DEFAULT, gd.GODOT_PROPERTY_HINT_NONE, ""
        );

        ClassRegistry.registerSignal(Self, "test_signal", .{ .{"arg0", i32}, .{"arg1", f32}, });
    }

    pub fn _process(self: *Self, delta: f64) void {
        self.base.rotate(delta);
    }

    pub fn test_method(self: *const Self, a: i32, b: bool) void {
        _ = self;
        std.debug.print("test_method a:{} b:{}\n", .{a, b});
    }

    pub fn test_return(self: *Self, a: i64) i64 {
        self.data += a;
        return self.data;
    }

    pub fn test_return_string(self: *const Self) String {
        _ = self;
        return String.initUtf8("String returned from zig");
    }

    pub fn test_return_array(self: *const Self) Array {
        _ = self;

        var array = Array.init();
        array.pushBackVars(.{ true, 1337, 420.69, @as([*:0]const u8, "My Variant String") });

        return array;
    }

    pub fn test_static_function(a: i64) void {
        std.debug.print("static_function:{}\n", .{a});
    }

    pub fn set_setget_property(self: *Self, value: u16) void {
        self.setget_property += value * 2;
    }

    pub fn get_setget_property(self: *const Self) u16 {
        return self.setget_property + 1;
    }

    pub fn test_memnew_and_cast(self: *const Self) void {
        {
            const node = TestNode2D._memnew();
            defer node.base.base.base.queueFree();
            const cast = ClassRegistry.castTo(Node2D, node);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)});
        }

        {
            const node = Node._memnew();
            defer node.queueFree();
            const cast = ClassRegistry.castTo(Node2D, node);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)}); //Null
        }

        {
            const child_node = self.base.base.base.getChild(0);
            const cast = ClassRegistry.castTo(Node2D, child_node);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)});
        }

        {
            const child_node = self.base.base.base.getChild(0);
            const cast = ClassRegistry.castTo(TestNode2D, child_node);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)});
        }
    }

};
