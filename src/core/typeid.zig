pub fn typeId(comptime T: type) usize {
    _ = T;
    return @intFromPtr(&struct {
        var x: u8 = 0;
    }.x);
}
