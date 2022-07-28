const Vector3 = @import("vector3.zig").Vector3;

pub const Basis = extern struct {

    elements: [3]Vector3,

};
