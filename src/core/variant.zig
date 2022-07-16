const gd = @import("api.zig");
const c = gd.c;

const std = @import("std");

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

    pub fn initCString(chars: [*:0]const u8) Self {
        var self = Self {
            .godot_variant = undefined,
        };

        var string = String.initUtf8(chars);
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


    inline fn godotVariantAsBool(variant: [*c]c.godot_variant) bool {
        return gd.api.*.godot_variant_as_bool.?(variant);
    }

    fn GodotVariantAsInt(comptime T: type) type {
        return struct {
            inline fn function(variant: [*c]c.godot_variant) T {
                return @intCast(T, gd.api.*.godot_variant_as_int.?(variant));
            }
        };
    }

    fn GodotVariantAsUint(comptime T: type) type {
        return struct {
            inline fn function(variant: [*c]c.godot_variant) T {
                return @intCast(T, gd.api.*.godot_variant_as_uint.?(variant));
            }
        };
    }

    fn GodotVariantAsFloat(comptime T: type) type {
        return struct {
            inline fn function(variant: [*c]c.godot_variant) T {
                return @floatCast(T, gd.api.*.godot_variant_as_real.?(variant));
            }
        };
    }

    // NOTE: These are not working properly! Due to a Zig bug with C ABI compatibility https://github.com/ziglang/zig/issues/1481
    // any struct returned from a function with sizeof <= 16 will not be correct and cause undefined behaviour, crashes etc

    inline fn godotVariantAsString(variant: [*c]c.godot_variant) String {
        return String.initGodotString(gd.api.*.godot_variant_as_string.?(variant));
    }

    inline fn godotVariantAsVector2(variant: [*c]c.godot_variant) Vector2 {
        return Vector2.initGodotVector2(gd.api.*.godot_variant_as_vector2.?(variant));
    }

    inline fn godotVariantAsRect2(variant: [*c]c.godot_variant) Rect2 {
        return Rect2.initGodotRect2(gd.api.*.godot_variant_as_rect2.?(variant));
    }

    inline fn godotVariantAsVector3(variant: [*c]c.godot_variant) Vector3 {
        return Vector3.initGodotVector3(gd.api.*.godot_variant_as_vector3.?(variant));
    }

    inline fn godotVariantAsTransform2D(variant: [*c]c.godot_variant) Transform2D {
        return Transform2D.initGodotTransform2D(gd.api.*.godot_variant_as_transform2d.?(variant));
    }

    inline fn godotVariantAsPlane(variant: [*c]c.godot_variant) Plane {
        return Plane.initGodotPlane(gd.api.*.godot_variant_as_plane.?(variant));
    }

    inline fn godotVariantAsQuat(variant: [*c]c.godot_variant) Quat {
        return Quat.initGodotQuat(gd.api.*.godot_variant_as_quat.?(variant));
    }

    inline fn godotVariantAsAABB(variant: [*c]c.godot_variant) AABB {
        return AABB.initGodotAABB(gd.api.*.godot_variant_as_aabb.?(variant));
    }

    inline fn godotVariantAsBasis(variant: [*c]c.godot_variant) Basis {
        return Basis.initGodotBasis(gd.api.*.godot_variant_as_basis.?(variant));
    }

    inline fn godotVariantAsTransform(variant: [*c]c.godot_variant) Transform {
        return Transform.initGodotTransform(gd.api.*.godot_variant_as_transform.?(variant));
    }

    inline fn godotVariantAsColor(variant: [*c]c.godot_variant) Color {
        return Color.initGodotColor(gd.api.*.godot_variant_as_color.?(variant));
    }

    inline fn godotVariantAsNodePath(variant: [*c]c.godot_variant) NodePath {
        return NodePath.initGodotNodePath(gd.api.*.godot_variant_as_node_path.?(variant));
    }

    inline fn godotVariantAsRID(variant: [*c]c.godot_variant) RID {
        return RID.initGodotRID(gd.api.*.godot_variant_as_rid.?(variant));
    }

    // inline fn godotVariantAsObject(variant: [*c]c.godot_variant) Object {
    //     return Object.initGodotObject(gd.api.*.godot_variant_as_object.?(variant));
    // }

    inline fn godotVariantAsDictionary(variant: [*c]c.godot_variant) Dictionary {
        return Dictionary.initGodotDictionary(gd.api.*.godot_variant_as_dictionary.?(variant));
    }

    inline fn godotVariantAsArray(variant: [*c]c.godot_variant) Array {
        return Array.initGodotArray(gd.api.*.godot_variant_as_array.?(variant));
    }

    inline fn godotVariantAsPoolByteArray(variant: [*c]c.godot_variant) PoolByteArray {
        return PoolByteArray.initGodotPoolByteArray(gd.api.*.godot_variant_as_pool_byte_array.?(variant));
    }

    inline fn godotVariantAsPoolIntArray(variant: [*c]c.godot_variant) PoolIntArray {
        return PoolIntArray.initGodotPoolIntArray(gd.api.*.godot_variant_as_pool_int_array.?(variant));
    }

    inline fn godotVariantAsPoolRealArray(variant: [*c]c.godot_variant) PoolRealArray {
        return PoolRealArray.initGodotPoolRealArray(gd.api.*.godot_variant_as_pool_real_array.?(variant));
    }

    inline fn godotVariantAsPoolStringArray(variant: [*c]c.godot_variant) PoolStringArray {
        return PoolStringArray.initGodotPoolStringArray(gd.api.*.godot_variant_as_pool_string_array.?(variant));
    }

    inline fn godotVariantAsPoolVector2Array(variant: [*c]c.godot_variant) PoolVector2Array {
        return PoolVector2Array.initGodotPoolVector2Array(gd.api.*.godot_variant_as_pool_vector2_array.?(variant));
    }

    inline fn godotVariantAsPoolVector3Array(variant: [*c]c.godot_variant) PoolVector3Array {
        return PoolVector3Array.initGodotPoolVector3Array(gd.api.*.godot_variant_as_pool_vector3_array.?(variant));
    }

    inline fn godotVariantAsPoolColorArray(variant: [*c]c.godot_variant) PoolColorArray {
        return PoolColorArray.initGodotPoolColorArray(gd.api.*.godot_variant_as_pool_color_array.?(variant));
    }

    pub fn variantAsType(comptime T: type) (fn([*c]c.godot_variant) callconv(.Inline) T) {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.TypeInfo).Union.tag_type.?;

        switch (type_info) {
            type_tag.Int => {
                if (type_info.Int.signedness == std.builtin.Signedness.signed) {
                    return GodotVariantAsInt(T).function;
                }
                else {
                    return GodotVariantAsUint(T).function;
                }
            },
            type_tag.Float => {
                return GodotVariantAsFloat(T).function;
            },
            else => {},
        }

        switch (T) {
            bool => {
                return godotVariantAsBool;
            },
            String => {
                return godotVariantAsString;
            },
            Vector2 => {
                return godotVariantAsVector2;
            },
            Rect2 => {
                return godotVariantAsRect2;
            },
            Vector3 => {
                return godotVariantAsVector3;
            },
            Transform2D => {
                return godotVariantAsTransform2D;
            },
            Plane => {
                return godotVariantAsPlane;
            },
            Quat => {
                return godotVariantAsQuat;
            },
            AABB => {
                return godotVariantAsAABB;
            },
            Basis => {
                return godotVariantAsBasis;
            },
            Transform => {
                return godotVariantAsTransform;
            },
            Color => {
                return godotVariantAsColor;
            },
            NodePath => {
                return godotVariantAsNodePath;
            },
            RID => {
                return godotVariantAsRID;
            },
            // Object => {
            //     return godotVariantAsObject;
            // },
            Dictionary => {
                return godotVariantAsDictionary;
            },
            Array => {
                return godotVariantAsArray;
            },
            PoolByteArray => {
                return godotVariantAsPoolByteArray;
            },
            PoolIntArray => {
                return godotVariantAsPoolIntArray;
            },
            PoolRealArray => {
                return godotVariantAsPoolRealArray;
            },
            PoolStringArray => {
                return godotVariantAsPoolStringArray;
            },
            PoolVector2Array => {
                return godotVariantAsPoolVector2Array;
            },
            PoolVector3Array => {
                return godotVariantAsPoolVector3Array;
            },
            PoolColorArray => {
                return godotVariantAsPoolColorArray;
            },
            else => {
                @compileError("Variant can't be converted as that type");
            },
        }

        return null;
    }


    inline fn voidAsGodotVariant(value: void) c.godot_variant {
        _ = value;
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_nil.?(&variant);
        return variant;
    }

    inline fn boolAsGodotVariant(value: bool) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_bool.?(&variant, value);
        return variant;
    }

    fn IntAsGodotVariant(comptime T: type) type {
        return struct {
            inline fn function(value: T) c.godot_variant {
                var variant: c.godot_variant = undefined;
                gd.api.*.godot_variant_new_int.?(&variant, value);
                return variant;
            }
        };
    }

    fn UintAsGodotVariant(comptime T: type) type {
        return struct {
            inline fn function(value: T) c.godot_variant {
                var variant: c.godot_variant = undefined;
                gd.api.*.godot_variant_new_uint.?(&variant, value);
                return variant;
            }
        };
    }

    fn FloatAsGodotVariant(comptime T: type) type {
        return struct {
            inline fn function(value: T) c.godot_variant {
                var variant: c.godot_variant = undefined;
                gd.api.*.godot_variant_new_real.?(&variant, value);
                return variant;
            }
        };
    }

    inline fn stringAsGodotVariant(value: String) c.godot_variant {
        var mutable_value = value; //So deinit can be called
        defer mutable_value.deinit(); //This will be copied when converted to a godot variant, so deinit to free any allocated memory, or it will leak

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_string.?(&variant, &mutable_value.godot_string);
        return variant;
    }

    inline fn vector2AsGodotVariant(value: Vector2) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_vector2.?(&variant, @ptrCast(*c.godot_vector2, &value));
        return variant;
    }

    inline fn rect2AsGodotVariant(value: Rect2) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_rect2.?(&variant, @ptrCast(*c.godot_rect2, &value));
        return variant;
    }

    inline fn vector3AsGodotVariant(value: Vector3) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_vector3.?(&variant, @ptrCast(*c.godot_vector3, &value));
        return variant;
    }

    inline fn transform2DAsGodotVariant(value: Transform2D) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_transform2d.?(&variant, @ptrCast(*c.godot_transform2d, &value));
        return variant;
    }

    inline fn planeAsGodotVariant(value: Plane) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_plane.?(&variant, @ptrCast(*c.godot_plane, &value));
        return variant;
    }

    inline fn quatAsGodotVariant(value: Quat) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_quat.?(&variant, @ptrCast(*c.godot_quat, &value));
        return variant;
    }

    inline fn aabbAsGodotVariant(value: AABB) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_aabb.?(&variant, @ptrCast(*c.godot_aabb, &value));
        return variant;
    }

    inline fn basisAsGodotVariant(value: Basis) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_basis.?(&variant, @ptrCast(*c.godot_basis, &value));
        return variant;
    }

    inline fn transformAsGodotVariant(value: Transform) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_transform.?(&variant, @ptrCast(*c.godot_transform, &value));
        return variant;
    }

    inline fn colorAsGodotVariant(value: Color) c.godot_variant {
        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_color.?(&variant, @ptrCast(*c.godot_color, &value));
        return variant;
    }

    inline fn nodePathAsGodotVariant(value: NodePath) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_node_path.?(&variant, &mutable_value.godot_node_path);
        return variant;
    }

    inline fn ridAsGodotVariant(value: RID) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_rid.?(&variant, &mutable_value.godot_rid);
        return variant;
    }

    // inline fn objectAsGodotVariant(value: Object) c.godot_variant {
    //     var variant: c.godot_variant = undefined;
    //     gd.api.*.godot_variant_new_object.?(&variant, @ptrCast(*c.godot_object, &value));
    //     return variant;
    // }

    inline fn dictionaryAsGodotVariant(value: Dictionary) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_dictionary.?(&variant, &mutable_value.godot_dictionary);
        return variant;
    }

    inline fn arrayAsGodotVariant(value: Array) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    inline fn poolByteArrayAsGodotVariant(value: PoolByteArray) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_pool_byte_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    inline fn poolIntArrayAsGodotVariant(value: PoolIntArray) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_pool_int_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    inline fn poolRealArrayAsGodotVariant(value: PoolRealArray) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_pool_real_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    inline fn poolStringArrayAsGodotVariant(value: PoolStringArray) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_pool_string_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    inline fn poolVector2ArrayAsGodotVariant(value: PoolVector2Array) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_pool_vector2_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    inline fn poolVector3ArrayAsGodotVariant(value: PoolVector3Array) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_pool_vector3_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    inline fn poolColorArrayAsGodotVariant(value: PoolColorArray) c.godot_variant {
        var mutable_value = value;
        defer mutable_value.deinit();

        var variant: c.godot_variant = undefined;
        gd.api.*.godot_variant_new_pool_color_array.?(&variant, &mutable_value.godot_array);
        return variant;
    }

    pub fn typeAsVariant(comptime T: type) (fn(T) callconv(.Inline) c.godot_variant) {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.TypeInfo).Union.tag_type.?;

        switch (type_info) {
            type_tag.Int => {
                if (type_info.Int.signedness == std.builtin.Signedness.signed) {
                    return IntAsGodotVariant(T).function;
                }
                else {
                    return UintAsGodotVariant(T).function;
                }
            },
            type_tag.Float => {
                return FloatAsGodotVariant(T).function;
            },
            else => {},
        }

        switch (T) {
            void => {
                return voidAsGodotVariant;
            },
            bool => {
                return boolAsGodotVariant;
            },
            String => {
                return stringAsGodotVariant;
            },
            Vector2 => {
                return vector2AsGodotVariant;
            },
            Rect2 => {
                return rect2AsGodotVariant;
            },
            Vector3 => {
                return vector3AsGodotVariant;
            },
            Transform2D => {
                return transform2DAsGodotVariant;
            },
            Plane => {
                return planeAsGodotVariant;
            },
            Quat => {
                return quatAsGodotVariant;
            },
            AABB => {
                return aabbAsGodotVariant;
            },
            Basis => {
                return basisAsGodotVariant;
            },
            Transform => {
                return transformAsGodotVariant;
            },
            Color => {
                return colorAsGodotVariant;
            },
            NodePath => {
                return nodePathAsGodotVariant;
            },
            RID => {
                return ridAsGodotVariant;
            },
            // Object => {
            //     return objectAsGodotVariant;
            // },
            Dictionary => {
                return dictionaryAsGodotVariant;
            },
            Array => {
                return arrayAsGodotVariant;
            },
            PoolByteArray => {
                return poolByteArrayAsGodotVariant;
            },
            PoolIntArray => {
                return poolIntArrayAsGodotVariant;
            },
            PoolRealArray => {
                return poolRealArrayAsGodotVariant;
            },
            PoolStringArray => {
                return poolStringArrayAsGodotVariant;
            },
            PoolVector2Array => {
                return poolVector2ArrayAsGodotVariant;
            },
            PoolVector3Array => {
                return poolVector3ArrayAsGodotVariant;
            },
            PoolColorArray => {
                return poolColorArrayAsGodotVariant;
            },
            else => {
                @compileError("Unsupported return type");
            },
        }

        return null;
    }

};
