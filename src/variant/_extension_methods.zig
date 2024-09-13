const std = @import("std");
const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const StringName = @import("../gen/builtin_classes/string_name.zig").StringName;
const String = @import("../gen/builtin_classes/string.zig").String;

pub const ArrayExt = struct {};
pub const CallableExt = struct {};
pub const DictionaryExt = struct {};
pub const NodePathExt = struct {};
pub const PackedByteArrayExt = struct {};
pub const PackedColorArrayExt = struct {};
pub const PackedFloat32ArrayExt = struct {};
pub const PackedFloat64ArrayExt = struct {};
pub const PackedInt32ArrayExt = struct {};
pub const PackedInt64ArrayExt = struct {};
pub const PackedStringArrayExt = struct {};
pub const PackedVector2ArrayExt = struct {};
pub const PackedVector3ArrayExt = struct {};
pub const RIDExt = struct {};
pub const SignalExt = struct {};

pub const StringNameExt = struct {

    pub fn initUtf8(chars: []const u8) StringName {
        var string = String.initUtf8(chars);
        defer string.deinit();

        const string_name_type = gi.GDExtensionVariantType.GDEXTENSION_VARIANT_TYPE_STRING_NAME;
        const string_constructor_index = 2;
        const string_ctor = gd.interface.?.variant_get_ptr_constructor.?(string_name_type, string_constructor_index);
        var string_name = std.mem.zeroes(StringName);
        gd.callBuiltinConstructor(string_ctor, string_name._nativePtr(), .{ string._nativePtr() });
        return string_name;
    }

};

pub const StringExt = struct {

    pub fn initUtf8(chars: []const u8) String {
        var string = std.mem.zeroes(String);
        gd.interface.?.string_new_with_utf8_chars_and_len.?(@ptrCast(&string), @ptrCast(chars.ptr), @intCast(chars.len));
        return string;
    }

};
