const std = @import("std");

const BindingGenerator = @import("binding_generator.zig");

pub fn build(b: *std.build.Builder) !void {
    const gdextension_api_file = b.option([]const u8, "gdextension", "Specify GDExtension API json file") orelse "";
    if (gdextension_api_file.len == 0) {
        std.debug.print("You must specify the GDExtension API file path to generate\n", .{});
        return;
    }

    const build_config = b.option(BindingGenerator.BuildConfiguration, "build_config", "Specify Godot bits build configuration") orelse BindingGenerator.BuildConfiguration.float_64;

    std.debug.print("Generating types for Godot build configuration:{s}\n", .{ @tagName(build_config) });
    std.debug.print("Generating Zig GDExtension API...\n", .{});
    try BindingGenerator.generateGDExtensionAPI(gdextension_api_file, build_config);
    std.debug.print("Done generating Zig GDExtension API\n", .{});
}
