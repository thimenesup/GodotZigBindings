const std = @import("std");

const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const Variant = @import("../variant/variant.zig").Variant;
const StringName = @import("../gen/builtin_classes/string_name.zig").StringName;
const String = @import("../gen/builtin_classes/string.zig").String;

pub const Wrapped = struct {
    _owner: ?*anyopaque = undefined,

    const Self = @This();

    pub fn initStringName(godot_class: *const StringName) Self {
        var self: Self = undefined;
        self._owner = gd.interface.?.classdb_construct_object.?(godot_class._nativePtr());
        return self;
    }

    pub fn postInitialize(self: *Self, comptime class: type) void {
        const extension_class = class._getExtensionClassName();
        if (extension_class != null) {
            gd.interface.?.object_set_instance.?(self._owner, @ptrCast(extension_class), @ptrCast(self));
        }
        gd.interface.?.object_set_instance_binding.?(self._owner, gd.token, @ptrCast(self), class._getBindingCallbacks());
    }

};

fn classTypeName(comptime class: type) []const u8 {
    const class_name = comptime blk: { // Remove parent namespaces from type
        const type_name = @typeName(class);
        const class_index = std.mem.lastIndexOf(u8, type_name, ".");
        const name = type_name[(class_index.? + 1)..type_name.len];
        break :blk name;
    };
    return class_name;
}

fn classInherits(comptime class: type, comptime base_class: type) bool {
    var c = class;
    while (true) {
        if (!@hasDecl(c, "BaseClass")) {
            return false;
        }
        if (c.BaseClass == Wrapped) {
            return false;
        }
        if (c.BaseClass == base_class) {
            return true;
        }
        c = c.BaseClass;
    }
    return false;
}

// This is for generated classes
pub fn GDExtensionClass(comptime class: type, comptime base_class: type) type {
    return struct {

        _wrapped: Wrapped,

        pub const Class = class;
        pub const BaseClass = base_class;

        var class_string_name: StringName = undefined;

        pub fn _notificationBind(instance: gi.GDExtensionClassInstancePtr, what: i32) callconv(.C) void { _ = instance; _ = what; }
        pub fn _setBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionConstVariantPtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; _ = value; return false; }
        pub fn _getBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; _ = value; return false; }
        pub fn _propertyCanRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; return false; }
        pub fn _propertyGetRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; _ = value; return false; }
        pub fn _toStringBind(instance: gi.GDExtensionClassInstancePtr, is_valid: *gi.GDExtensionBool, out: gi.GDExtensionStringPtr) callconv(.C) void { _ = instance; _ = is_valid; _ = out; }
        pub fn _getPropertyListBind(instance: gi.GDExtensionClassInstancePtr, count: [*c]u32) callconv(.C) [*c]gi.GDExtensionPropertyInfo { _ = instance; count.* = 0; return null; }
        pub fn _freePropertyListBind(instance: gi.GDExtensionClassInstancePtr, list: [*]const gi.GDExtensionPropertyInfo) callconv(.C) void { _ = instance; _ = list; }

        pub fn _getBindMembers() callconv(.C) ?*const fn() callconv(.C) void {
            return null;
        }

        pub fn _initializeClass() callconv(.C) void {

        }

        pub fn getClassStatic() callconv(.C) *StringName {
            class_string_name = StringName.initUtf8(classTypeName(class));
            return &class_string_name;
        }

        pub fn getParentClassStatic() callconv(.C) *StringName {
            return base_class.getClassStatic();
        }

        pub fn _bindingCreateCallback(token: ?*anyopaque, instance: ?*anyopaque) callconv(.C) ?*anyopaque {
            _ = token;
            const allocation = gd.interface.?.mem_alloc.?(@sizeOf(class));
            const new_wrapped: *Wrapped = @alignCast(@ptrCast(allocation));
            new_wrapped._owner = instance;
            return allocation;
        }

        pub fn _bindingFreeCallback(token: ?*anyopaque, instance: ?*anyopaque, binding: ?*anyopaque) callconv(.C) void {
            _ = token;
            _ = instance;
            gd.interface.?.mem_free.?(binding);
        }

        pub fn _bindingReferenceCallback(token: ?*anyopaque, instance: ?*anyopaque, reference: gi.GDExtensionBool) callconv(.C) gi.GDExtensionBool {
            _ = token;
            _ = instance;
            _ = reference;
            return true;
        }

        const _binding_callbacks = gi.GDExtensionInstanceBindingCallbacks {
            .create_callback = _bindingCreateCallback,
            .free_callback = _bindingFreeCallback,
            .reference_callback = _bindingReferenceCallback,
        };

        pub fn _getBindingCallbacks() callconv(.C) *const gi.GDExtensionInstanceBindingCallbacks {
            return &_binding_callbacks;
        }


        pub fn _memnew() *class {
            const allocation = gd.interface.?.mem_alloc.?(@sizeOf(class));
            const new_wrapped: *Wrapped = @alignCast(@ptrCast(allocation));
            new_wrapped.* = Wrapped.initStringName(class.getClassStatic());
            return @alignCast(@ptrCast(allocation));
        }

        pub inline fn _wrappedOwner(self: *const class) ?*anyopaque {
            return self._godot_class._wrapped._owner;
        }

        pub inline fn as(self: *class, comptime inherited: type) *inherited {
            comptime if (!classInherits(class, inherited)) {
                @compileError("Incorrect inherit cast");
            };
            return @ptrCast(self);
        }

    };
}


