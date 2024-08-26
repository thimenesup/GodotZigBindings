const std = @import("std");

const String = std.ArrayList(u8);

fn toSnakeCase(string: []const u8) String { //Must deinit string
    var snake_case = String.init(std.heap.page_allocator);

    var i: usize = 0;
    while (i < string.len) : (i += 1) {
        const char = string[i];
        if (i > 0) {
            if (i + 1 < string.len) {
                const next = string[i + 1];
                if (std.ascii.isLower(char) or std.ascii.isDigit(char)) {
                    if (std.ascii.isUpper(next) and next != 'D') { // NOTE: Arbitrary 'D' check so strings like "Body2DState" dont become "body_2_d_state"
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


fn extractBaseType(raw_type: []const u8) []const u8 { //Remove pointer decorations
    const index = std.mem.indexOf(u8, raw_type, "*");
    const end = if (index != null) index.? else raw_type.len;
    return raw_type[0..end];
}

fn countPtrsType(raw_type: []const u8) usize {
    var count: usize = 0;
    var i: usize = 0;
    while (i < raw_type.len) : (i += 1) {
        if (raw_type[i] == '*') {
            count += 1;
        }
    }
    return count;
}

fn convertPrimitiveBaseTypeToZig(base_type: []const u8) ?[]const u8 {
    // NOTE: Currently using widest numerical types since internally ptr call binds expect it
    // TODO: Implementing primitive arg encoding on calls would allow to use userfacing expected sizes in the function signature
    const primitive_conversions = [_][2][]const u8 {
        .{ "void", "void" },
        .{ "bool", "bool" },
        .{ "uint8_t", "i64" },
        .{ "uint16_t", "i64" },
        .{ "uint32_t", "i64" },
        .{ "uint64_t", "i64" },
        .{ "int8_t", "i64" },
        .{ "int16_t", "i64" },
        .{ "int32_t", "i64" },
        .{ "int64_t", "i64" },
        .{ "float", "f64" },
        .{ "double", "f64" },
        .{ "int", "i64" },
    };

    var i: usize = 0;
    while (i < primitive_conversions.len) : (i += 1) {
        if (std.mem.eql(u8, base_type, primitive_conversions[i][0])) {
            return primitive_conversions[i][1];
        }
    }
    return null;
}

fn convertPrimitiveTypeToZig(raw_type: []const u8) ?[]const u8 {
    const base_type = extractBaseType(raw_type);
    return convertPrimitiveBaseTypeToZig(base_type);
}

fn isPrimitive(raw_type: []const u8) bool {
    return convertPrimitiveTypeToZig(raw_type) != null;
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

fn isPtr(raw_type: []const u8) bool {
    const index = std.mem.indexOf(u8, raw_type, "*");
    return index != null;
}

fn isClassType(raw_type: []const u8) bool {
    // Terrible way to do this...
    if (isPrimitive(raw_type)) {
        return false;
    }
    if (isEnum(raw_type)) {
        return false;
    }
    if (isBitfield(raw_type)) {
        return false;
    }
    if (isTypedArray(raw_type)) {
        return false;
    }
    if (isBuiltinType(raw_type)) {
        return false;
    }
    if (isPtr(raw_type)) {
        return false;
    }
    return true;
}


fn stripName(string: []const u8) String { //Must deinit string
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


fn enumGetClass(raw_type: []const u8) String { //Must deinit string //Assumes parameter isClassEnum() //"enum::Class.EnumType" -> "Class"
    var converted = String.init(std.heap.page_allocator);
    defer converted.deinit();

    const enum_needle = "enum::";
    var class_begin_index = std.mem.indexOf(u8, raw_type, enum_needle);
    if (class_begin_index != null) {
        class_begin_index.? += enum_needle.len;

        var class_end_index = std.mem.indexOf(u8, raw_type, ".");
        if (class_end_index == null) {
            class_end_index = raw_type.len;
        }
        converted.appendSlice(raw_type[(class_begin_index.?)..class_end_index.?]) catch {};
    }

    return stripName(converted.items);
}

fn convertEnum(raw_type: []const u8) String { //Must deinit string //Assumes parameter isEnum() //"enum::Class.EnumType" -> "Class.EnumType"
    var converted = String.init(std.heap.page_allocator);

    const needle = "enum::";
    const prefix_index = std.mem.indexOf(u8, raw_type, needle);
    const begin_index = prefix_index.? + needle.len;
    converted.appendSlice(raw_type[begin_index..raw_type.len]) catch {};

    return converted;
}

fn convertBitfield(raw_type: []const u8) String { //Must deinit string //Assumes parameter isBitfield()
    var converted = String.init(std.heap.page_allocator);

    const needle = "bitfield::";
    const prefix_index = std.mem.indexOf(u8, raw_type, needle);
    const begin_index = prefix_index.? + needle.len;
    converted.appendSlice(raw_type[begin_index..raw_type.len]) catch {};

    return converted;
}

fn convertedTypedArrayType(raw_type: []const u8, is_primitive: *bool) String { //Must deinit string //Assumes parameter isTypedArray()
    var converted = String.init(std.heap.page_allocator);

    const type_begin_needle = "typedarray::";
    const type_begin_index = std.mem.indexOf(u8, raw_type, type_begin_needle);
    const begin_index = type_begin_index.? + type_begin_needle.len;
    const array_type = raw_type[begin_index..raw_type.len];

    const primitive_type = convertPrimitiveBaseTypeToZig(array_type);
    if (primitive_type != null) {
        converted.appendSlice(primitive_type.?) catch {};
    } else {
        converted.appendSlice(array_type) catch {};
    }
    is_primitive.* = primitive_type != null;

    return converted;
}

fn convertTypedArray(raw_type: []const u8) String { //Must deinit string //Assumes parameter isTypedArray()
    var is_primitive: bool = undefined;
    const contained_type = convertedTypedArrayType(raw_type, &is_primitive);
    defer contained_type.deinit();

    var converted = String.init(std.heap.page_allocator);
    std.fmt.format(converted.writer(), "TypedArray({s})", .{ contained_type.items }) catch {};
    return converted;
}

fn convertRawTypeToZigParameter(raw_type: []const u8, is_return_type: bool) String {
    if (isEnum(raw_type)) {
        const zig_enum = convertEnum(raw_type);
        return zig_enum;
    } else if (isBitfield(raw_type)) {
        const zig_bitfield = convertBitfield(raw_type);
        return zig_bitfield;
    } else if (isTypedArray(raw_type)) {
        const zig_typed_array = convertTypedArray(raw_type);
        return zig_typed_array;
    } else if (isPrimitive(raw_type)) {
        //Type may be a ptr
        const zig_primitive = convertPrimitiveTypeToZig(raw_type);
        const ptr_count = countPtrsType(raw_type);
        var converted = String.init(std.heap.page_allocator);
        if (ptr_count > 0 and std.mem.eql(u8, zig_primitive.?, "void")) {
            converted.appendSlice("?*anyopaque") catch {};
        } else {
            var i: usize = 0;
            while (i < ptr_count) : (i += 1) {
                converted.appendSlice("[*c]") catch {};
            }
            converted.appendSlice(zig_primitive.?) catch {};
        }
        return converted;
    } else if (isBuiltinType(raw_type)) {
        if (is_return_type) {
            //Always meant to be returned as value
            var converted = String.init(std.heap.page_allocator);
            converted.appendSlice(raw_type) catch {};
            return converted;
        } else {
            //Always meant to be passed as a const ptr
            var converted = String.init(std.heap.page_allocator);
            std.fmt.format(converted.writer(), "*const {s}", .{ raw_type }) catch {};
            return converted;
        }
    } else if (isClassType(raw_type)) {
        //Always meant to be passed around as a ptr
        var converted = String.init(std.heap.page_allocator);
        defer converted.deinit();
        std.fmt.format(converted.writer(), "?*{s}", .{ raw_type }) catch {};
        const stripped = stripName(converted.items);
        return stripped;
    } else {
        var converted = String.init(std.heap.page_allocator);
        converted.appendSlice(raw_type) catch {};
        return converted;
    }
}


fn stringMethodSignature(method_name: []const u8, converted_return_type: []const u8, is_const: bool, is_vararg: bool, arguments: ?*const std.json.Array) String { //Must deinit string
    var signature_args = String.init(std.heap.page_allocator);
    defer signature_args.deinit();

    if (arguments != null) {
        for (arguments.?.items) |arguments_item| {
            const argument = arguments_item.object;

            const arg_name = argument.get("name").?.string;
            const arg_type = argument.get("type").?.string;

            const converted_arg_type = convertRawTypeToZigParameter(arg_type, false);
            defer converted_arg_type.deinit();

            // NOTE: Zig doesn't really have default arguments
            // const arg_has_default = argument.get("has_default_value").?.bool;
            // const arg_default_value = argument.get("default_value").?.string;

            std.fmt.format(signature_args.writer(), ", p_{s}: {s}", .{ arg_name, converted_arg_type.items }) catch {};
        }
    }
    if (is_vararg) {
        signature_args.appendSlice(", p_vararg: anytype") catch {};
    }

    const camel_method_name = toCamelCase(method_name);
    defer camel_method_name.deinit();

    var string = String.init(std.heap.page_allocator);

    const constness_string = if (is_const) "const " else "";
    const return_string = if (is_vararg) "Variant" else converted_return_type;
    std.fmt.format(string.writer(),
        "    pub fn {s}(self: *{s}Self{s}) {s} {{\n",
        .{ camel_method_name.items, constness_string, signature_args.items, return_string }) catch {};

    return string;
}

fn stringArgs(arguments: ?*const std.json.Array) String { //Must deinit string
    var string = String.init(std.heap.page_allocator);
    if (arguments != null) {
        for (arguments.?.items, 0..) |arguments_item, index| {
            const argument = arguments_item.object;

            const arg_name = argument.get("name").?.string;
            const arg_type = argument.get("type").?.string;

            if (isClassType(arg_type)) {
                std.fmt.format(string.writer(), "(if (p_{s} != null) @as(*Wrapped, @ptrCast(p_{s}))._owner else null)", .{ arg_name, arg_name }) catch {};
            } else if (isPrimitive(arg_type)) {
                std.fmt.format(string.writer(), "&p_{s}", .{ arg_name }) catch {};
            } else {
                std.fmt.format(string.writer(), "p_{s}", .{ arg_name }) catch {};
            }

            if (index < (arguments.?.items.len - 1)) {
                string.appendSlice(", ") catch {};
            }
        }
    }
    return string;
}


fn usedProcessType(raw_type: []const u8, classes: *std.StringHashMap(void)) void {
    // Ignore builtin types since they already get imported by default
    if (isClassEnum(raw_type)) {
        const enum_class = enumGetClass(raw_type);
        if (!isBuiltinType(enum_class.items)) {
            classes.put(enum_class.items, {}) catch {};
        }
    } else if (isTypedArray(raw_type)) {
        var is_primitive: bool = undefined;
        const typed_array_class = convertedTypedArrayType(raw_type, &is_primitive);
        if (!is_primitive and !isBuiltinType(typed_array_class.items)) {
            classes.put(typed_array_class.items, {}) catch {};
        }
    } else if (isClassType(raw_type)) {
        const stripped_class = stripName(raw_type);
        classes.put(stripped_class.items, {}) catch {};
    }
}

fn getUsedClasses(class: *const std.json.ObjectMap) std.StringHashMap(void) { //Must deinit hashmap, key strings too //Names are stripped, CoreTypes not included
    var classes = std.StringHashMap(void).init(std.heap.page_allocator);

    if (class.get("inherits")) |get_inherits| {
        classes.put(get_inherits.string, {}) catch {};
    }

    if (class.get("methods")) |get_methods| {
        const methods = get_methods.array;
        for (methods.items) |item| {
            const method = item.object;

            if (method.get("return_value")) |get_return_value| {
                const return_value_object = get_return_value.object;
                const return_type = return_value_object.get("type").?.string;
                usedProcessType(return_type, &classes);
            }

            if (method.get("arguments")) |get_arguments| {
                const arguments = get_arguments.array;
                for (arguments.items) |arguments_item| {
                    const argument = arguments_item.object;
                    const arg_type = argument.get("type").?.string;
                    usedProcessType(arg_type, &classes);
                }
            }
        }
    }

    return classes;
}


fn stringImportCoreTypes() String { //Must deinit string
    var string = String.init(std.heap.page_allocator);
    for (core_types) |core| {
        std.fmt.format(string.writer(), "const {s} = ct.{s};\n", .{ core, core }) catch {};
    }
    return string;
}

fn stringImportGlobalEnums(global_enums: *const std.json.Array) String {
    var string = String.init(std.heap.page_allocator);
    for (global_enums.items) |enum_item| {
        const enum_object = enum_item.object;
        const enum_name = enum_object.get("name").?.string;

        if (std.mem.indexOf(u8, enum_name, "Variant.") != null) {
            continue; // Ignore Variant.ENUM enums
        }

        std.fmt.format(string.writer(), "const {s} = global_constants.{s};\n", .{ enum_name, enum_name }) catch {};
    }
    return string;
}

fn hasAnyPtrType(return_type: []const u8, arguments: *const std.json.Array) bool {
    if (isPtr(return_type)) {
        return true;
    }
    for (arguments.items) |arguments_item| {
        const argument = arguments_item.object;
        const arg_type = argument.get("type").?.string;
        if (isPtr(arg_type)) {
            return true;
        }
    }
    return false;
}

fn generateClass(class: *const std.json.ObjectMap, global_enums: *const std.json.Array) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    const class_name = class.get("name").?.string;
    const stripped_class_name = stripName(class_name);
    defer stripped_class_name.deinit();

    var base_class_name: []const u8 = "Wrapped";
    if (class.get("inherits")) |get_inherits| {
        base_class_name = get_inherits.string;
    }

    var stripped_base_name = stripName(base_class_name);
    defer stripped_base_name.deinit();

    if (base_class_name.len == 0) { // Base class is Wrapped
        stripped_base_name.clearRetainingCapacity();
        try stripped_base_name.appendSlice("Wrapped");
        base_class_name = stripped_base_name.items;
    }

    // Import api
    {
        try string.appendSlice("const gi = @import(\"../../gdextension_interface.zig\");\n");
        try string.appendSlice("const gd = @import(\"../../godot.zig\");\n\n");

        try string.appendSlice("const Wrapped = @import(\"../../core/wrapped.zig\").Wrapped;\n");
        try string.appendSlice("const GDExtensionClass = @import(\"../../core/wrapped.zig\").GDExtensionClass;\n\n");
    }

    // Import core types, must declare every identifier so we can have a local scope of it, since they removed that behaviour from usingnamespace...
    {
        try string.appendSlice("const ct = @import(\"../../core/core_types.zig\");\n");
        try string.appendSlice("const TypedArray = ct.TypedArray;\n");
        const type_imports = stringImportCoreTypes();
        defer type_imports.deinit();
        try string.appendSlice(type_imports.items);
        try string.appendSlice("\n");
    }

    // Same for global constants enums...
    {
        try string.appendSlice("const global_constants = @import(\"global_constants.zig\");\n");
        const global_imports = stringImportGlobalEnums(global_enums);
        defer global_imports.deinit();
        try string.appendSlice(global_imports.items);
        try string.appendSlice("\n");
    }

    // Import any other classes used by this one // While also making sure that they get imported only once
    {
        var used_classes = getUsedClasses(class);
        defer used_classes.deinit(); //TODO: Deinit key strings

        var iterator = used_classes.iterator();
        while (iterator.next()) |entry| {
            const used_class_name = entry.key_ptr.*;

            if (std.mem.eql(u8, used_class_name, stripped_class_name.items)) { // Dont import self
                continue;
            }

            const convention_class_name = toSnakeCase(used_class_name);
            defer convention_class_name.deinit();

            try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ used_class_name, convention_class_name.items, used_class_name });
        }

        try string.appendSlice("\n");
    }

    // Class struct definition
    {
        try std.fmt.format(string.writer(), "pub const {s} = struct {{\n\n", .{ stripped_class_name.items }); // Extra { to escape it

        try std.fmt.format(string.writer(), "    base: {s},\n\n", .{ base_class_name });

        try string.appendSlice("    const Self = @This();\n\n");

        try std.fmt.format(string.writer(),"    pub const GodotClass = GDExtensionClass(Self, {s});\n", .{ base_class_name });
        try string.appendSlice("    pub usingnamespace GodotClass;\n\n");
    }

    // Enums
    if (class.get("enums")) |get_enums| {
        const enums = get_enums.array;
        for (enums.items) |enum_item| {
            const enum_object = enum_item.object;
            const enum_name = enum_object.get("name").?.string;
            try std.fmt.format(string.writer(), "    pub const {s} = enum(i64) {{\n", .{ enum_name });

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

    if (class.get("methods")) |get_methods| {
        const methods = get_methods.array;

        // Method implementations
        for (methods.items) |item| {
            const method = item.object;

            const method_name = method.get("name").?.string;
            const escaped_method_name = escapeFunctionName(method_name);
            defer escaped_method_name.deinit();

            var return_type: []const u8 = "void";
            if (method.get("return_value")) |get_return_value| {
                const return_value_object = get_return_value.object;
                return_type = return_value_object.get("type").?.string;
            }

            // TODO: Implement ptr types and native structs
            if (method.get("arguments")) |get_arguments| {
                if (hasAnyPtrType(return_type, &get_arguments.array)) {
                    continue;
                }
            }

            const converted_return_type = convertRawTypeToZigParameter(return_type, true);
            defer converted_return_type.deinit();

            const is_virtual = method.get("is_virtual").?.bool;
            if (is_virtual) {
                // TODO: Implement
                continue;
            }

            const is_vararg = method.get("is_vararg").?.bool;
            const is_const = method.get("is_const").?.bool;
            const method_hash = method.get("hash").?.integer;

            const arg_arguments = if (method.get("arguments")) |get_arguments| &get_arguments.array else null;

            // Method signature
            {
                const method_signature = stringMethodSignature(escaped_method_name.items, converted_return_type.items, is_const, is_vararg, arg_arguments);
                defer method_signature.deinit();
                try string.appendSlice(method_signature.items);
            }

            // Method content

            try string.appendSlice("        const __class_name = Self.getClassStatic();\n");

            try std.fmt.format(string.writer(),
                "        var __method_name = gd.stringNameFromUtf8(\"{s}\");\n",
                .{ escaped_method_name.items });

            try string.appendSlice(
                "        defer __method_name.deinit();\n");

            try std.fmt.format(string.writer(), 
                "        const _gde_method_bind = gd.interface.?.classdb_get_method_bind.?(__class_name._nativePtr(), __method_name._nativePtr(), {});\n", 
                .{ method_hash });

            // Method call args
            const args_tuple = stringArgs(arg_arguments);
            defer args_tuple.deinit();

            if (is_vararg) {
                try std.fmt.format(string.writer(), "        return gd.callMbRet(_gde_method_bind, @as(*Wrapped, @ptrCast(self))._owner, .{{ {s} }} ++ p_vararg);\n", .{ args_tuple.items });
            } else {
                if (std.mem.eql(u8, return_type, "void")) { // No return
                    try std.fmt.format(string.writer(), "        gd.callNativeMbNoRet(_gde_method_bind, @as(*Wrapped, @ptrCast(self))._owner, .{{ {s} }});\n", .{ args_tuple.items });
                } else {
                    if (isClassType(return_type)) {
                        try std.fmt.format(string.writer(), "        return gd.callNativeMbRetObj({s}, _gde_method_bind, @as(*Wrapped, @ptrCast(self))._owner, .{{ {s} }});\n", .{ converted_return_type.items, args_tuple.items });
                    } else {
                        try std.fmt.format(string.writer(), "        return gd.callNativeMbRet({s}, _gde_method_bind, @as(*Wrapped, @ptrCast(self))._owner, .{{ {s} }});\n", .{ converted_return_type.items, args_tuple.items });
                    }
                }
            }

            // Method end
            try string.appendSlice("    }\n\n");
        }
    }

    // Class struct end
    try string.appendSlice("};\n");

    return string;
}

fn generatePackageClassImports(classes: *const std.json.Array) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    //Imports
    for (classes.items) |item| {
        const class = item.object;
        
        const class_name = class.get("name").?.string;
        const stripped_name = stripName(class_name);
        defer stripped_name.deinit();

        const convention_name = toSnakeCase(stripped_name.items);
        defer convention_name.deinit();
        
        try std.fmt.format(string.writer(), "pub const {s} = @import(\"{s}.zig\");\n", .{ convention_name.items, convention_name.items });
    }

    return string;
}

fn generateClassBindings(classes: *const std.json.Array, global_enums: *const std.json.Array) !void {
    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen/classes", .{});

    for (classes.items) |item| {
        const class = item.object;

        const class_name = class.get("name").?.string;
        const stripped_name = stripName(class_name);
        defer stripped_name.deinit();
        const convention_name = toSnakeCase(stripped_name.items);
        defer convention_name.deinit();

        var class_file_name = String.init(std.heap.page_allocator);
        defer class_file_name.deinit();
        try std.fmt.format(class_file_name.writer(), "{s}.zig", .{convention_name.items});

        const file_string = try generateClass(&class, global_enums);

        const class_file = try gen_dir.createFile(class_file_name.items, .{});
        defer class_file.close();
        try class_file.writeAll(file_string.items);
    }

    {
        const imports_file = try gen_dir.createFile("_classes.zig", .{});
        defer imports_file.close();

        const class_imports_string = try generatePackageClassImports(classes);
        defer class_imports_string.deinit();
        try imports_file.writeAll(class_imports_string.items);
    }
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
    var arg_names = String.init(std.heap.page_allocator);
    defer arg_names.deinit();

    var signature_args = String.init(std.heap.page_allocator);
    defer signature_args.deinit();

    if (arguments != null) {
        for (arguments.?.items, 0..) |arguments_item, i| {
            const argument = arguments_item.object;

            const arg_name = argument.get("name").?.string;
            const arg_type = argument.get("type").?.string;

            arg_names.appendSlice(arg_type) catch {};

            const converted_arg_type = convertRawTypeToZigParameter(arg_type, false);
            defer converted_arg_type.deinit();

            std.fmt.format(signature_args.writer(), "p_{s}: {s}", .{ arg_name, converted_arg_type.items }) catch {};

            if (i < (arguments.?.items.len - 1)) {
                signature_args.appendSlice(", ") catch {};
            }
        }
    }

    var string = String.init(std.heap.page_allocator);

    std.fmt.format(string.writer(),
        "    pub fn init{s}({s}) Self {{\n",
        .{ arg_names.items, signature_args.items, }) catch {};

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

        if (!std.mem.eql(u8, class_name, "StringName")) {
            try class_string.appendSlice("const StringName = ct.StringName;\n");
        }

        var used_classes = getUsedBuiltinClasses(class);
        defer used_classes.deinit();

        var iterator = used_classes.iterator();
        while (iterator.next()) |entry| {
            const used_class_name = entry.key_ptr.*;

            if (std.mem.eql(u8, used_class_name, class_name)) { // Dont import self
                continue;
            }

            if (std.mem.eql(u8, used_class_name, "StringName")) { // Exclude StringName since its imported by default due bindings relying on it
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

            const args_tuple = stringArgs(arg_arguments);
            defer args_tuple.deinit();

            try impl_binds.appendSlice(signature.items);

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
                "        {{ var __method_name = gd.stringNameFromUtf8(\"{s}\"); defer __method_name.deinit(); binds.{s} = ptr_mb(this_vt, __method_name._nativePtr(), {}); }}\n",
                . { method_name, escaped_method_name.items, method_hash });

            var return_type: []const u8 = "void";
            if (method.get("return_type")) |get_return_type| {
                return_type = get_return_type.string;
            }

            const converted_return_type = convertRawTypeToZigParameter(return_type, true);
            defer converted_return_type.deinit();

            const is_vararg = method.get("is_vararg").?.bool;
            const is_const = method.get("is_const").?.bool;

            const arg_arguments = if (method.get("arguments")) |get_arguments| &get_arguments.array else null;

            // Method signature
            const method_signature = stringMethodSignature(escaped_method_name.items, converted_return_type.items, is_const, is_vararg, arg_arguments);
            defer method_signature.deinit();
            try impl_binds.appendSlice(method_signature.items);

            // Method call args
            const args_tuple = stringArgs(arg_arguments);
            defer args_tuple.deinit();

            if (is_vararg) {
                try std.fmt.format(impl_binds.writer(),
                    "        return gd.callMbRet(binds.{s}, @ptrCast(&self._opaque), .{{ {s} }} ++ p_vararg);\n",
                    .{ escaped_method_name.items, args_tuple.items });
            } else {
                if (std.mem.eql(u8, return_type, "void")) { // No return
                    try std.fmt.format(impl_binds.writer(),
                        "        gd.callBuiltinMbNoRet(binds.{s}, @ptrCast(&self._opaque), .{{ {s} }});\n",
                        .{ escaped_method_name.items, args_tuple.items });
                } else {
                    try std.fmt.format(impl_binds.writer(),
                        "        return gd.callBuiltinMbRet({s}, binds.{s}, @ptrCast(&self._opaque), .{{ {s} }});\n",
                        .{ converted_return_type.items, escaped_method_name.items, args_tuple.items });
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
            const converted_right_type = convertRawTypeToZigParameter(right_type, false);
            defer converted_right_type.deinit();
            const converted_return_type = convertRawTypeToZigParameter(return_type, true);
            defer converted_return_type.deinit();

            try std.fmt.format(impl_binds.writer(),
                "    pub fn {s}{s}(self: *const Self, other: {s}) {s} {{\n",
                .{ operator_identifier, right_type, converted_right_type.items, converted_return_type.items });
            
            // Method content
            try std.fmt.format(impl_binds.writer(), "        return gd.callBuiltinOperatorPtr({s}, binds.{s}, @ptrCast(&self._opaque), @ptrCast(other));\n", .{ converted_return_type.items, bind_name.items});

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

        const stripped_name = stripName(class_name);
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


fn generateGlobalEnums(global_enums: *const std.json.Array) !void {
    var string = String.init(std.heap.page_allocator);
    defer string.deinit();

    for (global_enums.items) |enum_item| {
        const enum_object = enum_item.object;
        const enum_name = enum_object.get("name").?.string;

        if (std.mem.indexOf(u8, enum_name, "Variant.") != null) {
            continue; // Ignore Variant.ENUM enums
        }

        try std.fmt.format(string.writer(), "pub const {s} = enum(i64) {{\n", .{ enum_name });

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

    const classes = parsed.value.object.get("classes").?.array;
    try generateClassBindings(&classes, &global_enums);
}
