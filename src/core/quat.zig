const std = @import("std");
const epsilon = std.math.epsilon(f32);
const acos = std.math.acos;

const Vector3 = @import("vector3.zig").Vector3;
const Basis = @import("basis.zig").Basis;

pub const Quat = struct {

    const T = f32;

    x: T,
    y: T,
    z: T,
    w: T,

    const Self = @This();

    const identity = Quat.newIdentity();

    pub inline fn new(x: T, y: T, z: T, w: T) Self {
        const self = Self {
            .x = x,
            .y = y,
            .z = z,
            .w = w,
        };

        return self;
    }

    pub inline fn newIdentity() Self {
        const self = Self {
            .x = 0,
            .y = 0,
            .z = 0,
            .w = 1,
        };

        return self;
    }


    pub inline fn plus(self: *const Self, other: *const Quat) Self { // Operator +
        return Quat.new(self.x + other.x, self.y + other.y, self.z + other.z, self.w + other.w);
    }

    pub inline fn plusAssign(self: *Self, other: *const Quat) void { // Operator +=
        self.x += other.x;
        self.y += other.y;
        self.z += other.z;
        self.w += other.w;
    }

    pub inline fn minus(self: *const Self, other: *const Quat) Self { // Operator -
        return Quat.new(self.x - other.x, self.y - other.y, self.z - other.z, self.w - other.w);
    }

    pub inline fn minusAssign(self: *Self, other: *const Quat) void { // Operator -=
        self.x -= other.x;
        self.y -= other.y;
        self.z -= other.z;
        self.w -= other.w;
    }

    pub inline fn mul(self: *const Self, other: *const Quat) Self { // Operator *
        var quat = self.*;
        quat.mulAssign(other);
        return quat;
    }

    pub inline fn mulAssign(self: *Self, other: *const Quat) void { // Operator *=
        self.x = self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y;
        self.y = self.w * other.y + self.y * other.w + self.z * other.x - self.x * other.z;
        self.z = self.w * other.z + self.z * other.w + self.x * other.y - self.y * other.x;
        self.w = self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z;
    }

    pub inline fn mulScalar(self: *const Self, scalar: f32) Self { // Operator *
        return Quat.new(self.x * scalar, self.y * scalar, self.z * scalar, self.w * scalar);
    }

    pub inline fn mulAssignScalar(self: *Self, scalar: f32) void { // Operator *=
        self.x *= scalar;
        self.y *= scalar;
        self.z *= scalar;
        self.w *= scalar;
    }

    pub inline fn divScalar(self: *const Self, scalar: f32) Self { // Operator /
        return self.mulScalar(1.0 / scalar);
    }

    pub inline fn divAssignScalar(self: *Self, scalar: f32) void { // Operator /=
        self.* = self.divScalar(scalar);
    }

    pub inline fn negative(self: *const Self) Self { // Operator -x
        return Quat.new(-self.x, -self.y, -self.z, -self.w);
    }

    pub inline fn equal(self: *const Self, other: *const Quat) bool { // Operator ==
        return self.x == other.x and self.y == other.y and self.z == other.z and self.w == other.w;
    }

    pub inline fn notEqual(self: *const Self, other: *const Quat) bool { // Operator !=
        return self.x != other.x or self.y != other.y or self.z != other.z or self.w != other.w;
    }

    pub inline fn setEulerXyz(self: *Self, euler: *const Vector3) void {
        const half_a1 = euler.x * 0.5;
        const half_a2 = euler.y * 0.5;
        const half_a3 = euler.z * 0.5;

        const cos_a1 = @cos(half_a1);
        const sin_a1 = @sin(half_a1);
        const cos_a2 = @cos(half_a2);
        const sin_a2 = @sin(half_a2);
        const cos_a3 = @cos(half_a3);
        const sin_a3 = @sin(half_a3);

        self.x = sin_a1 * cos_a2 * cos_a3 + sin_a2 * sin_a3 * cos_a1;
        self.y = -sin_a1 * sin_a3 * cos_a2 + sin_a2 * cos_a1 * cos_a3;
        self.z = sin_a1 * sin_a2 * cos_a3 + sin_a3 * cos_a1 * cos_a2;
        self.w = -sin_a1 * sin_a2 * sin_a3 + cos_a1 * cos_a2 * cos_a3;
    }

    pub inline fn getEulerXyz(self: *const Self) Vector3 {
        const basis = Basis.newQuat(self);
        return basis.getEulerXyz();
    }

    pub inline fn setEulerYxz(self: *Self, euler: *const Vector3) void {
        const half_a1 = euler.x * 0.5;
        const half_a2 = euler.y * 0.5;
        const half_a3 = euler.z * 0.5;

        const cos_a1 = @cos(half_a1);
        const sin_a1 = @sin(half_a1);
        const cos_a2 = @cos(half_a2);
        const sin_a2 = @sin(half_a2);
        const cos_a3 = @cos(half_a3);
        const sin_a3 = @sin(half_a3);

        self.x = sin_a1 * cos_a2 * sin_a3 + cos_a1 * sin_a2 * cos_a3;
        self.y = sin_a1 * cos_a2 * cos_a3 - cos_a1 * sin_a2 * sin_a3;
        self.z = -sin_a1 * sin_a2 * cos_a3 + cos_a1 * sin_a2 * sin_a3;
        self.w = sin_a1 * sin_a2 * sin_a3 + cos_a1 * cos_a2 * cos_a3;
    }

    pub inline fn getEulerYxz(self: *const Self) Vector3 {
        const basis = Basis.newQuat(self);
        return basis.getEulerYxz();
    }

    pub inline fn dot(self: *const Self, other: *const Quat) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w;
    }

    pub inline fn lengthSquared(self: *const Self) f32 {
        return self.dot(self);
    }

    pub inline fn length(self: *const Self) f32 {
        return @sqrt(self.lengthSquared());
    }

    pub inline fn normalize(self: *Self) void {
        self.divAssignScalar(self.length());
    }

    pub inline fn normalized(self: *const Self) Self {
        var quat = self.*;
        quat.divAssignScalar(quat.length());
        return quat;
    }

    pub inline fn inverse(self: *const Self) Self {
        return Quat.new(-self.x, -self.y, -self.x, self.w);
    }

    pub fn slerp(self: *const Self, q: *const Quat, t: f32) Self {
        var to1: Quat = undefined;

        const cosom = self.dot(q);

        if (cosom < 0.0) {
            cosom = -cosom;
            to1.x = -q.x;
            to1.y = -q.y;
            to1.z = -q.z;
            to1.w = -q.w;
        }
        else {
            to1.x = q.x;
            to1.y = q.y;
            to1.z = q.z;
            to1.w = q.w;
        }

        var omega: f32 = undefined;
        var sinom: f32 = undefined;
        var scale0: f32 = undefined;
        var scale1: f32 = undefined;

        if ((1.0 - cosom) > epsilon) {
            omega = acos(cosom);
            sinom = @sin(omega);
            scale0 = @sin((1.0 - t) * omega) / sinom;
            scale1 = @sin(t * omega) / sinom;
        }
        else {
            scale0 = 1.0 - t;
            scale1 = t;
        }

        return Quat.new(scale0 * self.x + scale1 * to1.x, scale0 * self.y + scale1 * to1.y, scale0 * self.z + scale1 * to1.z, scale0 * self.w + divScalar * to1.w);
    }

    pub fn slerpni(self: *const Self, q: *const Quat, t: f32) Self {
        const from = self.*;

        const d = from.dot(q);

        if (@abs(d) > 0.9999)
            return from;
        
        const theta = acos(d);
        const sinT = 1.0 / @sin(theta);
        const newFactor = @sin(t * theta) * sinT;
        const invFactor = @sin((1.0 - t) * theta) * sinT;

        return Quat.new(invFactor * from.x + newFactor * q.x, invFactor * from.y + newFactor * q.y, invFactor * from.z + newFactor * q.z, invFactor * from.w + newFactor * q.w);
    }

    pub fn cubicSlerp(self: *const Self, q: *const Quat, prep: *const Quat, postq: *const Quat, t: f32) Self {
        const t2 = (1.0 - t) * t * 2;
        const sp = self.slerp(q, t);
        const sq = prep.slerpni(postq, t);
        return sp.slerpni(sq, t2);
    }

    pub fn getAxisAndAngle(self: *const Self, axis: *Vector3, angle: *f32) void {
        angle = 2.0 * acos(self.w);
        axis.x = self.x / @sqrt(1.0 - self.w * self.w);
        axis.y = self.y / @sqrt(1.0 - self.w * self.w);
        axis.z = self.z / @sqrt(1.0 - self.w * self.w);
    }

    pub fn setAxisAndAngle(self: *Self, axis: *const Vector3, angle: f32) void {
        const d = axis.length();

        if (d == 0) {
            self.x = 0;
            self.y = 0;
            self.z = 0;
            self.w = 0;
        }
        else {
            const sin_angle = @sin(angle * 0.5);
            const cos_angle = @cos(angle * 0.5);
            const s = sin_angle / d;
            self.x = axis.x * s;
            self.y = axis.y * s;
            self.z = axis.z * s;
            self.w = cos_angle;
        }
    }

};
