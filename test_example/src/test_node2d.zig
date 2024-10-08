const gdextension = @import("gdextension");
const ClassDB = gdextension.class_db.ClassDB;
const Wrapped = gdextension.wrapped.Wrapped;
const GDClass = gdextension.wrapped.GDClass;

const Variant = gdextension.core_types.Variant;
const String = gdextension.core_types.String;
const StringName = gdextension.core_types.StringName;
const Object = gdextension.classes.Object;
const Texture2D = gdextension.classes.Texture2D;

const UtilityFunctions = gdextension.classes.UtilityFunctions;
const Node = gdextension.classes.Node;
const Node2D = gdextension.classes.Node2D;

const std = @import("std");

pub const TestNode2D = struct {

    base: Node2D, // The inherited class must be defined
    data: i64,
    test_property: f32,
    setget_property: u16,
    object_property: ?*Texture2D,

    pub const GodotClass = GDClass(TestNode2D, Node2D); // This must be defined with the type class and inherited one, the name has to always be "GodotClass"
    pub usingnamespace GodotClass; // This is a must too

    const Self = @This();

    pub fn init() Self { // This must be defined
        var self = std.mem.zeroes(Self);
        self.data = 42;
        self.test_property = 1.23;
        self.setget_property = 1;
        self.object_property = null;
        return self;
    }

    pub fn deinit(self: *Self) void { // This must be defined
        _ = self;
    }

    pub fn _bindMembers() callconv(.C) void { // This must be defined, you register your custom class methods, functions, properties, and signals here
        ClassDB.bindMethod(Self, testMethod, "test_method", .{ "a", "b", "c" });
        ClassDB.bindStaticMethod(Self, testStaticMethod, "test_static_method", .{ "a", "b" });
        ClassDB.bindProperty(Self, "test_property", "test_property", null, null);
        ClassDB.bindProperty(Self, "setget_property", "setget_property", setSetgetProperty, getSetgetProperty);
        ClassDB.bindProperty(Self, "object_property", "object_property", null, null);
        ClassDB.bindSignal(Self, "test_signal", .{ i32, f32, ?*Node2D }, .{ "a", "b", "c" });
        ClassDB.bindMethod(Self, testMemnewCast, "test_memnew_cast", .{});
        ClassDB.bindMethod(Self, testVararg, "test_vararg", .{});
    }

    pub fn _notification(self: *Self, what: i32) void { // Virtual methods are automatically binded if defined/overriden
        _ = self;
        if (what == gdextension.classes.Node.notification_parented) {
            std.debug.print("parented\n", .{});
        }
    }

    pub fn _ready(self: *Self) void {
        _ = self;

        var string = String.initUtf8("_ready");
        defer string.deinit();
        var string_var = Variant.initString(&string);
        defer string_var.deinit();
        UtilityFunctions.print(&string_var, .{});
    }

    pub fn _process(self: *Self, delta: f64) void {
        self.as(Node2D).rotate(delta);
    }

    pub fn testMethod(self: *const Self, a: i32, b: bool, c: ?*Object) f32 {
        std.debug.print("testMethod a:{} b:{} c.instance_id:{}\n", .{a + self.data, b, c.?.getInstanceId()});
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

    pub fn testMemnewCast(self: *const Self) void {
        const Node3D = gdextension.classes.Node3D;
        {
            const cast = ClassDB.castTo(self, Node2D);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)});
        }
        {
            const cast = ClassDB.castTo(self, Node3D);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)}); //Null
        }
        {
            const node = TestNode2D._memnew();
            defer node.as(Node).queueFree();
            const cast = ClassDB.castTo(node, Node2D);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)});
        }
        {
            const node = Node3D._memnew();
            defer node.as(Node).queueFree();
            const cast = ClassDB.castTo(node, Node2D);
            std.debug.print("Cast:{}\n", .{@intFromPtr(cast)}); //Null
        }
    }

    pub fn testVararg(self: *Self) void {
        var signal_name = StringName.initUtf8("test_signal");
        defer signal_name.deinit();
        _ = self.as(Object).emitSignal(&signal_name, .{ 123, 3.2, self });
    }

};
