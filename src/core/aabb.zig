const gd = @import("api.zig");
const c = gd.c;

pub const AABB = struct {

    godot_aabb: c.godot_aabb,

};
