const std = @import("std");
const epsilon = std.math.epsilon(f32);

const Vector3 = @import("vector3.zig").Vector3;

pub const Plane = extern struct {

    normal: Vector3,
    d: f32,

    const Self = @This();

    pub inline fn new(normal: *const Vector3, d: f32) Self {
        const self = Self {
            .normal = normal.*,
            .d = d,
        };

        return self;
    }

    pub inline fn normalize(self: *Self) void {
        const len = self.normal.length();
        if (len == 0) {
            self.normal.x = Vector3.new(0, 0, 0);
            self.d = 0;
            return;
        }

        self.normal.divAssignScalar(len);
        self.d /= len;
    }

    pub inline fn normalized(self: *const Self) Self {
        var plane = self.*;
        plane.normalize();
        return plane;
    }

    pub inline fn getAnyPoint(self: *const Self) Vector3 {
        return self.normal * self.d;
    }

    pub inline fn getAnyPerpendicularNormal(self: *const Self) Vector3 {
        const p0 = Vector3.new(1, 0, 0);
        const p1 = Vector3.new(0, 1, 0);

        var p: Vector3 = undefined;

        if (@fabs(self.normal.dot(p0)) > 0.99) {
            p = p1;
        }
        else {
            p = p0;
        }

        p.minusAssign(self.normal.mulScalar(self.normal.dot(p)));
        p.normalize();

        return p;
    }

    pub inline fn intersect3(self: *const Self, plane1: *const Plane, plane2: *const Plane, result: ?*Vector3) Vector3 {
        const plane0 = self;

        const normal0 = plane0.normal;
        const normal1 = plane1.normal;
        const normal2 = plane2.normal;

        const denom = normal0.cross(normal1).dot(normal2);

        if (@fabs(denom) <= epsilon) {
            return false;
        }

        if (result != null) {
            result.* = (
                    (normal1.cross(normal2).mulScalar(plane0.d)) +
                    (normal2.cross(normal0).mulScalar(plane1.d)) +
                    (normal0.cross(normal1).mulScalar(plane2.d))
                ) / denom;
        }

        return true;
    }

    pub inline fn intersectsRay(self: *const Self, from: *const Vector3, dir: *const Vector3, intersection: *Vector3) bool {
        const segment = dir;
        const den = self.normal.dot(segment);

        if (@fabs(den) <= epsilon) {
            return false;
        }

        var dist = (self.normal.dot(from) - self.d) / den;

        if (dist > epsilon) {
            return false;
        }

        dist = -dist;
        intersection.* = from.plus(segment.mulScalar(dist));

        return true;
    }

    pub inline fn intersectsSegment(self: *const Self, begin: *const Vector3, end: *const Vector3, intersection: *Vector3) bool {
        const segment = begin.minus(end);
        const den = self.normal.dot(segment);

        if (@fabs(den) <= epsilon) {
            return false;
        }

        var dist = (self.normal.dot(begin) - self.d) / den;

        if (dist < -epsilon or dist > (1.0 + epsilon)) {
            return false;
        }

        dist = -dist;
        intersection.* = begin.plus(segment.mulScalar(dist));

        return true;
    }

    pub inline fn isAlmostLike(self: *const Self, other: *const Plane) bool {
        return self.normal.dot(other.normal) > epsilon and @fabs(self.d - other.d) < epsilon;
    }

    pub inline fn isPointOver(self: *const Self, point: *const Vector3) bool {
        return self.normal.dot(point) > self.d;
    }

    pub inline fn distanceTo(self: *const Self, point: *const Vector3) bool {
        return self.normal.dot(point) - self.d;
    }

    pub inline fn hasPoint(self: *const Self, point: *const Vector3, p_epsilon: f32) bool {
        var dist = self.normal.dot(point) - self.d;
        dist = @fabs(dist);
        return dist <= p_epsilon;
    }

};
