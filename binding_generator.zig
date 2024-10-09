const std = @import("std");

const String = std.ArrayList(u8);

fn toSnakeCase(string: []const u8) String { //Must deinit string
    var snake_case = String.init(std.heap.page_allocator);

    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        const char = string[i];
        if (i > 0 and (i + 1) < string.len) {
            const next = string[i + 1];
            if (std.ascii.isLower(char) or std.ascii.isDigit(char)) {
                // NOTE: Arbitrary 'D' check so strings like "Body2DState" dont become "body_2_d_state", therefore matching C++ GDExtension naming convention
                if (std.ascii.isDigit(char) and next == 'D') {
                    snake_case.append(std.ascii.toLower(char)) catch {};
                    continue;
                }

                if (std.ascii.isUpper(next)) {
                    snake_case.append(std.ascii.toLower(char)) catch {};
                    snake_case.append('_') catch {};
                    continue;
                }
            } else {
                const previous = string[i - 1];
                if (std.ascii.isLower(next) and std.ascii.isUpper(previous) and previous != '_') {
                    snake_case.append('_') catch {};
                    snake_case.append(std.ascii.toLower(char)) catch {};
                    continue;
                }
            }
        }

        snake_case.append(std.ascii.toLower(char)) catch {};
    }

    return snake_case;
}

fn toCamelCase(string: []const u8) String { //Must deinit string
    var camel_case = String.init(std.heap.page_allocator);

    var capitalize_next = false;

    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        const char = string[i];
        if (i > 0 and char == '_' or char == ' ') {
            capitalize_next = true;
            continue;
        }
        if (capitalize_next) {
            capitalize_next = false;
            camel_case.append(std.ascii.toUpper(char)) catch {};
        } else {
            camel_case.append(char) catch {};
        }
    }

    if (camel_case.items.len > 0) {
        camel_case.items[0] = std.ascii.toLower(camel_case.items[0]);
    }

    return camel_case;
}

fn upperString(string: []u8) void {
    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        string[i] = std.ascii.toUpper(string[i]);
    }
}


fn stripClassName(string: []const u8) String { //Must deinit string
    var stripped = String.init(std.heap.page_allocator);
    stripped.appendSlice(string) catch {};
    if (string.len > 0 and string[0] == '_') {
        _ = stripped.orderedRemove(0);
    }
    return stripped;
}

fn escapeFunctionName(string: []const u8) String { //Must deinit string
    const keywords = [_][]const u8 { "align", "resume" };

    var escaped = String.init(std.heap.page_allocator);

    for (keywords) |keyword| {
        if (std.mem.eql(u8, string, keyword)) {
            std.fmt.format(escaped.writer(), "_{s}", .{ string }) catch {};
            return escaped;
        }
    }

    escaped.appendSlice(string) catch {};

    return escaped;
}


fn convertIntPrimitive(base_type: []const u8) ?[]const u8 {
    const int_conversions = [_][2][]const u8 {
        .{ "int", "i64" }, //NOTE: Godot int is 64bit //WARNING: Except on NativeStructs...
        .{ "int8", "i8" },
        .{ "int16", "i16" },
        .{ "int32", "i32" },
        .{ "int64", "i64" },
        .{ "uint8", "u8" },
        .{ "uint16", "u16" },
        .{ "uint32", "u32" },
        .{ "uint64", "u64" },
        .{ "uint8_t", "u8" },
        .{ "uint16_t", "u16" },
        .{ "uint32_t", "u32" },
        .{ "uint64_t", "u64" },
        .{ "int8_t", "i8" },
        .{ "int16_t", "i16" },
        .{ "int32_t", "i32" },
        .{ "int64_t", "i64" },
    };

    var i: usize = 0;
    while (i < int_conversions.len) : (i += 1) {
        if (std.mem.eql(u8, base_type, int_conversions[i][0])) {
            return int_conversions[i][1];
        }
    }
    return null;
}

fn convertFloatPrimitive(base_type: []const u8) ?[]const u8 {
    const float_conversions = [_][2][]const u8 {
        .{ "float", "f64" }, //NOTE: Godot float is 64bit //WARNING: Except on NativeStructs...
        .{ "double", "f64" },
        .{ "float32", "f32" },
    };

    var i: usize = 0;
    while (i < float_conversions.len) : (i += 1) {
        if (std.mem.eql(u8, base_type, float_conversions[i][0])) {
            return float_conversions[i][1];
        }
    }
    return null;
}

fn convertPrimitiveBaseTypeToZig(base_type: []const u8) ?[]const u8 {
    const other_conversions = [_][2][]const u8 {
        .{ "void", "void" },
        .{ "bool", "bool" },
    };
    var i: usize = 0;
    while (i < other_conversions.len) : (i += 1) {
        if (std.mem.eql(u8, base_type, other_conversions[i][0])) {
            return other_conversions[i][1];
        }
    }

    if (convertFloatPrimitive(base_type)) |converted| {
        return converted;
    }
    if (convertIntPrimitive(base_type)) |converted| {
        return converted;
    }
    return null;
}

fn isBool(base_type: []const u8) bool {
    return std.mem.eql(u8, base_type, "bool");
}

fn isInt(base_type: []const u8) bool {
    return convertIntPrimitive(base_type) != null;
}

fn isFloat(base_type: []const u8) bool {
    return convertFloatPrimitive(base_type) != null;
}

fn isPrimitive(base_type: []const u8) bool {
    return convertPrimitiveBaseTypeToZig(base_type) != null;
}


fn isTypedArray(raw_type: []const u8) bool {
    const index = std.mem.indexOf(u8, raw_type, "typedarray::");
    if (index == null) {
        return false;
    }
    return index.? == 0;
}

fn isEnum(raw_type: []const u8) bool {
    const index = std.mem.indexOf(u8, raw_type, "enum::");
    if (index == null) {
        return false;
    }
    return index.? == 0;
}

fn isBitfield(raw_type: []const u8) bool {
    const index = std.mem.indexOf(u8, raw_type, "bitfield::");
    if (index == null) {
        return false;
    }
    return index.? == 0;
}

fn isClassEnum(raw_type: []const u8) bool {
    if (!isEnum(raw_type)) {
        return false;
    }
    const index = std.mem.indexOf(u8, raw_type, ".");
    return index != null;
}

fn isClassBitfield(raw_type: []const u8) bool {
    if (!isBitfield(raw_type)) {
        return false;
    }
    const index = std.mem.indexOf(u8, raw_type, ".");
    return index != null;
}

fn isGlobalEnum(raw_type: []const u8) bool {
    if (!isEnum(raw_type)) {
        return false;
    }
    const index = std.mem.indexOf(u8, raw_type, ".");
    return index == null;
}

fn isGlobalBitfield(raw_type: []const u8) bool {
    if (!isBitfield(raw_type)) {
        return false;
    }
    const index = std.mem.indexOf(u8, raw_type, ".");
    return index == null;
}

const core_types = [_][]const u8 { 
    "AABB",
    "Array",
    "Basis",
    "Callable",
    "Color",
    "Dictionary",
    "NodePath",
    "PackedByteArray",
    "PackedColorArray",
    "PackedFloat32Array",
    "PackedFloat64Array",
    "PackedInt32Array",
    "PackedInt64Array",
    "PackedStringArray",
    "PackedVector2Array",
    "PackedVector3Array",
    "Plane",
    "Projection",
    "Quaternion",
    "Rect2",
    "Rect2i",
    "RID",
    "Signal",
    "String",
    "StringName",
    "Transform2D",
    "Transform3D",
    "Variant",
    "Vector2",
    "Vector2i",
    "Vector3",
    "Vector3i",
    "Vector4",
    "Vector4i",
};

fn isBuiltinType(raw_type: []const u8) bool {
    for (core_types) |core| {
        if (std.mem.eql(u8, raw_type, core)) {
            return true;
        }
    }
    return false;
}

// NOTE: Make sure there are initialized before using either functions
var singletons_map: std.StringHashMap(void) = undefined;
var classes_map: std.StringHashMap(void) = undefined;
var native_structs_map: std.StringHashMap(void) = undefined;

fn initClassStructMaps(singletons: *const std.json.Array, classes: *const std.json.Array, native_structs: *const std.json.Array) void {
    singletons_map = std.StringHashMap(void).init(std.heap.page_allocator);
    for (singletons.items) |item| {
        const singleton = item.object;
        const class_name = singleton.get("name").?.string;
        singletons_map.putNoClobber(class_name, {}) catch {};
    }

    classes_map = std.StringHashMap(void).init(std.heap.page_allocator);
    for (classes.items) |item| {
        const class = item.object;
        const class_name = class.get("name").?.string;
        classes_map.putNoClobber(class_name, {}) catch {};
    }

    native_structs_map = std.StringHashMap(void).init(std.heap.page_allocator);
    for (native_structs.items) |item| {
        const class = item.object;
        const class_name = class.get("name").?.string;
        native_structs_map.putNoClobber(class_name, {}) catch {};
    }
}

fn isClassSingleton(raw_type: []const u8) bool {
    return singletons_map.contains(raw_type);
}

fn isClassType(raw_type: []const u8) bool {
    return classes_map.contains(raw_type);
}

fn isNativeStructType(raw_type: []const u8) bool {
    return native_structs_map.contains(raw_type);
}


fn isUnformattedEnum(raw_type: []const u8) bool { // NOTE: Need this for native structs, which contain unformatted enum types...
    const enum_index = std.mem.indexOf(u8, raw_type, "enum::");
    if (enum_index != null) {
        return false;
    }

    const bitfield_index = std.mem.indexOf(u8, raw_type, "bitfield::");
    if (bitfield_index != null) {
        return false;
    }

    const typedarray_index = std.mem.indexOf(u8, raw_type, "typedarray::");
    if (typedarray_index != null) {
        return false;
    }

    const index = std.mem.indexOf(u8, raw_type, "::");
    return index != null;
}

