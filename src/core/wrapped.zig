const std = @import("std");

const gi = @import("../gdextension_interface.zig");
const gd = @import("../godot.zig");

const Variant = @import("variant.zig").Variant;
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

// This is for generated classes
pub fn GDExtensionClass(comptime class: type, comptime base_class: type) type {
    return struct {

        var class_string_name: StringName = undefined;

        pub fn _notification(self: *Wrapped, what: i32) callconv(.C) void { _ = self; _ = what; }
        pub fn _set(self: *Wrapped, name: *const StringName, property: *const Variant) callconv(.C) bool { _ = self; _ = name; _ = property; return false; }
        pub fn _get(self: *const Wrapped, name: *const StringName, property: *Variant) callconv(.C) bool { _ = self; _ = name; _ = property; return false; }
        pub fn _getPropertyList(self: *const Wrapped, list: ?*anyopaque) callconv(.C) void { _ = self; _ = list; }
        pub fn _propertyCanRevert(self: *const Wrapped, name: *const StringName) callconv(.C) bool { _ = self; _ = name; return false; }
        pub fn _propertyGetRevert(self: *const Wrapped, name: *const StringName, property: *Variant) callconv(.C) bool { _ = self; _ = name; _ = property; return false; }
        pub fn _toString(self: *const Wrapped) callconv(.C) String { _ = self; const string = String.init(); return string; }

        pub fn _notificationBind(instance: gi.GDExtensionClassInstancePtr, what: i32) callconv(.C) void { _ = instance; _ = what; }
        pub fn _setBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionConstVariantPtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; _ = value; return false; }
        pub fn _getBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; _ = value; return false; }
        pub fn _getPropertyListBind(instance: gi.GDExtensionClassInstancePtr, count: [*c]u32) callconv(.C) [*c]gi.GDExtensionPropertyInfo { _ = instance; _ = count; return null; }
        pub fn _freePropertyListBind(instance: gi.GDExtensionClassInstancePtr, list: [*]const gi.GDExtensionPropertyInfo) callconv(.C) void { _ = instance; _ = list; }
        pub fn _propertyCanRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; return false; }
        pub fn _propertyGetRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool { _ = instance; _ = name; _ = value; return false; }
        pub fn _toStringBind(instance: gi.GDExtensionClassInstancePtr, is_valid: *gi.GDExtensionBool, out: gi.GDExtensionStringPtr) callconv(.C) void { _ = instance; _ = is_valid; _ = out; }

        pub fn _getBindMembers() callconv(.C) ?*const fn() callconv(.C) void {
            return null;
        }

        pub fn _getNotification() callconv(.C) ?*const fn(*Wrapped, i32) callconv(.C) void {
            return null;
        }

        pub fn _getSet() callconv(.C) ?*const fn(*Wrapped, *const StringName, *const Variant) callconv(.C) bool {
            return null;
        }

        pub fn _getGet() callconv(.C) ?*const fn(*const Wrapped, *const StringName, *Variant) callconv(.C) bool {
            return null;
        }

        pub fn _getGetPropertyList() callconv(.C) ?*const fn(*const Wrapped, ?*anyopaque) callconv(.C) void {
            return null;
        }

        pub fn _getPropertyCanRevert() callconv(.C) ?*const fn(*const Wrapped, *const StringName) callconv(.C) bool {
            return null;
        }

        pub fn _getPropertyGetRevert() callconv(.C) ?*const fn(*const Wrapped, *const StringName, *Variant) callconv(.C) bool {
            return null;
        }

        pub fn _getToString() callconv(.C) ?*const fn(*const Wrapped) callconv(.C) String {
            return null;
        }

        pub fn _initializeClass() callconv(.C) void {

        }

        pub fn getClassStatic() callconv(.C) *StringName {
            class_string_name = gd.stringNameFromUtf8(classTypeName(class));
            return &class_string_name;
        }

        pub fn getParentClassStatic() callconv(.C) *StringName {
            return base_class.getClassStatic();
        }

        pub fn _bindingCreateCallback(token: ?*anyopaque, instance: ?*anyopaque) callconv(.C) ?*anyopaque {
            _ = token;
            const class_instance: *class = @alignCast(@ptrCast(instance));
            class_instance.init();
            return instance;
        }

        pub fn _bindingFreeCallback(token: ?*anyopaque, instance: ?*anyopaque, binding: ?*anyopaque) callconv(.C) void {
            _ = token;
            const class_instance: *class = @alignCast(@ptrCast(instance));
            class_instance.deinit();
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

    };
}


