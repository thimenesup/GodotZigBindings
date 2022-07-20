const std = @import("std");

const String = std.ArrayList(u8);

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

fn enumGetClass(string: []const u8) String { //Must deinit string //Assumes parameter isEnum()
    var converted = String.init(std.heap.page_allocator);

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

    return converted;
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

fn getUsedClasses(class: *const std.json.ObjectMap) std.StringHashMap(void) { //Must deinit hashmap
    var classes = std.StringHashMap(void).init(std.heap.page_allocator);

    const base_class_name = class.get("base_class").?.String;
    classes.put(base_class_name, {}) catch {};

    const methods = class.get("methods").?.Array;
    for (methods.items) |item| {
        const method = item.Object;
        const return_type = method.get("return_type").?.String;
        
        if (isEnum(return_type)) {
            const enum_class = enumGetClass(return_type);
            //defer enum_class.deinit();
            classes.put(enum_class.items, {}) catch {};
        }
        else if (isClassType(return_type)) {
            const stripped_class = stripName(return_type);
            //defer stripped_class.deinit();
            classes.put(stripped_class.items, {}) catch {};
        }

        const arguments = method.get("arguments").?.Array;
        for (arguments.items) |arguments_item| {
            const argument = arguments_item.Object;
            const arg_type = argument.get("type").?.String;

            if (isEnum(arg_type)){
                const enum_class = enumGetClass(arg_type);
                //defer enum_class.deinit();
                classes.put(enum_class.items, {}) catch {};
            }
            else if (isClassType(arg_type)) {
                const stripped_class = stripName(arg_type);
                //defer stripped_class.deinit();
                classes.put(stripped_class.items, {}) catch {};
            }
        }
    }

    return classes;
}


fn generateClass(class: *const std.json.ObjectMap) !String { //Must deinit string
    var string = String.init(std.heap.page_allocator);

    const _class_name = stripName(class.get("name").?.String); defer _class_name.deinit(); const class_name = _class_name.items;
    var _base_class_name = stripName(class.get("base_class").?.String); defer _base_class_name.deinit(); var base_class_name = _base_class_name.items;

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
    defer used_classes.deinit();

    var iterator = used_classes.iterator();
    while (iterator.next()) |entry| {
        const used_class = entry.key_ptr.*;

        if (used_class.len == 0) {
            continue;
        }

        if (isCoreType(used_class)) { // Core type imported already //TODO: Should be done in getUsedClasses()
            continue;
        }

        const _stripped_class = stripName(used_class); defer _stripped_class.deinit(); const stripped_class = _stripped_class.items; //TODO: Should be done in getUsedClasses()

        if (std.mem.eql(u8, stripped_class, class_name)) { // Dont import self
            continue;
        }

        try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ stripped_class, stripped_class, stripped_class });
    }

    try string.appendSlice("\n");

    if (base_class_name.len == 0) { // Base class is Wrapped
        _base_class_name.clearRetainingCapacity();
        try _base_class_name.appendSlice("Wrapped");
        base_class_name = _base_class_name.items;
    }

    // Class struct definition

    try std.fmt.format(string.writer(), "pub const {s} = struct {{\n\n", .{ class_name }); // Extra { to escape it

    try std.fmt.format(string.writer(), "    base: {s},\n\n", .{ base_class_name });

    try string.appendSlice("    const Self = @This();\n\n");

    try string.appendSlice("    pub const GodotClass = GenGodotClass(Self);\n\n");

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
            try std.fmt.format(string.writer(), "        {s} = {},\n", .{ entry_name, entry_value.Integer });
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
        try std.fmt.format(string.writer(), "    pub const {s} = {};\n", .{ entry_name, entry_value.Integer });
    }

    try string.appendSlice("\n");

    // Define method binds

    try string.appendSlice("    const Binds = struct {\n");

    const methods = class.get("methods").?.Array;
    for (methods.items) |item| {
        const method = item.Object;

        const _method_name = escapeFunctionName(method.get("name").?.String); defer _method_name.deinit(); const method_name = _method_name.items;
        try std.fmt.format(string.writer(), "        pub var {s}: [*c]c.godot_method_bind = null;\n", .{ method_name });
    }

    try string.appendSlice("    };\n\n");

    // Init method binds

    try string.appendSlice("    pub fn initBindings() void {\n");

    for (methods.items) |item| {
        const method = item.Object;

        const _method_name = escapeFunctionName(method.get("name").?.String); defer _method_name.deinit(); const method_name = _method_name.items;
        try std.fmt.format(string.writer(), "        Binds.{s} = gd.api.*.godot_method_bind_get_method.?(@typeName(Self), \"{s}\");\n", .{ method_name, method_name });
    }

    try string.appendSlice("    }\n\n");

    // Method implementations

    for (methods.items) |item| {
        const method = item.Object;

        const _method_name = escapeFunctionName(method.get("name").?.String); defer _method_name.deinit(); const method_name = _method_name.items;
        const _return_type = makeGDNativeType(method.get("return_type").?.String); defer _return_type.deinit(); const return_type = _return_type.items;
        const is_const = method.get("is_const").?.Bool;
        //const has_varargs = method.get("has_varargs").?.Bool;
        const arguments = method.get("arguments").?.Array;

        var constness = String.init(std.heap.page_allocator); defer constness.deinit();
        if (is_const) {
            try constness.appendSlice("const ");
        }

        var signature_args = String.init(std.heap.page_allocator); defer signature_args.deinit();
        for (arguments.items) |arguments_item| {
            const argument = arguments_item.Object;

            const arg_name = argument.get("name").?.String;
            const _arg_type = makeGDNativeType(argument.get("type").?.String); defer _arg_type.deinit(); const arg_type = _arg_type.items;
            // const arg_has_default = argument.get("has_default_value").?.Bool;
            // const arg_default_value = argument.get("default_value").?.String;
            try std.fmt.format(signature_args.writer(), ", p_{s}: {s}", .{ arg_name, arg_type });
        }

        // Method signature
        try std.fmt.format(string.writer(), "    pub fn {s}(self: *{s}Self{s}) {s} {{\n", .{ method_name, constness.items, signature_args.items, return_type });

        // Method content //TODO: Support var_args
        var bind_args = String.init(std.heap.page_allocator); defer bind_args.deinit();
        for (arguments.items) |arguments_item| {
            const argument = arguments_item.Object;

            const arg_name = argument.get("name").?.String;
            try std.fmt.format(bind_args.writer(), " &p_{s},", .{ arg_name }); // Trailing comma is fine
        }
        if (bind_args.items.len == 0) {
            try bind_args.appendSlice(" null");
        }

        if (std.mem.eql(u8, return_type, "void")) { //No return
            try std.fmt.format(string.writer(), "        var _bind_args = [_]?*const anyopaque {{{s} }};\n", .{ bind_args.items });
            try std.fmt.format(string.writer(), "        gd.api.*.godot_method_bind_ptrcall.?(Binds.{s}, @intToPtr(*Wrapped, @ptrToInt(self)).owner, &_bind_args, null);\n", .{ method_name });
        }
        else {
            try std.fmt.format(string.writer(), "        var ret: {s} = undefined;\n", .{ return_type });
            try std.fmt.format(string.writer(), "        var _bind_args = [_]?*const anyopaque {{{s} }};\n", .{ bind_args.items });
            try std.fmt.format(string.writer(), "        gd.api.*.godot_method_bind_ptrcall.?(Binds.{s}, @intToPtr(*Wrapped, @ptrToInt(self)).owner, &_bind_args, &ret);\n", .{ method_name });
            try string.appendSlice("        return ret;\n");
        }

        // Method end
        try string.appendSlice("    }\n\n");
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
        
        const _class_name = stripName(class.get("name").?.String); defer _class_name.deinit(); const class_name = _class_name.items;
        
        try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ class_name, class_name, class_name });
    }

    try string.appendSlice("\n");

    //Registering
    try string.appendSlice("pub fn registerTypes() void {\n");
    
    for (classes.items) |item| {
        const class = item.Object;
        
        const _class_name = stripName(class.get("name").?.String); defer _class_name.deinit(); const class_name = _class_name.items;
        const _base_class_name = stripName(class.get("base_class").?.String); defer _base_class_name.deinit(); const base_class_name = _base_class_name.items;
        
        if (base_class_name.len == 0) {
            try std.fmt.format(string.writer(), "    Classes.registerGlobalType(\"{s}\", typeId({s}), 0);\n", .{ class_name, class_name});
        }
        else {
            try std.fmt.format(string.writer(), "    Classes.registerGlobalType(\"{s}\", typeId({s}), typeId({s}));\n", .{ class_name, class_name, base_class_name });
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
        
        const _class_name = stripName(class.get("name").?.String); defer _class_name.deinit(); const class_name = _class_name.items;
        
        try std.fmt.format(string.writer(), "const {s} = @import(\"{s}.zig\").{s};\n", .{ class_name, class_name, class_name });
    }

    try string.appendSlice("\n");

    //Initializing
    try string.appendSlice("pub fn initBindings() void {\n");

    for (classes.items) |item| {
        const class = item.Object;

        const _class_name = stripName(class.get("name").?.String); defer _class_name.deinit(); const class_name = _class_name.items;

        try std.fmt.format(string.writer(), "    {s}.initBindings();\n", .{ class_name });
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

    const gen_dir = try std.fs.cwd().makeOpenPath("src/test_gen", .{});

    for (tree.root.Array.items) |item| {
        const class = item.Object;

        const _class_name = stripName(class.get("name").?.String); defer _class_name.deinit(); const class_name = _class_name.items;

        var class_file_name = String.init(std.heap.page_allocator);
        defer class_file_name.deinit();
        try class_file_name.appendSlice(class_name);
        try class_file_name.appendSlice(".zig");

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
