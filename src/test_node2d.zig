const gd = @import("core/api.zig");
const c = gd.c;

const Classes = @import("core/classes.zig");
const Godot = @import("core/godot_global.zig").Godot;

const Node = @import("gen/node.zig").Node;
const Node2D = @import("gen/node2d.zig").Node2D;

const String = @import("core/string.zig").String;
const Array = @import("core/array.zig").Array;
const Variant = @import("core/variant.zig").Variant;

const std = @import("std");

pub const TestNode2D = struct {

    base: Node2D,
    data: i64,
    test_property: f32,
    setget_property: u16,

    pub const GodotClass = Classes.DefineGodotClass(TestNode2D, Node2D);
    pub usingnamespace GodotClass;

    const Self = @This();

    pub fn constructor(self: *Self) void {
        self.data = 0;
        self.test_property = 0;
        self.setget_property = 0;
    }

    pub fn destructor(self: *Self) void {
        _ = self;
    }

    pub fn registerMembers() void {
        Classes.registerMethod(Self, "_process", _process, c.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_method", test_method, c.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_return", test_return, c.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_return_string", test_return_string, c.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_return_array", test_return_array, c.GODOT_METHOD_RPC_MODE_DISABLED);
        Classes.registerMethod(Self, "test_memnew_and_cast", test_memnew_and_cast, c.GODOT_METHOD_RPC_MODE_DISABLED);

        Classes.registerFunction(Self, "test_static_function", test_static_function, c.GODOT_METHOD_RPC_MODE_DISABLED);

        Classes.registerProperty(Self, "test_property", "test_property", @as(f32, 0), null, null,
            c.GODOT_METHOD_RPC_MODE_DISABLED, c.GODOT_PROPERTY_USAGE_DEFAULT, c.GODOT_PROPERTY_HINT_NONE, ""
        );
        Classes.registerProperty(Self, "setget_property", "setget_property", @as(u16, 0), set_setget_property, get_setget_property,
            c.GODOT_METHOD_RPC_MODE_DISABLED, c.GODOT_PROPERTY_USAGE_DEFAULT, c.GODOT_PROPERTY_HINT_NONE, ""
        );

        Classes.registerSignal(Self, "test_signal", .{ .{"arg0", i32}, .{"arg1", f32}, });
    }

    pub fn _process(self: *Self, delta: f64) void {
        _ = self;

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

        var v0 = Variant.initBool(true);
        defer v0.deinit();
        array.pushBack(&v0);

        var v1 = Variant.initInt(1337);
        defer v1.deinit();
        array.pushBack(&v1);

        var v2 = Variant.initReal(420.69);
        defer v2.deinit();
        array.pushBack(&v2);

        var v3 = Variant.initCString("My Variant String");
        defer v3.deinit();
        array.pushBack(&v3);

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
            const cast = Classes.castTo(Node2D, node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)});
        }

        {
            const node = Node._memnew();
            defer node.queueFree();
            const cast = Classes.castTo(Node2D, node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)}); //Null
        }

        {
            const child_node = self.base.base.base.getChild(0);
            const cast = Classes.castTo(Node2D, child_node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)});
        }

        {
            const child_node = self.base.base.base.getChild(0);
            const cast = Classes.castTo(TestNode2D, child_node);
            std.debug.print("Cast:{}\n", .{@ptrToInt(cast)});
        }
    }

};