fn unformattedEnumGetClass(raw_type: []const u8) []const u8 { //Assumes parameter isUnformattedEnum()
    const class_end_needle = "::";
    const class_end_find = std.mem.indexOf(u8, raw_type, class_end_needle);
    const class_end_index = if (class_end_find) |f| f else raw_type.len;
    const class_type = raw_type[0..class_end_index];
    return class_type;
}

fn enumOrBitFieldGetClass(raw_type: []const u8) []const u8 { //Assumes parameter isClassEnum/isClassBitfield()
    const prefix_needle = "::";
    const class_begin_find = std.mem.indexOf(u8, raw_type, prefix_needle);
    const class_begin_index = if (class_begin_find) |f| (f + prefix_needle.len) else 0;

    const class_end_find = std.mem.indexOf(u8, raw_type, ".");
    const class_end_index = if (class_end_find) |f| f else raw_type.len;

    const class_type = raw_type[class_begin_index..class_end_index];
    return class_type;
}

fn enumOrBitFieldConverted(raw_type: []const u8) []const u8 { //Assumes parameter isEnum/isBitfield()
    const prefix_needle = "::";
    const prefix_find = std.mem.indexOf(u8, raw_type, prefix_needle);
    const begin_index = if (prefix_find) |f| (f + prefix_needle.len) else 0;
    return raw_type[begin_index..raw_type.len];
}

fn typedArrayGetType(raw_type: []const u8) []const u8 { //Assumes parameter isTypedArray()
    const type_begin_needle = "typedarray::";
    const type_begin_index = std.mem.indexOf(u8, raw_type, type_begin_needle);
    const begin_index = type_begin_index.? + type_begin_needle.len;
    const array_type = raw_type[begin_index..raw_type.len];
    return array_type;
}

fn typedArrayConverted(raw_type: []const u8) String { //Must deinit string //Assumes parameter isTypedArray()
    var base_type = typedArrayGetType(raw_type);
    if (isPrimitive(base_type)) {
        base_type = convertPrimitiveBaseTypeToZig(base_type).?;
    }

    var converted = String.init(std.heap.page_allocator);
    std.fmt.format(converted.writer(), "TypedArray({s})", .{ base_type }) catch {};
    return converted;
}


const TypeKind = enum {
    primitive,
    enum_,
    bitfield,
    builtin_type,
    typed_array,
    class,
    native_struct,
};

fn determineRawTypeKind(base_type: []const u8) TypeKind { //NOTE: Type expected to be as is from JSON, but with const or pointer qualifiers removed if any
    if (isEnum(base_type)) {
        return TypeKind.enum_;
    } else if (isBitfield(base_type)) {
        return TypeKind.bitfield;
    } else if (isTypedArray(base_type)) {
        return TypeKind.typed_array;
    } else if (isUnformattedEnum(base_type)) {
        return TypeKind.enum_;
    } else if (isPrimitive(base_type)) {
        return TypeKind.primitive;
    } else if (isBuiltinType(base_type)) {
        return TypeKind.builtin_type;
    } else if (isClassType(base_type)) {
        return TypeKind.class;
    } else if (isNativeStructType(base_type)) {
        return TypeKind.native_struct;
    } else {
        std.debug.print("Unknown type:{s}\n", .{ base_type });
        @panic("Unhandled type");
    }
}

const ParsedType = struct {
    undecorated_json_type: []const u8,
    type_kind: TypeKind,
    pointer: usize,
    is_const: bool,

    fn new(json_type: []const u8) ParsedType {
        var undecorated_json_type = json_type;

        const const_needle = "const ";
        const const_index = std.mem.indexOf(u8, undecorated_json_type, const_needle);
        var is_const = false;
        if (const_index != null) {
            is_const = true;
            undecorated_json_type = undecorated_json_type[(const_index.? + const_needle.len)..undecorated_json_type.len];
        }

        const ptr_index = std.mem.indexOf(u8, undecorated_json_type, "*");
        var pointer: usize = 0;
        if (ptr_index != null) {
            var i: usize = ptr_index.?;
            while (i < undecorated_json_type.len) : (i += 1) {
                if (undecorated_json_type[i] == '*') {
                    pointer += 1;
                }
            }

            undecorated_json_type = undecorated_json_type[0..ptr_index.?];
        }

        //There can be a space between type and many pointers because reasons...
        const space_needle = " ";
        const space_index = std.mem.indexOf(u8, undecorated_json_type, space_needle);
        if (space_index != null) {
            undecorated_json_type = undecorated_json_type[0..space_index.?];
        }

        const type_kind = determineRawTypeKind(undecorated_json_type);

        const parsed_type = ParsedType {
            .undecorated_json_type = undecorated_json_type,
            .type_kind = type_kind,
            .pointer = pointer,
            .is_const = is_const,
        };
        return parsed_type;
    }

    fn stringConverted(self: *const ParsedType, is_return_type: bool) String {
        var converted = String.init(std.heap.page_allocator);

        // NOTE: This is only really expected for primitives and native structs
        var i: usize = 0;
        while (i < self.pointer) : (i += 1) {
            converted.appendSlice("[*c]") catch {};
        }
        if (self.is_const) {
            converted.appendSlice("const ") catch {};
        }

        switch (self.type_kind) {
            TypeKind.primitive => {
                if (std.mem.eql(u8, self.undecorated_json_type, "void") and self.pointer > 0) {
                    converted.appendSlice("anyopaque") catch {};
                } else {
                    converted.appendSlice(convertPrimitiveBaseTypeToZig(self.undecorated_json_type).?) catch {};
                }
            },
            TypeKind.enum_ => {
                converted.appendSlice(enumOrBitFieldConverted(self.undecorated_json_type)) catch {};
            },
            TypeKind.bitfield => {
                converted.appendSlice(enumOrBitFieldConverted(self.undecorated_json_type)) catch {};
            },
            TypeKind.builtin_type => {
                if (!is_return_type) {
                    converted.appendSlice("*const ") catch {};
                }
                converted.appendSlice(self.undecorated_json_type) catch {};
            },
            TypeKind.typed_array => {
                const typed = typedArrayConverted(self.undecorated_json_type);
                defer typed.deinit();
                converted.appendSlice(typed.items) catch {};
            },
            TypeKind.class => {
                converted.appendSlice("?*") catch {};
                converted.appendSlice(self.undecorated_json_type) catch {};
            },
            TypeKind.native_struct => {
                converted.appendSlice(self.undecorated_json_type) catch {};
            },
        }
        return converted;
    }

};


fn stringFunctionSignatureBase(is_method: bool, function_name: []const u8, parsed_return_type_string: []const u8, is_const: bool, is_vararg: bool, arguments: ?*const std.json.Array) String { //Must deinit string
    var signature_args = String.init(std.heap.page_allocator);
    defer signature_args.deinit();

    if (arguments != null) {
        const arg_begin: usize = if (is_method) 1 else 0;
        for (arguments.?.items, arg_begin..) |arguments_item, arg_index| {
            const argument = arguments_item.object;

            const arg_name = argument.get("name").?.string;
            const raw_type = if (argument.get("meta")) |meta| meta.string else argument.get("type").?.string;
            const parsed_arg_type = ParsedType.new(raw_type);
            const string_type = parsed_arg_type.stringConverted(false);
            defer string_type.deinit();

            // NOTE: Zig doesn't really have default arguments
            // const arg_has_default = argument.get("has_default_value").?.bool;
            // const arg_default_value = argument.get("default_value").?.string;

            if (arg_index > 0) {
                signature_args.appendSlice(", ") catch {};
            }
            std.fmt.format(signature_args.writer(), "p_{s}: {s}", .{ arg_name, string_type.items }) catch {};
        }
    }
    if (is_vararg) {
        const arg_count = if (arguments != null) arguments.?.items.len else 0;
        const total_arg_count = if (is_method) arg_count + 1 else arg_count;
        if (total_arg_count > 0) {
            signature_args.appendSlice(", ") catch {};
        }
        signature_args.appendSlice("p_vararg: anytype") catch {};
    }

    const camel_function_name = toCamelCase(function_name);
    defer camel_function_name.deinit();

    var string = String.init(std.heap.page_allocator);
    if (is_method) {
        const constness_string = if (is_const) "const " else "";
        std.fmt.format(string.writer(),
            "    pub fn {s}(self: *{s}Self{s}) {s} {{\n",
            .{ camel_function_name.items, constness_string, signature_args.items, parsed_return_type_string }) catch {};
    } else {
        std.fmt.format(string.writer(),
            "    pub fn {s}({s}) {s} {{\n",
            .{ camel_function_name.items, signature_args.items, parsed_return_type_string }) catch {};
    }

    return string;
}

inline fn stringFunctionSignature(function_name: []const u8, parsed_return_type_string: []const u8, is_vararg: bool, arguments: ?*const std.json.Array) String { //Must deinit string
    return stringFunctionSignatureBase(false, function_name, parsed_return_type_string, false, is_vararg, arguments);
}

inline fn stringMethodSignature(method_name: []const u8, parsed_return_type_string: []const u8, is_const: bool, is_vararg: bool, arguments: ?*const std.json.Array) String { //Must deinit string
    return stringFunctionSignatureBase(true, method_name, parsed_return_type_string, is_const, is_vararg, arguments);
}

