const gd = @import("api.zig");
const c = gd.c;

const AABB = @import("aabb.zig").AABB;
const Basis = @import("basis.zig").Basis;
const Plane = @import("plane.zig").Plane;
const Quat = @import("quat.zig").Quat;
const Rect2 = @import("rect2.zig").Rect2;
const Transform = @import("transform.zig").Transform;
const Transform2D = @import("transform2d.zig").Transform2D;
const Vector2 = @import("vector2.zig").Vector2;
const Vector3 = @import("vector3.zig").Vector3;
const Color = @import("color.zig").Color;
const NodePath = @import("node_path.zig").NodePath;
const RID = @import("rid.zig").RID;
const Dictionary = @import("dictionary.zig").Dictionary;
const Array = @import("array.zig").Array;
const String = @import("string.zig").String;
const PoolArrays = @import("pool_arrays.zig");
const PoolByteArray = PoolArrays.PoolByteArray;
const PoolIntArray = PoolArrays.PoolIntArray;
const PoolRealArray = PoolArrays.PoolRealArray;
const PoolStringArray = PoolArrays.PoolStringArray;
const PoolVector2Array = PoolArrays.PoolVector2Array;
const PoolVector3Array = PoolArrays.PoolVector3Array;
const PoolColorArray = PoolArrays.PoolColorArray;

