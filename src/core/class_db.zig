const std = @import("std");
const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const BindWrapper = @import("bind_wrapper.zig");

const Variant = @import("../core/variant.zig").Variant;
const StringName = @import("../gen/builtin_classes/string_name.zig").StringName;

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

    fn getClassName(comptime T: type) ?*const StringName {
        const type_info = @typeInfo(T);
        const type_tag = @typeInfo(std.builtin.Type).Union.tag_type.?;
        switch (type_info) {
            type_tag.Struct => {
                return T.getClassStatic();
            },
            else => {
                return null;
            }
        }
    }


    const SignatureInfo = struct {
        const max_argument_count = 16;
        argument_count: u32,
        arguments_info: [max_argument_count]gi.GDExtensionPropertyInfo,
        arguments_metadata: [max_argument_count]gi.GDExtensionClassMethodArgumentMetadata,
        has_return_value: bool,
        return_value_info: gi.GDExtensionPropertyInfo,
        return_value_metadata: gi.GDExtensionClassMethodArgumentMetadata,
        default_argument_count: u32,
        default_arguments: [max_argument_count]gi.GDExtensionVariantPtr,
    };

    fn signatureInfo(comptime function: anytype, comptime is_method: bool) SignatureInfo {
        const fn_info = @typeInfo(@TypeOf(function)).Fn;
        const exclude_struct_offset = if (is_method) 1 else 0; // Offset to exclude the member struct from arguments
        const excluded_argument_count = fn_info.params.len - exclude_struct_offset;

        if (excluded_argument_count > SignatureInfo.max_argument_count) {
            @compileError("Too many arguments");
        }

        var signature: SignatureInfo = undefined;
        signature.argument_count = excluded_argument_count;

        inline for (fn_info.params, exclude_struct_offset..) |param, all_index| { // Begin from 1 to exclude member struct
            const i = all_index - exclude_struct_offset; // Offset due to excluded member struct

            var info: gi.GDExtensionPropertyInfo = undefined;

            const name = "arg"; // NOTE: Zig doesn't expose actual param names
            const param_name = gd.stringNameFromUtf8(name);
            info.name = param_name._nativePtr();

            const base_type = TypeGetBase(param.type.?);
            const variant_type = Variant.typeToVariantType(base_type);
            info._type = @enumFromInt(@intFromEnum(variant_type));

            if (variant_type == Variant.Type.object) {
                const class_name = getClassName(base_type);
                info.class_name = class_name.?._nativePtr();
            }

            info.hint = 0;
            info.hint_string = null;
            info.usage = 0;

            const metadata = gi.GDExtensionClassMethodArgumentMetadata.GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE; //TODO: Implement

            signature.arguments_info[i] = info;
            signature.arguments_metadata[i] = metadata;
        }

        signature.has_return_value = fn_info.return_type != null;
        if (signature.has_return_value) {
            var info: gi.GDExtensionPropertyInfo = undefined;

            info.name = null;

            const base_type = TypeGetBase(fn_info.return_type.?);
            const variant_type = Variant.typeToVariantType(base_type);
            info._type = @enumFromInt(@intFromEnum(variant_type));

            if (variant_type == Variant.Type.object) {
                const class_name = getClassName(base_type);
                info.class_name = class_name.?._nativePtr();
            }

            info.hint = 0;
            info.hint_string = null;
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


    pub fn registerClass(comptime class: type, is_virtual: bool, is_abstract: bool) void {
        const class_info = gi.GDExtensionClassCreationInfo {
            .is_virtual = is_virtual,
            .is_abstract = is_abstract,
            .set_func = class._setBind,
            .get_func = class._getBind,
            .get_property_list_func = class._getPropertyListBind,
            .free_property_list_func = class._freePropertyListBind,
            .property_can_revert_func = class._propertyCanRevertBind,
            .property_get_revert_func = class._propertyGetRevertBind,
            .notification_func = class._notificationBind,
            .to_string_func = class._toStringBind,
            .reference_func = null,
            .unreference_func = null,
            .create_instance_func = class._create,
            .free_instance_func = class._free,
            .get_virtual_func = null, //class._getVirtualFunc,
            .get_rid_func = null,
            .class_userdata = null, //class.getClassStatic,
        };

        const class_name = class.getClassStatic();
        const base_class_name = class.getParentClassStatic();

        gd.interface.?.classdb_register_extension_class.?(gd.library, class_name._nativePtr(), base_class_name._nativePtr(), &class_info);

        class._initializeClass();
    }

    pub fn bindMethod(comptime class: type, name: []const u8, comptime function: anytype) void {
        const fn_info = @typeInfo(@TypeOf(function)).Fn;

        comptime if (fn_info.params.len == 0) {
            @compileError("A method needs to take atleast the struct parameter");
        };
        comptime if (fn_info.params[0].type.? != *class and fn_info.params[0].type.? != *const class) {
            @compileError("The first parameter of a method should be the struct");
        };

        var info = signatureInfo(function, true);

        const method_flags = 1; // GlobalConstants.METHOD_FLAGS_DEFAULT

        const wrapper_call = BindWrapper.MethodCall(class, function);
        const wrapper_ptrcall = BindWrapper.MethodPtrCall(class, function);

        const string_name = gd.stringNameFromUtf8(name);

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

    pub fn bindStaticMethod(comptime class: type, name: []const u8, comptime function: anytype) void {
        var info = signatureInfo(function, false);

        const method_flags = 0;

        const wrapper_call = BindWrapper.FunctionCall(function);
        const wrapper_ptrcall = BindWrapper.FunctionPtrCall(function);

        const string_name = gd.stringNameFromUtf8(name);

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

};