fn stringArgsEncoding(arguments: ?*const std.json.Array) String { //Must deinit string
    var string = String.init(std.heap.page_allocator);
    if (arguments != null) {
        for (arguments.?.items) |arguments_item| {
            const argument = arguments_item.object;

            const arg_name = argument.get("name").?.string;
            const parsed_arg_type = ParsedType.new(argument.get("type").?.string);

            if (parsed_arg_type.type_kind == TypeKind.primitive and parsed_arg_type.pointer == 0) {
                if (isBool(parsed_arg_type.undecorated_json_type)) {
                    std.fmt.format(string.writer(), "        const p_{s}_encoded: u8 = @intFromBool(p_{s});\n", .{ arg_name, arg_name }) catch {};
                } else if (isInt(parsed_arg_type.undecorated_json_type)) {
                    std.fmt.format(string.writer(), "        const p_{s}_encoded: u64 = @as(u64, @intCast(p_{s}));\n", .{ arg_name, arg_name }) catch {};
                } else if (isFloat(parsed_arg_type.undecorated_json_type)) {
                    std.fmt.format(string.writer(), "        const p_{s}_encoded: f64 = @floatCast(p_{s});\n", .{ arg_name, arg_name }) catch {};
                } else {
                    @panic("Unexpected primitive encoding");
                }
            }
        }
    }
    return string;
}

fn stringArgs(arguments: ?*const std.json.Array) String { //Must deinit string
    var string = String.init(std.heap.page_allocator);
    if (arguments != null) {
        for (arguments.?.items, 0..) |arguments_item, index| {
            const argument = arguments_item.object;

            const arg_name = argument.get("name").?.string;
            const parsed_arg_type = ParsedType.new(argument.get("type").?.string);

            if (parsed_arg_type.pointer > 0) {
                std.fmt.format(string.writer(), "p_{s}", .{ arg_name }) catch {};
            } else {
                switch (parsed_arg_type.type_kind) {
                    TypeKind.class => {
                        std.fmt.format(string.writer(), "(if (p_{s} != null) p_{s}._wrappedOwner() else null)", .{ arg_name, arg_name }) catch {};
                    },
                    TypeKind.primitive => {
                        std.fmt.format(string.writer(), "&p_{s}_encoded", .{ arg_name }) catch {};
                    },
                    TypeKind.enum_, TypeKind.bitfield => {
                        std.fmt.format(string.writer(), "&p_{s}", .{ arg_name }) catch {};
                    },
                    else => {
                        std.fmt.format(string.writer(), "p_{s}", .{ arg_name }) catch {};
                    }
                }
            }

            if (index < (arguments.?.items.len - 1)) {
                string.appendSlice(", ") catch {};
            }
        }
    }
    return string;
}


fn filterPutUniqueBuiltinClass(parsed_type: *const ParsedType, used: *std.StringHashMap(void)) void {
    switch (parsed_type.type_kind) {
        TypeKind.builtin_type => {
            used.put(parsed_type.undecorated_json_type, {}) catch {};
        },
        TypeKind.typed_array => {
            used.put("TypedArray", {}) catch {};
            const array_type = typedArrayGetType(parsed_type.undecorated_json_type);
            if (isBuiltinType(array_type)) {
                used.put(array_type, {}) catch {};
            }
        },
        TypeKind.enum_ => {
            if (isUnformattedEnum(parsed_type.undecorated_json_type)) {
                const class = unformattedEnumGetClass(parsed_type.undecorated_json_type);
                if (isBuiltinType(class)) {
                    used.put(class, {}) catch {};
                }
            }
            else if (isClassEnum(parsed_type.undecorated_json_type)) {
                const class = enumOrBitFieldGetClass(parsed_type.undecorated_json_type);
                if (isBuiltinType(class)) {
                    used.put(class, {}) catch {};
                }
            }
        },
        TypeKind.bitfield => {
            if (isClassBitfield(parsed_type.undecorated_json_type)) {
                const class = enumOrBitFieldGetClass(parsed_type.undecorated_json_type);
                if (isBuiltinType(class)) {
                    used.put(class, {}) catch {};
                }
            }
        },
        else => {},
    }
}

fn filterPutUniqueClass(parsed_type: *const ParsedType, used: *std.StringHashMap(void)) void {
    switch (parsed_type.type_kind) {
        TypeKind.class => {
            used.put(parsed_type.undecorated_json_type, {}) catch {};
        },
        TypeKind.native_struct => {
            used.put(parsed_type.undecorated_json_type, {}) catch {};
        },
        TypeKind.enum_ => {
            if (isUnformattedEnum(parsed_type.undecorated_json_type)) {
                const class = unformattedEnumGetClass(parsed_type.undecorated_json_type);
                if (!isBuiltinType(class)) {
                    used.put(class, {}) catch {};
                }
            }
            else if (isClassEnum(parsed_type.undecorated_json_type)) {
                const class = enumOrBitFieldGetClass(parsed_type.undecorated_json_type);
                if (!isBuiltinType(class)) {
                    used.put(class, {}) catch {};
                }
            }
        },
        TypeKind.bitfield => {
            if (isClassBitfield(parsed_type.undecorated_json_type)) {
                const class = enumOrBitFieldGetClass(parsed_type.undecorated_json_type);
                if (!isBuiltinType(class)) {
                    used.put(class, {}) catch {};
                }
            }
        },
        TypeKind.typed_array => {
            const array_type = typedArrayGetType(parsed_type.undecorated_json_type);
            if (isClassType(array_type) or isNativeStructType(array_type)) {
                used.put(array_type, {}) catch {};
            }
        },
        else => {},
    }
}

fn filterPutUniqueGlobalEnums(parsed_type: *const ParsedType, used: *std.StringHashMap(void)) void {
    switch (parsed_type.type_kind) {
        TypeKind.enum_ => {
            if (isGlobalEnum(parsed_type.undecorated_json_type)) {
                used.put(parsed_type.undecorated_json_type, {}) catch {};
            }
        },
        TypeKind.bitfield => {
            if (isGlobalBitfield(parsed_type.undecorated_json_type)) {
                used.put(parsed_type.undecorated_json_type, {}) catch {};
            }
        },
        else => {},
    }
}


fn getUsedTypesByFunction(function: *const std.json.ObjectMap, json_types: *std.ArrayList([]const u8)) void {
    if (function.get("return_type")) |get_return_type| {
        json_types.append(get_return_type.string) catch {};
    } else if (function.get("return_value")) |get_return_value| {
        const return_value_object = get_return_value.object;
        const return_type = return_value_object.get("type").?.string;
        json_types.append(return_type) catch {};
    }

    if (function.get("arguments")) |get_arguments| {
        const arguments = get_arguments.array;
        for (arguments.items) |arguments_item| {
            const argument = arguments_item.object;
            const arg_type = argument.get("type").?.string;
            json_types.append(arg_type) catch {};
        }
    }
}

fn getUsedTypesByClass(class: *const std.json.ObjectMap, json_types: *std.ArrayList([]const u8)) void {
    if (class.get("inherits")) |get_inherits| {
        json_types.append(get_inherits.string) catch {};
    }

    if (class.get("methods")) |get_methods| {
        const methods = get_methods.array;
        for (methods.items) |item| {
            const method = item.object;
            getUsedTypesByFunction(&method, json_types);
        }
    }
}