// This is for custom classes
pub fn GDClass(comptime class: type, comptime base_class: type) type {
    return struct {

        var class_string_name: StringName = undefined;

        // These will be used by ClassDB
        var virtual_methods: std.AutoHashMap(StringName, gi.GDExtensionClassCallVirtual) = undefined;

        fn _initVirtualMethods() void {
            virtual_methods = std.AutoHashMap(StringName, gi.GDExtensionClassCallVirtual).init(std.heap.page_allocator);
        }

        pub fn _addVirtualMethod(name: []const u8, function_ptr: gi.GDExtensionClassCallVirtual) void {
            const string_name = gd.stringNameFromUtf8(name);
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


        pub fn _notification(self: *Wrapped, what: i32) callconv(.C) void { _ = self; _ = what; }
        pub fn _set(self: *Wrapped, name: *const StringName, property: *const Variant) callconv(.C) bool { _ = self; _ = name; _ = property; return false; }
        pub fn _get(self: *const Wrapped, name: *const StringName, property: *Variant) callconv(.C) bool { _ = self; _ = name; _ = property; return false; }
        pub fn _getPropertyList(self: *const Wrapped, list: ?*anyopaque) callconv(.C) void { _ = self; _ = list; }
        pub fn _propertyCanRevert(self: *const Wrapped, name: *const StringName) callconv(.C) bool { _ = self; _ = name; return false; }
        pub fn _propertyGetRevert(self: *const Wrapped, name: *const StringName, property: *Variant) callconv(.C) bool { _ = self; _ = name; _ = property; return false; }
        pub fn _toString(self: *const Wrapped) callconv(.C) String { _ = self; const string = String.init(); return string; }

        pub fn _getExtensionClassName() callconv(.C) ?*const StringName {
            class_string_name = gd.stringNameFromUtf8(classTypeName(class));
            return &class_string_name;
        }

        pub fn _getBindMembers() callconv(.C) ?*const fn() callconv(.C) void {
            return class._bindMembers;
        }

        pub fn _getNotification() callconv(.C) ?*const fn(*Wrapped, i32) callconv(.C) void {
            return _notification;
        }

        pub fn _getSet() callconv(.C) ?*const fn(*Wrapped, *const StringName, *const Variant) callconv(.C) bool {
            return _set;
        }

        pub fn _getGet() callconv(.C) ?*const fn(*const Wrapped, *const StringName, *Variant) callconv(.C) bool {
            return _get;
        }

        pub fn _getGetPropertyList() callconv(.C) ?*const fn(*const Wrapped, ?*anyopaque) callconv(.C) void {
            return _getPropertyList;
        }

        pub fn _getPropertyCanRevert() callconv(.C) ?*const fn(*const Wrapped, *const StringName) callconv(.C) bool {
            return _propertyCanRevert;
        }

        pub fn _getPropertyGetRevert() callconv(.C) ?*const fn(*const Wrapped, *const StringName, *Variant) callconv(.C) bool {
            return _propertyGetRevert;
        }

        pub fn _getToString() callconv(.C) ?*const fn(*const Wrapped) callconv(.C) String {
            return _toString;
        }

        pub fn _initializeClass() callconv(.C) void {
            const static = struct {
                var initialized = false;
            };
            if (static.initialized) {
                return;
            }

            base_class._initializeClass();

            _initVirtualMethods();

            if (class._getBindMembers() != base_class._getBindMembers()) {
                class._bindMembers();
            }

            static.initialized = true;
        }

        pub fn getClassStatic() callconv(.C) *StringName {
            class_string_name = gd.stringNameFromUtf8(classTypeName(class));
            return &class_string_name;
        }

        pub fn getParentClassStatic() callconv(.C) *StringName {
            return base_class.getClassStatic();
        }

        pub fn _create(data: ?*anyopaque) callconv(.C) gi.GDExtensionObjectPtr {
            _ = data;

            const allocation = gd.interface.?.mem_alloc.?(@sizeOf(class));
            const new_class: *class = @alignCast(@ptrCast(allocation));
            new_class.* = class.init();

            const new_wrapped: *Wrapped = @alignCast(@ptrCast(allocation));
            new_wrapped.* = Wrapped.initStringName(class.getParentClassStatic());
            new_wrapped.postInitialize(class);

            return new_wrapped._owner;
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
            _notification(@alignCast(@ptrCast(instance)), what);
        }

        pub fn _setBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, value: gi.GDExtensionConstVariantPtr) callconv(.C) gi.GDExtensionBool {
            return _set(@alignCast(@ptrCast(instance)), @ptrCast(name), @ptrCast(value));
        }

        pub fn _getBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, ret: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool {
            return _get(@alignCast(@ptrCast(instance)), @ptrCast(name), @ptrCast(ret));
        }

        pub fn _propertyCanRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr) callconv(.C) gi.GDExtensionBool {
            return _propertyCanRevert(@alignCast(@ptrCast(instance)), @ptrCast(name));
        }

        pub fn _propertyGetRevertBind(instance: gi.GDExtensionClassInstancePtr, name: gi.GDExtensionConstStringNamePtr, ret: gi.GDExtensionVariantPtr) callconv(.C) gi.GDExtensionBool {
            return _propertyGetRevert(@alignCast(@ptrCast(instance)), @ptrCast(name), @ptrCast(ret));
        }

        pub fn _toStringBind(instance: gi.GDExtensionClassInstancePtr, is_valid: [*c]gi.GDExtensionBool, out: gi.GDExtensionStringPtr) callconv(.C) void {
            const string_out: *String = @ptrCast(out);
            string_out.* = _toString(@alignCast(@ptrCast(instance)));
            is_valid.* = true;
        }

        pub fn _getPropertyListBind(instance: gi.GDExtensionClassInstancePtr, count: [*c]u32) callconv(.C) [*c]gi.GDExtensionPropertyInfo {
            _getPropertyList(@alignCast(@ptrCast(instance)), count);
            return null;
        }

        pub fn _freePropertyListBind(instance: gi.GDExtensionClassInstancePtr, list: [*c]const gi.GDExtensionPropertyInfo) callconv(.C) void {
            _ = instance;
            _ = list;
            // TODO: Implement
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

    };
}
