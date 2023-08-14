const std = @import("std");

pub fn build(b: *std.Build) !void {
    const lib = b.addSharedLibrary(.{
        .name = "gdnative_example",
        .root_source_file = .{ .path = "src/lib.zig" },
        .optimize = b.standardOptimizeOption(.{}),
        .target = b.standardTargetOptions(.{})
    });

    const gdnative_package_path = "../src/lib.zig"; //On your own projects it would be wise to use an environment variable with a global path pointing to it
    lib.addModule("gdnative", b.createModule(.{
        .source_file = .{.path = gdnative_package_path},
        .dependencies = &.{},
    }));
    lib.force_pic = true;

    // lib.install();
    b.installArtifact(lib);
}