fn generateClass(class: *const std.json.ObjectMap) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    const class_name = class.get("name").?.string;
    const stripped_class_name = stripClassName(class_name);
    defer stripped_class_name.deinit();

    var base_class_name: []const u8 = "Wrapped";
    if (class.get("inherits")) |get_inherits| {
        base_class_name = get_inherits.string;
    }

    var stripped_base_name = stripClassName(base_class_name);
    defer stripped_base_name.deinit();

    // Import api
    {
        try string.appendSlice("const gi = @import(\"../../gdextension_interface.zig\");\n");
        try string.appendSlice("const gd = @import(\"../../godot.zig\");\n\n");

        try string.appendSlice("const Wrapped = @import(\"../../core/wrapped.zig\").Wrapped;\n");
        try string.appendSlice("const GDExtensionClass = @import(\"../../core/wrapped.zig\").GDExtensionClass;\n");
        try string.appendSlice("const _ClassDB = @import(\"../../core/class_db.zig\").ClassDB;\n"); // Underscore so it doesn't conflict with generated ClassDB
        try string.appendSlice("const _Variant = @import(\"../../variant/variant.zig\").Variant;\n\n"); // Underscore to not conflict when importing Variant as used builtin type
    }

    var json_types = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer json_types.deinit();
    getUsedTypesByClass(class, &json_types);

    var parsed_types = std.ArrayList(ParsedType).init(std.heap.page_allocator);
    defer parsed_types.deinit();
    try parsed_types.resize(json_types.items.len);
    for (json_types.items, 0..) |json_type, i| {
        parsed_types.items[i] = ParsedType.new(json_type);
    }

    // Import core types, must declare every identifier so we can have a local scope of it, since they removed that behaviour from usingnamespace...
    {
        var used_builtin = std.StringHashMap(void).init(std.heap.page_allocator);
        defer used_builtin.deinit();
        for (parsed_types.items) |parsed_type| {
            filterPutUniqueBuiltinClass(&parsed_type, &used_builtin);
        }
        try used_builtin.put("StringName", {}); // Always import StringName, since its used for binds

        if (used_builtin.count() > 0) {
            try string.appendSlice("const ct = @import(\"../../core/core_types.zig\");\n");
        }

        var iterator = used_builtin.iterator();
        while (iterator.next()) |entry| {
            const used_builtin_name = entry.key_ptr.*;
            try std.fmt.format(string.writer(), "const {s} = ct.{s};\n", .{ used_builtin_name, used_builtin_name });
        }

        if (used_builtin.count() > 0) {
            try string.appendSlice("\n");
        }
    }

    // Same for global constants enums...
    {
        var used_globals = std.StringHashMap(void).init(std.heap.page_allocator);
        defer used_globals.deinit();
        for (parsed_types.items) |parsed_type| {
            filterPutUniqueGlobalEnums(&parsed_type, &used_globals);
        }

        if (used_globals.count() > 0) {
            try string.appendSlice("const gc = @import(\"global_constants.zig\");\n");
        }

        var iterator = used_globals.iterator();
        while (iterator.next()) |entry| {
            const used_global_enum = entry.key_ptr.*;
            const used_enum_name = enumOrBitFieldConverted(used_global_enum);
            try std.fmt.format(string.writer(), "const {s} = gc.{s};\n", .{ used_enum_name, used_enum_name });
        }

        if (used_globals.count() > 0) {
            try string.appendSlice("\n");
        }
    }

    // Import any other classes used by this one // While also making sure that they get imported only once
    {
        var used_classes = std.StringHashMap(void).init(std.heap.page_allocator);
        defer used_classes.deinit();
        for (parsed_types.items) |parsed_type| {
            filterPutUniqueClass(&parsed_type, &used_classes);
        }

        var iterator = used_classes.iterator();
        while (iterator.next()) |entry| {
            const used_class_name = entry.key_ptr.*;
            const used_class_stripped = stripClassName(used_class_name);

            if (std.mem.eql(u8, used_class_stripped.items, stripped_class_name.items)) { // Dont import self
                continue;
            }

            const used_class_convention = toSnakeCase(used_class_stripped.items);
            defer used_class_convention.deinit();

            try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ used_class_name, used_class_convention.items, used_class_name });
        }

        if (used_classes.count() > 0) {
            try string.appendSlice("\n");
        }
    }

    // Class struct definition
    {
        try std.fmt.format(string.writer(), "pub const {s} = struct {{\n\n", .{ stripped_class_name.items }); // Extra { to escape it

        try string.appendSlice("    const Self = @This();\n\n");

        try std.fmt.format(string.writer(),"    pub const GodotClass = GDExtensionClass(Self, {s});\n", .{ stripped_base_name.items });
        try string.appendSlice("    pub usingnamespace GodotClass;\n");
        try string.appendSlice("    _godot_class: GodotClass,\n\n");
    }

    // Enums
    if (class.get("enums")) |get_enums| {
        const enums = get_enums.array;
        for (enums.items) |enum_item| {
            const enum_object = enum_item.object;
            const enum_name = enum_object.get("name").?.string;
            try std.fmt.format(string.writer(), "    pub const {s} = enum(i32) {{\n", .{ enum_name });

            const values = enum_object.get("values").?.array;
            for (values.items) |values_item| {
                const value_object = values_item.object;
                const value_name = value_object.get("name").?.string;
                const value = value_object.get("value").?.integer;

                const convention_name = toSnakeCase(value_name);
                defer convention_name.deinit();

                try std.fmt.format(string.writer(), "        {s} = {},\n", .{ convention_name.items, value });
            }

            // Enum end
            try string.appendSlice("    };\n\n");
        }
    }

    // Constants
    if (class.get("constants")) |get_constants| {
        const constants = get_constants.array;
        for (constants.items) |constant_item| {
            const constant_object = constant_item.object;
            const constant_name = constant_object.get("name").?.string;

            var value_string = String.init(std.heap.page_allocator);
            defer value_string.deinit();
            if (constant_object.get("type")) |get_type| {
                const constant_type = get_type.string;
                const constant_value = constant_object.get("value").?.string;

                //TODO: Handle other types
                if (!std.mem.eql(u8, constant_type, "int")) {
                    continue;
                }
 
                try std.fmt.format(value_string.writer(), "{s}", .{ constant_value });
            } else {
                const constant_value = constant_object.get("value").?.integer;
                try std.fmt.format(value_string.writer(), "{}", .{ constant_value });
            }

            const convention_name = toSnakeCase(constant_name);
            defer convention_name.deinit();

            try std.fmt.format(string.writer(), "    pub const {s} = {s};\n", .{ convention_name.items, value_string.items });
        }

        if (constants.items.len > 0) {
            try string.appendSlice("\n");
        }
    }

    // Use another string for virtual binds so we can do both in a single method pass
    var virtuals_string = String.init(std.heap.page_allocator);
    defer virtuals_string.deinit();

    {
        try virtuals_string.appendSlice("    pub fn bindVirtuals(comptime T: type, comptime B: type) void {\n");
        if (class.get("inherits")) |_| {
            try std.fmt.format(virtuals_string.writer(), "        {s}.bindVirtuals(T, B);\n", .{ stripped_base_name.items });
        } else {
            try virtuals_string.appendSlice("        _ = T; _ = B;\n");
        }
    }

    if (isClassSingleton(class_name)) {
        try string.appendSlice(
            "    pub fn _getSingleton() *Self {\n" ++
            "        const __class_name = Self.getClassStatic();\n" ++
            "        const __singleton_obj = gd.interface.?.global_get_singleton.?(__class_name._nativePtr());\n" ++
            "        return @alignCast(@ptrCast(gd.interface.?.object_get_instance_binding.?(__singleton_obj, gd.token, Self._getBindingCallbacks())));\n" ++
            "    }\n\n"
        );
    }

    if (class.get("methods")) |get_methods| {
        const methods = get_methods.array;

        // Method implementations
        for (methods.items) |item| {
            const method = item.object;

            const method_name = method.get("name").?.string;
            const escaped_method_name = escapeFunctionName(method_name);
            defer escaped_method_name.deinit();

            const parsed_return_type = blk: {
                var json_return_type: []const u8 = "void";
                if (method.get("return_value")) |get_return_value| {
                    const return_value_object = get_return_value.object;
                    if (return_value_object.get("meta")) |meta| {
                        json_return_type = meta.string;
                    } else {
                        json_return_type = return_value_object.get("type").?.string;
                    }
                }
                break :blk ParsedType.new(json_return_type);
            };
            const return_string_type = parsed_return_type.stringConverted(true);
            defer return_string_type.deinit();

            const has_return_value = method.get("return_value") != null;
            const is_vararg = method.get("is_vararg").?.bool;
            const is_const = method.get("is_const").?.bool;
            const is_virtual = method.get("is_virtual").?.bool;
            const method_hash = if (method.get("hash")) |get_hash| get_hash.integer else 0;

            const arg_arguments = if (method.get("arguments")) |get_arguments| &get_arguments.array else null;

            // Method signature
            {
                const method_signature = stringMethodSignature(escaped_method_name.items, return_string_type.items, is_const, is_vararg, arg_arguments);
                defer method_signature.deinit();
                try string.appendSlice(method_signature.items);
            }

            // Method content
            if (is_virtual) {
                const camel_method_name = toCamelCase(escaped_method_name.items);
                defer camel_method_name.deinit();

                // Bind
                try std.fmt.format(virtuals_string.writer(), "        if (comptime _ClassDB.findVirtualMethodClass(T, \"{s}\")) |overrided| {{\n", .{ camel_method_name.items });
                try std.fmt.format(virtuals_string.writer(), "            _ClassDB.bindVirtualMethod(T, overrided.{s}, \"{s}\", .{{}});\n", .{ camel_method_name.items, escaped_method_name.items });
                try virtuals_string.appendSlice("        }\n");

                // Virtual functions are only meant to be stubs
                try string.appendSlice("        _ = self;\n");
                if (arg_arguments != null) {
                    for (arg_arguments.?.items) |arguments_item| {
                        const argument = arguments_item.object;

                        const arg_name = argument.get("name").?.string;
                        try std.fmt.format(string.writer(), "        _ = p_{s};\n", .{ arg_name });
                    }
                }
                if (has_return_value) {
                    try std.fmt.format(string.writer(), "        return _Variant.defaultConstruct({s});\n", .{ return_string_type.items });
                }
            } else {
                try string.appendSlice("        const __class_name = Self.getClassStatic();\n");

                try std.fmt.format(string.writer(),
                    "        var __method_name = StringName.initUtf8(\"{s}\");\n",
                    .{ escaped_method_name.items });

                try string.appendSlice(
                    "        defer __method_name.deinit();\n");

                try std.fmt.format(string.writer(), 
                    "        const _gde_method_bind = gd.interface.?.classdb_get_method_bind.?(__class_name._nativePtr(), __method_name._nativePtr(), {});\n", 
                    .{ method_hash });

                // Method call args
                const args_encoding = stringArgsEncoding(arg_arguments);
                defer args_encoding.deinit();
                try string.appendSlice(args_encoding.items);

                const args_tuple = stringArgs(arg_arguments);
                defer args_tuple.deinit();

                const no_return = std.mem.eql(u8, return_string_type.items, "void");
                if (is_vararg) {
                    try std.fmt.format(string.writer(), "        const ret = gd.callMbRet(_gde_method_bind, self._wrappedOwner(), .{{ {s} }} ++ p_vararg);\n", .{ args_tuple.items });
                    if (no_return) {
                        try string.appendSlice("        _ = ret;\n");
                    } else {
                        if (std.mem.eql(u8, return_string_type.items, "Variant")) {
                            try string.appendSlice("        return ret;\n");
                        } else {
                            try std.fmt.format(string.writer(), "        return ret.as({s});\n", .{ return_string_type.items });
                        }
                    }
                } else {
                    if (std.mem.eql(u8, return_string_type.items, "void")) { // No return
                        try std.fmt.format(string.writer(), "        gd.callNativeMbNoRet(_gde_method_bind, self._wrappedOwner(), .{{ {s} }});\n", .{ args_tuple.items });
                    } else {
                        if (parsed_return_type.type_kind == TypeKind.class) {
                            try std.fmt.format(string.writer(), "        return gd.callNativeMbRetObj({s}, _gde_method_bind, self._wrappedOwner(), .{{ {s} }});\n", .{ return_string_type.items, args_tuple.items });
                        } else {
                            try std.fmt.format(string.writer(), "        return gd.callNativeMbRet({s}, _gde_method_bind, self._wrappedOwner(), .{{ {s} }});\n", .{ return_string_type.items, args_tuple.items });
                        }
                    }
                }
            }

            // Method end
            try string.appendSlice("    }\n\n");
        }
    }

    {
        try virtuals_string.appendSlice("    }\n\n"); // bindVirtuals end
        try string.appendSlice(virtuals_string.items);
    }

    // Class struct end
    try string.appendSlice("};\n");

    return string;
}

