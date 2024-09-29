const std = @import("std");
const stdinf = std.math.inf(f32);
const epsilon = std.math.epsilon(f32);
const atan2 = std.math.atan2;

const math = @import("../core/math.zig");

pub const Vector2 = extern struct {

    const T = f32;

    x: T,
    y: T,

    const Self = @This();

    const Axis = enum {
        axis_x,
        axis_y,
        axis_count,
    };

    pub const zero = Vector2.new(0, 0);
    pub const one = Vector2.new(1, 1);
    pub const inf = Vector2.new(stdinf, stdinf);

    pub const left = Vector2.new(-1, 0);
    pub const right = Vector2.new(1, 0);
    pub const up = Vector2.new(0, -1);
    pub const down = Vector2.new(0, 1);

    pub inline fn new(p_x: T, p_y: T) Self {
        const self = Self {
            .x = p_x,
            .y = p_y,
        };

        return self;
    }

    pub inline fn axis(self: *const Self, p_axis: usize) *T { // Operator []
        switch (p_axis) {
            0 => {
                return &self.x;
            },
            else => {
                return &self.y;
            },
        }
    }

    pub inline fn plus(self: *const Self, other: *const Vector2) Self { // Operator +
        return Vector2.new(self.x + other.x, self.y + other.y);
    }

    pub inline fn plusAssign(self: *Self, other: *const Vector2) void { // Operator +=
        self.x += other.x;
        self.y += other.y;
    }

    pub inline fn minus(self: *const Self, other: *const Vector2) Self { // Operator -
        return Vector2.new(self.x - other.x, self.y - other.y);
    }

    pub inline fn minusAssign(self: *Self, other: *const Vector2) void { // Operator -=
        self.x -= other.x;
        self.y -= other.y;
    }

    pub inline fn mul(self: *const Self, other: *const Vector2) Self { // Operator *
        return Vector2.new(self.x * other.x, self.y * other.y);
    }

    pub inline fn mulAssign(self: *Self, other: *const Vector2) void { // Operator *=
        self.x *= other.x;
        self.y *= other.y;
    }

    pub inline fn mulScalar(self: *const Self, scalar: T) Self { // Operator *
        return Vector2.new(self.x * scalar, self.y * scalar);
    }

    pub inline fn mulAssignScalar(self: *Self, scalar: T) void { // Operator *=
        self.x *= scalar;
        self.y *= scalar;
    }

    pub inline fn div(self: *const Self, other: *const Vector2) Self { // Operator /
        return Vector2.new(self.x / other.x, self.y / other.y);
    }

    pub inline fn divAssign(self: *Self, other: *const Vector2) void { // Operator /=
        self.x /= other.x;
        self.y /= other.y;
    }

    pub inline fn divScalar(self: *const Self, scalar: T) Self { // Operator /
        return Vector2.new(self.x / scalar, self.y / scalar);
    }

    pub inline fn divAssignScalar(self: *Self, scalar: T) void { // Operator /=
        self.x /= scalar;
        self.y /= scalar;
    }

    pub inline fn negative(self: *const Self) Self { // Operator -x
        return Vector2.new(-self.x, -self.y);
    }

    pub inline fn equal(self: *const Self, other: *const Vector2) bool { // Operator ==
        return self.x == other.x and self.y == other.y;
    }

    pub inline fn notEqual(self: *const Self, other: *const Vector2) bool { // Operator !=
        return self.x != other.x or self.y != other.y;
    }

    pub inline fn less(self: *const Self, other: *const Vector2) bool { // Operator <
        if (self.x == other.x) {
            return self.y < other.y;
        }
        else {
            return self.x < other.x;
        }
    }

    pub inline fn lessEqual(self: *const Self, other: *const Vector2) bool { // Operator <=
        if (self.x == other.x) {
            return self.y <= other.y;
        }
        else {
            return self.x <= other.x;
        }
    }

    pub inline fn more(self: *const Self, other: *const Vector2) bool { // Operator >
        return !lessEqual(self, other);
    }

    pub inline fn moreEqual(self: *const Self, other: *const Vector2) bool { // Operator >=
        return !less(self, other);
    }

    pub inline fn normalize(self: *Self) void {
        var len = self.x * self.x + self.y * self.y;
        if (len != 0) {
            len = @sqrt(len);
            self.x /= len;
            self.y /= len;
        }
    }

    pub inline fn normalized(self: *const Self) Self {
        var ret = self.*;
        ret.normalize();
        return ret;
    }

    pub inline fn length(self: *const Self) T {
        return @sqrt(self.x * self.x + self.y * self.y);
    }

    pub inline fn lengthSquared(self: *const Self) T {
        return self.x * self.x + self.y * self.y;
    }

    pub inline fn distanceTo(self: *const Self, other: *const Vector2) T {
        const x = self.x - other.x;
        const y = self.y - other.y;
        return @sqrt(x * x + y * y);
    }

    pub inline fn distanceSquaredTo(self: *const Self, other: *const Vector2) T {
        const x = self.x - other.x;
        const y = self.y - other.y;
        return x * x + y * y;
    }

    pub inline fn angleTo(self: *const Self, other: *const Vector2) T {
        return atan2(T, self.cross(other), self.dot(other));
    }

    pub inline fn angleToPoint(self: *const Self, other: *const Vector2) T {
        return atan2(T, self.y - other.y, self.x - other.x);
    }

    pub inline fn directionTo(self: *const Self, other: *const Vector2) Self {
        var ret = Vector2.new(other.x - self.x, other.y - self.y);
        ret.normalize();
        return ret;
    }

    pub inline fn dot(self: *const Self, other: *const Vector2) T {
        return self.x * other.x + self.y * other.y;
    }

    pub inline fn cross(self: *const Self, other: *const Vector2) T {
        return self.x * other.x - self.y * other.y;
    }

    pub inline fn crossScalar(self: *const Self, scalar: T) Self {
        return Vector2.new(scalar * self.y, -scalar * self.x);
    }

    pub inline fn project(self: *const Self, other: *const Vector2) Self {
        const a = other.dot(self);
        const b = self.dot(self);
        return self.mulScalar(a / b);
    }

    pub inline fn planeProject(self: *const Self, d: T, other: *const Vector2) Self {
        const a = other.minus(self);
        return a.mulScalar(self.dot(other) - d);
    }

    pub inline fn clamped(self: *const Self, p_len: T) Self {
        const len = self.length();
        var v = self;
        if (len > 0 and p_len < 1) {
            v.divAssignScalar(len);
            v.mulAssignScalar(p_len);
        }
        return v;
    }

    pub inline fn linearInterpolate(self: *const Self, other: *const Vector2, p: T) Self {
        var ret = self.*;
        ret.x += p * (other.x - self.x);
        ret.y += p * (other.y - self.y);
        return ret;
    }

    pub inline fn moveToward(self: *const Self, to: *const Vector2, delta: T) Self {
        const v = self;
        const vd = to.minus(v);
        const len = vd.length();
        if (len <= delta or len < epsilon) {
            return to;
        }
        else {
            return v.plus(vd.divScalar(len * delta));
        }
    }

    pub inline fn slide(self: *const Self, other: *const Vector2) Self {
        return other.minus(self.mulScalar(self.dot(other)));
    }

    pub inline fn bounce(self: *const Self, normal: *const Vector2) Self {
        return negative(self.reflect(normal));
    }

    pub inline fn reflect(self: *const Self, normal: *const Vector2) Self {
        return negative(self.minus(normal).mul(self.dot(normal).mulScalar(2.0)));
    }

    pub inline fn angle(self: *const Self) T {
        return atan2(self.y, self.x);
    }

    pub inline fn setRotation(self: *Self, radians: T) void {
        self.x = @cos(radians);
        self.y = @sin(radians);
    }

    pub inline fn abs(self: *const Self) Self {
        return Vector2.new(@abs(self.x), @abs(self.y));
    }

    pub inline fn rotated(self: *const Self, by: T) Self {
        var ret = self.*;
        ret.setRotation(self.angle() + by);
        ret.mulAssignScalar(self.length());
        return ret;
    }

    pub inline fn tangent(self: *const Self) Self {
        return Vector2.new(self.y, -self.x);
    }

    pub inline fn floor(self: *const Self) Self {
        return Vector2.new(@floor(self.x), @floor(self.y));
    }

    pub inline fn snapped(self: *const Self, by: *const Vector2) Self {
        return Vector2.new(math.stepify(self.x, by.x), math.stepify(self.y, by.y));
    }

    pub inline fn aspect(self: *const Self) T {
        return self.x / self.y;
    }

    pub inline fn cartesian2polar(self: *const Self) Self {
        return Vector2.new(@sqrt(self.x * self.x + self.y * self.y), math.atan2(self.y, self.x));
    }

    pub inline fn polar2cartesian(self: *const Self) Self {
        return Vector2.new(self.x * @cos(self.y), self.x * @sin(self.y));
    }

};
