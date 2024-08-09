const std = @import("std");

const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const Object = @import("../gen/classes/object.zig").Object;

const AABB = @import("aabb.zig").AABB;
const Basis = @import("basis.zig").Basis;
const Color = @import("color.zig").Color;
const Plane = @import("plane.zig").Plane;
const Projection = @import("projection.zig").Projection;
const Quaternion = @import("quat.zig").Quaternion;
const Rect2 = @import("rect2.zig").Rect2;
const Rect2i = @import("rect2i.zig").Rect2i;
const Transform2D = @import("transform2d.zig").Transform2D;
const Transform3D = @import("transform.zig").Transform3D;
const TypedArray = @import("typed_array.zig").TypedArray;
const Vector2 = @import("vector2.zig").Vector2;
const Vector2i = @import("vector2i.zig").Vector2i;
const Vector3 = @import("vector3.zig").Vector3;
const Vector3i = @import("vector3i.zig").Vector3i;
const Vector4 = @import("vector4.zig").Vector4;
const Vector4i = @import("vector4i.zig").Vector4i;

// Generated
const Array = @import("../gen/builtin_classes/array.zig").Array;
const Callable = @import("../gen/builtin_classes/callable.zig").Callable;
const Dictionary = @import("../gen/builtin_classes/dictionary.zig").Dictionary;
const NodePath = @import("../gen/builtin_classes/node_path.zig").NodePath;
const PackedByteArray = @import("../gen/builtin_classes/packed_byte_array.zig").PackedByteArray;
const PackedColorArray = @import("../gen/builtin_classes/packed_color_array.zig").PackedColorArray;
const PackedFloat32Array = @import("../gen/builtin_classes/packed_float32_array.zig").PackedFloat32Array;
const PackedFloat64Array = @import("../gen/builtin_classes/packed_float64_array.zig").PackedFloat64Array;
const PackedInt32Array = @import("../gen/builtin_classes/packed_int32_array.zig").PackedInt32Array;
const PackedInt64Array = @import("../gen/builtin_classes/packed_int64_array.zig").PackedInt64Array;
const PackedStringArray = @import("../gen/builtin_classes/packed_string_array.zig").PackedStringArray;
const PackedVector2Array = @import("../gen/builtin_classes/packed_vector2_array.zig").PackedVector2Array;
const PackedVector3Array = @import("../gen/builtin_classes/packed_vector3_array.zig").PackedVector3Array;
const RID = @import("../gen/builtin_classes/rid.zig").RID;
const Signal = @import("../gen/builtin_classes/signal.zig").Signal;
const StringName = @import("../gen/builtin_classes/string_name.zig").StringName;
const String = @import("../gen/builtin_classes/string.zig").String;

