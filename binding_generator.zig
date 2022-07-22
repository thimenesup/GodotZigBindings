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
                if (std.ascii.isLower(char)) {
                    if (std.ascii.isUpper(next)) {
                        snake_case.append(std.ascii.toLower(char)) catch {};
                        snake_case.append('_') catch {};
                        continue;
                    }
                }
                else {
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
        }
        else {
            camel_case.append(char) catch {};
        }
    }

    if (camel_case.items.len > 0) {
        camel_case.items[0] = std.ascii.toLower(camel_case.items[0]);
    }

    return camel_case;
}


fn isEnum(string: []const u8) bool {
    const index = std.mem.indexOf(u8, string, "enum.");
    if (index == null) {
        return false;
    }
    
    return index.? == 0;
}

fn isPrimitive(string: []const u8) bool {
    const primitives = [_][]const u8 { "int", "bool", "real", "float", "void" };
    for (primitives) |primitive| {
        if (std.mem.eql(u8, string, primitive)) {
            return true;
        }
    }

    return false;
}

fn isCoreType(string: []const u8) bool {
    const core_types = [_][]const u8 { 
        "Array",
        "Basis",
        "Color",
        "Dictionary",
        "Error",
        "NodePath",
        "Plane",
        "PoolByteArray",
        "PoolIntArray",
        "PoolRealArray",
        "PoolStringArray",
        "PoolVector2Array",
        "PoolVector3Array",
        "PoolColorArray",
        "PoolIntArray",
        "PoolRealArray",
        "Quat",
        "Rect2",
        "AABB",
        "RID",
        "String",
        "Transform",
        "Transform2D",
        "Variant",
        "Vector2",
        "Vector3"
    };

    for (core_types) |core| {
        if (std.mem.eql(u8, string, core)) {
            return true;
        }
    }

    return false;
}

