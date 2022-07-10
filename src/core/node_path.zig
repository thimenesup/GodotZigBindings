const gd = @import("api.zig");
const c = gd.c;

const String = @import("string.zig").String;

pub const NodePath = struct {

    godot_node_path: c.godot_node_path,

    const Self = @This();

    pub fn deinit(self: *Self) void {
        gd.api.*.godot_node_path_destroy.?(&self.godot_node_path);
    }

    pub fn init() Self {
        const string = String.init();
        defer string.deinit();

        var self = Self {
            .godot_node_path = undefined,
        };

        gd.api.*.godot_node_path_new.?(&self.godot_node_path, &string.godot_string);
        return self;
    }

    pub fn initGodotNodePath(p_godot_node_path: c.godot_node_path) Self {
        const self = String {
            .godot_node_path = p_godot_node_path,
        };

        return self;
    }

    pub fn initCopy(other: *const NodePath) Self {
        var self = Self {
            .godot_node_path = undefined,
        };

        const string = String.initNodePath(other);
        defer string.deinit();
        gd.api.*.godot_node_path_destroy.?(&self.godot_node_path, &string.godot_string);

        return self;
    }

    pub fn initString(string: *const String) Self {
        var self = Self {
            .godot_node_path = undefined,
        };

        gd.api.*.godot_node_path_new.?(&self.godot_node_path, &string.godot_string);
        return self;
    }

    pub fn initChars(chars: [*]const u8) Self {
        const string = String.initUtf8(chars);
        defer string.deinit();

        var self = Self {
            .godot_node_path = undefined,
        };

        gd.api.*.godot_node_path_new.?(&self.godot_node_path, &string.godot_string);
        return self;
    }

    pub fn getName(self: *const Self, index: i32) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_node_path_get_name.?(&self.godot_node_path, index);
        return String.initGodotString(godot_string);
    }

    pub fn getNameCount(self: *const Self) i32 {
        return gd.api.*.godot_node_path_get_name_count.?(&self.godot_node_path);
    }

    pub fn getSubname(self: *const Self, index: i32) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_node_path_get_subname.?(&self.godot_node_path, index);
        return String.initGodotString(godot_string);
    }

    pub fn getSubnameCount(self: *const Self) i32 {
        return gd.api.*.godot_node_path_get_subname_count.?(&self.godot_node_path);
    }

    pub fn isAbsolute(self: *const Self) bool {
        return gd.api.*.godot_node_path_is_absolute.?(&self.godot_node_path);
    }

    pub fn isEmpty(self: *const Self) bool {
        return gd.api.*.godot_node_path_is_empty.?(&self.godot_node_path);
    }

    pub fn getAsPropertyPath(self: *const Self) NodePath { // Make sure you call .deinit() on returned struct
        const godot_node_path = gd.api_1_1.*.godot_node_path_get_as_property_path.?(&self.godot_node_path);
        return NodePath.initGodotNodePath(godot_node_path);
    }

    pub fn getConcatenatedSubnames(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_node_path_get_concatenated_subnames.?(&self.godot_node_path);
        return String.initGodotString(godot_string);
    }

    pub fn asString(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_node_path_as_string.?(&self.godot_node_path);
        return String.initGodotString(godot_string);
    }

    pub fn equal(self: *const Self, other: *const NodePath) bool { // Operator ==
        return gd.api.*.godot_node_path_operator_equal.?(&self.godot_node_path, &other.godot_node_path);
    }

    pub fn notEqual(self: *const Self, other: *const NodePath) bool { // Operator !=
        return !equal(self, other);
    }

    pub fn assign(self: *Self, other: *const NodePath) void { // Operator =
        gd.api.*.godot_node_path_destroy.?(&self.godot_node_path);
        const string = String.initNodePath(other);
        defer string.deinit();
        gd.api.*.godot_node_path_destroy.?(&self.godot_node_path, &string.godot_string);
    }

};
