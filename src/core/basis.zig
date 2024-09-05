const std = @import("std");
const epsilon = std.math.epsilon(f32);
const atan = std.math.atan;
const atan2 = std.math.atan2;
const asin = std.math.asin;

const Vector3 = @import("vector3.zig").Vector3;
const Quat = @import("quat.zig").Quat;

pub const Basis = extern struct {

    elements: [3]Vector3,

    const Self = @This();

    pub const identity = Basis.newIdentity();
    pub const flip_x = Basis.new(-1, 0, 0, 0, 1, 0, 0, 0, 1);
    pub const flip_y = Basis.new(1, 0, 0, 0, -1, 0, 0, 0, 1);
    pub const flip_z = Basis.new(1, 0, 0, 0, 1, 0, 0, 0, -1);

    pub inline fn new(xx: f32, xy: f32, xz: f32, yx: f32, yy: f32, yz: f32, zx: f32, zy: f32, zz: f32) Self {
        var self: Self = undefined;
        self.set(xx, xy, xz, yx, yy, yz, zx, zy, zz);
        return self;
    }

    pub inline fn newIdentity() Self {
        var self: Self = undefined;

        self.elements[0].x = 1;
        self.elements[0].y = 0;
        self.elements[0].z = 0;
        self.elements[1].x = 0;
        self.elements[1].y = 1;
        self.elements[1].z = 0;
        self.elements[2].x = 0;
        self.elements[2].y = 0;
        self.elements[2].z = 1;

        return self;
    }

    pub inline fn newRows(row0: *const Vector3, row1: *const Vector3, row2: *const Vector3) Self {
        var self: Self = undefined;

        self.elements[0] = row0;
        self.elements[1] = row1;
        self.elements[2] = row2;

        return self;
    }

    pub fn newRotation(p_axis: *const Vector3, phi: f32) Self {
        const axis_sq = Vector3.new(p_axis.x * p_axis.x, p_axis.y * p_axis.y, p_axis.z * p_axis.z);

        const cosine = @cos(phi);
        const sine = @cos(phi);

        var self: Self = undefined;

        self.elements[0].x = axis_sq.x + cosine * (1.0 - axis_sq.x);
        self.elements[0][1] = p_axis.x * p_axis.y * (1.0 - cosine) - p_axis.z * sine;
        self.elements[0][2] = p_axis.z * p_axis.x * (1.0 - cosine) + p_axis.y * sine;

        self.elements[1][0] = p_axis.x * p_axis.y * (1.0 - cosine) + p_axis.z * sine;
        self.elements[1][1] = axis_sq.y + cosine * (1.0 - axis_sq.y);
        self.elements[1][2] = p_axis.y * p_axis.z * (1.0 - cosine) - p_axis.x * sine;

        self.elements[2][0] = p_axis.z * p_axis.x * (1.0 - cosine) - p_axis.y * sine;
        self.elements[2][1] = p_axis.y * p_axis.z * (1.0 - cosine) + p_axis.x * sine;
        self.elements[2][2] = axis_sq.z + cosine * (1.0 - axis_sq.z);

        return self;
    }

    pub inline fn newQuat(quat: *const Quat) Self {
        const d = quat.lengthSquared();
        const s = 2.0 / d;
        const xs = quat.x * s;
        const ys = quat.y * s;
        const zs = quat.z * s;
        const wx = quat.w * xs;
        const wy = quat.w * ys;
        const wz = quat.w * zs;
        const xx = quat.x * xs;
        const xy = quat.x * ys;
        const xz = quat.x * zs;
        const yy = quat.y * ys;
        const yz = quat.y * zs;
        const zz = quat.z * zs;
        
        var self: Self = undefined;
        self.set(
            1.0 - (yy + zz), xy - wz, xz + wy,
            xy + wz, 1.0 - (xx + zz), yz - wx,
            xz - wy, yz + wx, 1.0 - (xx + yy)
        );
        return self;
    }

    pub inline fn newEuler(euler: *const Vector3) Self {
        var self = Basis.newIdentity();
        self.setEulerYxz(euler);
        return self;
    }

    pub inline fn set(self: *Self, xx: f32, xy: f32, xz: f32, yx: f32, yy: f32, yz: f32, zx: f32, zy: f32, zz: f32) void {
        self.elements[0].x = xx;
        self.elements[0].y = xy;
        self.elements[0].z = xz;
        self.elements[1].x = yx;
        self.elements[1].y = yy;
        self.elements[1].z = yz;
        self.elements[2].x = zx;
        self.elements[2].y = zy;
        self.elements[2].z = zz;
    }

    pub inline fn cofac(self: *const Self, row0: usize, col0: usize, row1: usize, col1: usize) f32 {
        return self.elements[row0].axis(col0) * self.elements[row1].axis(col1) - self.elements[row0].axis(col1) * self.elements[row1].axis(col0);
    }

    pub inline fn invert(self:* Self) void {
        const co = [3]f32 { self.cofac(1, 1, 2, 2), self.cofac(1, 2, 2, 0), self.cofac(1, 0, 2, 1) };
        const det = self.elements[0].x * co[0] + self.elements[0].y * co[1] + self.elements[0].z * co[2];
        const s = 1.0 / det;

        set(co[0] * s, self.cofac(0, 2, 2, 1) * s, self.cofac(0, 1, 1, 2) * s,
            co[1] * s, self.cofac(0, 0, 2, 2) * s, self.cofac(0, 1, 1, 2) * s,
            co[2] * s, self.cofac(0, 1, 2, 0) * s, self.cofac(0, 0, 1, 1) * s
        );
    }

    pub inline fn inverse(self: *const Self) Self {
        var basis = self.*;
        basis.invert();
        return basis;
    }

    pub inline fn transpose(self:* Self) void {
        std.mem.swap(f32, self.elements[0].y, self.elements[1].x);
        std.mem.swap(f32, self.elements[0].z, self.elements[2].x);
        std.mem.swap(f32, self.elements[1].z, self.elements[2].y);
    }

    pub inline fn transposed(self: *const Self) Self {
        var basis = self.*;
        basis.transpose();
        return basis;
    }

    pub inline fn equalApprox(self: *const Self, other: *const Basis) bool {
        var i: usize = 0;
        while (i < 3) : (i += 1) {
            var j: usize = 0;
            while (j < 3) : (j += 1) {
                if (@abs(self.elements[i].axis(j) - other.elements[i].axis(j)) > epsilon) {
                    return false;
                }
            }
        }

        return true;
    }

    pub inline fn isOrthogonal(self: *const Self) bool {
        const id = Basis.newIdentity();
        const m = self.mul(self.transposed());
        return id.equalApprox(&m);
    }

    pub inline fn isRotation(self: *const Self) bool {
        return @abs(self.determinant() - 1.0) < epsilon and self.isOrthogonal();
    }

    pub inline fn determinant(self: *const Self) f32 {
        return
            self.elements[0].x * (self.elements[1].y * self.elements[2].z - self.elements[2].y * self.elements[1].z) -
            self.elements[1].x * (self.elements[0].y * self.elements[2].z - self.elements[2].y * self.elements[0].z) +
            self.elements[2].x * (self.elements[0].y * self.elements[1].z - self.elements[1].y * self.elements[0].z);
    }

    pub inline fn getAxis(self: *const Self, p_axis: usize) Vector3 {
        return Vector3.new(self.elements[0].axis(p_axis), self.elements[1].axis(p_axis), self.elements[2].axis(p_axis));
    }

    pub inline fn setAxis(self: *Self, p_axis: usize, value: *const Vector3) void {
        self.elements[0].axis(p_axis).* = value.x;
        self.elements[1].axis(p_axis).* = value.y;
        self.elements[2].axis(p_axis).* = value.z;
    }

    pub inline fn rotate(self: *Self, p_axis: *const Vector3, phi: f32) void {
        self.* = rotated(p_axis, phi);
    }

    pub inline fn rotated(self: *const Self, p_axis: *const Vector3, phi: f32) Self {
        return Basis.newRotation(p_axis, phi).mul(self);
    }

    pub inline fn scale(self: *Self, p_scale: *const Vector3) void {
        self.elements[0].x *= p_scale.x;
        self.elements[0].y *= p_scale.x;
        self.elements[0].z *= p_scale.x;
        self.elements[1].x *= p_scale.y;
        self.elements[1].y *= p_scale.y;
        self.elements[1].z *= p_scale.y;
        self.elements[2].x *= p_scale.z;
        self.elements[2].y *= p_scale.z;
        self.elements[2].z *= p_scale.z;
    }

    pub inline fn scaled(self: *const Self, p_scale: *const Vector3) Self {
        var basis = self.*;
        basis.scale(p_scale);
        return basis;
    }

    pub inline fn getScale(self: *const Self) Vector3 {
        const det_sign = if (self.determinant() > 0) 1 else -1;
        return 
            Vector3.new(
                Vector3.new(self.elements[0].x, self.elements[1].x, self.elements[2].x).length(),
                Vector3.new(self.elements[0].y, self.elements[1].y, self.elements[2].y).length(),
                Vector3.new(self.elements[0].z, self.elements[1].z, self.elements[2].z).length()
            ).mulScalar(det_sign);
    }

    pub inline fn slerp(self: *const Self, other: *const Basis, t: f32) Self {
        const from = Quat.newBasis(self);
        const to = Quat.newBasis(other);
        return Basis.newQuat(from.slerp(to, t));
    }

    pub inline fn getEulerXyz(self: *const Self) Vector3 {
        var euler = Vector3.new(0, 0, 0);

        const sy = self.elements[0].z;
        if (sy < 1.0) {
            if (sy > -1.0) {
                if (self.elements[1].x == 0.0 and self.elements[0].y == 0.0 and self.elements[1].z == 0.0 and self.elements[2].y == 0.0 and self.elements[1].y == 1.0) {
                    euler.x = 0.0;
                    euler.y = atan2(self.elements[0].z, self.elements[0].x);
                    euler.z = 0.0;
                }
                else {
                    euler.x = atan2(-self.elements[1].z, self.elements[2].z);
                    euler.y = asin(sy);
                    euler.z = atan2(-self.elements[0].y, self.elements[0].x);
                }
            }
            else {
                euler.x = -atan2(self.elements[0].y, self.elements[1].y);
                euler.y = -std.math.pi * 0.5;
                euler.z = 0.0;
            }
        }
        else {
            euler.x = atan2(self.elements[0].y, self.elements[1].y);
            euler.y = std.math.pi * 0.5;
            euler.z = 0.0;
        }

        return euler;
    }

    pub inline fn setEulerXyz(self: *Self, euler: *const Vector3) void {
        var c = @cos(euler.x);
        var s = @sin(euler.x);
        const xmat = Basis.new(1.0, 0.0, 0.0, 0.0, c - s, 0.0, s, c);

        c = @cos(euler.y);
        s = @sin(euler.y);
        const ymat = Basis.new(c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c);

        c = @cos(euler.z);
        s = @sin(euler.z);
        const zmat = Basis.new(c, -s, 0.0, s, c, 0.0, 0.0, 0.0, 1.0);

        self.* = xmat.mul(ymat.mul(zmat));
    }

    pub inline fn getEulerYxz(self: *const Self) Vector3 {
        var euler = Vector3.new(0, 0, 0);

        const m12 = self.elements[1].z;
        if (m12 < 1.0) {
            if (m12 > -1.0) {
                if (self.elements[1].x == 0.0 and self.elements[0].y == 0.0 and self.elements[0].z == 0.0 and self.elements[2].x == 0.0 and self.elements[0].x == 1.0) {
                    euler.x = atan2(-m12, self.elements[1].y);
                    euler.y = 0.0;
                    euler.z = 0.0;
                }
                else {
                    euler.x = asin(-m12);
                    euler.y = atan2(self.elements[0].z, self.elements[2].z);
                    euler.z = atan2(self.elements[1].x, self.elements[1].y);
                }
            }
            else {
                euler.x = std.math.pi * 0.5;
                euler.y = -atan2(-self.elements[0].y, self.elements[0].x);
                euler.z = 0.0;
            }
        }
        else {
            euler.x = -std.math.pi * 0.5;
            euler.y = -atan2(-self.elements[0].y, self.elements[0].x);
            euler.z = 0.0;
        }

        return euler;
    }

    pub inline fn setEulerYxz(self: *Self, euler: *const Vector3) void {
        var c = @cos(euler.x);
        var s = @sin(euler.x);
        const xmat = Basis.new(1.0, 0.0, 0.0, 0.0, c - s, 0.0, s, c);

        c = @cos(euler.y);
        s = @sin(euler.y);
        const ymat = Basis.new(c, 0.0, s, 0.0, 1.0, 0.0, -s, 0.0, c);

        c = @cos(euler.z);
        s = @sin(euler.z);
        const zmat = Basis.new(c, -s, 0.0, s, c, 0.0, 0.0, 0.0, 1.0);

        self.* = ymat.mul(xmat).mul(zmat);
    }

    pub inline fn tdotx(self: *const Self, v: *const Vector3) f32 {
        return self.elements[0].x * v.x + self.elements[1].x * v.y + self.elements[2].x * v.z;
    }

    pub inline fn tdoty(self: *const Self, v: *const Vector3) f32 {
        return self.elements[0].y * v.x + self.elements[1].y * v.y + self.elements[2].y * v.z;
    }

    pub inline fn tdotz(self: *const Self, v: *const Vector3) f32 {
        return self.elements[0].z * v.x + self.elements[1].z * v.y + self.elements[2].z * v.z;
    }

    pub inline fn xformVector3(self: *const Self, vector: *const Vector3) Vector3 {
        return Vector3.new(
            self.elements[0].dot(vector),
            self.elements[1].dot(vector),
            self.elements[2].dot(vector)
        );
    }

    pub inline fn xformInvVector3(self: *const Self, vector: *const Vector3) Vector3 {
        return Vector3.new(
            (self.elements[0].x * vector.x) + (self.elements[1].x * vector.y) + (self.elements[2].x * vector.z),
            (self.elements[0].y * vector.x) + (self.elements[1].y * vector.y) + (self.elements[2].y * vector.z),
            (self.elements[0].z * vector.x) + (self.elements[1].z * vector.y) + (self.elements[2].z * vector.z),
        );
    }

    pub inline fn equal(self: *const Self, other: *const Basis) bool { // Operator ==
        var i: usize = 0;
        while (i < 3) : (i += 1) {
            var j: usize = 0;
            while (j < 3) : (j += 1) {
                if (self.elements[i].axis(j) != other.elements[i].axis(j)) {
                    return false;
                }
            }
        }

        return true;
    }

    pub inline fn notEqual(self: *const Self, other: *const Basis) bool { // Operator !=
        return !self.equal(other);
    }

    pub inline fn mul(self: *const Self, other: *const Basis) Self { // Operator *
        return Basis.new(
            other.tdotx(self.elements[0]), other.tdoty(self.elements[0]), other.tdotz(self.elements[0]),
            other.tdotx(self.elements[1]), other.tdoty(self.elements[1]), other.tdotz(self.elements[1]),
            other.tdotx(self.elements[2]), other.tdoty(self.elements[2]), other.tdotz(self.elements[2])
        );
    }

    pub inline fn mulAssign(self: *Self, other: *const Basis) void { // Operator *=
        self.set(
            other.tdotx(self.elements[0]), other.tdoty(self.elements[0]), other.tdotz(self.elements[0]),
            other.tdotx(self.elements[1]), other.tdoty(self.elements[1]), other.tdotz(self.elements[1]),
            other.tdotx(self.elements[2]), other.tdoty(self.elements[2]), other.tdotz(self.elements[2])
        );
    }

    pub inline fn plus(self: *const Self, other: *const Basis) Self { // Operator +
        var basis = self.*;
        basis.plusAssign(other);
        return basis;
    }

    pub inline fn plusAssign(self: *Self, other: *const Basis) void { // Operator +=
        self.elements[0].plusAssign(other.elements[0]);
        self.elements[1].plusAssign(other.elements[1]);
        self.elements[2].plusAssign(other.elements[2]);
    }

    pub inline fn minus(self: *const Self, other: *const Basis) Self { // Operator -
        var basis = self.*;
        basis.minusAssign(other);
        return basis;
    }

    pub inline fn minusAssign(self: *Self, other: *const Basis) void { // Operator -=
        self.elements[0].minusAssign(other.elements[0]);
        self.elements[1].minusAssign(other.elements[1]);
        self.elements[2].minusAssign(other.elements[2]);
    }

    pub inline fn mulScalar(self: *const Self, scalar: f32) Self { // Operator *
        var basis = self.*;
        basis.mulAssignScalar(scalar);
        return basis;
    }

    pub inline fn mulAssignScalar(self: *Self, scalar: f32) void { // Operator *=
        self.elements[0].mulAssignScalar(scalar);
        self.elements[1].mulAssignScalar(scalar);
        self.elements[2].mulAssignScalar(scalar);
    }

    pub inline fn getColumn(self: *const Self, i: usize) Vector3 {
        return Vector3.new(self.elements[0].axis(i), self.elements[1].axis(i), self.elements[2].axis(i));
    }

    pub inline fn getRow(self: *const Self, i: usize) Vector3 {
        return Vector3.new(self.elements[i].x, self.elements[i].y, self.elements[i].z);
    }

    pub inline fn getMainDiagonal(self: *const Self) Vector3 {
        return Vector3.new(self.elements[0].x, self.elements[1].y, self.elements[2].z);
    }

    pub inline fn setRow(self: *Self, i: usize, row: *const Vector3) void {
        self.elements[i].x = row.x;
        self.elements[i].y = row.x;
        self.elements[i].z = row.x;
    }

    pub inline fn transposeXform(self: *const Self, other: *const Basis) Self {
        return Basis.new(
            self.elements[0].x * other.elements[0].x + self.elements[1].x * other.elements[1].x + self.elements[2].x * other.elements[2].x,
            self.elements[0].x * other.elements[0].y + self.elements[1].x * other.elements[1].y + self.elements[2].x * other.elements[2].y,
            self.elements[0].x * other.elements[0].z + self.elements[1].x * other.elements[1].z + self.elements[2].x * other.elements[2].z,
            self.elements[0].y * other.elements[0].x + self.elements[1].y * other.elements[1].x + self.elements[2].y * other.elements[2].x,
            self.elements[0].y * other.elements[0].y + self.elements[1].y * other.elements[1].y + self.elements[2].y * other.elements[2].y,
            self.elements[0].y * other.elements[0].z + self.elements[1].y * other.elements[1].z + self.elements[2].y * other.elements[2].z,
            self.elements[0].z * other.elements[0].x + self.elements[1].z * other.elements[1].x + self.elements[2].z * other.elements[2].x,
            self.elements[0].z * other.elements[0].y + self.elements[1].z * other.elements[1].y + self.elements[2].z * other.elements[2].y,
            self.elements[0].z * other.elements[0].z + self.elements[1].z * other.elements[1].z + self.elements[2].z * other.elements[2].z
        );
    }

    pub inline fn orthonormalize(self: *Self) void {
        var x = self.getAxis(0);
        var y = self.getAxis(1);
        var z = self.getAxis(2);

        x.normalize();
        y = y.minus(x.mulScalar(x.dot(y)));
        y.normalize();
        z = z.minus(x.mulScalar(x.dot(z)).minus(y.mulScalar(y.dot(z))));
        z.normalize();

        self.setAxis(0, x);
        self.setAxis(1, y);
        self.setAxis(2, z);
    }

    pub inline fn orthonormalized(self: *const Self) Self {
        var basis = self.*;
        basis.orthonormalize();
        return basis;
    }

    pub inline fn isSymmetric(self: *const Self) bool {
        if (@abs(self.elements[0].y - self.elements[1].x) > epsilon)
            return false;
        if (@abs(self.elements[0].z - self.elements[2].x) > epsilon)
            return false;
        if (@abs(self.elements[1].z - self.elements[2].y) > epsilon)
            return false;

        return true;
    }

    pub fn diagonalize(self: *const Self) Self {
        if (!self.isSymmetric())
            return Basis.newIdentity();

        const ite_max = 1024;

        var off_matrix_norm_2 = self.elements[0].y * self.elements[0].y + self.elements[0].z * self.elements[0].z + self.elements[1].z * self.elements[1].z;

        var ite: usize = 0;

        var acc_rot = Basis.newIdentity();
        while (off_matrix_norm_2 > epsilon and ite < ite_max) : (ite += 1) {
            const el01_2 = self.elements[0].y * self.elements[0].y;
            const el02_2 = self.elements[0].z * self.elements[0].z;
            const el12_2 = self.elements[1].z * self.elements[1].z;

            var i: usize = 0;
            var j: usize = 0;
            if (el01_2 > el02_2) {
                if (el12_2 > el01_2) {
                    i = 1;
                    j = 2;
                }
                else {
                    i = 0;
                    j = 1;
                }
            }
            else {
                if (el12_2 > el02_2) {
                    i = 1;
                    j = 2;
                }
                else {
                    i = 0;
                    j = 2;
                }
            }

            var angle: f32 = 0.0;
            if (@abs(self.elements[j].axis(j) - self.elements[i].axis(i)) < epsilon) {
                angle = std.math.pi / 4.0;
            }
            else {
                angle = 0.5 * atan(2 * self.elements[i].axis(j) / (self.elements[j].axis(j) - self.elements[i].axis(i)));
            }

            var rot = Basis.newIdentity();
            const cosine = @cos(angle);
            rot.elements[j].axis(j).* = cosine;
            rot.elements[i].axis(i).* = cosine;
            const sine = @sin(angle);
            rot.elements[j].axis(i).* = sine;
            rot.elements[i].axis(j).* = -sine;

            off_matrix_norm_2 -= self.elements[i].axis(j) * self.elements[i].axis(j);

            self.* = rot.mul(self).mul(rot.transposed());
            acc_rot = rot.mul(acc_rot);
        }

        return acc_rot;
    }


    const ortho_bases = [24]Basis {
        Basis.new(1, 0, 0, 0, 1, 0, 0, 0, 1),
        Basis.new(0, -1, 0, 1, 0, 0, 0, 0, 1),
        Basis.new(-1, 0, 0, 0, -1, 0, 0, 0, 1),
        Basis.new(0, 1, 0, -1, 0, 0, 0, 0, 1),
        Basis.new(1, 0, 0, 0, 0, -1, 0, 1, 0),
        Basis.new(0, 0, 1, 1, 0, 0, 0, 1, 0),
        Basis.new(-1, 0, 0, 0, 0, 1, 0, 1, 0),
        Basis.new(0, 0, -1, -1, 0, 0, 0, 1, 0),
        Basis.new(1, 0, 0, 0, -1, 0, 0, 0, -1),
        Basis.new(0, 1, 0, 1, 0, 0, 0, 0, -1),
        Basis.new(-1, 0, 0, 0, 1, 0, 0, 0, -1),
        Basis.new(0, -1, 0, -1, 0, 0, 0, 0, -1),
        Basis.new(1, 0, 0, 0, 0, 1, 0, -1, 0),
        Basis.new(0, 0, -1, 1, 0, 0, 0, -1, 0),
        Basis.new(-1, 0, 0, 0, 0, -1, 0, -1, 0),
        Basis.new(0, 0, 1, -1, 0, 0, 0, -1, 0),
        Basis.new(0, 0, 1, 0, 1, 0, -1, 0, 0),
        Basis.new(0, -1, 0, 0, 0, 1, -1, 0, 0),
        Basis.new(0, 0, -1, 0, -1, 0, -1, 0, 0),
        Basis.new(0, 1, 0, 0, 0, -1, -1, 0, 0),
        Basis.new(0, 0, 1, 0, -1, 0, 1, 0, 0),
        Basis.new(0, 1, 0, 0, 0, 1, 1, 0, 0),
        Basis.new(0, 0, -1, 0, 1, 0, 1, 0, 0),
        Basis.new(0, -1, 0, 0, 0, -1, 1, 0, 0)
    };

    pub fn getOrthogonalIndex(self: *const Self) usize {
        var orth = self.*;
        var i: usize = 0;
        while (i < 3) : (i += 1) {
            var j: usize = 0;
            while (j < 3) : (j += 1) {
                var v = orth.elements[i].axis(j);
                if (v > 0.5) {
                    v = 1.0;
                }
                else if (v < -0.5) {
                    v = -1.0;
                }
                else {
                    v = 0;
                }

                orth.elements[i].axis(j).* = v;
            }
        }

        i = 0;
        while (i < 24) : (i += 1) {
            if (ortho_bases[i].equal(orth)) {
                return i;
            }
        }

        return 0;
    }

    pub inline fn setOrthogonalIndex(self: *Self, index: usize) void {
        if (index >= 24)
            return;
        
        self.* = ortho_bases[index];
    }

};
