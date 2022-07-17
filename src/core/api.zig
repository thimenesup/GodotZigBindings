pub const c = @cImport({
    @cInclude("gdnative_api_struct.gen.h");
});

const std = @import("std");

const Wrapped = @import("wrapped.zig").Wrapped;
//const GenTypes = @import("../gen/_register_types.zig");
const GenBindings = @import("../gen/_init_bindings.zig");

pub var api: [*c]const c.godot_gdnative_core_api_struct = null;
pub var api_1_1: [*c]const c.godot_gdnative_core_1_1_api_struct = null;
pub var api_1_2: [*c]const c.godot_gdnative_core_1_2_api_struct = null;
pub var nativescript_api: [*c]const c.godot_gdnative_ext_nativescript_api_struct = null;
pub var nativescript_1_1_api: [*c]const c.godot_gdnative_ext_nativescript_1_1_api_struct = null;
pub var pluginscript_api: [*c]const c.godot_gdnative_ext_pluginscript_api_struct = null;
pub var android_api: [*c]const c.godot_gdnative_ext_android_api_struct = null;
pub var arvr_api: [*c]const c.godot_gdnative_ext_arvr_api_struct = null;
pub var videodecoder_api: [*c]const c.godot_gdnative_ext_videodecoder_api_struct = null;
pub var net_api: [*c]const c.godot_gdnative_ext_net_api_struct = null;
pub var net_3_2_api: [*c]const c.godot_gdnative_ext_net_3_2_api_struct = null;

pub var gndlib: ?*anyopaque = null;
pub var nativescript_handle: ?*anyopaque = null;
pub var language_index: i32 = 0;

pub fn gdnative_init(p_options: [*c]c.godot_gdnative_init_options) void {
    api = p_options.*.api_struct;
    gndlib = p_options.*.gd_native_library;

    if (api.*.next != null) {
        api_1_1 = @ptrCast(@TypeOf(api_1_1), api.*.next);
        if (api_1_1.*.next != null){
            api_1_2 = @ptrCast(@TypeOf(api_1_2), api_1_1.*.next);
        }
    }

    // Find NativeScript extensions.
    var i: usize = 0;
    while (i < api.*.num_extensions) : (i += 1) {
        switch (api.*.extensions[i].*.type) {
            c.GDNATIVE_EXT_NATIVESCRIPT => {
                nativescript_api = @ptrCast(@TypeOf(nativescript_api), api.*.extensions[i]);
                if (nativescript_api.*.next != null) {
                    nativescript_1_1_api = @ptrCast(@TypeOf(nativescript_1_1_api), nativescript_api.*.next);
                }
            },
            c.GDNATIVE_EXT_PLUGINSCRIPT => {
                pluginscript_api = @ptrCast(@TypeOf(pluginscript_api), api.*.extensions[i]);
            },
            c.GDNATIVE_EXT_ANDROID => {
                android_api = @ptrCast(@TypeOf(android_api), api.*.extensions[i]);
            },
            c.GDNATIVE_EXT_ARVR => {
                arvr_api = @ptrCast(@TypeOf(arvr_api), api.*.extensions[i]);
            },
            c.GDNATIVE_EXT_VIDEODECODER => {
                videodecoder_api = @ptrCast(@TypeOf(videodecoder_api), api.*.extensions[i]);
            },
            c.GDNATIVE_EXT_NET => {
                net_api = @ptrCast(@TypeOf(net_api), api.*.extensions[i]);
                if (net_api.*.next != null) {
                    net_3_2_api = @ptrCast(@TypeOf(net_3_2_api), net_api.*.next);
                }
            },
            else => {},
        }
    }

    var binding_funcs = std.mem.zeroInit(c.godot_instance_binding_functions, .{});
    binding_funcs.alloc_instance_binding_data = wrapper_create;
    binding_funcs.free_instance_binding_data = wrapper_destroy;

    language_index = nativescript_1_1_api.*.godot_nativescript_register_instance_binding_data_functions.?(binding_funcs);

    //GenTypes.registerTypes(); // TODO: Register Godot generated class types
    GenBindings.initBindings(); // Init Godot generated class bindings
}

pub fn gdnative_terminate(p_options: [*c]c.godot_gdnative_terminate_options) void {
    _ = p_options;
}

pub fn nativescript_init(p_handle: ?*anyopaque) void {
    nativescript_handle = p_handle;
}

pub fn nativescript_terminate(p_handle: ?*anyopaque) void {
    _ = p_handle;
    nativescript_1_1_api.*.godot_nativescript_unregister_instance_binding_data_functions.?(language_index);
}


fn wrapper_create(data: ?*anyopaque, type_tag: ?*const anyopaque, instance: ?*c.godot_object) callconv(.C) ?*anyopaque {
    _ = data;

    const wrapper_data = api.*.godot_alloc.?(@sizeOf(Wrapped));
    var wrapper = @ptrCast(?*Wrapped, @alignCast(@alignOf(?*Wrapped), wrapper_data));
    if (wrapper == null) {
        return null;
    }

    wrapper.?.owner = instance;
    wrapper.?.type_tag = @ptrToInt(type_tag);

    return @ptrCast(?*anyopaque, wrapper);
}

fn wrapper_destroy(data: ?*anyopaque, wrapper: ?*anyopaque) callconv(.C) void {
    _ = data;
    
    if (wrapper != null) {
        api.*.godot_free.?(wrapper);
    }
}
