const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(
        .{
            .name = "gdnative_example",
            .root_source_file = .{
                .path = "src/lib.zig"
            },
            .version = .{
                .major = 1,
                .minor = 0,
                .patch = 0,
            },
            .target = target,
            .optimize = mode,
        }
    );
    lib.force_pic = true;

    const gdnative_package_path = "../src/lib.zig"; //On your own projects it would be wise to use an environment variable with a global path pointing to it
    lib.addModule(
        "gdnative",
        b.createModule(.{
            .source_file = .{
                .path = gdnative_package_path
            },
        }),
    );

    b.installArtifact(lib);
}
