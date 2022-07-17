const gd = @import("api.zig");
const c = gd.c;

pub const Wrapped = struct {
    owner: ?*c.godot_object,
    type_tag: usize,
};
