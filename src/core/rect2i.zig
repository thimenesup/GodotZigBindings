const Vector2i = @import("vector2i.zig").Vector2i;

pub const Rect2i = extern struct {

    const T = i32;

    position: Vector2i,
    size: Vector2i,

    const Self = @This();

};
