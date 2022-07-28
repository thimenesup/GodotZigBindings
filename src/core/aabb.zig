const Vector3 = @import("vector3.zig").Vector3;

pub const AABB = extern struct {

    position: Vector3,
    size: Vector3,

};