fn generateClassBindings(classes: *const std.json.Array) !void {
    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen/classes", .{});

    for (classes.items) |item| {
        const class = item.object;

        const class_name = class.get("name").?.string;
        const stripped_name = stripClassName(class_name);
        defer stripped_name.deinit();
        const convention_name = toSnakeCase(stripped_name.items);
        defer convention_name.deinit();

        var class_file_name = String.init(std.heap.page_allocator);
        defer class_file_name.deinit();
        try std.fmt.format(class_file_name.writer(), "{s}.zig", .{convention_name.items});

        const file_string = try generateClass(&class);

        const class_file = try gen_dir.createFile(class_file_name.items, .{});
        defer class_file.close();
        try class_file.writeAll(file_string.items);
    }
}


const StructField = struct {
    raw_type: []const u8,
    pointer: usize,
    array: usize,
    identifier: []const u8,
};

var real_t_32bits = false;
inline fn isReal32Bits() bool {
    return real_t_32bits;
}

fn extractFormatFields(format: []const u8, fields: *std.ArrayList(StructField)) void {
    var slice = format;
    while (true) {
        var raw_type = slice;
        {
            const needle = " ";
            const index = std.mem.indexOf(u8, slice, needle);
            raw_type = slice[0..index.?];
            slice = slice[(index.? + needle.len)..slice.len];
        }

        {
            //NOTE: Godot int and float are always 64 bit, except on struct fields where they are 32bit... so we must convert them for proper layout sizes...
            if (std.mem.eql(u8, raw_type, "int")) {
                raw_type = "int32";
            } else if (std.mem.eql(u8, raw_type, "float")) {
                raw_type = "float32";
            }
            //Also real_t can be either 32bit or 64bit depending on build config...
            if (std.mem.eql(u8, raw_type, "real_t")) {
                if (isReal32Bits()) {
                    raw_type = "float32";
                } else {
                    raw_type = "double";
                }
            }
        }

        var pointer: usize = 0;
        {
            const end_needle = ";";
            const end_index = std.mem.indexOf(u8, slice, end_needle);
            const statement_end_index = if (end_index != null) end_index.? else slice.len;

            const ptr_needle = "*";
            const ptr_index = std.mem.indexOf(u8, slice, ptr_needle);
            if (ptr_index != null and ptr_index.? < statement_end_index) {
                pointer += 1;
                slice = slice[(ptr_index.? + ptr_needle.len)..slice.len];
            }
        }

        var identifier = slice;
        var done = false;
        {
            const end_needle = ";";
            const end_index = std.mem.indexOf(u8, slice, end_needle);
            const statement_end_index = if (end_index != null) end_index.? else slice.len;

            // Skip initialization value (if any)
            const assign_needle = " ";
            const assign_index = std.mem.indexOf(u8, slice, assign_needle);

            var identifier_end_index = statement_end_index;
            if (assign_index != null and assign_index.? < identifier_end_index) {
                identifier_end_index = assign_index.?;
            }
            identifier = slice[0..identifier_end_index];

            if (statement_end_index + end_needle.len < slice.len) {
                slice = slice[(statement_end_index + end_needle.len)..slice.len];
            } else {
                done = true;
            }
        }

        var array: usize = 0;
        {
            const end_needle = ";";
            const end_index = std.mem.indexOf(u8, slice, end_needle);
            const statement_end_index = if (end_index != null) end_index.? else slice.len;

            const array_begin_needle = "[";
            const array_begin_index = std.mem.indexOf(u8, slice, array_begin_needle);
            if (array_begin_index != null and array_begin_index.? < statement_end_index) {
                const array_end_needle = "]";
                const array_end_index = std.mem.indexOf(u8, slice, array_end_needle);
                const array_string = slice[(array_begin_index.? + array_begin_needle.len)..array_end_index.?];
                array = std.fmt.parseInt(usize, array_string, 10) catch 0;
                slice = slice[(array_end_index.? + array_end_needle.len)..slice.len];
                slice = slice[end_needle.len..slice.len]; // Implicitly skip end statement ";"
            }
        }

        const field = StructField {
            .raw_type = raw_type,
            .pointer = pointer,
            .array = array,
            .identifier = identifier,
        };
        fields.append(field) catch {};

        if (done) {
            break;
        }
    }
}


fn unformattedEnumConverted(raw_type: []const u8) String { //Must deinit string //Assumes parameter isUnformattedEnum()
    const needle = "::";
    const index = std.mem.indexOf(u8, raw_type, needle);
    const class_name = raw_type[0..index.?];
    const enum_name = raw_type[(index.? + needle.len)..raw_type.len];

    var converted = String.init(std.heap.page_allocator);
    std.fmt.format(converted.writer(), "{s}.{s}", .{ class_name, enum_name }) catch {};
    return converted;
}

fn structRawTypeToZigType(raw_type: []const u8) String { //Must deinit string
    if (isUnformattedEnum(raw_type)) {
        return unformattedEnumConverted(raw_type);
    } else if (isPrimitive(raw_type)) {
        var converted = String.init(std.heap.page_allocator);
        converted.appendSlice(convertPrimitiveBaseTypeToZig(raw_type).?) catch {};
        return converted;
    } else {
        return stripClassName(raw_type);
    }
}

fn generateNativeStruct(native_struct: *const std.json.ObjectMap) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    const class_name = native_struct.get("name").?.string;
    const stripped_class_name = stripClassName(class_name);
    defer stripped_class_name.deinit();

    const format = native_struct.get("format").?.string;
    var fields = std.ArrayList(StructField).init(std.heap.page_allocator);
    defer fields.deinit();
    extractFormatFields(format, &fields);

    var parsed_types = std.ArrayList(ParsedType).init(std.heap.page_allocator);
    defer parsed_types.deinit();
    try parsed_types.resize(fields.items.len);
    for (fields.items, 0..) |field, i| {
        parsed_types.items[i] = ParsedType.new(field.raw_type);
    }

    { // Import any used builtin classes, once
        var used_builtin = std.StringHashMap(void).init(std.heap.page_allocator);
        defer used_builtin.deinit();
        for (parsed_types.items) |parsed_type| {
            filterPutUniqueBuiltinClass(&parsed_type, &used_builtin);
        }

        if (used_builtin.count() > 0) {
            try string.appendSlice("const ct = @import(\"../../core/core_types.zig\");\n");
        }

        var iterator = used_builtin.iterator();
        while (iterator.next()) |entry| {
            const used_builtin_name = entry.key_ptr.*;
            try std.fmt.format(string.writer(), "const {s} = ct.{s};\n", .{ used_builtin_name, used_builtin_name });
        }
    }

    { // Import any used classes, once
        var used_classes = std.StringHashMap(void).init(std.heap.page_allocator);
        defer used_classes.deinit();
        for (parsed_types.items) |parsed_type| {
            filterPutUniqueClass(&parsed_type, &used_classes);
        }

        var iterator = used_classes.iterator();
        while (iterator.next()) |entry| {
            const used_class_name = entry.key_ptr.*;
            const used_class_stripped = stripClassName(used_class_name);

            if (std.mem.eql(u8, used_class_stripped.items, stripped_class_name.items)) { // Dont import self
                continue;
            }

            const used_class_convention = toSnakeCase(used_class_stripped.items);
            defer used_class_convention.deinit();

            try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ used_class_name, used_class_convention.items, used_class_name });
        }

        try string.appendSlice("\n");
    }

    try std.fmt.format(string.writer(), "pub const {s} = extern struct {{\n", .{ stripped_class_name.items });

    for (fields.items) |field| {
        try std.fmt.format(string.writer(), "    {s}: ", .{ field.identifier });

        var i: usize = 0;
        while (i < field.pointer) : (i += 1) {
            try string.appendSlice("[*c]");
        }

        if (field.array > 0) {
            try std.fmt.format(string.writer(), "[{}]", .{ field.array });
        }

        const converted_type = structRawTypeToZigType(field.raw_type);
        defer converted_type.deinit();
        try std.fmt.format(string.writer(), "{s},\n", .{ converted_type.items });
    }

    try string.appendSlice("};\n"); // Struct end

    return string;
}

fn generateNativeStructs(native_structs: *const std.json.Array) !void {
    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen/classes", .{});
    for (native_structs.items) |item| {
        const native_struct = item.object;

        const class_name = native_struct.get("name").?.string;
        const stripped_name = stripClassName(class_name);
        defer stripped_name.deinit();
        const convention_name = toSnakeCase(stripped_name.items);
        defer convention_name.deinit();

        var class_file_name = String.init(std.heap.page_allocator);
        defer class_file_name.deinit();
        try std.fmt.format(class_file_name.writer(), "{s}.zig", .{convention_name.items});

        const file_string = try generateNativeStruct(&native_struct);

        const class_file = try gen_dir.createFile(class_file_name.items, .{});
        defer class_file.close();
        try class_file.writeAll(file_string.items);
    }
}


