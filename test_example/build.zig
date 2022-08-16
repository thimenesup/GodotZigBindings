const std = @import("std");

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("gdnative_example", "src/lib.zig", b.version(1, 0, 0));
    lib.setTarget(target);
    lib.setBuildMode(mode);

    lib.force_pic = true;

    const gdnative_package_path = "../src/lib.zig"; //On your own projects it would be wise to use an environment variable with a global path pointing to it
    lib.addPackagePath("gdnative", gdnative_package_path);

    lib.install();
}
