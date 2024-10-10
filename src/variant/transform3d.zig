const Basis = @import("basis.zig").Basis;
const Vector3 = @import("vector3.zig").Vector3;
const Plane = @import("plane.zig").Plane;
const AABB = @import("aabb.zig").AABB;
const Quaternion = @import("quaternion.zig").Quaternion;

pub const Transform3D = extern struct {

    basis: Basis,
    origin: Vector3,

    const Self = @This();

    pub const identity = Transform3D.newIdentity();
    pub const flip_x = Transform3D.new(-1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0);
    pub const flip_y = Transform3D.new(1, 0, 0, 0, -1, 0, 0, 0, 1, 0, 0, 0);
    pub const flip_z = Transform3D.new(1, 0, 0, 0, 1, 0, 0, 0, -1, 0, 0, 0);

    pub inline fn new(basis: *const Basis, origin: *const Vector3) Self {
        const self = Self {
            .basis = basis.*,
            .origin = origin.*,
        };

        return self;
    }

    pub inline fn newIdentity() Self {
        const self = Self {
            .basis = Basis.newIdentity(),
            .origin = Vector3.new(0, 0, 0),
        };

        return self;
    }

    pub inline fn set(self: *Self, xx: f32, xy: f32, xz: f32, yx: f32, yy: f32, yz: f32, zx: f32, zy: f32, zz: f32, tx: f32, ty: f32, tz: f32) void {
        self.basis.elements[0].x = xx;
        self.basis.elements[0].y = xy;
        self.basis.elements[0].z = xz;
        self.basis.elements[1].x = yx;
        self.basis.elements[1].y = yy;
        self.basis.elements[1].z = yz;
        self.basis.elements[2].x = zx;
        self.basis.elements[2].y = zy;
        self.basis.elements[2].z = zz;
        self.origin.x = tx;
        self.origin.y = ty;
        self.origin.z = tz;
    }

    pub inline fn xformVector3(self: *const Self, vector: *const Vector3) Vector3 {
        return Vector3.new(
            self.basis.elements[0].dot(vector).plus(self.origin.x),
            self.basis.elements[1].dot(vector).plus(self.origin.y),
            self.basis.elements[2].dot(vector).plus(self.origin.z)
        );
    }

    pub inline fn xformInvVector3(self: *const Self, vector: *const Vector3) Vector3 {
        const v = vector.minus(self.origin);
        return Vector3.new(
            (self.basis.elements[0].x * v.x) + (self.basis[1].x + v.y) + (self.basis[2].x * v.z),
            (self.basis.elements[0].y * v.x) + (self.basis[1].y + v.y) + (self.basis[2].y * v.z),
            (self.basis.elements[0].z * v.x) + (self.basis[1].z + v.y) + (self.basis[2].z * v.z)
        );
    }

    pub inline fn xformPlane(self: *const Self, plane: *const Plane) Plane {
        var point = plane.normal.mulScalar(plane.d);
        var point_dir = point.plus(plane.normal);
        point = self.xformVector3(point);
        point_dir = self.xformVector3(point_dir);

        var normal = point_dir.minus(point);
        normal.normalize();
        const d = normal.dot(point);

        return Plane.new(normal, d);
    }

    pub inline fn xformInvPlane(self: *const Self, plane: *const Plane) Plane {
        var point = plane.normal.mulScalar(plane.d);
        var point_dir = point.plus(plane.normal);
        point = self.xformInvVector3(point);
        point_dir = self.xformInvVector3(point_dir);

        var normal = point_dir.minus(point);
        normal.normalize();
        const d = normal.dot(point);

        return Plane.new(normal, d);
    }

    pub inline fn xformAABB(self: *const Self, aabb: *const AABB) AABB {
        const x = self.basis.getAxis(0).mulScalar(aabb.size.x);
        const y = self.basis.getAxis(1).mulScalar(aabb.size.y);
        const z = self.basis.getAxis(2).mulScalar(aabb.size.z);
        const pos = self.xformVector3(aabb.position);

        var new_aabb: AABB = undefined;
        new_aabb.position = pos;
        new_aabb.expandTo(pos.plus(x));
        new_aabb.expandTo(pos.plus(y));
        new_aabb.expandTo(pos.plus(z));
        new_aabb.expandTo(pos.plus(x).plus(y));
        new_aabb.expandTo(pos.plus(x).plus(z));
        new_aabb.expandTo(pos.plus(y).plus(z));
        new_aabb.expandTo(pos.plus(x).plus(y).plus(z));
        return new_aabb;
    }

    pub inline fn xformInvAABB(self: *const Self, aabb: *const AABB) AABB {
        const vertices = [8]Vector3 {
            Vector3.new(aabb.position.x + aabb.size.x, aabb.position.y + aabb.size.y, aabb.position.z + aabb.size.z),
            Vector3.new(aabb.position.x + aabb.size.x, aabb.position.y + aabb.size.y, aabb.position.z),
            Vector3.new(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z + aabb.size.z),
            Vector3.new(aabb.position.x + aabb.size.x, aabb.position.y, aabb.position.z),
            Vector3.new(aabb.position.x, aabb.position.y + aabb.size.y, aabb.position.z + aabb.size.z),
            Vector3.new(aabb.position.x, aabb.position.y + aabb.size.y, aabb.position.z),
            Vector3.new(aabb.position.x, aabb.position.y, aabb.position.z + aabb.size.z),
            Vector3.new(aabb.position.x, aabb.position.y, aabb.position.z)
        };

        var new_aabb: AABB = undefined;
        new_aabb.position = self.xformInvVector3(vertices[0]);

        inline for (vertices) |vertex| {
            new_aabb.expandTo(self.xformInvVector3(vertex));
        }

        return new_aabb;
    }

    pub inline fn affineInvert(self: *Self) void {
        self.basis.invert();
        self.origin = self.basis.xformVector3(self.origin.negative());
    }

    pub inline fn affineInverse(self: *const Self) Self {
        var transform = self.*;
        transform.affineInvert();
        return transform;
    }

    pub inline fn invert(self: *Self) void {
        self.basis.transpose();
        self.origin = self.basis.xformVector3(self.origin.negative());
    }

    pub inline fn inverse(self: *const Self) Self {
        var transform = self.*;
        transform.invert();
        return transform;
    }

    pub inline fn rotate(self: *Self, axis: *const Vector3, phi: f32) void {
        self.* = self.rotated(axis, phi);
    }

    pub inline fn rotated(self: *const Self, axis: *const Vector3, phi: f32) Self {
        return Transform3D.new(Basis.new(axis, phi), Vector3.new(0, 0, 0)).mul(self);
    }

    pub inline fn rotateBasis(self: *Self, axis: *const Vector3, phi: f32) void {
        self.basis.rotate(axis, phi);
    }

    pub inline fn lookingAt(self: *const Self, target: *const Vector3, up: *const Vector3) Self {
        var transform = self.*;
        transform.setLookAt(self.origin, target, up);
        return transform;
    }

    pub inline fn setLookAt(self: *Self, eye: *const Vector3, target: *const Vector3, up: *const Vector3) void {
        var v_z = eye.minus(target);
        v_z.normalize();

        var v_y = up;
        var v_x = v_y.cross(v_z);

        v_y = v_z.cross(v_x);
        v_y.normalize();

        v_x.normalize();

        self.basis.setAxis(0, v_x);
        self.basis.setAxis(1, v_y);
        self.basis.setAxis(2, v_z);

        self.origin = eye;
    }

    pub inline fn interpolateWith(self: *const Self, other: *const Transform3D, p_c: f32) Self {
        const src_scale = self.basis.getScale();
        const src_rot = Quaternion.newBasis(self.basis);
        const src_loc = self.origin;

        const dst_scale = other.basis.getScale();
        const dst_rot = Quaternion.newBasis(other.basis);
        const dst_loc = other.origin;

        var dst = Transform3D.newIdentity();
        dst.basis = src_rot.slerp(dst_rot, p_c);
        dst.basis.scale(src_scale.linearInterpolate(dst_scale), p_c);
        dst.origin = src_loc.linearInterpolate(dst_loc, p_c);
        return dst;
    }

    pub inline fn scale(self: *Self, p_scale: *const Vector3) void {
        self.basis.scale(p_scale);
        self.origin.mulAssign(p_scale);
    }

    pub inline fn scaled(self: *const Self, p_scale: *const Vector3) Self {
        var transform = self.*;
        transform.scale(p_scale);
        return transform;
    }

    pub inline fn scaleBasis(self: *Self, p_scale: *const Vector3) void {
        self.basis.scale(p_scale);
    }

    pub inline fn translate(self: *Self, translation: *const Vector3) void {
        self.origin.x += self.basis.elements[0].dot(translation);
        self.origin.y += self.basis.elements[1].dot(translation);
        self.origin.z += self.basis.elements[2].dot(translation);
    }

    pub inline fn translated(self: *const Self, translation: *const Vector3) Self {
        var transform = self.*;
        transform.translate(translation);
        return transform;
    }

    pub inline fn orthonormalize(self: *Self) void {
        self.basis.orthonormalize();
    }

    pub inline fn orthonormalized(self: *const Self) Self {
        var transform = self.*;
        transform.orthonormalize();
        return transform;
    }

    pub inline fn equal(self: *const Self, other: *const Transform3D) bool { // Operator ==
        return self.basis.equal(other.basis) and self.origin.equal(other.origin);
    }

    pub inline fn notEqual(self: *const Self, other: *const Transform3D) bool { // Operator !=
        return self.basis.notEqual(other.basis) or self.origin.notEqual(other.origin);
    }

    pub inline fn mul(self: *const Self, other: *const Transform3D) Self { // Operator *
        var transform = self.*;
        transform.mulAssign(other);
        return transform;
    }

    pub inline fn mulAssign(self: *Self, other: *const Transform3D) void { // Operator *=
        self.origin = self.xformVector3(other.origin);
        self.basis.mulAssign(other.basis);
    }

};
