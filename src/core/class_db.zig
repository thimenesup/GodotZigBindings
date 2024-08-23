const std = @import("std");
const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const BindWrapper = @import("bind_wrapper.zig");

const Wrapped = @import("../core/wrapped.zig").Wrapped;
const Variant = @import("../variant/variant.zig").Variant;
const StringName = @import("../gen/builtin_classes/string_name.zig").StringName;
const String = @import("../gen/builtin_classes/string.zig").String;

// From GlobalConstants
const method_flag_default = 1;
const method_flag_editor = 2;
const method_flag_const = 4;
const method_flag_virtual = 8;
const method_flag_vararg = 16;
const method_flag_static = 32;
const method_flag_object_core = 64;


pub const ClassDB = struct {

    pub var current_level: gi.GDExtensionInitializationLevel = undefined;

    pub fn initialize(p_level: gi.GDExtensionInitializationLevel) void {
        _ = p_level;
    }

    pub fn deinitialize(p_level: gi.GDExtensionInitializationLevel) void {
        _ = p_level;
    }


    fn TypeGetBase(comptime T: type) type {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
        switch (type_info) {
            type_tag.Pointer => {
                return type_info.Pointer.child;
            },
            type_tag.Optional => {
                return type_info.Optional.child;
            },
            else => {
                return T;
            },
        }
    }

    fn classStringName(comptime T: type) StringName {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
        switch (type_info) {
            type_tag.Struct => {
                if (@hasDecl(T, "GodotClass")) {
                    return T.getClassStatic();
                }
            },
            else => { }
        }
        return StringName.init();
    }


    const StringStorage = extern struct {
        name: StringName,
        class: StringName,
        hint: String,
    };

    const SignatureInfo = extern struct {
        const max_argument_count = 16;

        storage: [max_argument_count + 1]StringStorage, // Plus one for return value

        argument_count: u32,
        arguments_info: [max_argument_count]gi.GDExtensionPropertyInfo,
        arguments_metadata: [max_argument_count]gi.GDExtensionClassMethodArgumentMetadata,
        has_return_value: bool,
        return_value_info: gi.GDExtensionPropertyInfo,
        return_value_metadata: gi.GDExtensionClassMethodArgumentMetadata,
        default_argument_count: u32,
        default_arguments: [max_argument_count]gi.GDExtensionVariantPtr,

        const Self = @This();

        pub fn init(comptime function: anytype, comptime is_method: bool, arg_names: anytype) SignatureInfo {
            const fn_info = @typeInfo(@TypeOf(function)).Fn;
            const exclude_struct_offset = if (is_method) 1 else 0; // Offset to exclude the member struct from arguments
            const excluded_argument_count = fn_info.params.len - exclude_struct_offset;

            if (excluded_argument_count > SignatureInfo.max_argument_count) {
                @compileError("Too many arguments");
            }

            var signature = std.mem.zeroes(Self);
            signature.argument_count = excluded_argument_count;

            inline for (fn_info.params, 0..) |param, all_index| {
                if (all_index < exclude_struct_offset) { // Exclude
                    continue;
                }
                const i = all_index - exclude_struct_offset; // Offset due to excluded member struct

                const arg_name = if (i < arg_names.len) arg_names[i] else "unnamed_arg";
                const base_type = TypeGetBase(param.type.?);
                const variant_type = Variant.typeToVariantType(base_type);

                var storage = &signature.storage[i];
                storage.name = gd.stringNameFromUtf8(arg_name);
                storage.class = classStringName(base_type);
                storage.hint = String.init();

                var info: gi.GDExtensionPropertyInfo = undefined;

                info.name = &storage.name;
                info._type = @enumFromInt(@intFromEnum(variant_type));
                info.class_name = &storage.class;
                info.hint = 0;
                info.hint_string = &storage.hint;
                info.usage = 0;

                const metadata = gi.GDExtensionClassMethodArgumentMetadata.GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE; //TODO: Implement

                signature.arguments_info[i] = info;
                signature.arguments_metadata[i] = metadata;
            }

            signature.has_return_value = fn_info.return_type.? != void;
            if (signature.has_return_value) {
                const name = "ret";
                const base_type = TypeGetBase(fn_info.return_type.?);
                const variant_type = Variant.typeToVariantType(base_type);

                var storage = &signature.storage[max_argument_count];
                storage.name = gd.stringNameFromUtf8(name);
                storage.class = classStringName(base_type);
                storage.hint = String.init();

                var info: gi.GDExtensionPropertyInfo = undefined;

                info.name = &storage.name;
                info._type = @enumFromInt(@intFromEnum(variant_type));
                info.class_name = &storage.class;
                info.hint = 0;
                info.hint_string = &storage.hint;
                info.usage = 0;

                const metadata = gi.GDExtensionClassMethodArgumentMetadata.GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE; //TODO: Implement

                signature.return_value_info = info;
                signature.return_value_metadata = metadata;
            }

            // NOTE: Zig doesn't have default argument values
            signature.default_argument_count = 0;
            signature.default_arguments[0] = null;

            return signature;
        }

        pub fn deinit(self: *Self) void {
            var i: usize = 0;
            while (i < self.argument_count) : (i += 1) {
                const storage = &self.storage[i];
                storage.name.deinit();
                storage.class.deinit();
                storage.hint.deinit();
            }

            if (self.has_return_value) {
                const storage = &self.storage[max_argument_count];
                storage.name.deinit();
                storage.class.deinit();
                storage.hint.deinit();
            }
        }

    };


    pub fn registerClass(comptime class: type, is_virtual: bool, is_abstract: bool) void {
        const class_info = gi.GDExtensionClassCreationInfo {
            .is_virtual = is_virtual,
            .is_abstract = is_abstract,
            .set_func = null,
            .get_func = null,
            .get_property_list_func = null,
            .free_property_list_func = null,
            .property_can_revert_func = null,
            .property_get_revert_func = null,
            .notification_func = null,
            .to_string_func = null,
            .reference_func = null,
            .unreference_func = null,
            .create_instance_func = class._create,
            .free_instance_func = class._free,
            .get_virtual_func = class._getVirtualMethod,
            .get_rid_func = null,
            .class_userdata = null,
        };

        const class_name = class.getClassStatic();
        const base_class_name = class.getParentClassStatic();

        gd.interface.?.classdb_register_extension_class.?(gd.library, class_name._nativePtr(), base_class_name._nativePtr(), &class_info);

        class._initializeClass();
    }

    pub fn bindMethod(comptime class: type, comptime function: anytype, name: []const u8, arg_names: anytype) void {
        const fn_info = @typeInfo(@TypeOf(function)).Fn;

        comptime if (fn_info.params.len == 0) {
            @compileError("A method needs to take atleast the struct parameter");
        };
        comptime if (fn_info.params[0].type.? != *class and fn_info.params[0].type.? != *const class) {
            @compileError("The first parameter of a method should be the struct");
        };

        var info = SignatureInfo.init(function, true, arg_names);
        defer info.deinit();

        const is_const = fn_info.params[0].type == *const class;
        comptime var method_flags = method_flag_default;
        if (is_const) {
            method_flags |= method_flag_const;
        }

        const wrapper_call = BindWrapper.MethodCall(class, function);
        const wrapper_ptrcall = BindWrapper.MethodPtrCall(class, function);

        var string_name = gd.stringNameFromUtf8(name);
        defer string_name.deinit();

        const method_info = gi.GDExtensionClassMethodInfo {
            .name = string_name._nativePtr(),
            .method_userdata = null,
            .call_func = wrapper_call.functionWrap,
            .ptrcall_func = wrapper_ptrcall.functionWrap,
            .method_flags = method_flags,
            .has_return_value = info.has_return_value,
            .return_value_info = &info.return_value_info,
            .return_value_metadata = info.return_value_metadata,
            .argument_count = info.argument_count,
            .arguments_info = &info.arguments_info,
            .arguments_metadata = &info.arguments_metadata,
            .default_argument_count = info.default_argument_count,
            .default_arguments = &info.default_arguments,
        };

        const class_name = class.getClassStatic();
        gd.interface.?.classdb_register_extension_class_method.?(gd.library, class_name._nativePtr(), &method_info);
    }

    pub fn bindStaticMethod(comptime class: type, comptime function: anytype, name: []const u8, arg_names: anytype) void {
        var info = SignatureInfo.init(function, false, arg_names);
        defer info.deinit();

        const method_flags = method_flag_default | method_flag_static;

        const wrapper_call = BindWrapper.FunctionCall(function);
        const wrapper_ptrcall = BindWrapper.FunctionPtrCall(function);

        var string_name = gd.stringNameFromUtf8(name);
        defer string_name.deinit();

        const method_info = gi.GDExtensionClassMethodInfo {
            .name = string_name._nativePtr(),
            .method_userdata = null,
            .call_func = wrapper_call.functionWrap,
            .ptrcall_func = wrapper_ptrcall.functionWrap,
            .method_flags = method_flags,
            .has_return_value = info.has_return_value,
            .return_value_info = &info.return_value_info,
            .return_value_metadata = info.return_value_metadata,
            .argument_count = info.argument_count,
            .arguments_info = &info.arguments_info,
            .arguments_metadata = &info.arguments_metadata,
            .default_argument_count = info.default_argument_count,
            .default_arguments = &info.default_arguments,
        };

        const class_name = class.getClassStatic();
        gd.interface.?.classdb_register_extension_class_method.?(gd.library, class_name._nativePtr(), &method_info);
    }

    pub fn bindVirtualMethod(comptime class: type, comptime function: anytype, name: []const u8, arg_names: anytype) void {
        _ = arg_names;
        const wrapper_call = BindWrapper.VirtualMethodCall(class, function);
        class._addVirtualMethod(name, wrapper_call.functionWrap);
    }


    fn PropertyDefaultSetter(comptime class: type, comptime field_name: []const u8) type {
        return struct {
            const class_instance: class = undefined;
            const field_type = @TypeOf(@field(class_instance, field_name));
            inline fn function(instance: *class, value: field_type) void {
                @field(instance, field_name) = value;
            }
        };
    }

    fn PropertyDefaultGetter(comptime class: type, comptime field_name: []const u8) type {
        return struct {
            const class_instance: class = undefined;
            const field_type = @TypeOf(@field(class_instance, field_name));
            inline fn function(instance: *const class) field_type {
                return @field(instance, field_name);
            }
        };
    }

    pub fn bindProperty(comptime class: type, comptime field: []const u8, name: []const u8, comptime setter: anytype, comptime getter: anytype) void {
        const class_instance: class = undefined;
        const field_type = @TypeOf(@field(class_instance, field));
        const variant_type = Variant.typeToVariantType(field_type);

        // Must create and bind setter and getter methods
        const setter_name = "set_" ++ field;
        const getter_name = "get_" ++ field;
        var setter_string = gd.stringNameFromUtf8(setter_name);
        defer setter_string.deinit();
        var getter_string = gd.stringNameFromUtf8(getter_name);
        defer getter_string.deinit();

        const setter_func = if (@TypeOf(setter) == @TypeOf(null)) PropertyDefaultSetter(class, field).function else setter;
        const getter_func = if (@TypeOf(getter) == @TypeOf(null)) PropertyDefaultGetter(class, field).function else getter;

        bindMethod(class, setter_func, setter_name, .{});
        bindMethod(class, getter_func, getter_name, .{});

        var name_string = gd.stringNameFromUtf8(name);
        defer name_string.deinit();
        var property_class_name = classStringName(field_type);
        defer property_class_name.deinit();
        var hint_string = String.init();
        defer hint_string.deinit();

        var info: gi.GDExtensionPropertyInfo = undefined;
        info.name = name_string._nativePtr();
        info._type = @enumFromInt(@intFromEnum(variant_type));
        info.class_name = property_class_name._nativePtr();
        info.hint = 0;
        info.hint_string = hint_string._nativePtr();
        info.usage = 0;

        const class_name = class.getClassStatic();
        gd.interface.?.classdb_register_extension_class_property.?(gd.library, class_name._nativePtr(), &info, setter_string._nativePtr(), getter_string._nativePtr());
    }

    pub fn bindSignal(comptime class: type, name: []const u8, comptime arg_types: anytype, comptime arg_names: anytype) void {
        var string_storage: [arg_types.len]StringStorage = undefined;
        var args_info: [arg_types.len]gi.GDExtensionPropertyInfo = undefined;

        inline for (arg_types, 0..) |arg_type, i| {
            const arg_name = if (i < arg_names.len) arg_names[i] else "unnamed_arg";
            const base_type = TypeGetBase(arg_type);
            const variant_type = Variant.typeToVariantType(base_type);

            var storage = &string_storage[i];
            storage.name = gd.stringNameFromUtf8(arg_name);
            storage.class = classStringName(base_type);
            storage.hint = String.init();

            var info: gi.GDExtensionPropertyInfo = undefined;
            info.name = storage.name._nativePtr();
            info._type = @enumFromInt(@intFromEnum(variant_type));
            info.class_name = storage.class._nativePtr();
            info.hint = 0;
            info.hint_string = storage.hint._nativePtr();
            info.usage = 0;
            args_info[i] = info;
        }

        var string_name = gd.stringNameFromUtf8(name);
        defer string_name.deinit();

        const class_name = class.getClassStatic();
        gd.interface.?.classdb_register_extension_class_signal.?(gd.library, class_name._nativePtr(), string_name._nativePtr(), &args_info, arg_types.len);

        inline for (arg_types, 0..) |arg_type, i| {
            _ = arg_type;
            var storage = &string_storage[i];
            storage.name.deinit();
            storage.class.deinit();
            storage.hint.deinit();
        }
    }


    pub fn castTo(instance: anytype, comptime class: type) ?*class {
        const class_name = class.getClassStatic();
        const class_tag = gd.interface.?.classdb_get_class_tag.?(class_name._nativePtr());
        const casted: gi.GDExtensionObjectPtr = @ptrCast(gd.interface.?.object_cast_to.?(@as(*const Wrapped, @ptrCast(instance))._owner, class_tag));
        if (casted == null) {
            return null;
        }
        return @alignCast(@ptrCast(gd.interface.?.object_get_instance_binding.?(casted, gd.token, class._getBindingCallbacks())));
    }

};