fn isClassType(string: []const u8) bool {
    return !isCoreType(string) and !isPrimitive(string) and !isEnum(string);
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

fn enumGetClass(string: []const u8) String { //Must deinit string //Assumes parameter isEnum() //enum.Class.Value -> Class
    var converted = String.init(std.heap.page_allocator);
    defer converted.deinit();

    const class_index = std.mem.indexOf(u8, string, ".");
    if (class_index != null) {
        const identifier_index = std.mem.indexOf(u8, string, "::");
        if (identifier_index != null) {
            converted.appendSlice(string[(class_index.? + 1)..identifier_index.?]) catch {};
        }
        else {
            converted.appendSlice(string[(class_index.? + 1)..string.len]) catch {};
        }
    }

    return stripName(converted.items);
}

fn enumToZigEnum(string: []const u8) String { //Must deinit string //Assumes parameter isEnum()
    var converted = String.init(std.heap.page_allocator);

    const class_index = std.mem.indexOf(u8, string, ".");
    if (class_index != null) {
        const identifier_index = std.mem.indexOf(u8, string, "::");
        if (identifier_index != null) {
            converted.appendSlice(string[(class_index.? + 1)..identifier_index.?]) catch {};
            converted.appendSlice(".") catch {};
            converted.appendSlice(string[(identifier_index.? + 2)..string.len]) catch {};
        }
        else {
            converted.appendSlice(string[(class_index.? + 1)..string.len]) catch {};
        }
    }

    return converted;
}

fn makeGDNativeType(string: []const u8) String { //Must deinit string
    var converted = String.init(std.heap.page_allocator);
    defer converted.deinit();

    if (isEnum(string)) {
        const zig_enum = enumToZigEnum(string);
        defer zig_enum.deinit();
        converted.appendSlice(zig_enum.items) catch {};
    }
    else if (isClassType(string)) {
        std.fmt.format(converted.writer(), "?*{s}", .{ string }) catch {};
    }
    else if (std.mem.eql(u8, string, "int")) {
        converted.appendSlice("i64") catch {};
    }
    else if (std.mem.eql(u8, string, "float")) {
        converted.appendSlice("f64") catch {};
    }
    else {
        converted.appendSlice(string) catch {};
    }

    const stripped = stripName(converted.items);
    return stripped;
}

fn getUsedClasses(class: *const std.json.ObjectMap) std.StringHashMap(void) { //Must deinit hashmap, key strings too //Names are stripped, CoreTypes not included
    var classes = std.StringHashMap(void).init(std.heap.page_allocator);
    
    const base_class_name = class.get("base_class").?.String;
    if (base_class_name.len > 0) {
        classes.put(base_class_name, {}) catch {};
    }

    const methods = class.get("methods").?.Array;
    for (methods.items) |item| {
        const method = item.Object;
        const return_type = method.get("return_type").?.String;
        
        if (isEnum(return_type)) {
            const enum_class = enumGetClass(return_type);
            if (!isCoreType(enum_class.items)) {
                classes.put(enum_class.items, {}) catch {};
            }
        }
        else if (isClassType(return_type)) {
            const stripped_class = stripName(return_type);
            classes.put(stripped_class.items, {}) catch {};
        }

        const arguments = method.get("arguments").?.Array;
        for (arguments.items) |arguments_item| {
            const argument = arguments_item.Object;
            const arg_type = argument.get("type").?.String;

            if (isEnum(arg_type)){
                const enum_class = enumGetClass(arg_type);
                if (!isCoreType(enum_class.items)) {
                    classes.put(enum_class.items, {}) catch {};
                }
            }
            else if (isClassType(arg_type)) {
                const stripped_class = stripName(arg_type);
                classes.put(stripped_class.items, {}) catch {};
            }
        }
    }

    return classes;
}


fn generateClass(class: *const std.json.ObjectMap) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    const class_name = class.get("name").?.String;
    const stripped_class_name = stripName(class_name);
    defer stripped_class_name.deinit();

    var base_class_name = class.get("base_class").?.String;
    var stripped_base_name = stripName(base_class_name);
    defer stripped_base_name.deinit();

    if (base_class_name.len == 0) { // Base class is Wrapped
        stripped_base_name.clearRetainingCapacity();
        try stripped_base_name.appendSlice("Wrapped");
        base_class_name = stripped_base_name.items;
    }

    const class_is_instanciable = class.get("instanciable").?.Bool;
    const class_is_singleton = class.get("singleton").?.Bool;

    // Import api

    try string.appendSlice("const gd = @import(\"../core/api.zig\");\n");
    try string.appendSlice("const c = gd.c;\n\n");

    try string.appendSlice("const GenGodotClass = @import(\"../core/wrapped.zig\").GenGodotClass;\n\n");

    // Import core types, must declare every identifier so we can have a local scope of it, since they removed that behaviour from usingnamespace...

    try string.appendSlice("const CoreTypes = @import(\"../core/core_types.zig\");\n");
    try string.appendSlice("const Error = CoreTypes.Error;\n");
    try string.appendSlice("const Wrapped = CoreTypes.Wrapped;\n");
    try string.appendSlice("const Variant = CoreTypes.Variant;\n");
    try string.appendSlice("const AABB = CoreTypes.AABB;\n");
    try string.appendSlice("const Basis = CoreTypes.Basis;\n");
    try string.appendSlice("const Plane = CoreTypes.Plane;\n");
    try string.appendSlice("const Quat = CoreTypes.Quat;\n");
    try string.appendSlice("const Rect2 = CoreTypes.Rect2;\n");
    try string.appendSlice("const Transform = CoreTypes.Transform;\n");
    try string.appendSlice("const Transform2D = CoreTypes.Transform2D;\n");
    try string.appendSlice("const Vector2 = CoreTypes.Vector2;\n");
    try string.appendSlice("const Vector3 = CoreTypes.Vector3;\n");
    try string.appendSlice("const Color = CoreTypes.Color;\n");
    try string.appendSlice("const NodePath = CoreTypes.NodePath;\n");
    try string.appendSlice("const RID = CoreTypes.RID;\n");
    try string.appendSlice("const Dictionary = CoreTypes.Dictionary;\n");
    try string.appendSlice("const Array = CoreTypes.Array;\n");
    try string.appendSlice("const String = CoreTypes.String;\n");
    try string.appendSlice("const PoolByteArray = CoreTypes.PoolByteArray;\n");
    try string.appendSlice("const PoolIntArray = CoreTypes.PoolIntArray;\n");
    try string.appendSlice("const PoolRealArray = CoreTypes.PoolRealArray;\n");
    try string.appendSlice("const PoolStringArray = CoreTypes.PoolStringArray;\n");
    try string.appendSlice("const PoolVector2Array = CoreTypes.PoolVector2Array;\n");
    try string.appendSlice("const PoolVector3Array = CoreTypes.PoolVector3Array;\n");
    try string.appendSlice("const PoolColorArray = CoreTypes.PoolColorArray;\n");

    try string.appendSlice("\n");

    // Import any other classes used by this one // While also making sure that they get imported only once

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

    // Class struct definition

    try std.fmt.format(string.writer(), "pub const {s} = struct {{\n\n", .{ stripped_class_name.items }); // Extra { to escape it

    try std.fmt.format(string.writer(), "    base: {s},\n\n", .{ base_class_name });

    try string.appendSlice("    const Self = @This();\n\n");

    try std.fmt.format(string.writer(), "    pub const GodotClass = GenGodotClass(Self, {s}, {s});\n", .{ class_is_instanciable, class_is_singleton });
    try string.appendSlice("    pub usingnamespace GodotClass;\n\n"); // Not necessary, but makes calling its nested functions less verbose

    // Enums

    const enums = class.get("enums").?.Array;
    for (enums.items) |enum_item| {
        const class_enum = enum_item.Object;
        const enum_name = class_enum.get("name").?.String;
        try std.fmt.format(string.writer(), "    pub const {s} = enum(i64) {{\n", .{ enum_name });

        const values = class_enum.get("values").?.Object;
        var value_iterator = values.iterator();
        while (value_iterator.next()) |entry| {
            const entry_name = entry.key_ptr.*;
            const entry_value = entry.value_ptr.*;

            const convention_name = toSnakeCase(entry_name);
            defer convention_name.deinit();

            try std.fmt.format(string.writer(), "        {s} = {},\n", .{ convention_name.items, entry_value.Integer });
        }

        // Enum end
        try string.appendSlice("    };\n\n");
    }

    // Constants
    
    const constants = class.get("constants").?.Object;
    var const_iterator = constants.iterator();
    while (const_iterator.next()) |entry| {
        const entry_name = entry.key_ptr.*;
        const entry_value = entry.value_ptr.*;

        const convention_name = toSnakeCase(entry_name);
        defer convention_name.deinit();

        try std.fmt.format(string.writer(), "    pub const {s} = {};\n", .{ convention_name.items, entry_value.Integer });
    }

    if (constants.count() > 0) {
        try string.appendSlice("\n");
    }

    // Define method binds

    try string.appendSlice("    const Binds = struct {\n");

    const methods = class.get("methods").?.Array;
    for (methods.items) |item| {
        const method = item.Object;

        const method_name = method.get("name").?.String;
        const escaped_method_name = escapeFunctionName(method_name);
        defer escaped_method_name.deinit();

        try std.fmt.format(string.writer(), "        {s}: [*c]c.godot_method_bind,\n", .{ escaped_method_name.items });
    }

    try string.appendSlice("    };\n\n");

    try string.appendSlice("    var binds: Binds = undefined;\n\n");

    // Init method binds

    try string.appendSlice("    pub fn initBindings() void {\n");

    for (methods.items) |item| {
        const method = item.Object;

        const method_name = method.get("name").?.String;
        const escaped_method_name = escapeFunctionName(method_name);
        defer escaped_method_name.deinit();

        try std.fmt.format(string.writer(), "        binds.{s} = gd.api.*.godot_method_bind_get_method.?(\"{s}\", \"{s}\");\n", 
            .{ escaped_method_name.items, class_name, method_name });
    }

    try string.appendSlice("    }\n\n");

    // Method implementations

    for (methods.items) |item| {
        const method = item.Object;

        const method_name = method.get("name").?.String;
        const escaped_method_name = escapeFunctionName(method_name);
        defer escaped_method_name.deinit();

        const return_type = method.get("return_type").?.String;
        const return_gd_type = makeGDNativeType(return_type);
        defer return_gd_type.deinit();

        const is_const = method.get("is_const").?.Bool;
        const has_varargs = method.get("has_varargs").?.Bool;
        const arguments = method.get("arguments").?.Array;

        { // Method signature
            const camel_method_name = toCamelCase(escaped_method_name.items);
            defer camel_method_name.deinit();

            var constness = String.init(std.heap.page_allocator); defer constness.deinit();
            if (is_const) {
                try constness.appendSlice("const ");
            }

            var signature_args = String.init(std.heap.page_allocator); defer signature_args.deinit();
            for (arguments.items) |arguments_item| {
                const argument = arguments_item.Object;

                const arg_name = argument.get("name").?.String;
                const arg_type = argument.get("type").?.String;
                const arg_gd_type = makeGDNativeType(arg_type);
                defer arg_gd_type.deinit();

                // const arg_has_default = argument.get("has_default_value").?.Bool;
                // const arg_default_value = argument.get("default_value").?.String;
                try std.fmt.format(signature_args.writer(), ", p_{s}: {s}", .{ arg_name, arg_gd_type.items });
            }

            if (has_varargs) {
                try signature_args.appendSlice(", p_var_args: *const Array");
            }

            try std.fmt.format(string.writer(), "    pub fn {s}(self: *{s}Self{s}) {s} {{\n", 
                .{ camel_method_name.items, constness.items, signature_args.items, return_gd_type.items });
        }

        // Method content

        if (has_varargs) {
            try std.fmt.format(string.writer(), 
                "        const total_arg_count = {} + p_var_args.size();\n\n", 
                .{ arguments.items.len });

            try string.appendSlice(
                "        var _bind_args = @ptrCast([*c][*c]c.godot_variant, @alignCast(@alignOf([*c][*c]c.godot_variant), gd.api.*.godot_alloc.?(@sizeOf([*c]c.godot_variant) * total_arg_count)));\n\n");

            for (arguments.items) |arguments_item, i| {
                const argument = arguments_item.Object;

                const arg_name = argument.get("name").?.String;
                try std.fmt.format(string.writer(), 
                    "        var _variant_{s} = Variant.init(p_{s});\n" ++ 
                    "        defer _variant_{s}.deinit();\n" ++ 
                    "        _bind_args[{}] = &_variant_{s}.godot_variant;\n\n", 
                    .{ arg_name, arg_name, arg_name, i, arg_name });
            }

            try std.fmt.format(string.writer(), 
                "        var i: usize = 0;\n" ++ 
                "        while (i < p_var_args.size()) : (i += 1) {{\n" ++ 
                "            _bind_args[i + {}] = &p_var_args.get(@intCast(i32, i)).godot_variant;\n" ++ 
                "        }}\n\n",
                .{ arguments.items.len });

            try std.fmt.format(string.writer(), 
                "        const result = gd.api.*.godot_method_bind_call.?(binds.{s}, @intToPtr(*Wrapped, @ptrToInt(self)).owner, _bind_args, total_arg_count, null);\n\n", 
                .{ escaped_method_name.items });
            
            //try string.appendSlice("        gd.api.*.godot_free.?(@ptrCast(?*anyopaque, _bind_args));\n\n"); //NOTE: The CPP bindings dont free this, not sure if intended or its a leak

            if (std.mem.eql(u8, return_type, "void")) {
                try string.appendSlice("        _ = result;\n");
            }
            else {
                try string.appendSlice(
                    "        const ret = Variant.initGodotVariant(result);\n" ++ 
                    "        return ret;\n");
            }

            // Method end
            try string.appendSlice("    }\n\n");
        }
        else {
            var bind_args = String.init(std.heap.page_allocator);
            defer bind_args.deinit();

            for (arguments.items) |arguments_item| {
                const argument = arguments_item.Object;

                const arg_name = argument.get("name").?.String;
                const arg_type = argument.get("type").?.String;
                if (isClassType(arg_type)) {
                    try std.fmt.format(bind_args.writer(), " @ptrCast(*Wrapped, p_{s}).owner,", .{ arg_name }); // Trailing comma is fine
                }
                else {
                    try std.fmt.format(bind_args.writer(), " &p_{s},", .{ arg_name }); // Trailing comma is fine
                }
            }
            if (bind_args.items.len == 0) {
                try bind_args.appendSlice(" null");
            }

            if (std.mem.eql(u8, return_type, "void")) { //No return
                try std.fmt.format(string.writer(), 
                    "        var _bind_args = [_]?*const anyopaque {{{s} }};\n", 
                    .{ bind_args.items });
                
                try std.fmt.format(string.writer(), 
                    "        gd.api.*.godot_method_bind_ptrcall.?(binds.{s}, @intToPtr(*Wrapped, @ptrToInt(self)).owner, &_bind_args, null);\n", 
                    .{ escaped_method_name.items });
            }
            else {
                try std.fmt.format(string.writer(), 
                    "        var ret: {s} = undefined;\n", 
                    .{ return_gd_type.items });
                    
                try std.fmt.format(string.writer(), 
                    "        var _bind_args = [_]?*const anyopaque {{{s} }};\n", 
                    .{ bind_args.items });

                try std.fmt.format(string.writer(), 
                    "        gd.api.*.godot_method_bind_ptrcall.?(binds.{s}, @intToPtr(*Wrapped, @ptrToInt(self)).owner, &_bind_args, &ret);\n", 
                    .{ escaped_method_name.items });
                
                if (isClassType(return_type)) { //Must use instance binding
                    try string.appendSlice("        if (ret != null) {\n");
                    try string.appendSlice("            const instance_data = gd.nativescript_1_1_api.*.godot_nativescript_get_instance_binding_data.?(gd.language_index, ret);\n");

                    try std.fmt.format(string.writer(), 
                        "            ret = @ptrCast({s}, @alignCast(@alignOf({s}), instance_data));\n", 
                        .{ return_gd_type.items, return_gd_type.items });

                    try string.appendSlice("        }\n");
                }

                try string.appendSlice("        return ret;\n");
            }

            // Method end
            try string.appendSlice("    }\n\n");
        }
    }

    // Class struct end

    try string.appendSlice("};\n");

    return string;
}

