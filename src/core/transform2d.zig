const std = @import("std");
const acos = std.math.acos;
const atan2 = std.math.atan2;

const Vector2 = @import("vector2.zig").Vector2;
const Rect2 = @import("rect2.zig").Rect2;

pub const Transform2D = extern struct {

    elements: [3]Vector2,

    const Self = @This();

    const identity = Transform2D.newIdentity();
    const flip_x = Transform2D.new(-1, 0, 0, 1, 0, 0);
    const flip_y = Transform2D.new(1, 0, 0, -1, 0, 0);

    pub inline fn new(xx: f32, xy: f32, yx: f32, yy: f32, ox: f32, oy: f32) Self {
        var self: Self = undefined;

        self.elements[0].x = xx;
        self.elements[0].y = xy;
        self.elements[1].x = yx;
        self.elements[1].y = yy;
        self.elements[2].x = ox;
        self.elements[2].y = oy;

        return self;
    }

    pub inline fn newIdentity() Self {
        var self: Self = undefined;

        self.elements[0].x = 1.0;
        self.elements[0].y = 0.0;
        self.elements[1].x = 0.0;
        self.elements[1].y = 1.0;
        self.elements[2].x = 0.0;
        self.elements[2].y = 0.0;

        return self;
    }

    pub inline fn newRotation(rotation: f32, position: *const Vector2) Self {
        var self: Self = undefined;

        const cr = @cos(rotation);
        const sr = @sin(rotation);
        self.elements[0].x = cr;
        self.elements[0].y = sr;
        self.elements[1].x = -sr;
        self.elements[1].y = cr;
        self.elements[2] = position;

        return self;
    }

    pub inline fn getOrigin(self: *const Self) Vector2 {
        return self.elements[2];
    }

    pub inline fn setOrigin(self: *Self, origin: *const Vector2) void {
        self.elements[2] = origin;
    }

    pub inline fn tdotx(self: *const Self, v: *const Vector2) f32 {
        return self.elements[0].x * v.x + self.elements[1].x * v.y;
    }

    pub inline fn tdoty(self: *const Self, v: *const Vector2) f32 {
        return self.elements[0].y * v.x + self.elements[1].y * v.y;
    }

    pub inline fn basisXform(self: *const Self, v: *const Vector2) Vector2 {
        return Vector2.new(self.tdotx(v), self.tdoty(v));
    }

    pub inline fn basisXformInv(self: *const Self, v: *const Vector2) Vector2 {
        return Vector2.new(self.elements[0].dot(v), self.elements[1].dot(v));
    }

    pub inline fn xformVector2(self: *const Self, v: *const Vector2) Vector2 {
        return Vector2.new(self.tdotx(v), self.tdoty(v)).plus(self.elements[2]);
    }

    pub inline fn xformInvVector2(self: *const Self, p_v: *const Vector2) Vector2 {
        const v = p_v.minus(self.elements[2]);
        return Vector2.new(self.elements[0].dot(v), self.elements[1].dot(v));
    }

    pub inline fn xformRect(self: *const Self, rect: *const Rect2) Rect2 {
        const x = self.elements[0].mul(rect.size.x);
        const y = self.elements[1].mul(rect.size.y);
        const position = self.xformVector2(rect.position);

        var new_rect = Rect2.new();
        new_rect.position = position;
        new_rect.expandTo(position.plus(x));
        new_rect.expandTo(position.plus(y));
        new_rect.expandTo(position.plus(x).plus(y));
        return new_rect;
    }

    pub inline fn xformInvRect(self:* const Self, rect: *const Rect2) Rect2 {
        var ends: [4]Vector2 = undefined;
        ends[0] = self.xformInv(rect.position);
        ends[1] = self.xformInv(Vector2.new(rect.position.x, rect.position.y + rect.size.y));
        ends[2] = self.xformInv(Vector2.new(rect.position.x + rect.size.x, rect.position.y + rect.size.y));
        ends[3] = self.xformInv(Vector2.new(rect.position.x + rect.size.x, rect.position.y));

        var new_rect = Rect2.new();
        new_rect.position = ends[0];
        new_rect.expandTo(ends[1]);
        new_rect.expandTo(ends[2]);
        new_rect.expandTo(ends[3]);
        return new_rect;
    }

    pub inline fn setRotationAndScale(self: *Self, rotation: f32, p_scale: *const Vector2) void {
        self.elements[0].x = @cos(rotation) * p_scale.x;
        self.elements[1].y = @cos(rotation) * p_scale.y;
        self.elements[1].x = @sin(rotation) * p_scale.y;
        self.elements[0].y = @sin(rotation) * p_scale.x;
    }

    pub inline fn invert(self: *Self) void {
        std.mem.swap(f32, self.elements[0].y, self.elements[1].x);
        self.elements[2] = self.basisXform(self.elements[2].negative());
    }

    pub inline fn inverse(self: *const Self) Self {
        var transform2d = self.*;
        transform2d.invert();
        return transform2d;
    }

    pub inline fn affineInvert(self: *Self) void {
        const det = self.basisDeterminant();
        const idet = 1.0 / det;

        std.mem.swap(self.elements[0].x, self.elements[1].y);
        self.elements[0].mulAssign(Vector2.new(idet, -idet));
        self.elements[1].mulAssign(Vector2.new(-idet, idet));

        self.elements[2] = self.basisXform(self.elements[2].negative());
    }

    pub inline fn affineInverse(self: *const Self) Self {
        var transform2d = self.*;
        transform2d.affineInvert();
        return transform2d;
    }

    pub inline fn rotate(self: *Self, phi: f32) void {
        self.* = Transform2D.newRotation(phi, Vector2.new(0, 0)).mul(self);
    }

    pub inline fn getRotation(self: *const Self) f32 {
        const det = self.basisDeterminant();
        const m = self.orthonormalized();
        if (det < 0.0) {
            m.scaleBasis(Vector2.new(-1, -1));
        }
        return atan2(m.elements[0].y, m.elements[0].x);
    }

    pub inline fn setRotation(self: *Self, rotation: f32) void {
        const cr = @cos(rotation);
        const sr = @sin(rotation);
        self.elements[0].x = cr;
        self.elements[0].y = sr;
        self.elements[1].x = -sr;
        self.elements[1].y = cr;
    }

    pub inline fn getScale(self: *const Self) Vector2 {
        const det_sign = if (self.basisDeterminant() > 0) 1 else -1;
        return Vector2.new(self.elements[0].length(), self.elements[1].length()).mulScalar(det_sign);
    }

    pub inline fn scale(self: *Self, p_scale: *const Vector2) void {
        self.scaleBasis(p_scale);
        self.elements[2].mulAssign(p_scale);
    }

    pub inline fn scaleBasis(self: *Self, p_scale: *const Vector2) void {
        self.elements[0].x *= p_scale.x;
        self.elements[0].y *= p_scale.y;
        self.elements[1].x *= p_scale.x;
        self.elements[1].y *= p_scale.y;
    }

    pub inline fn translate(self: *Self, translation: *const Vector2) void {
        self.elements[2].plusAssign(self.basisXform(translation));
    }

    pub inline fn orthonormalize(self: *Self) void {
        var x = self.elements[0];
        var y = self.elements[1];

        x.normalize();
        y = y.minus(x.mulScalar(x.dot(y)));
        y.normalize();

        self.elements[0] = x;
        self.elements[1] = y;
    }

    pub inline fn orthonormalized(self: *const Self) Self {
        var transform2d = self.*;
        transform2d.orthonormalize();
        return transform2d;
    }

    pub inline fn equal(self: *const Self, other: *const Transform2D) bool { //Operator ==
        inline for (self.elements, 0..) |element, i| {
            _ = element;
            if (self.elements[i].notEqual(other.elements[i])) {
                return false;
            }
        }

        return true;
    }

    pub inline fn notEqual(self: *const Self, other: *const Transform2D) bool { //Operator !=
        inline for (self.elements, 0..) |element, i| {
            _ = element;
            if (self.elements[i].notEqual(other.elements[i])) {
                return true;
            }
        }

        return false;
    }

    pub inline fn mul(self: *const Self, other: *const Transform2D) Self { //Operator *
        var transform2d = self.*;
        transform2d.mulAssign(other);
        return transform2d;
    }

    pub inline fn mulAssign(self: *Self, other: *const Transform2D) void { //Operator *=
        self.elements[2] = self.xformVector2(other.elements[2]);

        const x0 = self.tdotx(other.elements[0]);
        const x1 = self.tdoty(other.elements[0]);
        const y0 = self.tdotx(other.elements[1]);
        const y1 = self.tdoty(other.elements[1]);

        self.elements[0].x = x0;
        self.elements[0].y = x1;
        self.elements[1].x = y0;
        self.elements[1].y = y1;
    }

    pub inline fn scaled(self: *const Self, p_scale: *const Vector2) Self {
        var transform2d = self.*;
        transform2d.scale(p_scale);
        return transform2d;
    }

    pub inline fn basisScaled(self: *const Self, p_scale: *const Vector2) Self {
        var transform2d = self.*;
        transform2d.scaleBasis(p_scale);
        return transform2d;
    }

    pub inline fn untranslated(self: *const Self) Self {
        var transform2d = self.*;
        transform2d.elements[2] = Vector2.new(0, 0);
        return transform2d;
    }

    pub inline fn translated(self: *const Self, offset: *const Vector2) Self {
        var transform2d = self.*;
        transform2d.translate(offset);
        return transform2d;
    }

    pub inline fn rotated(self: *const Self, phi: f32) Self {
        var transform2d = self.*;
        transform2d.rotate(phi);
        return transform2d;
    }

    pub inline fn basisDeterminant(self: *const Self) f32 {
        return self.elements[0].x * self.elements[1].y - self.elements[0].y * self.elements[1].x;
    }

    pub fn interpolateWith(self: *const Self, other: *const Transform2D, p_c: f32) Self {
        const p1 = self.getOrigin();
        const p2 = other.getOrigin();

        const r1 = self.getRotation();
        const r2 = other.getRotation();

        const s1 = self.getScale();
        const s2 = other.getScale();

        const v1 = Vector2.new(@cos(r1), @sin(r1));
        const v2 = Vector2.new(@cos(r2), @sin(r2));

        var dot = v1.dot(v2);

        dot = if (dot < -1.0) 1.0 else (if (dot > 1.0) 1.0 else dot);

        var v: Vector2 = undefined;

        if (dot > 0.9995) {
            v = v1.linearInterpolate(v2, p_c).normalized();
        }
        else {
            const angle = p_c * acos(dot);
            const v3 = v2.minus(v1.mulScalar(dot)).normalized();
            v = v1.mulScalar(@cos(angle)).plus(v3.mulScalar(@sin(angle)));
        }

        var res = Transform2D.newRotation(atan2(v.y, v.x), p1.linearInterpolate(p2, p_c));
        res.scaleBasis(s1.linearInterpolate(s2, p_c));
        return res;
    }

};
