const Vector2 = @import("vector2.zig").Vector2;

pub const Rect2 = extern struct {

    const T = f32;

    position: Vector2,
    size: Vector2,

    const Self = @This();

    pub inline fn new(p_x: T, p_y: T, s_x: T, s_y: T) Self {
        const self = Self {
            .position = Vector2.new(p_x, p_y),
            .size = Vector2.new(s_x, s_y),
        };

        return self;
    }

    pub inline fn getArea(self: *const Self) T {
        return self.size.x * self.size.y;
    }

    pub inline fn intersects(self: *const Self, other: *const Rect2) bool {
        if (self.position.x >= other.position.x + other.size.x)
            return false;
        if (self.position.x + other.size.x <= other.position.x)
            return false;
        if (self.position.y >= other.position.y + other.size.y)
            return false;
        if (self.position.y + self.size.y <= other.position.y)
            return false;

        return true;
    }

};
