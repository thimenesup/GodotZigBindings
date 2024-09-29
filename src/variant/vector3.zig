const std = @import("std");
const stdinf = std.math.inf(f32);
const epsilon = std.math.epsilon(f32);
const atan2 = std.math.atan2;

const math = @import("../core/math.zig");

const Basis = @import("basis.zig").Basis;

pub const Vector3 = extern struct {

    const T = f32;

    x: T,
    y: T,
    z: T,

    const Self = @This();

    const Axis = enum {
        axis_x,
        axis_y,
        axis_z,
        axis_count,
    };

    pub const zero = Vector3.new(0, 0, 0);
    pub const one = Vector3.new(1, 1, 1);
    pub const inf = Vector3.new(stdinf, stdinf, stdinf);

    pub const left = Vector3.new(-1, 0, 0);
    pub const right = Vector3.new(1, 0, 0);
    pub const up = Vector3.new(0, -1, 0);
    pub const down = Vector3.new(0, 1, 0);
    pub const forward = Vector3.new(0, 0, -1);
    pub const back = Vector3.new(0, 0, 1);

    pub inline fn new(p_x: T, p_y: T, p_z: T) Self {
        const self = Self {
            .x = p_x,
            .y = p_y,
            .z = p_z,
        };

        return self;
    }

    pub inline fn axis(self: *const Self, p_axis: usize) *T { // Operator []
        switch (p_axis) {
            0 => {
                return &self.x;
            },
            1 => {
                return &self.y;
            },
            else => {
                return &self.z;
            },
        }
    }

    pub inline fn plus(self: *const Self, other: *const Vector3) Self { // Operator +
        return Vector3.new(self.x + other.x, self.y + other.y, self.z + other.z);
    }

    pub inline fn plusAssign(self: *Self, other: *const Vector3) void { // Operator +=
        self.x += other.x;
        self.y += other.y;
        self.z += other.z;
    }

    pub inline fn minus(self: *const Self, other: *const Vector3) Self { // Operator -
        return Vector3.new(self.x - other.x, self.y - other.y, self.z - other.z);
    }

    pub inline fn minusAssign(self: *Self, other: *const Vector3) void { // Operator -=
        self.x -= other.x;
        self.y -= other.y;
        self.z -= other.z;
    }

    pub inline fn mul(self: *const Self, other: *const Vector3) Self { // Operator *
        return Vector3.new(self.x * other.x, self.y * other.y, self.z * other.z);
    }

    pub inline fn mulAssign(self: *Self, other: *const Vector3) void { // Operator *=
        self.x *= other.x;
        self.y *= other.y;
        self.z *= other.z;
    }

    pub inline fn mulScalar(self: *const Self, scalar: T) Self { // Operator *
        return Vector3.new(self.x * scalar, self.y * scalar, self.z * scalar);
    }

    pub inline fn mulAssignScalar(self: *Self, scalar: T) void { // Operator *=
        self.x *= scalar;
        self.y *= scalar;
        self.z *= scalar;
    }

    pub inline fn div(self: *const Self, other: *const Vector3) Self { // Operator /
        return Vector3.new(self.x / other.x, self.y / other.y, self.z / other.z);
    }

    pub inline fn divAssign(self: *Self, other: *const Vector3) void { // Operator /=
        self.x /= other.x;
        self.y /= other.y;
        self.z /= other.z;
    }

    pub inline fn divScalar(self: *const Self, scalar: T) Self { // Operator /
        return Vector3.new(self.x / scalar, self.y / scalar, self.z / scalar);
    }

    pub inline fn divAssignScalar(self: *Self, scalar: T) void { // Operator /=
        self.x /= scalar;
        self.y /= scalar;
        self.z /= scalar;
    }

    pub inline fn negative(self: *const Self) Self { // Operator -x
        return Vector3.new(-self.x, -self.y, -self.z);
    }

    pub inline fn equal(self: *const Self, other: *const Vector3) bool { // Operator ==
        return self.x == other.x and self.y == other.y and self.z == other.z;
    }

    pub inline fn notEqual(self: *const Self, other: *const Vector3) bool { // Operator !=
        return self.x != other.x or self.y != other.y or self.z != other.z;
    }

    pub inline fn less(self: *const Self, other: *const Vector3) bool { // Operator <
        if (self.x == other.x) {
            if (self.y == other.y) {
                return self.z < other.z;
            }
            else {
                return self.y < other.y;
            }
        }
        else {
            return self.x < other.x;
        }
    }

    pub inline fn lessEqual(self: *const Self, other: *const Vector3) bool { // Operator <=
        if (self.x == other.x) {
            if (self.y == other.y) {
                return self.z <= other.z;
            }
            else {
                return self.y < other.y;
            }
        }
        else {
            return self.x < other.x;
        }
    }

    pub inline fn more(self: *const Self, other: *const Vector3) bool { // Operator >
        return !lessEqual(self, other);
    }

    pub inline fn moreEqual(self: *const Self, other: *const Vector3) bool { // Operator >=
        return !less(self, other);
    }

    pub inline fn abs(self: *const Self) Self {
        return Vector3.new(@abs(self.x), @abs(self.y), @abs(self.z));
    }

    pub inline fn ceil(self: *const Self) Self {
        return Vector3.new(@ceil(self.x), @ceil(self.y), @ceil(self.z));
    }

    pub inline fn cross(self: *const Self, other: *const Vector3) Self {
        const x = (self.y * other.z) - (self.z * other.y);
        const y = (self.z * other.x) - (self.x * other.z);
        const z = (self.x * other.y) - (self.y * other.x);
        return Vector3.new(x, y, z);
    }

    pub inline fn linearInterpolate(self: *const Self, other: *const Vector3, t: T) Self {
        const x = self.x + (t * (other.x - self.x));
        const y = self.y + (t * (other.y - self.y));
        const z = self.z + (t * (other.z - self.z));
        return Vector3.new(x, y, z);
    }

    pub inline fn slerp(self: *const Self, other: *const Vector3, t: T) Self {
        const theta = self.angleTo(other);
        return self.rotated(self.cross(other).normalized(), theta * t);
    }

    pub inline fn moveToward(self: *const Self, to: *const Vector3, delta: T) Self {
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

    pub inline fn bounce(self: *const Self, normal: *const Vector3) Self {
        return negative(self.reflect(normal));
    }

    pub inline fn length(self: *const Self) T {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    pub inline fn lengthSquared(self: *const Self) T {
        return self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub inline fn distanceTo(self: *const Self, other: *const Vector3) T {
        const x = self.x - other.x;
        const y = self.y - other.y;
        const z = self.z - other.z;
        return @sqrt(x * x + y * y + z * z);
    }

    pub inline fn distanceSquaredTo(self: *const Self, other: *const Vector3) T {
        const x = self.x - other.x;
        const y = self.y - other.y;
        const z = self.z - other.z;
        return x * x + y * y + z * z;
    }

    pub inline fn dot(self: *const Self, other: *const Vector3) T {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub inline fn project(self: *const Self, other: *const Vector3) Self {
        return other.mul(self.dot(other).div(other.lengthSquared()));
    }

    pub inline fn angleTo(self: *const Self, other: *const Vector3) T {
        return atan2(self.cross(other).length(), self.dot(other));
    }

    pub inline fn directionTo(self: *const Self, other: *const Vector3) Self {
        var ret = Vector3.new(other.x - self.x, other.y - self.y, other.z - self.z);
        ret.normalize();
        return ret;
    }

    pub inline fn floor(self: *const Self) Self {
        return Vector3.new(@floor(self.x), @floor(self.y), @floor(self.z));
    }

    pub inline fn inverse(self: *const Self) Self {
        return Vector3.new(1.0 / self.x, 1.0 / self.y, 1.0 / self.z);
    }

    pub inline fn isNormalized(self: *const Self) bool {
        return @abs(self.lengthSquared() - 1.0) < 0.00001;
    }

    pub inline fn maxAxis(self: *const Self) i32 {
        if (self.x < self.y) {
            if (self.y < self.z) {
                return 2;
            }
            else {
                return 1;
            }
        }
        else {
            if (self.x < self.z) {
                return 2;
            }
            else {
                return 0;
            }
        }
    }

    pub inline fn minAxis(self: *const Self) i32 {
        if (self.x < self.y) {
            if (self.x < self.z) {
                return 0;
            }
            else {
                return 2;
            }
        }
        else {
            if (self.y < self.z) {
                return 1;
            }
            else {
                return 2;
            }
        }
    }

    pub inline fn normalize(self: *Self) void {
        var len = self.x * self.x + self.y * self.y + self.z * self.z;
        if (len != 0) {
            len = @sqrt(len);
            self.x /= len;
            self.y /= len;
            self.z /= len;
        }
    }

    pub inline fn normalized(self: *const Self) Self {
        var ret = self.*;
        ret.normalize();
        return ret;
    }

    pub inline fn reflect(self: *const Self, normal: *const Vector3) Self {
        return negative(self.minus(normal.mulScalar(normal.mulScalar(self.dot(normal)), 2.0)));
    }

    pub inline fn rotated(self: *const Self, p_axis: *const Vector3, phi: T) Self {
        var ret = self.*;
        ret.rotate(p_axis, phi);
        return ret;
    }

    pub inline fn rotate(self: *Self, p_axis: *const Vector3, phi: T) void {
        self.* = Basis.newRotation(p_axis, phi).xformVector3(self);
    }

    pub inline fn slide(self: *const Self, by: *const Vector3) Self {
        return self.minus(by.mulScalar(self.dot(by)));
    }

    pub inline fn snap(self: *Self, by: T) void {
        self.x = math.stepify(self.x, by);
        self.y = math.stepify(self.y, by);
        self.z = math.stepify(self.z, by);
    }

    pub inline fn snapped(self: *const Self, by: T) Self {
        var ret = self.*;
        ret.snap(by);
        return ret;
    }

};
