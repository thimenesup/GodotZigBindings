const Array = @import("../gen/builtin_classes/array.zig").Array;

pub fn TypedArray(comptime T: type) type {

    _ = T;

    return extern struct {
        array: Array,
    };

}
