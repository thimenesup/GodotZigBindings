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
        var gdnative_file_path = String.init(b.allocator);
        defer gdnative_file_path.deinit();

        try gdnative_file_path.appendSlice(gdnative_headers);
        try gdnative_file_path.appendSlice("/gdnative_api.json");

        std.debug.print("Generating Zig gdnative api...\n", .{});
        try BindingGenerator.generateGDNativeAPI(gdnative_file_path.items);
        std.debug.print("Done generating Zig gdnative api\n", .{});


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
        try BindingGenerator.generateClassBindings(api_file_path.items);
        std.debug.print("Done generating Zig class file bindings\n", .{});
    }

    _ = target;
    _ = mode;

    // const lib = b.addDynamicLibrary("gdnative", "src/lib.zig");
    // lib.setTarget(target);
    // lib.setBuildMode(mode);

    // lib.force_pic = true;

    // const use_c = b.option(bool, "use_c", "Use C Godot Headers and LibC") orelse true;
    // if (use_c) {
    //     lib.linkLibC();
    //     lib.addIncludeDir(gdnative_headers);
    // }

    // lib.install();
}
