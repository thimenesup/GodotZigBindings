const gd = @import("gdnative_types.zig");
const api = @import("api.zig");

const String = @import("string.zig").String;

pub const Godot = struct {

    pub fn print(string: *const String) void {
        api.core.godot_print.?(&string.godot_string);
    }

    pub fn printWarning(description: *const String, function: *const String, file: *const String, line: i32) void {
        const c_description = description.allocCString();
        const c_function = function.allocCString();
        const c_file = file.allocCString();

        if ((c_description != null) and (c_function != null) and (c_file != null)) {
            api.core.godot_print_warning.?(c_description, c_function, c_file, line);
        }
        
        if (c_description != null) { api.core.godot_free.?(c_description); }
        if (c_function != null) { api.core.godot_free.?(c_function); }
        if (c_file != null) { api.core.godot_free.?(c_file); }
    }

    pub fn printError(description: *const String, function: *const String, file: *const String, line: i32) void {
        const c_description = description.allocCString();
        const c_function = function.allocCString();
        const c_file = file.allocCString();

        if ((c_description != null) and (c_function != null) and (c_file != null)) {
            api.core.godot_print_error.?(c_description, c_function, c_file, line);
        }
        
        if (c_description != null) { api.core.godot_free.?(c_description); }
        if (c_function != null) { api.core.godot_free.?(c_function); }
        if (c_file != null) { api.core.godot_free.?(c_file); }
    }

    pub fn printWarningCString(description: [*:0]const u8, function: [*:0]const u8, file: [*:0]const u8, line: i32) void {
        api.core.godot_print_warning.?(description, function, file, line);
    }

    pub fn printErrorCString(description: [*:0]const u8, function: [*:0]const u8, file: [*:0]const u8, line: i32) void {
        api.core.godot_print_error.?(description, function, file, line);
    }

};
