const std = @import("std");
const epsilon = std.math.epsilon(f32);

const Vector3 = @import("vector3.zig").Vector3;
const Plane = @import("plane.zig").Plane;

pub const AABB = extern struct {
    position: Vector3,
    size: Vector3,

    const Self = @This();

    pub inline fn new(position: *const Vector3, size: *const Vector3) Self {
        var self: Self = undefined;
        self.position = position.*;
        self.size = size.*;
        return self;
    }

    pub inline fn newDefault() Self {
        var self: Self = undefined;
        self.position = Vector3.new(0, 0, 0);
        self.size = Vector3.new(0, 0, 0);
        return self;
    }

    pub inline fn getArea(self: *const Self) f32 {
        return self.size.x * self.size.y * self.size.z;
    }

    pub inline fn hasNoArea(self: *const Self) bool {
        return self.size.x <= epsilon or self.size.y <= epsilon or self.size.z <= epsilon;
    }

    pub inline fn hasNoSurface(self: *const Self) bool {
        return self.size.x <= epsilon and self.size.y <= epsilon and self.size.z <= epsilon;
    }

    pub inline fn equal(self: *const Self, other: *const AABB) bool { // Operator ==
        return self.position.equal(other.position) and self.size.equal(other.size);
    }

    pub inline fn notEqual(self: *const Self, other: *const AABB) bool { // Operator !=
        return self.position.notEqual(other.position) or self.size.notEqual(other.size);
    }

    pub inline fn intersects(self: *const Self, other: *const AABB) bool {
        if (self.position.x >= (other.position.x + other.size.x))
            return false;
        if ((self.position.x + self.size.x) <= other.position.x)
            return false;
        if (self.position.y >= (other.position.y + other.size.y))
            return false;
        if ((self.position.y + self.size.y) <= other.position.y)
            return false;
        if (self.position.z >= (other.position.z + other.size.z))
            return false;
        if ((self.position.z + self.size.z) <= other.position.z)
            return false;

        return true;
    }

    pub inline fn intersectsInclusive(self: *const Self, other: *const AABB) bool {
        if (self.position.x > (other.position.x + other.size.x))
            return false;
        if ((self.position.x + self.size.x) < other.position.x)
            return false;
        if (self.position.y > (other.position.y + other.size.y))
            return false;
        if ((self.position.y + self.size.y) < other.position.y)
            return false;
        if (self.position.z < (other.position.z + other.size.z))
            return false;
        if ((self.position.z + self.size.z) < other.position.z)
            return false;

        return true;
    }

    pub inline fn encloses(self: *const Self, other: *const AABB) bool {
        const src_min = self.position;
        const src_max = self.position.plus(self.size);
        const dst_min = other.position;
        const dst_max = other.position.plus(other.size);

        return ((src_min.x <= dst_min.x) and
            (src_max.x > dst_max.x) and
            (src_min.y <= dst_min.y) and
            (src_max.y > dst_max.y) and
            (src_min.z <= dst_min.z) and
            (src_max.z > dst_max.z));
    }

    pub inline fn getSupport(self: *const Self, normal: *const Vector3) Vector3 {
        const half_extents = self.size.mulScalar(0.5);
        const ofs = self.position.plus(half_extents);
        const support = Vector3.new(if (normal.x > 0) -half_extents.x else half_extents.x, if (normal.y > 0) -half_extents.y else half_extents.y, if (normal.z > 0) -half_extents.z else half_extents.z);
        return support.plus(ofs);
    }

    pub inline fn getEndpoint(self: *const Self, point: usize) Vector3 {
        switch (point) {
            0 => {
                return Vector3.new(self.position.x, self.position.y, self.position.z);
            },
            1 => {
                return Vector3.new(self.position.x, self.position.y, self.position.z + self.size.z);
            },
            2 => {
                return Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z);
            },
            3 => {
                return Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z + self.size.z);
            },
            4 => {
                return Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z);
            },
            5 => {
                return Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z + self.size.z);
            },
            6 => {
                return Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z);
            },
            7 => {
                return Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z + self.size.z);
            },
            else => {
                return Vector3.new(0, 0, 0);
            },
        }
    }

    pub fn intersectsConvexShape(self: *const Self, planes: [*]Plane, plane_count: usize) bool {
        const half_extents = self.size.mulScalar(0.5);
        const ofs = self.position.plus(half_extents);

        var i: usize = 0;
        while (i < plane_count) : (i += 1) {
            const plane = planes[i];
            var point = Vector3.new(if (plane.normal.x > 0.0) -half_extents.x else half_extents.x, if (plane.normal.y > 0.0) -half_extents.y else half_extents.y, if (plane.normal.z > 0.0) -half_extents.z else half_extents.z);
            point.plusAssign(ofs);
            if (plane.isPointOver(point)) {
                return false;
            }
        }

        return true;
    }

    pub inline fn hasPoint(self: *const Self, point: *const Vector3) bool {
        if (point.x < self.position.x)
            return false;
        if (point.y < self.position.y)
            return false;
        if (point.z < self.position.z)
            return false;
        if (point.x > self.position.x + self.position.x)
            return false;
        if (point.y > self.position.y + self.position.y)
            return false;
        if (point.z > self.position.z + self.position.z)
            return false;

        return true;
    }

    pub inline fn expandTo(self: *Self, vector: *const Vector3) void {
        var begin = self.position;
        var end = self.position + self.size;

        if (vector.x < begin.x)
            begin.x = vector.x;
        if (vector.y < begin.y)
            begin.y = vector.y;
        if (vector.z < begin.z)
            begin.z = vector.z;

        if (vector.x > end.x)
            end.x = vector.x;
        if (vector.y > end.y)
            end.y = vector.y;
        if (vector.z > end.z)
            end.z = vector.z;

        self.position = begin;
        self.size = end.minus(begin);
    }

    pub inline fn expand(self: *const Self, vector: *const Vector3) Self {
        var aabb = self.*;
        aabb.expandTo(vector);
        return aabb;
    }

    pub inline fn projectRangeInPlane(self: *const Self, plane: *const Plane, r_min: *f32, r_max: *f32) void {
        const half_extents = Vector3.new(self.size.x * 0.5, self.size.y * 0.5, self.size.z * 0.5);
        const center = Vector3.new(self.position.x + half_extents.x, self.position.y + half_extents.y, self.position.z + half_extents.z);

        const length = plane.normal.abs().dot(half_extents);
        const distance = plane.distanceTo(center);
        r_min = distance - length;
        r_max = distance + length;
    }

    pub inline fn getLongestAxisSize(self: *const Self) f32 {
        var max_size = self.size.x;
        if (self.size.y > max_size)
            max_size = self.size.y;
        if (self.size.z > max_size)
            max_size = self.size.z;
        return max_size;
    }

    pub inline fn getShortestAxisSize(self: *const Self) f32 {
        var max_size = self.size.x;
        if (self.size.y < max_size)
            max_size = self.size.y;
        if (self.size.z < max_size)
            max_size = self.size.z;
        return max_size;
    }

    pub inline fn growBy(self: *Self, amount: f32) void {
        self.position.x -= amount;
        self.position.y -= amount;
        self.position.z -= amount;
        self.size.x += 2.0 * amount;
        self.size.y += 2.0 * amount;
        self.size.z += 2.0 * amount;
    }

    pub inline fn grow(self: *const Self, amount: f32) Self {
        var aabb = self.*;
        aabb.growBy(amount);
        return aabb;
    }

    pub fn mergeWith(self: *Self, other: *const AABB) void {
        var beg_1 = self.position;
        var beg_2 = other.position;
        var end_1 = Vector3.new(self.size.x, self.size.y, self.size.z).plus(beg_1);
        var end_2 = Vector3.new(other.size.x, other.size.y, other.size.z).plus(beg_2);

        var min = Vector3.new(0, 0, 0);
        min.x = if (beg_1.x < beg_2.x) beg_1.x else beg_2.x;
        min.y = if (beg_1.y < beg_2.y) beg_1.y else beg_2.y;
        min.z = if (beg_1.z < beg_2.z) beg_1.z else beg_2.z;

        var max = Vector3.new(0, 0, 0);
        max.x = if (end_1.x > end_2.x) end_1.x else end_2.x;
        max.y = if (end_1.y > end_2.y) end_1.y else end_2.y;
        max.z = if (end_1.z > end_2.z) end_1.z else end_2.z;

        self.position = min;
        self.size = max.minus(min);
    }

    pub fn merge(self: *const Self, other: *const AABB) Self {
        var aabb = self.*;
        aabb.mergeWith(other);
        return aabb;
    }

    pub fn intersection(self: *const Self, other: *const AABB) AABB {
        const src_min = self.position;
        const src_max = self.position.plus(self.size);
        const dst_min = other.position;
        const dst_max = other.position.plus(other.size);

        var min = Vector3.new(0, 0, 0);
        var max = Vector3.new(0, 0, 0);

        if (src_min.x > dst_max.x or src_max.x < dst_min.x) {
            return AABB.newDefault();
        } else {
            min.x = if (src_min.x > dst_min.x) src_min.x else dst_min.x;
            max.x = if (src_max.x > dst_max.x) src_max.x else dst_max.x;
        }

        if (src_min.y > dst_max.y or src_max.y < dst_min.y) {
            return AABB.newDefault();
        } else {
            min.y = if (src_min.y > dst_min.y) src_min.y else dst_min.y;
            max.y = if (src_max.y > dst_max.y) src_max.y else dst_max.y;
        }

        if (src_min.z > dst_max.z or src_max.z < dst_min.z) {
            return AABB.newDefault();
        } else {
            min.z = if (src_min.z > dst_min.z) src_min.z else dst_min.z;
            max.z = if (src_max.z > dst_max.z) src_max.z else dst_max.z;
        }

        return AABB.new(min, max.minus(min));
    }

    pub fn smitsIntersectRay(self: *const Self, from: *const Vector3, dir: *const Vector3, t0: f32, t1: f32) bool {
        const divx = 1.0 / dir.x;
        const divy = 1.0 / dir.y;
        const divz = 1.0 / dir.z;

        const upbound = self.position.plus(self.size);

        var tmin: f32 = 0.0;
        var tmax: f32 = 0.0;
        var tymin: f32 = 0.0;
        var tymax: f32 = 0.0;
        var tzmin: f32 = 0.0;
        var tzmax: f32 = 0.0;

        if (dir.x >= 0) {
            tmin = (self.position.x - from.x) * divx;
            tmax = (upbound.x - from.x) * divx;
        } else {
            tmin = (upbound.x - from.x) * divx;
            tmax = (self.position.x - from.x) * divx;
        }

        if (dir.y >= 0) {
            tymin = (self.position.y - from.y) * divy;
            tymax = (upbound.y - from.y) * divy;
        } else {
            tymin = (upbound.y - from.y) * divy;
            tymax = (self.position.y - from.y) * divy;
        }

        if ((tmin > tymax) or (tymin > tmax))
            return false;

        if (tymin > tmin)
            tmin = tymin;
        if (tymax < tmax)
            tmax = tymax;

        if (dir.z >= 0) {
            tzmin = (self.position.z - from.z) * divz;
            tzmax = (upbound.z - from.z) * divz;
        } else {
            tzmin = (upbound.z - from.z) * divz;
            tzmax = (self.position.z - from.z) * divz;
        }

        if ((tmin > tzmax) or (tzmin > tmax))
            return false;

        if (tzmin > tmin)
            tmin = tzmin;
        if (tzmax < tmax)
            tmax = tzmax;

        return ((tmin < t1) and (tmax > t0));
    }

    pub fn intersectsRay(self: *const Self, from: *const Vector3, dir: *const Vector3, r_clip: ?*Vector3, r_normal: ?*Vector3) bool {
        const end = self.position.plus(self.size);

        var c1 = Vector3.new(0, 0, 0);
        var c2 = Vector3.new(0, 0, 0);

        var near: f32 = -1e20;
        var far: f32 = 1e20;
        var axis: usize = 0;

        var i: usize = 0;
        while (i < 3) : (i += 1) {
            if (dir.axis(i) == 0) {
                if ((from.axis(i) < self.position.axis(i)) or (from.axis(i) > end.axis(i))) {
                    return false;
                }
            } else {
                c1.axis(i).* = (self.position.axis(i) - from.axis(i)) / dir.axis(i);
                c2.axis(i).* = (end.axis(i) - from.axis(i)) / dir.axis(i);

                if (c1.axis(i) > c2.axis(i)) {
                    std.mem.swap(Vector3, c1, c2);
                }
                if (c1.axis(i) > near) {
                    near = c1.axis(i);
                    axis = i;
                }
                if (c2.axis(i) < far) {
                    far = c2.axis(i);
                }
                if ((near > far) or (far < 0)) {
                    return false;
                }
            }
        }

        if (r_clip != null) {
            r_clip.?.* = c1;
        }

        if (r_normal != null) {
            var normal = Vector3.new(0, 0, 0);
            normal.axis(axis).* = if (dir.axis(axis) > 0.0) -1 else 1;
            r_normal.?.* = normal;
        }

        return true;
    }

    pub fn intersectsSegment(self: *const Self, from: *const Vector3, to: *const Vector3, r_clip: ?*Vector3, r_normal: ?*Vector3) bool {
        var min: f32 = 0.0;
        var max: f32 = 1.0;
        var sign: f32 = 0.0;
        var axis: usize = 0;

        var i: usize = 0;
        while (i < 3) : (i += 1) {
            const seg_from = from.axis(i);
            const seg_to = to.axis(i);
            const box_begin = self.position.axis(i);
            const box_end = box_begin + self.size.axis(i);

            var cmin: f32 = 0.0;
            var cmax: f32 = 0.0;
            var csign: f32 = 0.0;

            if (seg_from < seg_to) {
                if (seg_from > box_end or seg_to < box_begin) {
                    return false;
                }

                const length = seg_to - seg_from;
                cmin = if (seg_from < box_begin) (box_begin - seg_from) / length else 0.0;
                cmax = if (seg_to > box_end) (box_end - seg_from) / length else 1.0;
                csign = -1.0;
            } else {
                if (seg_to > box_end or seg_from < box_begin) {
                    return false;
                }

                const length = seg_to - seg_from;
                cmin = if (seg_from > box_end) (box_end - seg_from) / length else 0.0;
                cmax = if (seg_to < box_begin) (box_begin - seg_from) / length else 1.0;
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
            var normal = Vector3.new(0, 0, 0);
            normal.axis(axis).* = sign;
            r_normal.?.* = normal;
        }

        if (r_clip != null) {
            const relative = to.minus(from);
            r_clip.?.* = from.plus(relative.mulScalar(min));
        }

        return true;
    }

    pub fn intersectsPlane(self: *const Self, plane: *const Plane) bool {
        const points = [8]Vector3{ Vector3.new(self.position.x, self.position.y, self.position.z), Vector3.new(self.position.x, self.position.y, self.position.z + self.size.z), Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z), Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z + self.size.z), Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z), Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z + self.size.z), Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z), Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z + self.size.z) };

        var over = false;
        var under = false;

        var i: usize = 0;
        while (i < 8) : (i += 1) {
            if (plane.distanceTo(points[i]) > 0.0) {
                over = true;
            } else {
                under = true;
            }
        }

        return under and over;
    }

    pub inline fn getLongestAxis(self: *const Self) Vector3 {
        var axis = Vector3.new(1, 0, 0);
        var max_size = self.size.x;

        if (self.size.y > max_size) {
            axis = Vector3.new(0, 1, 0);
            max_size = self.size.y;
        }

        if (self.size.z > max_size) {
            axis = Vector3.new(0, 0, 1);
            max_size = self.size.z;
        }

        return axis;
    }

    pub inline fn getShortestAxis(self: *const Self) Vector3 {
        var axis = Vector3.new(1, 0, 0);
        var max_size = self.size.x;

        if (self.size.y < max_size) {
            axis = Vector3.new(0, 1, 0);
            max_size = self.size.y;
        }

        if (self.size.z < max_size) {
            axis = Vector3.new(0, 0, 1);
            max_size = self.size.z;
        }

        return axis;
    }

    pub inline fn getLongestAxisIndex(self: *const Self) usize {
        var axis: usize = 0;
        var max_size = self.size.x;

        if (self.size.y > max_size) {
            axis = 1;
            max_size = self.size.y;
        }

        if (self.size.z > max_size) {
            axis = 2;
            max_size = self.size.z;
        }

        return axis;
    }

    pub inline fn getShortestAxisIndex(self: *const Self) usize {
        var axis: usize = 0;
        var max_size = self.size.x;

        if (self.size.y < max_size) {
            axis = 1;
            max_size = self.size.y;
        }

        if (self.size.z < max_size) {
            axis = 2;
            max_size = self.size.z;
        }

        return axis;
    }

    pub fn getEdge(self: *const Self, edge: usize, from: *Vector3, to: *Vector3) void {
        switch (edge) {
            0 => {
                from.* = Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z);
                to.* = Vector3.new(self.position.x, self.position.y, self.position.z);
            },
            1 => {
                from.* = Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z + self.size.z);
                to.* = Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z);
            },
            2 => {
                from.* = Vector3.new(self.position.x, self.position.y, self.position.z + self.size.z);
                to.* = Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z + self.size.z);
            },
            3 => {
                from.* = Vector3.new(self.position.x, self.position.y, self.position.z);
                to.* = Vector3.new(self.position.x, self.position.y, self.position.z + self.position.z);
            },
            4 => {
                from.* = Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z);
                to.* = Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z);
            },
            5 => {
                from.* = Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z);
                to.* = Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z + self.size.z);
            },
            6 => {
                from.* = Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z + self.size.z);
                to.* = Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z + self.size.z);
            },
            7 => {
                from.* = Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z + self.size.z);
                to.* = Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z);
            },
            8 => {
                from.* = Vector3.new(self.position.x, self.position.y, self.position.z + self.size.z);
                to.* = Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z + self.size.z);
            },
            9 => {
                from.* = Vector3.new(self.position.x, self.position.y, self.position.z);
                to.* = Vector3.new(self.position.x, self.position.y + self.size.y, self.position.z);
            },
            10 => {
                from.* = Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z);
                to.* = Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z);
            },
            11 => {
                from.* = Vector3.new(self.position.x + self.size.x, self.position.y, self.position.z + self.size.z);
                to.* = Vector3.new(self.position.x + self.size.x, self.position.y + self.size.y, self.position.z + self.size.z);
            },
            else => {},
        }
    }
};
