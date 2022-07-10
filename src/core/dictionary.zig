const gd = @import("api.zig");
const c = gd.c;

const Variant = @import("variant.zig").Variant;
const Array = @import("array.zig").Array;
const String = @import("string.zig").String;

pub const Dictonary = struct {

    godot_dictionary: c.godot_dictionary,

    const Self = @This();

    pub fn deinit(self: *Self) void {
        gd.api.*.godot_dictonary_destroy.?(&self.godot_dictionary);
    }

    pub fn init() Self {
        var self = Self {
            .godot_dictionary = undefined,
        };

        gd.api.*.godot_dictionary_new.?(&self.godot_dictionary);

        return self;
    }

    pub fn assign(self: *Self, other: *const Dictonary) void {
        gd.api.*.godot_dictionary_destroy.?(&self.godot_dictionary);
        gd.api.*.godot_dictionary_new_copy.?(&self.godot_dictionary, other.godot_dictionary);
    }

    pub fn clear(self: *Self) void {
        gd.api.*.godot_dictionary_clear.?(&self.godot_dictionary);
    }

    pub fn empty(self: *const Self) bool {
        return gd.api.*.godot_dictionary_empty.?(&self.godot_dictionary);
    }

    pub fn has(self: *const Self, key: *const Variant) bool {
        return gd.api.*.godot_dictionary_has.?(&self.godot_dictionary, &key.godot_variant);
    }

    pub fn has_all(self: *const Self, p_keys: *const Array) bool {
        return gd.api.*.godot_dictionary_has_all.?(&self.godot_dictionary, &p_keys.godot_array);
    }

    pub fn hash(self: *const Self) u32 {
        return gd.api.*.godot_dictionary_hash.?(&self.godot_dictionary);
    }
    
    pub fn keys(self: *const Self) Array { // Make sure you call .deinit() on returned struct
        const godot_array = gd.api.*.godot_dictionary_keys.?(&self.godot_dictionary);
        return Array.initGodotArray(godot_array);
    }

    pub fn set(self: *Self, key: *const Variant, value: *const Variant) void { // Operator d[k] = v
        const godot_variant = gd.api.*.godot_dictionary_operator_index.?(&self.godot_dictionary, &key.godot_variant);
        godot_variant.* = value.godot_variant;
    }

    pub fn get(self: *const Self, key: *const Variant) Variant { // Operator v = d[k] // Make sure you call .deinit() on returned struct
        const godot_variant = gd.api.*.godot_dictionary_operator_index.?(&self.godot_dictionary, &key.godot_variant);
        return Variant.initGodotVariant(godot_variant.*);
    }

    pub fn size(self: *const Self) i32 {
        return gd.api.*.godot_dictionary_size.?(&self.godot_dictionary);
    }

    pub fn toJson(self: *const Self) String { // Make sure you call .deinit() on returned struct
        const godot_string = gd.api.*.godot_dictionary_to_json.?(&self.godot_dictionary);
        return String.initGodotString(godot_string);
    }

    pub fn values(self: *const Self) Array { // Make sure you call .deinit() on returned struct
        const godot_array = gd.api.*.godot_dictionary_values.?(&self.godot_dictionary);
        return Array.initGodotArray(godot_array);
    }

};