// This is for custom classes
pub fn GDClass(comptime class: type, comptime base_class: type) type {
    return struct {

        _wrapped: Wrapped,

        pub const Class = class;
        pub const BaseClass = base_class;

        var class_initialized: bool = false;
        var class_string_name: StringName = undefined;

        // These will be used by ClassDB
        var virtual_methods: std.AutoHashMap(StringName, gi.GDExtensionClassCallVirtual) = undefined;

        fn _initVirtualMethods() void {
            virtual_methods = std.AutoHashMap(StringName, gi.GDExtensionClassCallVirtual).init(std.heap.page_allocator);
        }

        pub fn _addVirtualMethod(name: []const u8, function_ptr: gi.GDExtensionClassCallVirtual) void {
            const string_name = StringName.initUtf8(name);
            virtual_methods.putNoClobber(string_name, function_ptr) catch {};
        }

        pub fn _getVirtualMethod(user_data: ?*anyopaque, name: gi.GDExtensionConstStringNamePtr) callconv(.C) gi.GDExtensionClassCallVirtual {
            _ = user_data;
            const string_name: *const StringName = @ptrCast(name);
            const function_ptr = virtual_methods.get(string_name.*);
            if (function_ptr != null) {
                return function_ptr.?;
            } else {
                return null;
            }
        }

        pub fn _getExtensionClassName() callconv(.C) ?*const StringName {
            class_string_name = StringName.initUtf8(classTypeName(class));
            return &class_string_name;
        }

        pub fn _getBindMembers() callconv(.C) ?*const fn() callconv(.C) void {
            return class._bindMembers;
        }

        pub fn bindVirtuals(comptime T: type, comptime B: type) void {
            base_class.bindVirtuals(T, B);
        }

        pub fn _initializeClass() callconv(.C) void {
            if (class_initialized) {
                return;
            }

            base_class._initializeClass();

            _initVirtualMethods();

            if (class._getBindMembers() != base_class._getBindMembers()) {
                class._bindMembers();
                base_class.bindVirtuals(class, base_class);
            }

            class_initialized = true;
        }

        pub fn getClassStatic() callconv(.C) *StringName {
            class_string_name = StringName.initUtf8(classTypeName(class));
            return &class_string_name;
        }

        pub fn getParentClassStatic() callconv(.C) *StringName {
            return base_class.getClassStatic();
        }

        pub fn _memnew() *class {
            const allocation = gd.interface.?.mem_alloc.?(@sizeOf(class));
            const new_class: *class = @alignCast(@ptrCast(allocation));
            new_class.* = class.init();

            const new_wrapped: *Wrapped = @alignCast(@ptrCast(allocation));
            new_wrapped.* = Wrapped.initStringName(class.getParentClassStatic());
            new_wrapped.postInitialize(class);

            return new_class;
        }

        pub fn _create(data: ?*anyopaque) callconv(.C) gi.GDExtensionObjectPtr {
            _ = data;

            const instance = class._memnew();
            return @as(*const Wrapped, @ptrCast(instance))._owner;
        }

        pub fn _free(data: ?*anyopaque, ptr: gi.GDExtensionClassInstancePtr) callconv(.C) void {
            _ = data;
            if (ptr != null) {
                const class_instance: *class = @alignCast(@ptrCast(ptr));
                class_instance.deinit();
                gd.interface.?.mem_free.?(class_instance);
            }
        }

        pub fn _notificationBind(instance: gi.GDExtensionClassInstancePtr, what: i32) callconv(.C) void {
            if (instance == null) {
                return;
            }
            if (@hasDecl(class, "_notification")) {
                class._notification(@alignCast(@ptrCast(instance)), what);
            } else {
                base_class._notificationBind(instance, what);
            }
        }

        pub fn _setBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionConstVariantPtr) callconv(.C) gi.GDExtensionBool {
            if (instance == null) {
                return false;
            }
            if (@hasDecl(class, "_set")) {
                return class._set(@alignCast(@ptrCast(instance)), @ptrCast(name), @ptrCast(value));
            } else {
                return base_class._setBind(instance, name, value);
            }
        }

        pub fn _getBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, ret: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool {
            if (instance == null) {
                return false;
            }
            if (@hasDecl(class, "_get")) {
                return class._get(@alignCast(@ptrCast(instance)), @ptrCast(name), @ptrCast(ret));
            } else {
                return base_class._getBind(instance, name, ret);
            }
        }

        pub fn _propertyCanRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr) callconv(.C) gi.GDExtensionBool {
            if (instance == null) {
                return false;
            }
            if (@hasDecl(class, "_propertyCanRevert")) {
                return class._propertyCanRevert(@alignCast(@ptrCast(instance)), @ptrCast(name));
            } else {
                return base_class._propertyCanRevertBind(instance, name);
            }
        }

        pub fn _propertyGetRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, ret: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool {
            if (instance == null) {
                return false;
            }
            if (@hasDecl(class, "_propertyGetRevert")) {
                return class._propertyGetRevert(@alignCast(@ptrCast(instance)), @ptrCast(name), @ptrCast(ret));
            } else {
                return base_class._propertyGetRevertBind(instance, name, ret);
            }
        }

        pub fn _toStringBind(instance: gi.GDExtensionClassInstancePtr, is_valid: [*c]gi.GDExtensionBool, out: gi.GDExtensionStringPtr) callconv(.C) void {
            const string_out: *String = @alignCast(@ptrCast(out));
            if (instance == null) {
                return;
            }
            if (@hasDecl(class, "_toString")) {
                var string: String = class._toString(instance);
                defer string.deinit();
                string_out.* = string;
                is_valid.* = true;
            } else {
                base_class._toStringBind(instance, is_valid, out);
            }
        }

        pub fn _getPropertyListBind(instance: gi.GDExtensionClassInstancePtr, count: [*c]u32) callconv(.C) [*c]gi.GDExtensionPropertyInfo {
            if (instance == null) {
                return null;
            }
            if (@hasDecl(class, "_getPropertyList")) {
                const properties: []const gi.GDExtensionPropertyInfo = class._getPropertyList(instance);
                const allocation = gd.interface.?.mem_alloc.?(@sizeOf(gi.GDExtensionPropertyInfo * properties.len));
                for (properties, 0..) |property, i| {
                    allocation[i] = property;
                }
                count.* = properties.len;
                return allocation;
            } else {
                return base_class._getPropertyListBind(instance, count);
            }
        }

        pub fn _freePropertyListBind(instance: gi.GDExtensionClassInstancePtr, list: [*c]const gi.GDExtensionPropertyInfo) callconv(.C) void {
            _ = instance;
            if (list != null) {
                gd.interface.?.mem_free.?(@constCast(@ptrCast(list)));
            }
        }

        pub fn _bindingCreateCallback(token: ?*anyopaque, instance: ?*anyopaque) callconv(.C) ?*anyopaque {
            _ = token;
            _ = instance;
            return null;
        }

        pub fn _bindingFreeCallback(token: ?*anyopaque, instance: ?*anyopaque, binding: ?*anyopaque) callconv(.C) void {
            _ = token;
            _ = instance;
            _ = binding;
        }

        pub fn _bindingReferenceCallback(token: ?*anyopaque, instance: ?*anyopaque, reference: gi.GDExtensionBool) callconv(.C) gi.GDExtensionBool {
            _ = token;
            _ = instance;
            _ = reference;
            return true;
        }

        const _binding_callbacks = gi.GDExtensionInstanceBindingCallbacks {
            .create_callback = _bindingCreateCallback,
            .free_callback = _bindingFreeCallback,
            .reference_callback = _bindingReferenceCallback,
        };

        pub fn _getBindingCallbacks() callconv(.C) *const gi.GDExtensionInstanceBindingCallbacks {
            return &_binding_callbacks;
        }


        pub inline fn _wrappedOwner(self: *const class) ?*anyopaque {
            return self._godot_class._wrapped._owner;
        }

        pub inline fn as(self: *class, comptime inherited: type) *inherited {
            comptime if (!classInherits(class, inherited)) {
                @compileError("Incorrect cast, class doesn't inherit given type");
            };
            return @ptrCast(self);
        }

    };
}
