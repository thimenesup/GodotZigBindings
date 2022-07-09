const std = @import("std");

//https://zig.news/xq/zig-build-explained-part-2-1850

pub fn build(b: *std.build.Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const lib = b.addSharedLibrary("gdnative", "src/lib.zig", b.version(0, 1, 0));
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.linkLibC();

    lib.force_pic = true;

    const gdnative_headers = std.process.getEnvVarOwned(b.allocator, "GDNATIVE_HEADERS") catch "";
    defer b.allocator.free(gdnative_headers);

    lib.addIncludeDir(gdnative_headers);

    lib.install();
}