fn writeImportString(string: *String, class: *const std.json.ObjectMap) !void {
    const class_name = class.get("name").?.string;
    const stripped_name = stripClassName(class_name);
    defer stripped_name.deinit();

    const convention_name = toSnakeCase(stripped_name.items);
    defer convention_name.deinit();

    try std.fmt.format(string.writer(), "pub const {s} = @import(\"{s}.zig\").{s};\n", .{ stripped_name.items, convention_name.items, stripped_name.items });
}

fn generatePackageClassImports(classes: *const std.json.Array, native_structs: *const std.json.Array) !void {
    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen/classes", .{});

    const imports_file = try gen_dir.createFile("_classes.zig", .{});
    defer imports_file.close();

    var string = String.init(std.heap.page_allocator);
    defer string.deinit();

    try string.appendSlice("pub const UtilityFunctions = @import(\"utility_functions.zig\").UtilityFunctions;");

    //Class imports
    for (classes.items) |item| {
        try writeImportString(&string, &item.object);
    }

    //Struct imports
    for (native_structs.items) |item| {
        try writeImportString(&string, &item.object);
    }

    try imports_file.writeAll(string.items);
}


fn getVariantTypeEnum(string: []const u8) String { //Must deinit string
    if (std.mem.eql(u8, string, "Variant")) { // Special case...
        var converted = String.init(std.heap.page_allocator);
        converted.appendSlice("NIL") catch {};
        return converted;
    }

    const converted = toSnakeCase(string);
    upperString(converted.items);
    return converted;
}

fn getBuiltinClassSize(string: []const u8, class_sizes: *const std.json.Array) i64 {
    for (class_sizes.items) |item| {
        const class_object = item.object;
        const class_name = class_object.get("name").?.string;
        if (std.mem.eql(u8, string, class_name)) {
            const class_size = class_object.get("size").?.integer;
            return class_size;
        }
    }
    return 0;
}

fn getOperatorNameIdentifier(string: []const u8) []const u8 {
    const operators = [_][2][]const u8 {
        .{ "==", "equal" },
        .{ "!=", "notEqual" },
        .{ "<", "less" },
        .{ "<=", "lessEqual" },
        .{ ">", "greater" },
        .{ ">=", "greaterEqual" },
        .{ "+", "add" },
        .{ "-", "substract" },
        .{ "*", "multiply" },
        .{ "/", "divide" },
        .{ "unary-", "negate" },
        .{ "unary+", "positive" },
        .{ "%", "module" },
        .{ "**", "power" },
        .{ "<<", "usize" },
        .{ ">>", "f32" },
        .{ "&", "bitAnd" },
        .{ "|", "bitOr" },
        .{ "^", "bitXor" },
        .{ "~", "bitNegate" },
        .{ "and", "and" },
        .{ "or", "or" },
        .{ "xor", "xor" },
        .{ "not", "not" },
        .{ "in", "in" },
    };

    var i: usize = 0;
    while (i < operators.len) : (i += 1) {
        if (std.mem.eql(u8, string, operators[i][0])) {
            return operators[i][1];
        }
    }
    return "";
}

fn getUsedBuiltinClasses(class: *const std.json.ObjectMap) std.StringHashMap(void) { //Must deinit hashmap
    var classes = std.StringHashMap(void).init(std.heap.page_allocator);

    if (class.get("constructors")) |get_constructors| {
        const constructors = get_constructors.array;
        for (constructors.items) |ctr_item| {
            const constructor = ctr_item.object;
            if (constructor.get("arguments")) |get_arguments| {
                const arguments = get_arguments.array;
                for (arguments.items) |arg_item| {
                    const argument = arg_item.object;
                    const arg_type = argument.get("type").?.string;
                    if (isBuiltinType(arg_type)) {
                        classes.put(arg_type, {}) catch {};
                    }
                }
            }
        }
    }

    if (class.get("methods")) |get_methods| {
        const methods = get_methods.array;
        for (methods.items) |method_item| {
            const method = method_item.object;
            if (method.get("arguments")) |get_arguments| {
                const arguments = get_arguments.array;
                for (arguments.items) |arg_item| {
                    const argument = arg_item.object;
                    const arg_type = argument.get("type").?.string;
                    if (isBuiltinType(arg_type)) {
                        classes.put(arg_type, {}) catch {};
                    }
                }
            }
            if (method.get("return_type")) |get_return_type| {
                if (isBuiltinType(get_return_type.string)) {
                    classes.put(get_return_type.string, {}) catch {};
                }
            }
        }
    }

    if (class.get("operators")) |get_operators| {
        const operators = get_operators.array;
        for (operators.items) |item| {
            const operator = item.object;
            const right_type = operator.get("right_type").?.string;
            if (isBuiltinType(right_type)) {
                classes.put(right_type, {}) catch {};
            }
            const return_type = operator.get("return_type").?.string;
            if (isBuiltinType(return_type)) {
                classes.put(return_type, {}) catch {};
            }
        }
    }

    return classes;
}


fn stringBuiltinConstructorSignature(arguments: ?*const std.json.Array) String { //Must deinit string
    var arg_type_names = String.init(std.heap.page_allocator);
    defer arg_type_names.deinit();

    var signature_args = String.init(std.heap.page_allocator);
    defer signature_args.deinit();

    if (arguments != null) {
        for (arguments.?.items, 0..) |arguments_item, i| {
            const argument = arguments_item.object;

            const arg_type = argument.get("type").?.string;
            arg_type_names.appendSlice(arg_type) catch {};

            const parsed_arg_type = ParsedType.new(arg_type);
            const string_type = parsed_arg_type.stringConverted(false);
            defer string_type.deinit();

            const arg_name = argument.get("name").?.string;
            std.fmt.format(signature_args.writer(), "p_{s}: {s}", .{ arg_name, string_type.items }) catch {};

            if (i < (arguments.?.items.len - 1)) {
                signature_args.appendSlice(", ") catch {};
            }
        }
    }

    var string = String.init(std.heap.page_allocator);

    std.fmt.format(string.writer(),
        "    pub fn init{s}({s}) Self {{\n",
        .{ arg_type_names.items, signature_args.items, }) catch {};

    return string;
}


