const Vector2 = @import("vector2.zig").Vector2;
const Transform2D = @import("transform2d.zig").Transform2D;

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

    pub inline fn distanceTo(self: *const Self, point: *const Vector2) f32 {
        var dist = 1e20;

        if (point.x < self.position.x) {
            dist = @min(dist, self.position.x - point.x);
        }
        if (point.y < self.position.y) {
            dist = @min(dist, self.position.y - point.y);
        }
        if (point.x >= (self.position.x + self.size.x)) {
            dist = @min(point.x - (self.position.x + self.size.x), dist);
        }
        if (point.y >= (self.position.y + self.size.y)) {
            dist = @min(point.y - (self.position.y + self.size.y), dist);
        }

        if (dist == 1e20) {
            return 0.0;
        }
        else {
            return dist;
        }
    }

    pub fn intersectsSegment(self: *const Self, from: *const Vector2, to: *const Vector2, r_position: ?*Vector2, r_normal: ?*Vector2) bool {
        var min: f32 = 0.0;
        var max: f32 = 1.0;
        var sign: f32 = 0.0;
        var axis: usize = 0;

        var i: usize = 0;
        while (i < 2) : (i += 1) {
            const seg_from = from.axis(i);
            const seg_to = to.axis(i);
            const box_begin = self.position.axis(i);
            const box_end = box_begin + self.size.axis(i);

            var cmin: f32 = 0.0;
            var cmax: f32 = 0.0;
            var csign: f32 = 0.0;

            if (seg_from < seg_to) {
                if (seg_from > box_end or seg_to < box_begin)
                    return false;
                
                const length = seg_to - seg_from;
                cmin = if (seg_from < box_begin) (box_begin - seg_from) / length else 0.0;
                cmax = if (seg_to > box_end) (box_end - seg_from) / length else 1.0;
                csign = -1.0;
            }
            else {
                if (seg_to > box_end or seg_from < box_begin)
                    return false;
                
                const length = seg_to - seg_from;
                cmin = if (seg_from < box_end) (box_end - seg_from) / length else 0.0;
                cmax = if (seg_to > box_begin) (box_begin - seg_from) / length else 1.0;
                csign = 1.0;
            }

            if (cmin > min) {
                min = cmin;
                axis = i;
                sign = csign;
            }
            if (cmax < max) {
                max = cmax;
            }
            if (max < min) {
                return false;
            }
        }

        if (r_normal != null) {
            var normal = Vector2.new(0, 0);
            normal.axis(axis).* = sign;
            r_normal.?.* = normal;
        }

        if (r_position != null) {
            const relative = to.minus(from);
            r_position.?.* = from.plus(relative.mulScalar(min));
        }

        return true;
    }

    // pub fn intersectsTransformed(self: *const Self, xform: *const Transform2D, other: *const Rect2) bool {
    //     return true; //TODO: No gotos in Zig...
    // }

    pub inline fn encloses(self: *const Self, other: *const Rect2) bool {
        return 
            (other.position.x >= self.position.x) and (other.position.y >= self.position.y) and
            ((other.position.x + other.size.x) < (self.position.x + self.size.x)) and
            ((other.position.y + other.size.y) < (self.position.y + self.size.y));
    }

    pub inline fn hasNoArea(self: *const Self) bool {
        return (self.size.x <= 0 or self.size.y <= 0);
    }

        pub inline fn clip(self: *const Self, other: *const Rect2) Self {
        var new_rect = other.*;

        if (!self.intersects(new_rect))
            return Rect2.new(0, 0, 0, 0);
        
        new_rect.position.x = @max(other.position.x, self.position.x);
        new_rect.position.y = @max(other.position.y, self.position.y);

        const other_end = other.position.plus(other.size);
        const self_end = self.position.plus(self.size);

        new_rect.size.x = @min(other_end.x, self_end.x) - new_rect.position.x;
        new_rect.size.y = @min(other_end.y, self_end.y) - new_rect.position.y;

        return new_rect;
    }

    pub inline fn merge(self: *const Self, other: *const Rect2) Self {
        var new_rect = other.*;

        new_rect.position.x = @min(other.position.x, self.position.x);
        new_rect.position.y = @min(other.position.y, self.position.y);

        new_rect.size.x = @max(other.position.x + other.size.x, self.position.x + self.size.x);
        new_rect.size.y = @max(other.position.y + other.size.y, self.position.y + self.size.y);

        new_rect.size = new_rect.size.minus(new_rect.position);

        return new_rect;
    }

    pub inline fn hasPoint(self: *const Self, point: *const Vector2) bool {
        if (point.x < self.position.x)
            return false;
        if (point.y < self.position.y)
            return false;

        if (point.x >= (self.position.x + self.size.x))
            return false;
        if (point.y >= (self.position.y + self.size.y))
            return false;

        return true;
    }

    pub inline fn noArea(self: *const Self) bool {
        return self.size.x <= 0 or self.size.y <= 0;
    }

    pub inline fn equal(self: *const Self, other: *const Rect2) bool { //Operator ==
        return self.position.equal(other.position) and self.size.equal(other.size);
    }

    pub inline fn notEqual(self: *const Self, other: *const Rect2) bool { //Operator !=
        return self.position.notEqual(other.position) or self.size.notEqual(other.size);
    }

    pub inline fn grow(self: *const Self, by: f32) Self {
        var rect = self.*;
        rect.position.x -= by;
        rect.position.y -= by;
        rect.size.x += by * 2;
        rect.size.y += by * 2;
        return rect;
    }

    pub inline fn expand(self: *const Self, vector: *const Vector2) Self {
        var rect = self.*;
        rect.expandTo(vector);
        return rect;
    }

    pub inline fn expandTo(self: *Self, vector: *const Vector2) void {
        var begin = self.position;
        var end = self.position + self.size;

        if (vector.x < begin.x)
            begin.x = vector.x;
        if (vector.y < begin.y)
            begin.y = vector.y;
        
        if (vector.x > end.x)
            end.x = vector.x;
        if (vector.y > end.y)
            end.y = vector.y;
        
        self.position = begin;
        self.size = end.minus(begin);
    }

};
