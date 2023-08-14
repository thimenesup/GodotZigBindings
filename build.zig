const std = @import("std");

const BindingGenerator = @import("binding_generator.zig");

pub fn build(b: *std.build.Builder) !void {
    const gdnative_api_file = b.option([]const u8, "gdnative", "Specify GDNative API json file") orelse "";
    if (gdnative_api_file.len == 0) {
        std.debug.print("You must specify the GDNative API file path to generate\n", .{});
        return;
    }

    const classes_api_file = b.option([]const u8, "classes", "Specify classes API json file") orelse "";
    if (classes_api_file.len == 0) {
        std.debug.print("You must specify the classes API file path to generate\n", .{});
        return;
    }

    std.debug.print("Generating Zig GDNative API...\n", .{});
    try BindingGenerator.generateGDNativeAPI(gdnative_api_file);
    std.debug.print("Done generating Zig GDNative API\n", .{});

    std.debug.print("Generating Zig class file bindings...\n", .{});
    try BindingGenerator.generateClassBindings(classes_api_file);
    std.debug.print("Done generating Zig class file bindings\n", .{});
}