fn generateBuiltinClass(class: *const std.json.ObjectMap, class_sizes: *const std.json.Array) !String { //Must deinit string
    var class_string = String.init(std.heap.page_allocator);

    const class_name = class.get("name").?.string;

    // Import api
    {
        try class_string.appendSlice("const std = @import(\"std\");\n"); // Only imported to use std.mem.zeroes()
        try class_string.appendSlice("const gi = @import(\"../../gdextension_interface.zig\");\n");
        try class_string.appendSlice("const gd = @import(\"../../godot.zig\");\n\n");
    }

    // Import any other classes used by this one // While also making sure that they get imported only once
    {
        try class_string.appendSlice("const Wrapped = @import(\"../../core/wrapped.zig\").Wrapped;\n");
        try class_string.appendSlice("const Object = @import(\"../../gen/classes/object.zig\").Object;\n");
        try class_string.appendSlice("const ct = @import(\"../../core/core_types.zig\");\n");

        var used_builtin = getUsedBuiltinClasses(class);
        defer used_builtin.deinit();
        try used_builtin.put("StringName", {}); // Always import StringName, since its used for binds

        var iterator = used_builtin.iterator();
        while (iterator.next()) |entry| {
            const used_class_name = entry.key_ptr.*;

            if (std.mem.eql(u8, used_class_name, class_name)) { // Dont import self
                continue;
            }

            const convention_class_name = toSnakeCase(used_class_name);
            defer convention_class_name.deinit();

            try std.fmt.format(class_string.writer(), "const {s} = ct.{s};\n", .{ used_class_name, used_class_name });
        }

        try class_string.appendSlice("\n");
    }

    // Class struct definition
    {
        try std.fmt.format(class_string.writer(), "pub const {s} = extern struct {{\n\n", .{ class_name }); // Extra { to escape it

        const class_size = getBuiltinClassSize(class_name, class_sizes);
        try std.fmt.format(class_string.writer(), "    _opaque: [{}]u8,\n\n", .{ class_size }); // Extra { to escape it

        // Import extension methods namespaced here, so we can use them as if they were builtin
        try std.fmt.format(class_string.writer(), "    pub usingnamespace @import(\"../../variant/_extension_methods.zig\").{s}Ext;\n\n", .{ class_name });

        try class_string.appendSlice("    const Self = @This();\n\n");
    }

    // Use multiple strings so we can process de/con/structors, methods and operators in a single pass
    // NOTE: Separate de/con/structors from method binds to ensure its initalization before usage, particularly important due to constructing StringName to get the methods
    var def_binds = String.init(std.heap.page_allocator);
    defer def_binds.deinit();

    var init_ctr_binds = String.init(std.heap.page_allocator);
    defer init_ctr_binds.deinit();

    var init_mb_binds = String.init(std.heap.page_allocator);
    defer init_mb_binds.deinit();

    var impl_binds = String.init(std.heap.page_allocator);
    defer impl_binds.deinit();

    // Def binds begin
    {
        try def_binds.appendSlice("    const Binds = struct {\n");
    }

    // Init binds begin
    {
        const variant_type_enum = getVariantTypeEnum(class_name);
        defer variant_type_enum.deinit();

        // De/con/structors
        try init_ctr_binds.appendSlice("    pub fn initConstructorBinds() void {\n");
        // Convenience shorthands
        try std.fmt.format(init_ctr_binds.writer(), "        const this_vt = gi.GDExtensionVariantType.GDEXTENSION_VARIANT_TYPE_{s};\n", .{ variant_type_enum.items });
        try init_ctr_binds.appendSlice("        const ptr_ctor = gd.interface.?.variant_get_ptr_constructor.?;\n");

        // Regular methods
        try init_mb_binds.appendSlice("    pub fn initMethodBinds() void {\n");
        // Convenience shorthands
        try std.fmt.format(init_mb_binds.writer(), "        const this_vt = gi.GDExtensionVariantType.GDEXTENSION_VARIANT_TYPE_{s};\n", .{ variant_type_enum.items });
        try init_mb_binds.appendSlice(
            "        const ptr_mb = gd.interface.?.variant_get_ptr_builtin_method.?;\n" ++
            "        const ptr_op = gd.interface.?.variant_get_ptr_operator_evaluator.?;\n");
    }

    // Implicit methods
    {
        try impl_binds.appendSlice(
            "    pub inline fn _nativePtr(self: *const Self) gi.GDExtensionTypePtr {\n" ++
            "        return @constCast(@ptrCast(&self._opaque));\n" ++
            "    }\n\n");
    }

    const has_destructor = class.get("has_destructor").?.bool;
    if (has_destructor) {
        try def_binds.appendSlice("        destructor: gi.GDExtensionPtrDestructor,\n");

        try init_ctr_binds.appendSlice("        binds.destructor = gd.interface.?.variant_get_ptr_destructor.?(this_vt);\n");

        try impl_binds.appendSlice(
            "    pub fn deinit(self: *Self) void {\n" ++
            "        binds.destructor.?(&self._opaque);\n" ++
            "    }\n\n");
    }

    if (class.get("constructors")) |get_constructors| {
        const constructors = get_constructors.array;
        for (constructors.items) |item| {
            const constructor = item.object;

            const index = constructor.get("index").?.integer;
            try std.fmt.format(def_binds.writer(), "        constructor_{}: gi.GDExtensionPtrConstructor,\n", .{ index });

            try std.fmt.format(init_ctr_binds.writer(), "        binds.constructor_{} = ptr_ctor(this_vt, {});\n", .{ index, index });

            const arg_arguments = if (constructor.get("arguments")) |get_arguments| &get_arguments.array else null;
            const signature = stringBuiltinConstructorSignature(arg_arguments);
            defer signature.deinit();
            try impl_binds.appendSlice(signature.items);

            const args_encoding = stringArgsEncoding(arg_arguments);
            defer args_encoding.deinit();
            try impl_binds.appendSlice(args_encoding.items);

            const args_tuple = stringArgs(arg_arguments);
            defer args_tuple.deinit();

            try std.fmt.format(impl_binds.writer(), "        var self = std.mem.zeroes(Self);\n" ++
                    "        gd.callBuiltinConstructor(binds.constructor_{}, @ptrCast(&self._opaque), .{{ {s} }});\n" ++
                    "        return self;\n",
                .{ index, args_tuple.items });

            // Constructor end
            try impl_binds.appendSlice("    }\n\n");
        }
    }

    if (class.get("methods")) |get_methods| {
        const methods = get_methods.array;
        for (methods.items) |item| {
            const method = item.object;

            const method_name = method.get("name").?.string;
            const escaped_method_name = escapeFunctionName(method_name);
            defer escaped_method_name.deinit();

            const method_hash = method.get("hash").?.integer;

            try std.fmt.format(def_binds.writer(), "        {s}: gi.GDExtensionPtrBuiltInMethod,\n", .{ escaped_method_name.items });

            try std.fmt.format(init_mb_binds.writer(),
                "        {{ var __method_name = StringName.initUtf8(\"{s}\"); defer __method_name.deinit(); binds.{s} = ptr_mb(this_vt, __method_name._nativePtr(), {}); }}\n",
                . { method_name, escaped_method_name.items, method_hash });

            const parsed_return_type = blk: {
                var json_return_type: []const u8 = "void";
                if (method.get("return_type")) |get_return_type| {
                    json_return_type = get_return_type.string;
                }
                break :blk ParsedType.new(json_return_type);
            };
            const return_string_type = parsed_return_type.stringConverted(true);
            defer return_string_type.deinit();

            const is_vararg = method.get("is_vararg").?.bool;
            const is_const = method.get("is_const").?.bool;

            const arg_arguments = if (method.get("arguments")) |get_arguments| &get_arguments.array else null;

            // Method signature
            const method_signature = stringMethodSignature(escaped_method_name.items, return_string_type.items, is_const, is_vararg, arg_arguments);
            defer method_signature.deinit();
            try impl_binds.appendSlice(method_signature.items);

            // Method call args
            const args_encoding = stringArgsEncoding(arg_arguments);
            defer args_encoding.deinit();
            try impl_binds.appendSlice(args_encoding.items);

            const args_tuple = stringArgs(arg_arguments);
            defer args_tuple.deinit();

            const no_return = std.mem.eql(u8, return_string_type.items, "void");
            if (is_vararg) {
                try std.fmt.format(impl_binds.writer(), "        const ret = gd.callMbRet(binds.{s}, self._nativePtr(), .{{ {s} }} ++ p_vararg);\n", .{ escaped_method_name.items, args_tuple.items });
                if (no_return) {
                    try impl_binds.appendSlice("        _ = ret;\n");
                } else {
                    if (std.mem.eql(u8, return_string_type.items, "Variant")) {
                        try impl_binds.appendSlice("        return ret;\n");
                    } else {
                        try std.fmt.format(impl_binds.writer(), "        return ret.as({s});\n", .{ return_string_type.items });
                    }
                }
            } else {
                if (no_return) { // No return
                    try std.fmt.format(impl_binds.writer(),
                        "        gd.callBuiltinMbNoRet(binds.{s}, self._nativePtr(), .{{ {s} }});\n",
                        .{ escaped_method_name.items, args_tuple.items });
                } else {
                    try std.fmt.format(impl_binds.writer(),
                        "        return gd.callBuiltinMbRet({s}, binds.{s}, self._nativePtr(), .{{ {s} }});\n",
                        .{ return_string_type.items, escaped_method_name.items, args_tuple.items });
                }
            }

            // Method end
            try impl_binds.appendSlice("    }\n\n");
        }
    }

    if (class.get("operators")) |get_operators| {
        const operators = get_operators.array;
        for (operators.items) |item| {
            const operator = item.object;

            const name = operator.get("name").?.string;
            const right_type = operator.get("right_type").?.string;
            const return_type = operator.get("return_type").?.string;

            const operator_identifier = getOperatorNameIdentifier(name);

            var bind_name = String.init(std.heap.page_allocator);
            defer bind_name.deinit();
            try std.fmt.format(bind_name.writer(), "operator_{s}_{s}", .{ operator_identifier, right_type });

            try std.fmt.format(def_binds.writer(), "        {s}: gi.GDExtensionPtrOperatorEvaluator,\n", .{ bind_name.items });

            const operator_type_enum = getVariantTypeEnum(operator_identifier);
            defer operator_type_enum.deinit();

            const right_variant_type_enum = getVariantTypeEnum(right_type);
            defer right_variant_type_enum.deinit();

            try std.fmt.format(init_mb_binds.writer(),
                "        binds.{s} = ptr_op(gi.GDExtensionVariantOperator.GDEXTENSION_VARIANT_OP_{s}, this_vt, gi.GDExtensionVariantType.GDEXTENSION_VARIANT_TYPE_{s});\n",
                . { bind_name.items, operator_type_enum.items, right_variant_type_enum.items });

            // Method signature
            const parsed_right_type = ParsedType.new(right_type);
            const string_right_type = parsed_right_type.stringConverted(false);
            defer string_right_type.deinit();

            const parsed_return_type = ParsedType.new(return_type);
            const string_return_type = parsed_return_type.stringConverted(true);
            defer string_return_type.deinit();

            try std.fmt.format(impl_binds.writer(),
                "    pub fn {s}{s}(self: *const Self, other: {s}) {s} {{\n",
                .{ operator_identifier, right_type, string_right_type.items, string_return_type.items });
            
            // Method content
            try std.fmt.format(impl_binds.writer(), "        return gd.callBuiltinOperatorPtr({s}, binds.{s}, @ptrCast(&self._opaque), @ptrCast(other));\n", .{ string_return_type.items, bind_name.items});

            // Method end
            try impl_binds.appendSlice("    }\n\n");
        }
    }

    // Def binds end
    {
        try def_binds.appendSlice("    };\n\n");
        try def_binds.appendSlice("    var binds: Binds = undefined;\n\n");
    }

    { // Init constructor binds end
        try init_ctr_binds.appendSlice("    }\n\n");
    }

    // Init method binds end
    {
        try init_mb_binds.appendSlice("    }\n\n");
    }

    // Assemble string segments
    {
        try class_string.appendSlice(def_binds.items);
        try class_string.appendSlice(init_ctr_binds.items);
        try class_string.appendSlice(init_mb_binds.items);
        try class_string.appendSlice(impl_binds.items);
    }

    // Class struct end
    try class_string.appendSlice("};\n");

    return class_string;
}

fn isBuiltinClassExcluded(string: []const u8) bool {
    //Don't generate bindings for primitives or math types
    const excluded_types = [_][]const u8 {
        "AABB",
        "Basis",
        "bool",
        "Color",
        "float",
        "int",
        "Nil",
        "Plane",
        "Projection",
        "Quaternion",
        "Rect2",
        "Rect2i",
        "Transform2D",
        "Transform3D",
        "Vector2",
        "Vector2i",
        "Vector3",
        "Vector3i",
        "Vector4",
        "Vector4i",
    };

    for (excluded_types) |excluded| {
        if (std.mem.eql(u8, string, excluded)) {
            return true;
        }
    }
    return false;
}

