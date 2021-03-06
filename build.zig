const std = @import("std");

const String = std.ArrayList(u8);
const BindingGenerator = @import("binding_generator.zig");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const gdnative_headers = try std.process.getEnvVarOwned(b.allocator, "GDNATIVE_HEADERS");
    defer b.allocator.free(gdnative_headers);

    const generate_bindings = b.option(bool, "generate_bindings", "Generate Zig class file bindings") orelse false;
    if (generate_bindings) {
        var api_file_path = String.init(b.allocator);
        defer api_file_path.deinit();

        const custom_api_file = b.option([]const u8, "custom_api_file", "Specify a custom Godot api json file for generating Zig class files") orelse "";
        if (custom_api_file.len > 0) {
            try api_file_path.appendSlice(custom_api_file);
        }
        else {
            try api_file_path.appendSlice(gdnative_headers);
            try api_file_path.appendSlice("/api.json");
        }

        std.debug.print("Generating Zig class file bindings...\n", .{});

        try BindingGenerator.generateBindings(api_file_path.items);

        std.debug.print("Done generating Zig class file bindings\n", .{});
    }
    
    const lib = b.addSharedLibrary("gdnative", "src/lib.zig", b.version(0, 1, 0));
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.linkLibC();

    lib.force_pic = true;

    lib.addIncludeDir(gdnative_headers);

    lib.install();
}
