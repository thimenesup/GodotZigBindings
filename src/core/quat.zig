const gd = @import("api.zig");
const c = gd.c;

pub const Quat = struct {

    godot_quat: c.godot_quat,

};
