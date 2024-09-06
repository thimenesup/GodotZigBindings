const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(
        .{
            .name = "gdextension_example",
            .root_source_file = .{
                .src_path = .{
                    .owner = b,
                    .sub_path = "src/lib.zig",
                },
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

    const gdextension_package_path = "../src/lib.zig"; //On your own projects it would be wise to use an environment variable with a global path pointing to it
    lib.root_module.addImport(
        "gdextension",
        b.createModule(.{
            .root_source_file = .{
                .src_path = .{
                    .owner = b,
                    .sub_path = gdextension_package_path,
                },
            },
        }),
    );

    b.installArtifact(lib);
}
