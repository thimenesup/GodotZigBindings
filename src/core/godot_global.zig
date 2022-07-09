const gd = @import("api.zig");
const c = gd.c;

const String = @import("string.zig").String;

pub const Godot = struct {

    pub fn print(string: *const String) void {
        gd.api.*.godot_print.?(&string.godot_string);
    }

};
