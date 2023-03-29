const std = @import("std");

const String = std.ArrayList(u8);
const BindingGenerator = @import("binding_generator.zig");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    _ = target;
    _ = mode;

    const getHeaders = b.option(bool, "getHeaders", "Specify a custom Godot api json file for generating Zig class files") orelse false;
    const doGen = b.option(bool, "generate", "Generate Zig bindings") orelse true;

    if (getHeaders) {
        try doGetHeaders(b);
    }

    if (doGen) {
        try doGenerate(b);
    }
}

fn doGetHeaders(b: *std.build.Builder) !void {
    std.debug.print("Retrieving headers...\n", .{});
    _ = b.exec(&.{ "git", "clone", "-b", "3.x", "https://github.com/godotengine/godot-headers.git" });
    std.debug.print("Headers retrieved successfully!\n", .{});
}

fn doGenerate(b: *std.build.Builder) !void {
    const gdnative_headers = b.pathFromRoot("./godot-headers");

    var gdnative_file_path = String.init(b.allocator);
    defer gdnative_file_path.deinit();

    try gdnative_file_path.appendSlice(gdnative_headers);
    try gdnative_file_path.appendSlice("/gdnative_api.json");

    std.debug.print("Generating Zig gdnative api...\n", .{});
    try BindingGenerator.generateGDNativeAPI(gdnative_file_path.items);
    std.debug.print("Done generating Zig gdnative api\n", .{});

    var api_file_path = String.init(b.allocator);
    defer api_file_path.deinit();

    if (b.option([]const u8, "custom_api_file", "Specify a custom Godot api json file for generating Zig class files")) |custom_api_file| {
        try api_file_path.appendSlice(custom_api_file);
    } else {
        try api_file_path.appendSlice(gdnative_headers);
        try api_file_path.appendSlice("/api.json");
    }

    std.debug.print("Generating Zig class file bindings...\n", .{});
    try BindingGenerator.generateClassBindings(api_file_path.items);
    std.debug.print("Done generating Zig class file bindings\n", .{});
}
