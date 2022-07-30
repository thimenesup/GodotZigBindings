const std = @import("std");

pub const Color = extern struct {

    const T = f32;

    r: T,
    g: T,
    b: T,
    a: T,

    const Self = @This();

    pub inline fn new(p_r: T, p_g: T, p_b: T, p_a: T) Self {
        const self = Self {
            .r = p_r,
            .g = p_g,
            .b = p_b,
            .a = p_a,
        };

        return self;
    }

    pub inline fn newDefault() Self {
        const self = Self {
            .r = 0.0,
            .g = 0.0,
            .b = 0.0,
            .a = 1.0,
        };

        return self;
    }

    pub inline fn equal(self: *const Self, other: *const Color) bool { // Operator ==
        return (self.r == other.r and self.g == other.g and self.b == other.b and self.a == other.a);
    }

    pub inline fn notEqual(self: *const Self, other: *const Color) bool { // Operator !=
        return (self.r != other.r or self.g != other.g or self.b != other.b or self.a != other.a);
    }

    pub inline fn less(self: *const Self, other: *const Color) bool { // Operator <
        if (self.r == other.r) {
            if (self.g == other.g) {
                if (self.b == other.b) {
                    return self.a < other.a;
                }
                else {
                    return self.b < other.b;
                }
            }
            else {
                return self.g < other.g;
            }
        }
        else {
            return self.r < other.r;
        }
    }

    pub inline fn lessEqual(self: *const Self, other: *const Color) bool { // Operator <
        if (self.r == other.r) {
            if (self.g == other.g) {
                if (self.b == other.b) {
                    return self.a <= other.a;
                }
                else {
                    return self.b < other.b;
                }
            }
            else {
                return self.g < other.g;
            }
        }
        else {
            return self.r < other.r;
        }
    }

    pub inline fn more(self: *const Self, other: *const Color) bool { // Operator >
        return !lessEqual(self, other);
    }

    pub inline fn moreEqual(self: *const Self, other: *const Color) bool { // Operator >=
        return !less(self, other);
    }

    pub inline fn plus(self: *const Self, other: *const Color) Self { // Operator +
        var color = self.*;
        color.plusAssign(other);
        return color;
    }

    pub inline fn plusAssign(self: *Self, other: *const Color) void { // Operator +=
        self.r += other.r;
        self.g += other.g;
        self.b += other.b;
        self.a += other.a;
    }

    pub inline fn minus(self: *const Self, other: *const Color) Self { // Operator -
        var color = self.*;
        color.minusAssign(other);
        return color;
    }

    pub inline fn minusAssign(self: *Self, other: *const Color) void { // Operator -=
        self.r -= other.r;
        self.g -= other.g;
        self.b -= other.b;
        self.a -= other.a;
    }

    pub inline fn mul(self: *const Self, other: *const Color) Self { // Operator *
        var color = self.*;
        color.mulAssign(other);
        return color;
    }

    pub inline fn mulAssign(self: *Self, other: *const Color) void { // Operator *=
        self.r *= other.r;
        self.g *= other.g;
        self.b *= other.b;
        self.a *= other.a;
    }

    pub inline fn mulScalar(self: *const Self, scalar: f32) Self { // Operator *
        var color = self.*;
        color.mulAssignScalar(scalar);
        return color;
    }

    pub inline fn mulAssignScalar(self: *Self, scalar: f32) void { // Operator *=
        self.r *= scalar;
        self.g *= scalar;
        self.b *= scalar;
        self.a *= scalar;
    }

    pub inline fn div(self: *const Self, other: *const Color) Self { // Operator /
        var color = self.*;
        color.divAssign(other);
        return color;
    }

    pub inline fn divAssign(self: *Self, other: *const Color) void { // Operator /=
        self.r /= other.r;
        self.g /= other.g;
        self.b /= other.b;
        self.a /= other.a;
    }

    pub inline fn divScalar(self: *const Self, scalar: f32) Self { // Operator /
        var color = self.*;
        color.divAssignScalar(scalar);
        return color;
    }

    pub inline fn divAssignScalar(self: *Self, scalar: f32) void { // Operator /=
        self.r /= scalar;
        self.g /= scalar;
        self.b /= scalar;
        self.a /= scalar;
    }

    pub inline fn negative(self: *const Self) Self { // Operator -x
        var color = self.*;
        color.r = 1.0 - self.r;
        color.g = 1.0 - self.g;
        color.b = 1.0 - self.b;
        color.a = 1.0 - self.a;
        return color;
    }

    pub inline fn to32(self: *const Self) u32 {
        var c: u32 = 0;
        c |= @floatToInt(u8, self.a * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.r * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.g * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.b * 255);
        return c;
    }

    pub inline fn toARGB32(self: *const Self) u32 {
        var c: u32 = 0;
        c |= @floatToInt(u8, self.a * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.r * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.g * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.b * 255);
        return c;
    }

    pub inline fn toABGR32(self: *const Self) u32 {
        var c: u32 = 0;
        c |= @floatToInt(u8, self.a * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.b * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.g * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.r * 255);
        return c;
    }

    pub inline fn toRGBA32(self: *const Self) u32 {
        var c: u32 = 0;
        c |= @floatToInt(u8, self.r * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.g * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.b * 255);
        c <<= 8;
        c |= @floatToInt(u8, self.a * 255);
        return c;
    }

    pub inline fn toARGB64(self: *const Self) u64 {
        var c: u64 = 0;
        c |= @floatToInt(u16, self.a * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.r * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.g * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.b * 65535);
        return c;
    }

    pub inline fn toABGR64(self: *const Self) u64 {
        var c: u64 = 0;
        c |= @floatToInt(u16, self.a * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.b * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.g * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.r * 65535);
        return c;
    }

    pub inline fn toRGBA64(self: *const Self) u64 {
        var c: u64 = 0;
        c |= @floatToInt(u16, self.r * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.g * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.b * 65535);
        c <<= 16;
        c |= @floatToInt(u16, self.a * 65535);
        return c;
    }

    pub inline fn getR8(self: *const Self) u8 {
        return @floatToInt(u8, self.r * 255);
    }

    pub inline fn getG8(self: *const Self) u8 {
        return @floatToInt(u8, self.g * 255);
    }

    pub inline fn getB8(self: *const Self) u8 {
        return @floatToInt(u8, self.b * 255);
    }

    pub inline fn getA8(self: *const Self) u8 {
        return @floatToInt(u8, self.a * 255);
    }

    pub inline fn gray(self: *const Self) f32 {
        return (self.r + self.g + self.b) / 3.0;
    }

    pub inline fn getH(self: *const Self) f32 {
        var min = @minimum(self.r, self.g);
        min = @minimum(min, self.b);
        var max = @maximum(self.r, self.g);
        max = @maximum(max, self.b);

        const delta = max - min;
        if (delta == 0.0) {
            return 0.0;
        }

        var h: f32 = 0.0;
        if (self.r == max) {
            h = (self.g - self.b) / delta;
        }
        else if (self.g == max) {
            h = 2.0 + (self.b - self.r) / delta;
        }
        else {
            h = 4.0 + (self.r - self.g) / delta;
        }

        h /= 6.0;
        if (h < 0.0) {
            h += 1.0;
        }

        return h;
    }

    pub inline fn getS(self: *const Self) f32 {
        var min = @minimum(self.r, self.g);
        min = @minimum(min, self.b);
        var max = @maximum(self.r, self.g);
        max = @maximum(max, self.b);
        const delta = max - min;
        return if (max != 0.0) delta / max else 0.0;
    }

    pub inline fn getV(self: *const Self) f32 {
        var max = @maximum(self.r, self.g);
        max = @maximum(max, self.b);
        return max;
    }

    pub fn setHsv(self: *Self, p_h: T, p_s: T, p_v: T, p_a: T) void {
        _ = p_a;

        if (p_s == 0.0) {
            self.r = p_v;
            self.g = p_v;
            self.b = p_v;
            return;
        }

        var h = p_h * 6.0;
        h = @mod(p_h, 6.0);
        const i: usize = @floor(h);

        const f = h - i;
        const p = p_v * (1.0 - p_s);
        const q = p_v * (1.0 - p_s * f);
        const t = p_v * (1.0 - p_s * (1.0 - f));

        switch (i) {
            0 => {
                self.r = p_v;
                self.g = t;
                self.b = p;
            },
            1 => {
                self.r = q;
                self.g = p_v;
                self.b = p;
            },
            2 => {
                self.r = p;
                self.g = p_v;
                self.b = t;
            },
            3 => {
                self.r = p;
                self.g = q;
                self.b = p_v;
            },
            4 => {
                self.r = t;
                self.g = p;
                self.b = p_v;
            },
            else => {
                self.r = p_v;
                self.g = p;
                self.b = q;
            },
        }
    }

    pub fn fromHsv(p_h: T, p_s: T, p_v: T, p_a: T) Self {
        var h = @mod(p_h * 360.0, 360.0);
        if (h < 0.0) {
            h += 360.0;
        }

        const i = @floatToInt(usize, h / 60.0);
        const c = p_v * p_s;
        const x = c * (1.0 - @fabs(@mod(h / 60.0, 2.0) - 1.0));

        var r: T = 0.0;
        var g: T = 0.0;
        var b: T = 0.0;

        switch (i) {
            0 => {
                r = c;
                g = x;
                b = 0.0;
            },
            1 => {
                r = x;
                g = c;
                b = 0.0;
            },
            2 => {
                r = 0.0;
                g = c;
                b = x;
            },
            3 => {
                r = 0.0;
                g = x;
                b = c;
            },
            4 => {
                r = x;
                g = 0.0;
                b = c;
            },
            5 => {
                r = c;
                g = 0.0;
                b = x;
            },
            else => {
                r = 0.0;
                g = 0.0;
                b = 0.0;
            },
        }

        const m = p_v - c;
        return Color.new(m + r, m + g, m + b, p_a);
    }

    pub inline fn darkened(self: *const Self, amount: T) Self {
        var color = self.*;
        color.r = color.r * (1.0 - amount);
        color.g = color.g * (1.0 - amount);
        color.b = color.b * (1.0 - amount);
        return color;
    }

    pub inline fn lightened(self: *const Self, amount: T) Self {
        var color = self.*;
        color.r = color.r + (1.0 - color.r) * amount;
        color.g = color.g + (1.0 - color.g) * amount;
        color.b = color.b + (1.0 - color.b) * amount;
        return color;
    }

    pub inline fn invert(self: *Self) void {
        self.r = 1.0 - self.r;
        self.g = 1.0 - self.g;
        self.b = 1.0 - self.b;
    }

    pub inline fn inverted(self: *const Self) Self {
        var color = self.*;
        color.invert();
        return color;
    }

    pub inline fn contrast(self: *Self) void {
        self.r = @mod(self.r + 0.5, 1.0);
        self.g = @mod(self.g + 0.5, 1.0);
        self.b = @mod(self.b + 0.5, 1.0);
    }

    pub inline fn contrasted(self: *const Self) Self {
        var color = self.*;
        color.contrast();
        return color;
    }

    pub inline fn linearInterpolate(self: *const Self, other: *const Color, t: f32) Self {
        var color = self.*;
        color.r += t * (other.r - self.r);
        color.g += t * (other.g - self.g);
        color.b += t * (other.b - self.b);
        color.a += t * (other.a - self.a);
        return color;
    }

    pub inline fn blend(self: *const Self, other: *const Color) Self {
        var color = Color.newDefault();
        const sa = 1.0 - other.a;
        color.a = self.a * sa + other.a;
        if (color.a == 0.0) {
            return Color.new(0, 0, 0, 0);
        }
        else {
            color.r = (self.r * self.a * sa + other.r * other.a) / color.a;
            color.g = (self.g * self.a * sa + other.g * other.a) / color.a;
            color.b = (self.b * self.a * sa + other.b * other.a) / color.a;
        }
        return color;
    }

    pub inline fn toLinear(self: *const Self) Self {
        return Color.new(
            if (self.r < 0.04045) self.r * (1.0 / 12.92) else std.math.pow(T, (self.r + 0.055) * (1.0 / (1 + 0.055)), 2.4),
            if (self.g < 0.04045) self.g * (1.0 / 12.92) else std.math.pow(T, (self.g + 0.055) * (1.0 / (1 + 0.055)), 2.4),
            if (self.b < 0.04045) self.b * (1.0 / 12.92) else std.math.pow(T, (self.b + 0.055) * (1.0 / (1 + 0.055)), 2.4),
            self.a
        );
    }

    pub inline fn hex(p_hex: u32) Self {
        var mut_hex = p_hex;
        const a = (mut_hex & 0xFF) / 255.0;
        mut_hex >>= 8;
        const r = (mut_hex & 0xFF) / 255.0;
        mut_hex >>= 8;
        const g = (mut_hex & 0xFF) / 255.0;
        mut_hex >>= 8;
        const b = (mut_hex & 0xFF) / 255.0;
        return Color.new(r, g, b, a);
    }

};
