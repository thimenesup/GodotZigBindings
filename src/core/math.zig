const std = @import("std");

// Other functions like clamp() and such are already present in Zig's std

pub inline fn lerp(T: type, min: T, max: T, weight: T) T {
    return min + weight * (max - min);
}

pub inline fn lerpAngle(T: type, from: T, to: T, weight: T) T {
	const difference = @mod(to - from, std.math.tau);
	const distance = @mod(2.0 * difference, std.math.tau) - difference;
	return from + distance * weight;
}

pub inline fn inverseLerp(T: type, from: T, to: T, weight: T) T {
    return (weight - from) / (to - from);
}

pub inline fn rangeLerp(T: type, value: T, istart: T, istop: T, ostart: T, ostop: T) T {
    return lerp(ostart, ostop, inverseLerp(istart, istop, value));
}

pub inline fn isEqualApprox(T: type, a: T, b: T) bool {
    if (a == b) {
        return true;
    }

    var tolerance = std.math.epsilon * @abs(a);
    if (tolerance < std.math.epsilon) {
        tolerance = std.math.epsilon;
    }

    return @abs(a - b) < tolerance;
}

pub inline fn isEqualApproxTolerance(T: type, a: T, b: T, tolerance: T) bool {
    if (a == b) {
        return true;
    }

    return @abs(a - b) < tolerance;
}

pub inline fn isZeroApprox(T: type, x: T) bool {
    return @abs(x) < std.math.epsilon;
}

pub inline fn sign(T: type, x: T) T {
    return if (x < 0) -1 else 1;
}

pub inline fn deg2rad(T: type, x: T) T {
    return x * std.math.pi / 180.0;
}

pub inline fn rad2deg(T: type, x: T) T {
    return x * 180.0 / std.math.pi;
}

pub inline fn linear2db(T: type, linear: T) T {
    return std.math.log(linear) * 8.6858896380650365530225783783321;
}

pub inline fn db2linear(T: type, db: T) T {
    return std.math.exp(db * 0.11512925464970228420089957273422);
}

pub inline fn moveToward(T: type, from: T, to: T, delta: T) T {
    return if (@abs(to - from) <= delta) to else from + sign(to - from) * delta;
}

pub inline fn stepify(T: type, value: T, step: T) T {
    if (step != 0) {
        value = @floor(value / step + 0.5) * step;
    }
    return value;
}

pub inline fn nextPowerOf2(x: u32) u32 {
    if (x == 0)
        return 0;

    --x;
    x |= x >> 1;
    x |= x >> 2;
    x |= x >> 4;
    x |= x >> 8;
    x |= x >> 16;

    return x + 1;
}
