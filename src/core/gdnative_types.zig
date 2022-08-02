const builtin = @import("builtin");

const types = if (builtin.link_libc) @cImport({ @cInclude("gdnative_api_struct.gen.h"); }) else @import("gdnative_api_types.zig");
pub usingnamespace types;

const api = if (builtin.link_libc) struct {} else @import("gdnative_api.zig");
pub usingnamespace api;