pub const Variant = struct {

    godot_variant: c.godot_variant,

    const Self = @This();

    const Type = enum {
        nil,
        int,
        bool,
        real,
        string,

        vector2,
        rect2,
        vector3,
        transform2d,
        plane,
        quat,
        aabb,
        basis,
        transform,

        color,
        node_path,
        rid,
        object,
        dictionary,
        array,

        pool_byte_array,
        pool_int_array,
        pool_real_array,
        pool_string_array,
        pool_vector2_array,
        pool_vector3_array,
        pool_color_array,

        variant_max,
    };

    pub fn deinit(self: *Self) void {
        gd.api.*.godot_variant_destroy.?(&self.godot_variant);
    }

    pub fn init() Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_nil.?(&self.godot_variant);

        return self;
    }

    pub fn initGodotVariant(godot_variant: c.godot_variant) Self {
        const self = Self {
            .godot_variant = godot_variant,
        };

        return self;
    }

    pub fn initCopy(other: *const Variant) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_copy.?(&self.godot_variant, &other.godot_variant);

        return self;
    }

    pub fn initBool(p_bool: bool) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_bool.?(&self.godot_variant, p_bool);

        return self;
    }

    pub fn initInt(p_int: i64) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_int.?(&self.godot_variant, p_int);

        return self;
    }

    pub fn initUint(p_uint: u64) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_uint.?(&self.godot_variant, p_uint);

        return self;
    }

    pub fn initReal(p_float: f64) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_real.?(&self.godot_variant, p_float);

        return self;
    }

    pub fn initString(p_string: *const String) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_string.?(&self.godot_variant, &p_string.godot_string);

        return self;
    }

    pub fn initCstring(chars: [*:0]const u8) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        var string = String.init_utf8(chars);
        gd.api.*.godot_variant_new_string.?(&self.godot_variant, &string.godot_string);

        return self;
    }

    pub fn initVector2(p_vector2: *const Vector2) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_vector2.?(&self.godot_variant, &p_vector2.godot_vector2);

        return self;
    }

    pub fn initRect2(p_rect2: *const Rect2) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_rect2.?(&self.godot_variant, &p_rect2.godot_rect2);

        return self;
    }

    pub fn initVector3(p_vector3: *const Vector3) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_vector3.?(&self.godot_variant, &p_vector3.godot_vector3);

        return self;
    }

    pub fn initPlane(p_plane: *const Plane) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_plane.?(&self.godot_variant, &p_plane.godot_plane);

        return self;
    }

    pub fn initAABB(p_aabb: *const AABB) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_aabb.?(&self.godot_variant, &p_aabb.godot_aabb);

        return self;
    }

    pub fn initQuat(p_quat: *const Quat) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_quat.?(&self.godot_variant, &p_quat.godot_quat);

        return self;
    }

    pub fn initBasis(p_basis: *const Basis) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_basis.?(&self.godot_variant, &p_basis.godot_basis);

        return self;
    }

    pub fn initTransform2D(p_transform2d: *const Transform2D) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_transform2d.?(&self.godot_variant, &p_transform2d.godot_transform2d);

        return self;
    }

    pub fn initTransform(p_transform: *const Transform) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_transform.?(&self.godot_variant, &p_transform.godot_transform);

        return self;
    }

    pub fn initColor(p_color: *const Color) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_color.?(&self.godot_variant, &p_color.godot_color);

        return self;
    }

    pub fn initNodePath(p_node_path: *const NodePath) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_node_path.?(&self.godot_variant, &p_node_path.godot_node_path);

        return self;
    }

    pub fn initRID(p_rid: *const RID) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_rid.?(&self.godot_variant, &p_rid.godot_rid);

        return self;
    }

    // pub fn initObject(p_object: *const Object) Self {
    //     var self = Self {
    //         .godot_variant = undefined,
    //     };

    //     gd.api.*.godot_variant_new_object.?(&self.godot_variant, p_object.owner);

    //     return self;
    // }

    pub fn initDictionary(p_dictionary: *const Dictionary) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_dictionary.?(&self.godot_variant, &p_dictionary.godot_dictionary);

        return self;
    }

    pub fn initArray(p_array: *const Array) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_array.?(&self.godot_variant, &p_array.godot_array);

        return self;
    }

    pub fn initPoolByteArray(p_pool_byte_array: *const PoolByteArray) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_pool_byte_array.?(&self.godot_variant, &p_pool_byte_array.godot_pool_byte_array);

        return self;
    }

    pub fn initPoolIntArray(p_pool_int_array: *const PoolIntArray) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_pool_int_array.?(&self.godot_variant, &p_pool_int_array.godot_pool_int_array);

        return self;
    }

    pub fn initPoolReayArray(p_pool_real_array: *const PoolRealArray) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_pool_real_array.?(&self.godot_variant, &p_pool_real_array.godot_pool_real_array);

        return self;
    }

    pub fn initPoolStringArray(p_pool_string_array: *const PoolStringArray) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_pool_string_array.?(&self.godot_variant, &p_pool_string_array.godot_pool_string_array);

        return self;
    }

    pub fn initPoolVector2Array(p_pool_vector2_array: *const PoolVector2Array) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_pool_vector2_array.?(&self.godot_variant, &p_pool_vector2_array.godot_pool_vector2_array);

        return self;
    }

    pub fn initPoolVector3Array(p_godot_pool_vector3_array: *const PoolVector3Array) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_pool_vector3_array.?(&self.godot_variant, &p_godot_pool_vector3_array.godot_pool_vector3_array);

        return self;
    }

    pub fn initPoolColorArray(p_godot_pool_color_array: *const PoolColorArray) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        gd.api.*.godot_variant_new_pool_color_array.?(&self.godot_variant, &p_godot_pool_color_array.godot_pool_color_array);

        return self;
    }

    pub fn asBool(self: *const Self) bool {
        return gd.api.*.godot_variant_booleanize.?(&self.godot_variant);
    }

    pub fn asInt(self: *const Self) i64 {
        return gd.api.*.godot_variant_as_int.?(&self.godot_variant);
    }

    pub fn asUint(self: *const Self) u64 {
        return gd.api.*.godot_variant_as_uint.?(&self.godot_variant);
    }

    pub fn asReal(self: *const Self) f64 {
        return gd.api.*.godot_variant_as_real.?(&self.godot_variant);
    }

    pub fn asString(self: *const Self) String {
        const godot_value = gd.api.*.godot_variant_as_string.?(&self.godot_variant);
        return String.initGodotString(godot_value);
    }

    pub fn asVector2(self: *const Self) Vector2 {
        const godot_value = gd.api.*.godot_variant_as_vector2.?(&self.godot_variant);
        return @ptrCast(*Vector2, &godot_value).*;
    }

    pub fn asRect2(self: *const Self) Rect2 {
        const godot_value = gd.api.*.godot_variant_as_rect2.?(&self.godot_variant);
        return @ptrCast(*Rect2, &godot_value).*;
    }

    pub fn asVector3(self: *const Self) Vector3 {
        const godot_value = gd.api.*.godot_variant_as_vector3.?(&self.godot_variant);
        return @ptrCast(*Vector3, &godot_value).*;
    }

    pub fn asPlane(self: *const Self) Vector2 {
        const godot_value = gd.api.*.godot_variant_as_plane.?(&self.godot_variant);
        return @ptrCast(*Plane, &godot_value).*;
    }

    pub fn asAABB(self: *const Self) AABB {
        const godot_value = gd.api.*.godot_variant_as_aabb.?(&self.godot_variant);
        return @ptrCast(*AABB, &godot_value).*;
    }

    pub fn asQuat(self: *const Self) Quat {
        const godot_value = gd.api.*.godot_variant_as_quat.?(&self.godot_variant);
        return @ptrCast(*Quat, &godot_value).*;
    }

    pub fn asBasis(self: *const Self) Basis {
        const godot_value = gd.api.*.godot_variant_as_basis.?(&self.godot_variant);
        return @ptrCast(*Basis, &godot_value).*;
    }

    pub fn asTransform(self: *const Self) Transform {
        const godot_value = gd.api.*.godot_variant_as_transform.?(&self.godot_variant);
        return @ptrCast(*Transform, &godot_value).*;
    }

    pub fn asTransform2D(self: *const Self) Transform2D {
        const godot_value = gd.api.*.godot_variant_as_transform2d.?(&self.godot_variant);
        return @ptrCast(*Transform2D, &godot_value).*;
    }

    pub fn asColor(self: *const Self) Color {
        const godot_value = gd.api.*.godot_variant_as_color.?(&self.godot_variant);
        return @ptrCast(*Color, &godot_value).*;
    }

    pub fn asNodePath(self: *const Self) NodePath {
        const godot_value = gd.api.*.godot_variant_as_node_path.?(&self.godot_variant);
        return NodePath.initGodotNodePath(godot_value);
    }

    pub fn asRID(self: *const Self) RID {
        const godot_value = gd.api.*.godot_variant_as_rid.?(&self.godot_variant);
        return @ptrCast(*RID, &godot_value).*;
    }

    pub fn asDictionary(self: *const Self) Dictionary {
        const godot_value = gd.api.*.godot_variant_as_dictionary.?(&self.godot_variant);
        return Dictionary.initGodotDictionary(godot_value);
    }

    pub fn asArray(self: *const Self) Array {
        const godot_value = gd.api.*.godot_variant_as_array.?(&self.godot_variant);
        return Array.initGodotArray(godot_value);
    }

    pub fn asPoolByteArray(self: *const Self) PoolByteArray {
        const godot_value = gd.api.*.godot_variant_as_pool_byte_array.?(&self.godot_variant);
        return PoolByteArray.initGodotPoolByteArray(godot_value);
    }

    pub fn asPoolIntArray(self: *const Self) PoolIntArray {
        const godot_value = gd.api.*.godot_variant_as_pool_int_array.?(&self.godot_variant);
        return PoolIntArray.initGodotPoolIntArray(godot_value);
    }

    pub fn asPoolRealArray(self: *const Self) PoolRealArray {
        const godot_value = gd.api.*.godot_variant_as_pool_real_array.?(&self.godot_variant);
        return PoolRealArray.initGodotPoolRealArray(godot_value);
    }

    pub fn asPoolStringArray(self: *const Self) PoolStringArray {
        const godot_value = gd.api.*.godot_variant_as_pool_string_array.?(&self.godot_variant);
        return PoolStringArray.initGodotPoolStringArray(godot_value);
    }

    pub fn asPoolVector2Array(self: *const Self) PoolVector2Array {
        const godot_value = gd.api.*.godot_variant_as_pool_vector2_array.?(&self.godot_variant);
        return PoolVector2Array.initGodotPoolVector2Array(godot_value);
    }

    pub fn asPoolVector3Array(self: *const Self) PoolVector3Array {
        const godot_value = gd.api.*.godot_variant_as_pool_vector3_array.?(&self.godot_variant);
        return PoolVector3Array.initGodotPoolVector3Array(godot_value);
    }

    pub fn asPoolColorArray(self: *const Self) PoolColorArray {
        const godot_value = gd.api.*.godot_variant_as_pool_color_array.?(&self.godot_variant);
        return PoolColorArray.initGodotPoolColorArray(godot_value);
    }

    // pub fn asObject(self: *const Self) Object {
    //     return gd.api.*.godot_variant_as_object.?(&self.godot_variant);
    // }

    pub fn getType(self: *const Self) Type {
        return @intToEnum(Type, gd.api.*.godot_variant_get_type.?(&self.godot_variant));
    }

    pub fn call(self: *Self, method: *const String, args: *[*]const Variant, arg_count: i32) Variant { // Make sure you call .deinit() on returned struct
        const godot_value = gd.api.*.godot_variant_call.?(&self.godot_variant, &method.godot_string, @ptrCast([*c]c.godot_variant, args), arg_count, null);
        return Variant.initGodotVariant(godot_value);
    }

    pub fn hasMethod(self: *const Self, method: *const String) bool {
        return gd.api.*.godot_variant_has_method.?(&self.godot_variant, &method.godot_string);
    }

    pub fn equal(self: *const Self, other: *const Variant) bool { // Operator ==
        return gd.api.*.godot_variant_operator_equal.?(&self.godot_variant, &other.godot_variant);
    }

    pub fn notEqual(self: *const Self, other: *const Variant) bool { // Operator !=
        return !equal(self, other);
    }

    pub fn less(self: *const Self, other: *const Variant) bool { // Operator <
        return gd.api.*.godot_variant_operator_less.?(&self.godot_variant, &other.godot_variant);
    }

    pub fn lessEqual(self: *const Self, other: *const Variant) bool { // Operator <=
        return less(self, other) || equal(self, other);
    }

    pub fn more(self: *const Self, other: *const Variant) bool { // Operator >
        return !lessEqual(self, other);
    }

    pub fn moreEqual(self: *const Self, other: *const Variant) bool { // Operator >=
        return !less(self, other);
    }

    pub fn hashCompare(self: *const Self, other: *const Variant) bool {
        return gd.api.*.godot_variant_hash_compare.?(&self.godot_variant, &other.godot_variant);
    }

};
