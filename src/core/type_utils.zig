const std = @import("std");

pub inline fn BaseType(comptime T: type) type {
    const type_info = @typeInfo(T);
    const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
    switch (type_info) {
        type_tag.Pointer => {
            return type_info.Pointer.child;
        },
        type_tag.Optional => {
            return BaseType(type_info.Optional.child);
        },
        else => {
            return T;
        }
    }
}

pub inline fn isPointerType(comptime T: type) bool {
    const type_info = @typeInfo(T);
    const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
    switch (type_info) {
        type_tag.Pointer => {
            return true;
        },
        type_tag.Optional => {
            return isPointerType(type_info.Optional.child);
        },
        else => {
            return false;
        }
    }
}

pub inline fn isTypeGodotObjectClass(comptime T: type) bool {
    const type_info = @typeInfo(T);
    const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
    switch (type_info) {
        type_tag.Struct => {
            return @hasDecl(T, "GodotClass");
        },
        type_tag.Pointer => {
            return isTypeGodotObjectClass(type_info.Pointer.child);
        },
        type_tag.Optional => {
            return isTypeGodotObjectClass(type_info.Optional.child);
        },
        else => {
            return false;
        }
    }
}
