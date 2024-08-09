const Vector4 = @import("vector4.zig").Vector4;

pub const Projection = extern struct {

    elements: [4]Vector4,

    const Self = @This();

};
