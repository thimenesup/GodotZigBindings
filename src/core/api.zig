const gd = @import("gdnative_types.zig");

const std = @import("std");

const Wrapped = @import("wrapped.zig").Wrapped;
const ClassRegistry = @import("class_registry.zig");
const GenTypes = @import("../classes/_register_types.zig");
const GenBindings = @import("../classes/_init_bindings.zig");

pub var core: *const gd.godot_gdnative_core_api_struct = undefined;
pub var core_1_1: *const gd.godot_gdnative_core_1_1_api_struct = undefined;
pub var core_1_2: *const gd.godot_gdnative_core_1_2_api_struct = undefined;
pub var nativescript: *const gd.godot_gdnative_ext_nativescript_api_struct = undefined;
pub var nativescript_1_1: *const gd.godot_gdnative_ext_nativescript_1_1_api_struct = undefined;
pub var pluginscript: *const gd.godot_gdnative_ext_pluginscript_api_struct = undefined;
pub var android: *const gd.godot_gdnative_ext_android_api_struct = undefined;
pub var arvr: *const gd.godot_gdnative_ext_arvr_api_struct = undefined;
pub var videodecoder: *const gd.godot_gdnative_ext_videodecoder_api_struct = undefined;
pub var net: *const gd.godot_gdnative_ext_net_api_struct = undefined;
pub var net_3_2: *const gd.godot_gdnative_ext_net_3_2_api_struct = undefined;

pub var gndlib: ?*anyopaque = null;
pub var nativescript_handle: ?*anyopaque = null;
pub var language_index: i32 = 0;

pub fn gdnativeInit(p_options: [*c]gd.godot_gdnative_init_options) void {
    core = p_options.*.api_struct;
    gndlib = p_options.*.gd_native_library;

    if (core.next != null) {
        core_1_1 = @ptrCast(@TypeOf(core_1_1), core.next);
        if (core_1_1.next != null){
            core_1_2 = @ptrCast(@TypeOf(core_1_2), core_1_1.next);
        }
    }

    // Find NativeScript extensions.
    var i: usize = 0;
    while (i < core.num_extensions) : (i += 1) {
        switch (core.extensions[i].*.type) {
            gd.GDNATIVE_EXT_NATIVESCRIPT => {
                nativescript = @ptrCast(@TypeOf(nativescript), core.extensions[i]);
                if (nativescript.next != null) {
                    nativescript_1_1 = @ptrCast(@TypeOf(nativescript_1_1), nativescript.next);
                }
            },
            gd.GDNATIVE_EXT_PLUGINSCRIPT => {
                pluginscript = @ptrCast(@TypeOf(pluginscript), core.extensions[i]);
            },
            gd.GDNATIVE_EXT_ANDROID => {
                android = @ptrCast(@TypeOf(android), core.extensions[i]);
            },
            gd.GDNATIVE_EXT_ARVR => {
                arvr = @ptrCast(@TypeOf(arvr), core.extensions[i]);
            },
            gd.GDNATIVE_EXT_VIDEODECODER => {
                videodecoder = @ptrCast(@TypeOf(videodecoder), core.extensions[i]);
            },
            gd.GDNATIVE_EXT_NET => {
                net = @ptrCast(@TypeOf(net), core.extensions[i]);
                if (net.next != null) {
                    net_3_2 = @ptrCast(@TypeOf(net_3_2), net.next);
                }
            },
            else => {},
        }
    }

    var binding_funcs = std.mem.zeroInit(gd.godot_instance_binding_functions, .{});
    binding_funcs.alloc_instance_binding_data = wrapperCreate;
    binding_funcs.free_instance_binding_data = wrapperDestroy;

    language_index = nativescript_1_1.godot_nativescript_register_instance_binding_data_functions.?(binding_funcs);

    ClassRegistry.initTypeTagRegistry();

    GenTypes.registerTypes(); // Register Godot generated class types
    GenBindings.initBindings(); // Init Godot generated class bindings
}

pub fn gdnativeTerminate(p_options: [*c]gd.godot_gdnative_terminate_options) void {
    _ = p_options;

    ClassRegistry.deinitTypeTagRegistry();
}

pub fn nativescriptInit(p_handle: ?*anyopaque) void {
    nativescript_handle = p_handle;
}

pub fn nativescriptTerminate(p_handle: ?*anyopaque) void {
    _ = p_handle;
    nativescript_1_1.godot_nativescript_unregister_instance_binding_data_functions.?(language_index);
}


fn wrapperCreate(data: ?*anyopaque, type_tag: ?*const anyopaque, instance: ?*gd.godot_object) callconv(.C) ?*anyopaque {
    _ = data;

    const wrapper_data = core.godot_alloc.?(@sizeOf(Wrapped));
    var wrapper = @ptrCast(?*Wrapped, @alignCast(@alignOf(Wrapped), wrapper_data));
    if (wrapper == null) {
        return null;
    }

    wrapper.?.owner = instance;
    wrapper.?.type_tag = @ptrToInt(type_tag);

    return @ptrCast(?*anyopaque, wrapper);
}

fn wrapperDestroy(data: ?*anyopaque, wrapper: ?*anyopaque) callconv(.C) void {
    _ = data;
    
    if (wrapper != null) {
        core.godot_free.?(wrapper);
    }
}
