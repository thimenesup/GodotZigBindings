pub const Wrapped = @import("wrapped.zig").Wrapped;
pub const Variant = @import("../variant/variant.zig").Variant;

// Math
pub const AABB = @import("../variant/aabb.zig").AABB;
pub const Basis = @import("../variant/basis.zig").Basis;
pub const Color = @import("../variant/color.zig").Color;
pub const Plane = @import("../variant/plane.zig").Plane;
pub const Projection = @import("../variant/projection.zig").Projection;
pub const Quaternion = @import("../variant/quaternion.zig").Quaternion;
pub const Rect2 = @import("../variant/rect2.zig").Rect2;
pub const Rect2i = @import("../variant/rect2i.zig").Rect2i;
pub const Transform2D = @import("../variant/transform2d.zig").Transform2D;
pub const Transform3D = @import("../variant/transform3d.zig").Transform3D;
pub const TypedArray = @import("../variant/typed_array.zig").TypedArray;
pub const Vector2 = @import("../variant/vector2.zig").Vector2;
pub const Vector2i = @import("../variant/vector2i.zig").Vector2i;
pub const Vector3 = @import("../variant/vector3.zig").Vector3;
pub const Vector3i = @import("../variant/vector3i.zig").Vector3i;
pub const Vector4 = @import("../variant/vector4.zig").Vector4;
pub const Vector4i = @import("../variant/vector4i.zig").Vector4i;

// Generated
pub const Array = @import("../gen/builtin_classes/array.zig").Array;
pub const Callable = @import("../gen/builtin_classes/callable.zig").Callable;
pub const Dictionary = @import("../gen/builtin_classes/dictionary.zig").Dictionary;
pub const NodePath = @import("../gen/builtin_classes/node_path.zig").NodePath;
pub const PackedByteArray = @import("../gen/builtin_classes/packed_byte_array.zig").PackedByteArray;
pub const PackedColorArray = @import("../gen/builtin_classes/packed_color_array.zig").PackedColorArray;
pub const PackedFloat32Array = @import("../gen/builtin_classes/packed_float32_array.zig").PackedFloat32Array;
pub const PackedFloat64Array = @import("../gen/builtin_classes/packed_float64_array.zig").PackedFloat64Array;
pub const PackedInt32Array = @import("../gen/builtin_classes/packed_int32_array.zig").PackedInt32Array;
pub const PackedInt64Array = @import("../gen/builtin_classes/packed_int64_array.zig").PackedInt64Array;
pub const PackedStringArray = @import("../gen/builtin_classes/packed_string_array.zig").PackedStringArray;
pub const PackedVector2Array = @import("../gen/builtin_classes/packed_vector2_array.zig").PackedVector2Array;
pub const PackedVector3Array = @import("../gen/builtin_classes/packed_vector3_array.zig").PackedVector3Array;
pub const RID = @import("../gen/builtin_classes/rid.zig").RID;
pub const Signal = @import("../gen/builtin_classes/signal.zig").Signal;
pub const StringName = @import("../gen/builtin_classes/string_name.zig").StringName;
pub const String = @import("../gen/builtin_classes/string.zig").String;