fn generateTypeRegistry(classes: *const std.json.Array) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    try string.appendSlice("const Classes = @import(\"../core/classes.zig\");\n");
    try string.appendSlice("const typeId = @import(\"../core/typeid.zig\").typeId;\n\n");

    //Imports
    for (classes.items) |item| {
        const class = item.Object;
        
        const class_name = class.get("name").?.String;
        const stripped_name = stripName(class_name);
        defer stripped_name.deinit();

        const convention_name = toSnakeCase(stripped_name.items);
        defer convention_name.deinit();
        
        try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ stripped_name.items, convention_name.items, stripped_name.items });
    }

    try string.appendSlice("\n");

    //Registering
    try string.appendSlice("pub fn registerTypes() void {\n");
    
    for (classes.items) |item| {
        const class = item.Object;
        
        const class_name = class.get("name").?.String;
        const stripped_name = stripName(class_name);
        defer stripped_name.deinit();

        const base_class_name = class.get("base_class").?.String;
        const stripped_base_name = stripName(base_class_name);
        defer stripped_base_name.deinit();
        
        if (base_class_name.len == 0) {
            try std.fmt.format(string.writer(), "    Classes.registerGlobalType(\"{s}\", typeId({s}), 0);\n", .{ class_name, stripped_name.items});
        }
        else {
            try std.fmt.format(string.writer(), "    Classes.registerGlobalType(\"{s}\", typeId({s}), typeId({s}));\n", 
                .{ class_name, stripped_name.items, stripped_base_name.items });
        }
    }

    try string.appendSlice("}\n");

    return string;
}

