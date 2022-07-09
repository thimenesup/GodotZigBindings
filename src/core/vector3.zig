const gd = @import("api.zig");
const c = gd.c;

pub const Vector3 = struct {

    godot_vector3: c.godot_vector3,

};