fn generateBuiltinClassBindings(classes: *const std.json.Array, class_sizes: *const std.json.Array) !void {
    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen/builtin_classes", .{});

    for (classes.items) |item| {
        const class = item.object;

        const class_name = class.get("name").?.string;
        if (isBuiltinClassExcluded(class_name)) {
            continue;
        }

        const stripped_name = stripClassName(class_name);
        defer stripped_name.deinit();
        const convention_name = toSnakeCase(stripped_name.items);
        defer convention_name.deinit();

        var class_file_name = String.init(std.heap.page_allocator);
        defer class_file_name.deinit();
        try std.fmt.format(class_file_name.writer(), "{s}.zig", .{convention_name.items});

        const file_string = try generateBuiltinClass(&class, class_sizes);

        const class_file = try gen_dir.createFile(class_file_name.items, .{});
        defer class_file.close();
        try class_file.writeAll(file_string.items);
    }
}


fn generateUtilityFunction(function: *const std.json.ObjectMap) !String {
    var string = String.init(std.heap.page_allocator);

    const function_name = function.get("name").?.string;
    const escaped_function_name = escapeFunctionName(function_name);
    defer escaped_function_name.deinit();

    const parsed_return_type = blk: {
        var json_return_type: []const u8 = "void";
        if (function.get("return_type")) |get_return_type| {
            json_return_type = get_return_type.string;
        }
        break :blk ParsedType.new(json_return_type);
    };
    const return_string_type = parsed_return_type.stringConverted(true);
    defer return_string_type.deinit();

    const is_vararg = function.get("is_vararg").?.bool;
    const method_hash = if (function.get("hash")) |get_hash| get_hash.integer else 0;

    const arg_arguments = if (function.get("arguments")) |get_arguments| &get_arguments.array else null;

    // Function signature
    const function_signature = stringFunctionSignature(escaped_function_name.items, return_string_type.items, is_vararg, arg_arguments);
    defer function_signature.deinit();
    try string.appendSlice(function_signature.items);

    // Function content
    try std.fmt.format(string.writer(), "        var __function_name = StringName.initUtf8(\"{s}\");\n", .{ escaped_function_name.items });
    try string.appendSlice("        defer __function_name.deinit();\n");
    try std.fmt.format(string.writer(),"        const _gde_function_bind = gd.interface.?.variant_get_ptr_utility_function.?(__function_name._nativePtr(), {});\n", .{ method_hash });

    // Function call args
    const args_encoding = stringArgsEncoding(arg_arguments);
    defer args_encoding.deinit();
    try string.appendSlice(args_encoding.items);

    const args_tuple = stringArgs(arg_arguments);
    defer args_tuple.deinit();

    const no_return = std.mem.eql(u8, return_string_type.items, "void");
    if (is_vararg) {
        try std.fmt.format(string.writer(), "        const ret = gd.callUtilityRet(Variant, _gde_function_bind, .{{ {s} }} ++ p_vararg);\n", .{ args_tuple.items });
        if (no_return) {
            try string.appendSlice("        _ = ret;\n");
        } else {
            if (std.mem.eql(u8, return_string_type.items, "Variant")) {
                try string.appendSlice("        return ret;\n");
            } else {
                try std.fmt.format(string.writer(), "        return ret.as({s});\n", .{ return_string_type.items });
            }
        }
    } else {
        if (no_return) {
            try std.fmt.format(string.writer(), "        gd.callUtilityNoRet(_gde_function_bind, .{{ {s} }});\n", .{ args_tuple.items });
        } else {
            if (parsed_return_type.type_kind == TypeKind.class) {
                try std.fmt.format(string.writer(), "        return gd.callUtilityRetObj({s}, _gde_function_bind, .{{ {s} }});\n", .{ return_string_type.items, args_tuple.items });
            } else {
                try std.fmt.format(string.writer(), "        return gd.callUtilityRet({s}, _gde_function_bind, .{{ {s} }});\n", .{ return_string_type.items, args_tuple.items });
            }
        }
    }

    try string.appendSlice("    }\n\n"); // Function end

    return string;
}

fn generateUtilityFunctions(functions: *const std.json.Array) !void {
    var string = String.init(std.heap.page_allocator);
    defer string.deinit();

    // Imports
    {
        try string.appendSlice("const gd = @import(\"../../godot.zig\");\n\n");
        try string.appendSlice("const Object = @import(\"../../gen/classes/object.zig\").Object;\n\n");

        var json_types = std.ArrayList([]const u8).init(std.heap.page_allocator);
        defer json_types.deinit();
        for (functions.items) |item| {
            const function = item.object;
            getUsedTypesByFunction(&function, &json_types);
        }

        var parsed_types = std.ArrayList(ParsedType).init(std.heap.page_allocator);
        defer parsed_types.deinit();
        try parsed_types.resize(json_types.items.len);
        for (json_types.items, 0..) |json_type, i| {
            parsed_types.items[i] = ParsedType.new(json_type);
        }

        var used_builtin = std.StringHashMap(void).init(std.heap.page_allocator);
        defer used_builtin.deinit();
        for (parsed_types.items) |parsed_type| {
            filterPutUniqueBuiltinClass(&parsed_type, &used_builtin);
        }
        try used_builtin.put("StringName", {}); // Always import StringName, since its used for binds

        if (used_builtin.count() > 0) {
            try string.appendSlice("const ct = @import(\"../../core/core_types.zig\");\n");
        }

        var iterator = used_builtin.iterator();
        while (iterator.next()) |entry| {
            const used_builtin_name = entry.key_ptr.*;
            try std.fmt.format(string.writer(), "const {s} = ct.{s};\n", .{ used_builtin_name, used_builtin_name });
        }

        if (used_builtin.count() > 0) {
            try string.appendSlice("\n");
        }
    }

    try string.appendSlice("pub const UtilityFunctions = struct {\n\n");

    for (functions.items) |item| {
        const function = item.object;
        const function_string = try generateUtilityFunction(&function);
        defer function_string.deinit();
        try string.appendSlice(function_string.items);
    }

    try string.appendSlice("};\n"); // Struct end

    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen/classes", .{});
    const class_file = try gen_dir.createFile("utility_functions.zig", .{});
    defer class_file.close();
    try class_file.writeAll(string.items);
}


fn generateGlobalEnums(global_enums: *const std.json.Array) !void {
    var string = String.init(std.heap.page_allocator);
    defer string.deinit();

    for (global_enums.items) |enum_item| {
        const enum_object = enum_item.object;
        const enum_name = enum_object.get("name").?.string;

        if (std.mem.indexOf(u8, enum_name, "Variant.") != null) {
            continue; // Ignore Variant.ENUM enums
        }

        try std.fmt.format(string.writer(), "pub const {s} = enum(i32) {{\n", .{ enum_name });

        const values = enum_object.get("values").?.array;
        for (values.items) |values_item| {
            const value_object = values_item.object;
            const value_name = value_object.get("name").?.string;
            const value = value_object.get("value").?.integer;

            const convention_name = toSnakeCase(value_name);
            defer convention_name.deinit();

            try std.fmt.format(string.writer(), "    {s} = {},\n", .{ convention_name.items, value });
        }

        // Enum end
        try string.appendSlice("};\n\n");
    }

    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen/classes", .{});
    const class_file = try gen_dir.createFile("global_constants.zig", .{});
    defer class_file.close();
    try class_file.writeAll(string.items);
}


pub const BuildConfiguration = enum {
    float_32,
    float_64,
    double_32,
    double_64,
};

pub fn generateGDExtensionAPI(api_path: []const u8, selected_build_configuration: BuildConfiguration) !void {
    var api_file = try std.fs.cwd().openFile(api_path, .{});
    defer api_file.close();

    const api_file_buffer = try api_file.readToEndAlloc(std.heap.page_allocator, 1024 * 1024 * 16);
    defer std.heap.page_allocator.free(api_file_buffer);

    var parsed = try std.json.parseFromSlice(std.json.Value, std.heap.page_allocator, api_file_buffer, .{});
    defer parsed.deinit();

    const singletons = parsed.value.object.get("singletons").?.array;
    const classes = parsed.value.object.get("classes").?.array;
    const native_structs = parsed.value.object.get("native_structures").?.array;
    initClassStructMaps(&singletons, &classes, &native_structs);

    const global_enums = parsed.value.object.get("global_enums").?.array;
    try generateGlobalEnums(&global_enums);

    const builtin_classes = parsed.value.object.get("builtin_classes").?.array;
    const selected_configuration_string = @tagName(selected_build_configuration);
    const builtin_class_size_configurations = parsed.value.object.get("builtin_class_sizes").?.array;
    for (builtin_class_size_configurations.items) |item| {
        const configuration = item.object;
        const build_configuration = configuration.get("build_configuration").?.string;
        if (std.mem.eql(u8, selected_configuration_string, build_configuration)) {
            const builtin_class_sizes = configuration.get("sizes").?.array;
            try generateBuiltinClassBindings(&builtin_classes, &builtin_class_sizes);
            break;
        }
    }

    real_t_32bits = selected_build_configuration == BuildConfiguration.float_32 or selected_build_configuration == BuildConfiguration.float_64;

    const utility_functions = parsed.value.object.get("utility_functions").?.array;
    try generateUtilityFunctions(&utility_functions);

    try generateClassBindings(&classes);
    try generateNativeStructs(&native_structs);
    try generatePackageClassImports(&classes, &native_structs);
}