fn generateInitBindings(classes: *const std.json.Array) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    //Imports
    for (classes.items) |item| {
        const class = item.Object;
        
        const class_name = class.get("name").?.String;
        const stripped_name = stripName(class_name);
        defer stripped_name.deinit();

        const convention_name = toSnakeCase(stripped_name.items);
        defer convention_name.deinit();

        try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ stripped_name.items, convention_name.items, stripped_name.items });
    }

    try string.appendSlice("\n");

    //Initializing
    try string.appendSlice("pub fn initBindings() void {\n");

    for (classes.items) |item| {
        const class = item.Object;

        const class_name = class.get("name").?.String;
        const stripped_name = stripName(class_name);
        defer stripped_name.deinit();

        try std.fmt.format(string.writer(), "    {s}.initBindings();\n", .{ stripped_name.items });
    }

    try string.appendSlice("}\n");

    return string;
}

pub fn generateBindings(api_path: []const u8) !void {
    var api_file = try std.fs.cwd().openFile(api_path, .{});
    defer api_file.close();

    const api_file_buffer = try api_file.readToEndAlloc(std.heap.page_allocator, 1024 * 1024 * 16);
    defer std.heap.page_allocator.free(api_file_buffer);

    var parser = std.json.Parser.init(std.heap.page_allocator, false);
    defer parser.deinit();

    var tree = try parser.parse(api_file_buffer);
    defer tree.deinit();

    const gen_dir = try std.fs.cwd().makeOpenPath("src/gen", .{});

    for (tree.root.Array.items) |item| {
        const class = item.Object;

        const class_name = class.get("name").?.String;
        const stripped_name = stripName(class_name);
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


    const registry_file = try gen_dir.createFile("_register_types.zig", .{});
    defer registry_file.close();

    const registry_string = try generateTypeRegistry(&tree.root.Array);
    defer registry_string.deinit();
    try registry_file.writeAll(registry_string.items);

    const bindings_file = try gen_dir.createFile("_init_bindings.zig", .{});
    defer bindings_file.close();

    const bindings_string = try generateInitBindings(&tree.root.Array);
    defer bindings_string.deinit();
    try bindings_file.writeAll(bindings_string.items);
}