pub const Variant = struct {

    const GODOT_VARIANT_SIZE = 24;

    _opaque: [GODOT_VARIANT_SIZE]u8,

    const Self = @This();

    pub const Type = enum(i64) {
        nil,

        bool,
        int,
        float,
        string,

        vector2,
        vector2i,
        rect2,
        rect2i,
        vector3,
        vector3i,
        transform2d,
        vector4,
        vector4i,
        plane,
        quaternion,
        aabb,
        basis,
        transform3d,
        projection,

        color,
        string_name,
        node_path,
        rid,
        object,
        callable,
        signal,
        dictionary,
        array,

        packed_byte_array,
        packed_int32_array,
        packed_int64_array,
        packed_float32_array,
        packed_float64_array,
        packed_string_array,
        packed_vector2_array,
        packed_vector3_array,
        packed_color_array,
        variant_max,
    };

    pub const Operator = enum(i64) {
        op_equal,
        op_not_equal,
        op_less,
        op_less_equal,
        op_greater,
        op_greater_equal,

        op_add,
        op_substract,
        op_multiply,
        op_divide,
        op_negate,
        op_positive,
        op_module,

        op_shift_left,
        op_shift_right,
        op_bit_and,
        op_bit_or,
        op_bit_xor,
        op_bit_negate,

        op_and,
        op_or,
        op_xor,
        op_not,

        op_in,
        op_max,
    };

    var from_type_constructor: [@intFromEnum(Type.variant_max)]gi.GDExtensionVariantFromTypeConstructorFunc = undefined;
    var to_type_constructor: [@intFromEnum(Type.variant_max)]gi.GDExtensionTypeFromVariantConstructorFunc = undefined;

    inline fn fromTypeConstructor(t: Variant.Type) gi.GDExtensionVariantFromTypeConstructorFunc { return from_type_constructor[@intFromEnum(t)]; }
    inline fn toTypeConstructor(t: Variant.Type) gi.GDExtensionTypeFromVariantConstructorFunc { return to_type_constructor[@intFromEnum(t)]; }

    pub fn initBindings() void {
        var i: usize = 1; // Start from 1 to skip Nil
        while (i < @intFromEnum(Type.variant_max)) : (i += 1) {
            from_type_constructor[i] = gd.interface.?.get_variant_from_type_constructor.?(@enumFromInt(i));
            to_type_constructor[i] = gd.interface.?.get_variant_to_type_constructor.?(@enumFromInt(i));
        }

        Array.initBindings();
        Callable.initBindings();
        Dictionary.initBindings();
        NodePath.initBindings();
        PackedByteArray.initBindings();
        PackedColorArray.initBindings();
        PackedFloat32Array.initBindings();
        PackedFloat64Array.initBindings();
        PackedInt32Array.initBindings();
        PackedInt64Array.initBindings();
        PackedStringArray.initBindings();
        PackedVector2Array.initBindings();
        PackedVector3Array.initBindings();
        RID.initBindings();
        Signal.initBindings();
        StringName.initBindings();
        String.initBindings();
    }

    pub inline fn _nativePtr(self: *const Self) gi.GDExtensionTypePtr {
        return @constCast(@ptrCast(&self._opaque));
    }

    pub fn deinit(self: *Self) void {
        gd.interface.?.variant_new_nil.?(self._nativePtr());
    }

    pub fn init() Self {
        var self: Self = undefined;
        gd.interface.?.variant_new_nil.?(self._nativePtr());
        return self;
    }

    pub fn initVoid(p_void: void) Self {
        _ = p_void;
        var self: Self = undefined;
        gd.interface.?.variant_new_nil.?(self._nativePtr());
        return self;
    }

    pub fn initAny(any: anytype) Self {
        var self: Self = undefined;
        self = typeAsVariant(@TypeOf(any))(any);
        return self;
    }

    pub fn initVariantPtr(other: gi.GDExtensionConstVariantPtr) Variant {
        var self: Self = undefined;
        gd.interface.?.variant_new_copy.?(self._nativePtr(), other);
        return self;
    }

    pub fn initVariant(other: *const Variant) Variant {
        var self: Self = undefined;
        gd.interface.?.variant_new_copy.?(self._nativePtr(), other._nativePtr());
        return self;
    }

    pub fn initBool(p_bool: bool) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.bool).?(self._nativePtr(), @ptrCast(&p_bool));
        return self;
    }

    pub fn initInt(p_int: i64) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.int).?(self._nativePtr(), @ptrCast(&p_int));
        return self;
    }

    pub fn initFloat(p_float: f64) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.float).?(self._nativePtr(), @ptrCast(&p_float));
        return self;
    }

    pub fn initAABB(p_aabb: *const AABB) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.aabb).?(self._nativePtr(), @ptrCast(&p_aabb));
        return self;
    }

    pub fn initBasis(p_basis: *const Basis) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.basis).?(self._nativePtr(), @ptrCast(&p_basis));
        return self;
    }

    pub fn initColor(p_color: *const Color) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.color).?(self._nativePtr(), @ptrCast(&p_color));
        return self;
    }

    pub fn initPlane(p_plane: *const Plane) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.plane).?(self._nativePtr(), @ptrCast(&p_plane));
        return self;
    }

    pub fn initProjection(p_projection: *const Projection) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.projection).?(self._nativePtr(), @ptrCast(&p_projection));
        return self;
    }

    pub fn initQuaternion(p_quaternion: *const Quaternion) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.quaternion).?(self._nativePtr(), @ptrCast(&p_quaternion));
        return self;
    }

    pub fn initRect2(p_rect2: *const Rect2) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.rect2).?(self._nativePtr(), @ptrCast(&p_rect2));
        return self;
    }

    pub fn initRect2i(p_rect2i: *const Rect2i) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.rect2i).?(self._nativePtr(), @ptrCast(&p_rect2i));
        return self;
    }

    pub fn initTransform3D(p_transform3d: *const Transform3D) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.transform3d).?(self._nativePtr(), @ptrCast(&p_transform3d));
        return self;
    }

    pub fn initTransform2D(p_transform2d: *const Transform2D) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.transform2d).?(self._nativePtr(), @ptrCast(&p_transform2d));
        return self;
    }

    pub fn initVector2(p_vector2: *const Vector2) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.vector2).?(self._nativePtr(), @ptrCast(&p_vector2));
        return self;
    }

    pub fn initVector2i(p_vector2i: *const Vector2i) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.vector2i).?(self._nativePtr(), @ptrCast(&p_vector2i));
        return self;
    }

    pub fn initVector3(p_vector3: *const Vector3) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.vector3).?(self._nativePtr(), @ptrCast(&p_vector3));
        return self;
    }

    pub fn initVector3i(p_vector3i: *const Vector3i) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.vector3i).?(self._nativePtr(), @ptrCast(&p_vector3i));
        return self;
    }

    pub fn initVector4(p_vector4: *const Vector4) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.vector4).?(self._nativePtr(), @ptrCast(&p_vector4));
        return self;
    }

    pub fn initVector4i(p_vector4i: *const Vector4i) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.vector4i).?(self._nativePtr(), @ptrCast(&p_vector4i));
        return self;
    }

    pub fn initArray(p_array: *const Array) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.array).?(self._nativePtr(), @ptrCast(p_array._nativePtr()));
        return self;
    }

    pub fn initCallable(p_callable: *const Callable) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.callable).?(self._nativePtr(), @ptrCast(&p_callable));
        return self;
    }

    pub fn initDictionary(p_dictionary: *const Dictionary) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.dictionary).?(self._nativePtr(), @ptrCast(p_dictionary._nativePtr()));
        return self;
    }

    pub fn initNodePath(p_node_path: *const NodePath) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.node_path).?(self._nativePtr(), @ptrCast(p_node_path._nativePtr()));
        return self;
    }

    pub fn initPackedByteArray(p_packed_byte_array: *const PackedByteArray) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_byte_array).?(self._nativePtr(), @ptrCast(p_packed_byte_array._nativePtr()));
        return self;
    }

    pub fn initPackedColorArray(p_packed_color_array: *const PackedColorArray) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_color_array).?(self._nativePtr(), @ptrCast(p_packed_color_array._nativePtr()));
        return self;
    }

    pub fn initPackedFloat32Array(p_packed_float32_array: *const PackedFloat32Array) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_float32_array).?(self._nativePtr(), @ptrCast(p_packed_float32_array._nativePtr()));
        return self;
    }

    pub fn initPackedFloat64Array(p_packed_float64_array: *const PackedFloat32Array) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_float64_array).?(self._nativePtr(), @ptrCast(p_packed_float64_array._nativePtr()));
        return self;
    }

    pub fn initPackedInt32Array(p_packed_int32_array: *const PackedInt32Array) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_int32_array).?(self._nativePtr(), @ptrCast(p_packed_int32_array._nativePtr()));
        return self;
    }

    pub fn initPackedInt64Array(p_packed_int64_array: *const PackedInt64Array) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_int64_array).?(self._nativePtr(), @ptrCast(p_packed_int64_array._nativePtr()));
        return self;
    }

    pub fn initPackedStringArray(p_packed_string_array: *const PackedStringArray) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_string_array).?(self._nativePtr(), @ptrCast(p_packed_string_array._nativePtr()));
        return self;
    }

    pub fn initPackedVector2Array(p_packed_vector2_array: *const PackedVector2Array) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_vector2_array).?(self._nativePtr(), @ptrCast(p_packed_vector2_array._nativePtr()));
        return self;
    }

    pub fn initPackedVector3Array(p_packed_vector3_array: *const PackedVector3Array) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.packed_vector3_array).?(self._nativePtr(), @ptrCast(p_packed_vector3_array._nativePtr()));
        return self;
    }

    pub fn initRID(p_rid: *const RID) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.rid).?(self._nativePtr(), @ptrCast(p_rid._nativePtr()));
        return self;
    }


    pub fn initSignal(p_signal: *const Signal) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.signal).?(self._nativePtr(), @ptrCast(&p_signal));
        return self;
    }

    pub fn initStringName(p_string_name: *const StringName) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.string_name).?(self._nativePtr(), @ptrCast(&p_string_name));
        return self;
    }

    pub fn initString(p_string: *const String) Self {
        var self: Self = undefined;
        fromTypeConstructor(Type.string).?(self._nativePtr(), @ptrCast(&p_string));
        return self;
    }

    pub fn initObject(p_object: *const Object) Self {
        var self: Self = undefined;
        if (p_object != null) {
            fromTypeConstructor(Type.object).?(self._nativePtr(), @ptrCast(p_object.base._owner));
        } else {
            const null_object: ?*anyopaque = null;
            fromTypeConstructor(Type.object).?(self._nativePtr(), @ptrCast(&null_object));
        }
        return self;
    }


    pub fn asBool(self: *const Self) bool {
        var result: gi.GDExtensionBool = undefined;
        toTypeConstructor(Type.bool).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asInt(self: *const Self) i64 {
        var result: gi.GDExtensionInt = undefined;
        toTypeConstructor(Type.int).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asFloat(self: *const Self) f64 {
        var result: f64 = undefined;
        toTypeConstructor(Type.float).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asAABB(self: *const Self) AABB {
        var result: AABB = undefined;
        toTypeConstructor(Type.aabb).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asBasis(self: *const Self) Basis {
        var result: Basis = undefined;
        toTypeConstructor(Type.basis).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asColor(self: *const Self) Color {
        var result: Color = undefined;
        toTypeConstructor(Type.color).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPlane(self: *const Self) Vector2 {
        var result: Plane = undefined;
        toTypeConstructor(Type.plane).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asProjection(self: *const Self) Projection {
        var result: Projection = undefined;
        toTypeConstructor(Type.projection).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asQuaternion(self: *const Self) Quaternion {
        var result: Quaternion = undefined;
        toTypeConstructor(Type.quaternion).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asRect2(self: *const Self) Rect2 {
        var result: Rect2 = undefined;
        toTypeConstructor(Type.rect2).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asRect2i(self: *const Self) Rect2i {
        var result: Rect2i = undefined;
        toTypeConstructor(Type.rect2i).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asTransform3D(self: *const Self) Transform3D {
        var result: Transform3D = undefined;
        toTypeConstructor(Type.transform3d).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asTransform2D(self: *const Self) Transform2D {
        var result: Transform2D = undefined;
        toTypeConstructor(Type.transform2d).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asVector2(self: *const Self) Vector2 {
        var result: Vector2 = undefined;
        toTypeConstructor(Type.vector2).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asVector2i(self: *const Self) Vector2i {
        var result: Vector2i = undefined;
        toTypeConstructor(Type.vector2i).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asVector3(self: *const Self) Vector3 {
        var result: Vector3 = undefined;
        toTypeConstructor(Type.vector3).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asVector3i(self: *const Self) Vector3i {
        var result: Vector3i = undefined;
        toTypeConstructor(Type.vector3i).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asVector4(self: *const Self) Vector4 {
        var result: Vector4 = undefined;
        toTypeConstructor(Type.vector4).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asVector4i(self: *const Self) Vector4i {
        var result: Vector4i = undefined;
        toTypeConstructor(Type.vector4i).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asArray(self: *const Self) Array {
        var result: Array = undefined;
        toTypeConstructor(Type.array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asCallable(self: *const Self) Callable {
        var result: Callable = undefined;
        toTypeConstructor(Type.callable).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asDictionary(self: *const Self) Dictionary {
        var result: Dictionary = undefined;
        toTypeConstructor(Type.dictionary).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asNodePath(self: *const Self) NodePath {
        var result: NodePath = undefined;
        toTypeConstructor(Type.node_path).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedByteArray(self: *const Self) PackedByteArray {
        var result: PackedByteArray = undefined;
        toTypeConstructor(Type.packed_byte_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedColorArray(self: *const Self) PackedColorArray {
        var result: PackedColorArray = undefined;
        toTypeConstructor(Type.packed_color_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedFloat32Array(self: *const Self) PackedFloat32Array {
        var result: PackedFloat32Array = undefined;
        toTypeConstructor(Type.packed_float32_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedFloat64Array(self: *const Self) PackedFloat64Array {
        var result: PackedFloat64Array = undefined;
        toTypeConstructor(Type.packed_float64_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedInt32Array(self: *const Self) PackedInt32Array {
        var result: PackedInt32Array = undefined;
        toTypeConstructor(Type.packed_int32_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedInt64Array(self: *const Self) PackedInt64Array {
        var result: PackedInt64Array = undefined;
        toTypeConstructor(Type.packed_int64_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedStringArray(self: *const Self) PackedStringArray {
        var result: PackedStringArray = undefined;
        toTypeConstructor(Type.packed_string_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedVector2Array(self: *const Self) PackedVector2Array {
        var result: PackedVector2Array = undefined;
        toTypeConstructor(Type.packed_vector2_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asPackedVector3Array(self: *const Self) PackedVector3Array {
        var result: PackedVector3Array = undefined;
        toTypeConstructor(Type.packed_vector3_array).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asRID(self: *const Self) RID {
        var result: RID = undefined;
        toTypeConstructor(Type.rid).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asSignal(self: *const Self) Signal {
        var result: Signal = undefined;
        toTypeConstructor(Type.signal).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asStringName(self: *const Self) StringName {
        var result: StringName = undefined;
        toTypeConstructor(Type.string_name).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asString(self: *const Self) String {
        var result: String = undefined;
        toTypeConstructor(Type.string).?(@ptrCast(&result), self._nativePtr());
        return result;
    }

    pub fn asObject(self: *const Self) ?*Object {
        var object: ?*anyopaque = undefined;
        toTypeConstructor(Type.object).?(&object, self._nativePtr());
        if (object == null) {
            return null;
        }
        return @ptrCast(gd.interface.?.object_get_instance_binding.?(object, gd.token, &Object._binding_callbacks));
    }


    pub fn getType(self: *const Self) Type {
        return @enumFromInt(gd.interface.?.variant_get_type.?(self._nativePtr()));
    }


    fn VariantAsInt(comptime T: type) type {
        return struct {
            fn function(variant: *const Variant) T {
                return @intCast(variant.asInt());
            }
        };
    }

    fn VariantAsFloat(comptime T: type) type {
        return struct {
            fn function(variant: *const Variant) T {
                return @floatCast(variant.asFloat());
            }
        };
    }

    pub fn variantAsType(comptime T: type) (fn(*const Variant) T) {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;

        switch (type_info) {
            type_tag.Struct => {
                if (@hasDecl(T, "GodotClass")) {
                    return Variant.asObject;
                }
            },
            type_tag.Int => {
                return VariantAsInt(T).function;
            },
            type_tag.Float => {
                return VariantAsFloat(T).function;
            },
            else => {},
        }

        switch (T) {
            bool => {
                return Variant.asBool;
            },
            AABB => {
                return Variant.asAABB;
            },
            Basis => {
                return Variant.asBasis;
            },
            Color => {
                return Variant.asColor;
            },
            Vector2 => {
                return Variant.asVector2;
            },
            Vector2i => {
                return Variant.asVector2i;
            },
            Rect2 => {
                return Variant.asRect2;
            },
            Rect2i => {
                return Variant.asRect2i;
            },
            Vector3 => {
                return Variant.asVector3;
            },
            Vector3i => {
                return Variant.asVector3i;
            },
            Vector4=> {
                return Variant.asVector4;
            },
            Vector4i => {
                return Variant.asVector4i;
            },
            Transform2D => {
                return Variant.asTransform2D;
            },
            Transform3D => {
                return Variant.asTransform3D;
            },
            Plane => {
                return Variant.asPlane;
            },
            Projection => {
                return Variant.asProjection;
            },
            Quaternion => {
                return Variant.asQuaternion;
            },
            Array => {
                return Variant.asArray;
            },
            Callable => {
                return Variant.asCallable;
            },
            NodePath => {
                return Variant.asNodePath;
            },
            Dictionary => {
                return Variant.asDictionary;
            },
            PackedByteArray => {
                return Variant.asPackedByteArray;
            },
            PackedColorArray => {
                return Variant.asPackedColorArray;
            },
            PackedFloat32Array => {
                return Variant.asPackedFloat32Array;
            },
            PackedFloat64Array => {
                return Variant.asPackedFloat64Array;
            },
            PackedInt32Array => {
                return Variant.asPackedInt32Array;
            },
            PackedInt64Array => {
                return Variant.asPackedInt64Array;
            },
            PackedStringArray => {
                return Variant.asPackedStringArray;
            },
            PackedVector2Array => {
                return Variant.asPackedVector2Array;
            },
            PackedVector3Array => {
                return Variant.asPackedVector3Array;
            },
            RID => {
                return Variant.asRID;
            },
            Signal => {
                return Variant.asSignal;
            },
            StringName => {
                return Variant.asStringName;
            },
            String => {
                return Variant.asString;
            },
            else => {
                @compileLog("Variant can't be converted as type:", T);
            },
        }

        return null;
    }

    pub fn typeAsVariant(comptime T: type) (fn(T) Variant) {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;

        switch (type_info) {
            type_tag.Struct => {
                if (@hasDecl(T, "GodotClass")) {
                    return Variant.initObject;
                }
            },
            type_tag.Int => {
                return Variant.initInt;
            },
            type_tag.Float => {
                return Variant.initFloat;
            },
            type_tag.ComptimeInt => {
                return Variant.initInt;
            },
            type_tag.ComptimeFloat => {
                return Variant.initFloat;
            },
            // type_tag.Pointer => {
            //     if (type_info.Pointer.child == u8) {
            //         return cstringAsGodotVariant;
            //     }
            // },
            else => {},
        }

        switch (T) {
            void => {
                return Variant.initVoid;
            },
            bool => {
                return Variant.initBool;
            },
            AABB => {
                return Variant.initAABB;
            },
            Basis => {
                return Variant.initBasis;
            },
            Color => {
                return Variant.initColor;
            },
            Vector2 => {
                return Variant.initVector2;
            },
            Vector2i => {
                return Variant.initVector2i;
            },
            Rect2 => {
                return Variant.initRect2;
            },
            Rect2i => {
                return Variant.initRect2i;
            },
            Vector3 => {
                return Variant.initVector3;
            },
            Vector3i => {
                return Variant.initVector3i;
            },
            Vector4=> {
                return Variant.initVector4;
            },
            Vector4i => {
                return Variant.initVector4i;
            },
            Transform2D => {
                return Variant.initTransform2D;
            },
            Transform3D => {
                return Variant.initTransform3D;
            },
            Plane => {
                return Variant.initPlane;
            },
            Projection => {
                return Variant.initProjection;
            },
            Quaternion => {
                return Variant.initQuaternion;
            },
            Array => {
                return Variant.initArray;
            },
            Callable => {
                return Variant.initCallable;
            },
            NodePath => {
                return Variant.initNodePath;
            },
            Dictionary => {
                return Variant.initDictionary;
            },
            PackedByteArray => {
                return Variant.initPackedByteArray;
            },
            PackedColorArray => {
                return Variant.initPackedColorArray;
            },
            PackedFloat32Array => {
                return Variant.initPackedFloat32Array;
            },
            PackedFloat64Array => {
                return Variant.initPackedFloat64Array;
            },
            PackedInt32Array => {
                return Variant.initPackedInt32Array;
            },
            PackedInt64Array => {
                return Variant.initPackedInt64Array;
            },
            PackedStringArray => {
                return Variant.initPackedStringArray;
            },
            PackedVector2Array => {
                return Variant.initPackedVector2Array;
            },
            PackedVector3Array => {
                return Variant.initPackedVector3Array;
            },
            RID => {
                return Variant.initRID;
            },
            Signal => {
                return Variant.initSignal;
            },
            StringName => {
                return Variant.initStringName;
            },
            String => {
                return Variant.initString;
            },
            else => {
                @compileLog("Unsupported return type:", T);
            },
        }

        return null;
    }

    pub fn typeToVariantType(comptime T: type) Type {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;

        switch (type_info) {
            type_tag.Struct => {
                if (@hasDecl(T, "GodotClass")) {
                    return Type.object;
                }
            },
            type_tag.Int => {
                return Type.int;
            },
            type_tag.Float => {
                return Type.float;
            },
            else => {},
        }

        switch (T) {
            @TypeOf(null) => {
                return Type.nil;
            },
            void => {
                return Type.nil;
            },
            bool => {
                return Type.bool;
            },
            AABB => {
                return Type.aabb;
            },
            Basis => {
                return Type.basis;
            },
            Color => {
                return Type.color;
            },
            Vector2 => {
                return Type.vector2;
            },
            Vector2i => {
                return Type.vector2i;
            },
            Rect2 => {
                return Type.rect2;
            },
            Rect2i => {
                return Type.rect2i;
            },
            Vector3 => {
                return Type.vector3;
            },
            Vector3i => {
                return Type.vector3i;
            },
            Vector4=> {
                return Type.vector4;
            },
            Vector4i => {
                return Type.vector4i;
            },
            Transform2D => {
                return Type.transform2d;
            },
            Transform3D => {
                return Type.transform3d;
            },
            Plane => {
                return Type.plane;
            },
            Projection => {
                return Type.projection;
            },
            Quaternion => {
                return Type.quaternion;
            },
            Array => {
                return Type.array;
            },
            Callable => {
                return Type.callable;
            },
            NodePath => {
                return Type.node_path;
            },
            Dictionary => {
                return Type.dictionary;
            },
            PackedByteArray => {
                return Type.packed_byte_array;
            },
            PackedColorArray => {
                return Type.packed_color_array;
            },
            PackedFloat32Array => {
                return Type.packed_float32_array;
            },
            PackedFloat64Array => {
                return Type.packed_float64_array;
            },
            PackedInt32Array => {
                return Type.packed_int32_array;
            },
            PackedInt64Array => {
                return Type.packed_int64_array;
            },
            PackedStringArray => {
                return Type.packed_string_array;
            },
            PackedVector2Array => {
                return Type.packed_vector2_array;
            },
            PackedVector3Array => {
                return Type.packed_vector3_array;
            },
            RID => {
                return Type.rid;
            },
            Signal => {
                return Type.signal;
            },
            StringName => {
                return Type.string_name;
            },
            String => {
                return Type.string;
            },
            else => {
                @compileLog("Unknown type:", T);
            },
        }

        return Type.variant_max;
    }

};
