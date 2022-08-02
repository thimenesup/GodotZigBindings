// NOTE: This has to be manually modified to make sure it matches the C GDNative Headers API version in use in case of any compatibility breaking changes etc
// godot-headers version 3.2

const gd = @import("gdnative_api.zig"); // godot_gdnative_init_options needs to know the definition of core_api_struct

// Basic core types

pub const godot_error = c_int;
pub const godot_variant_type = c_int;
pub const godot_vector3_axis = c_int;

pub const godot_bool = bool;
pub const godot_int = c_int;
pub const godot_real = f32;
pub const godot_object = anyopaque;
pub const godot_char_type = c_ushort;

pub const godot_pool_byte_array_read_access = godot_pool_array_read_access;
pub const godot_pool_int_array_read_access = godot_pool_array_read_access;
pub const godot_pool_real_array_read_access = godot_pool_array_read_access;
pub const godot_pool_string_array_read_access = godot_pool_array_read_access;
pub const godot_pool_vector2_array_read_access = godot_pool_array_read_access;
pub const godot_pool_vector3_array_read_access = godot_pool_array_read_access;
pub const godot_pool_color_array_read_access = godot_pool_array_read_access;

pub const godot_pool_byte_array_write_access = godot_pool_array_write_access;
pub const godot_pool_int_array_write_access = godot_pool_array_write_access;
pub const godot_pool_real_array_write_access = godot_pool_array_write_access;
pub const godot_pool_string_array_write_access = godot_pool_array_write_access;
pub const godot_pool_vector2_array_write_access = godot_pool_array_write_access;
pub const godot_pool_vector3_array_write_access = godot_pool_array_write_access;
pub const godot_pool_color_array_write_access = godot_pool_array_write_access;

pub const godot_pool_array_read_access = extern struct {
    _dont_touch_that: [1]u8,
};

pub const godot_pool_array_write_access = extern struct {
    _dont_touch_that: [1]u8,
};

pub const godot_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_pool_byte_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_pool_int_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_pool_real_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_pool_string_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_pool_vector2_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_pool_vector3_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_pool_color_array = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_string = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_char_string = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_string_name = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_dictionary = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_node_path = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_rid = extern struct {
    _dont_touch_that: [@sizeOf(?*anyopaque)]u8,
};

pub const godot_variant = extern struct {
    _dont_touch_that: [24]u8,
};

pub const godot_color = extern struct {
    _dont_touch_that: [16]u8,
};

pub const godot_vector2 = extern struct {
    _dont_touch_that: [8]u8,
};

pub const godot_vector3 = extern struct {
    _dont_touch_that: [12]u8,
};

pub const godot_basis = extern struct {
    _dont_touch_that: [36]u8,
};

pub const godot_quat = extern struct {
    _dont_touch_that: [16]u8,
};

pub const godot_aabb = extern struct {
    _dont_touch_that: [24]u8,
};

pub const godot_plane = extern struct {
    _dont_touch_that: [16]u8,
};

pub const godot_rect2 = extern struct {
    _dont_touch_that: [16]u8,
};

pub const godot_transform = extern struct {
    _dont_touch_that: [48]u8,
};

pub const godot_transform2d = extern struct {
    _dont_touch_that: [24]u8,
};

pub const godot_method_bind = extern struct {
    _dont_touch_that: [1]u8,
};

pub const godot_variant_operator = c_int;
pub const godot_variant_call_error_error = c_int;

pub const godot_variant_call_error = extern struct {
    @"error": godot_variant_call_error_error,
    argument: c_int,
    expected: godot_variant_type,
};

// API types

pub const GDNATIVE_CORE: c_int = 0;
pub const GDNATIVE_EXT_NATIVESCRIPT: c_int = 1;
pub const GDNATIVE_EXT_PLUGINSCRIPT: c_int = 2;
pub const GDNATIVE_EXT_ANDROID: c_int = 3;
pub const GDNATIVE_EXT_ARVR: c_int = 4;
pub const GDNATIVE_EXT_VIDEODECODER: c_int = 5;
pub const GDNATIVE_EXT_NET: c_int = 6;

pub const godot_class_constructor = ?fn (...) callconv(.C) ?*godot_object;
pub const native_call_cb = ?fn (?*anyopaque, [*c]godot_array) callconv(.C) godot_variant;

pub const godot_gdnative_init_options = extern struct {
    in_editor: godot_bool,
    core_api_hash: u64,
    editor_api_hash: u64,
    no_api_hash: u64,
    report_version_mismatch: ?fn (?*const godot_object, [*c]const u8, godot_gdnative_api_version, godot_gdnative_api_version) callconv(.C) void,
    report_loading_error: ?fn (?*const godot_object, [*c]const u8) callconv(.C) void,
    gd_native_library: ?*godot_object,
    api_struct: [*c]const gd.godot_gdnative_core_api_struct,
    active_library_path: [*c]const godot_string,
};

pub const godot_gdnative_terminate_options = extern struct {
    in_editor: godot_bool,
};

pub const godot_gdnative_api_version = extern struct {
    major: c_uint,
    minor: c_uint,
};

pub const godot_gdnative_api_struct = extern struct {
    type: c_uint,
    version: godot_gdnative_api_version,
    next: [*c]const godot_gdnative_api_struct,
};

// Nativescript

pub const godot_method_rpc_mode = c_int;
pub const GODOT_METHOD_RPC_MODE_DISABLED: c_int = 0;
pub const GODOT_METHOD_RPC_MODE_REMOTE: c_int = 1;
pub const GODOT_METHOD_RPC_MODE_MASTER: c_int = 2;
pub const GODOT_METHOD_RPC_MODE_PUPPET: c_int = 3;
pub const GODOT_METHOD_RPC_MODE_SLAVE: c_int = 3;
pub const GODOT_METHOD_RPC_MODE_REMOTESYNC: c_int = 4;
pub const GODOT_METHOD_RPC_MODE_SYNC: c_int = 4;
pub const GODOT_METHOD_RPC_MODE_MASTERSYNC: c_int = 5;
pub const GODOT_METHOD_RPC_MODE_PUPPETSYNC: c_int = 6;

pub const godot_property_hint = c_int;
pub const GODOT_PROPERTY_HINT_NONE: c_int = 0;
pub const GODOT_PROPERTY_HINT_RANGE: c_int = 1;
pub const GODOT_PROPERTY_HINT_EXP_RANGE: c_int = 2;
pub const GODOT_PROPERTY_HINT_ENUM: c_int = 3;
pub const GODOT_PROPERTY_HINT_EXP_EASING: c_int = 4;
pub const GODOT_PROPERTY_HINT_LENGTH: c_int = 5;
pub const GODOT_PROPERTY_HINT_SPRITE_FRAME: c_int = 6;
pub const GODOT_PROPERTY_HINT_KEY_ACCEL: c_int = 7;
pub const GODOT_PROPERTY_HINT_FLAGS: c_int = 8;
pub const GODOT_PROPERTY_HINT_LAYERS_2D_RENDER: c_int = 9;
pub const GODOT_PROPERTY_HINT_LAYERS_2D_PHYSICS: c_int = 10;
pub const GODOT_PROPERTY_HINT_LAYERS_3D_RENDER: c_int = 11;
pub const GODOT_PROPERTY_HINT_LAYERS_3D_PHYSICS: c_int = 12;
pub const GODOT_PROPERTY_HINT_FILE: c_int = 13;
pub const GODOT_PROPERTY_HINT_DIR: c_int = 14;
pub const GODOT_PROPERTY_HINT_GLOBAL_FILE: c_int = 15;
pub const GODOT_PROPERTY_HINT_GLOBAL_DIR: c_int = 16;
pub const GODOT_PROPERTY_HINT_RESOURCE_TYPE: c_int = 17;
pub const GODOT_PROPERTY_HINT_MULTILINE_TEXT: c_int = 18;
pub const GODOT_PROPERTY_HINT_PLACEHOLDER_TEXT: c_int = 19;
pub const GODOT_PROPERTY_HINT_COLOR_NO_ALPHA: c_int = 20;
pub const GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSY: c_int = 21;
pub const GODOT_PROPERTY_HINT_IMAGE_COMPRESS_LOSSLESS: c_int = 22;
pub const GODOT_PROPERTY_HINT_OBJECT_ID: c_int = 23;
pub const GODOT_PROPERTY_HINT_TYPE_STRING: c_int = 24;
pub const GODOT_PROPERTY_HINT_NODE_PATH_TO_EDITED_NODE: c_int = 25;
pub const GODOT_PROPERTY_HINT_METHOD_OF_VARIANT_TYPE: c_int = 26;
pub const GODOT_PROPERTY_HINT_METHOD_OF_BASE_TYPE: c_int = 27;
pub const GODOT_PROPERTY_HINT_METHOD_OF_INSTANCE: c_int = 28;
pub const GODOT_PROPERTY_HINT_METHOD_OF_SCRIPT: c_int = 29;
pub const GODOT_PROPERTY_HINT_PROPERTY_OF_VARIANT_TYPE: c_int = 30;
pub const GODOT_PROPERTY_HINT_PROPERTY_OF_BASE_TYPE: c_int = 31;
pub const GODOT_PROPERTY_HINT_PROPERTY_OF_INSTANCE: c_int = 32;
pub const GODOT_PROPERTY_HINT_PROPERTY_OF_SCRIPT: c_int = 33;
pub const GODOT_PROPERTY_HINT_MAX: c_int = 34;

pub const godot_property_usage_flags = c_int;
pub const GODOT_PROPERTY_USAGE_STORAGE: c_int = 1;
pub const GODOT_PROPERTY_USAGE_EDITOR: c_int = 2;
pub const GODOT_PROPERTY_USAGE_NETWORK: c_int = 4;
pub const GODOT_PROPERTY_USAGE_EDITOR_HELPER: c_int = 8;
pub const GODOT_PROPERTY_USAGE_CHECKABLE: c_int = 16;
pub const GODOT_PROPERTY_USAGE_CHECKED: c_int = 32;
pub const GODOT_PROPERTY_USAGE_INTERNATIONALIZED: c_int = 64;
pub const GODOT_PROPERTY_USAGE_GROUP: c_int = 128;
pub const GODOT_PROPERTY_USAGE_CATEGORY: c_int = 256;
pub const GODOT_PROPERTY_USAGE_STORE_IF_NONZERO: c_int = 512;
pub const GODOT_PROPERTY_USAGE_STORE_IF_NONONE: c_int = 1024;
pub const GODOT_PROPERTY_USAGE_NO_INSTANCE_STATE: c_int = 2048;
pub const GODOT_PROPERTY_USAGE_RESTART_IF_CHANGED: c_int = 4096;
pub const GODOT_PROPERTY_USAGE_SCRIPT_VARIABLE: c_int = 8192;
pub const GODOT_PROPERTY_USAGE_STORE_IF_NULL: c_int = 16384;
pub const GODOT_PROPERTY_USAGE_ANIMATE_AS_TRIGGER: c_int = 32768;
pub const GODOT_PROPERTY_USAGE_UPDATE_ALL_IF_MODIFIED: c_int = 65536;
pub const GODOT_PROPERTY_USAGE_DEFAULT: c_int = 7;
pub const GODOT_PROPERTY_USAGE_DEFAULT_INTL: c_int = 71;
pub const GODOT_PROPERTY_USAGE_NOEDITOR: c_int = 5;

pub const godot_property_attributes = extern struct {
    rset_type: godot_method_rpc_mode,
    type: godot_int,
    hint: godot_property_hint,
    hint_string: godot_string,
    usage: godot_property_usage_flags,
    default_value: godot_variant,
};

pub const godot_instance_create_func = extern struct {
    create_func: ?fn (?*godot_object, ?*anyopaque) callconv(.C) ?*anyopaque,
    method_data: ?*anyopaque,
    free_func: ?fn (?*anyopaque) callconv(.C) void,
};

pub const godot_instance_destroy_func = extern struct {
    destroy_func: ?fn (?*godot_object, ?*anyopaque, ?*anyopaque) callconv(.C) void,
    method_data: ?*anyopaque,
    free_func: ?fn (?*anyopaque) callconv(.C) void,
};

pub const godot_method_attributes = extern struct {
    rpc_type: godot_method_rpc_mode,
};

pub const godot_instance_method = extern struct {
    method: ?fn (?*godot_object, ?*anyopaque, ?*anyopaque, c_int, [*c][*c]godot_variant) callconv(.C) godot_variant,
    method_data: ?*anyopaque,
    free_func: ?fn (?*anyopaque) callconv(.C) void,
};

pub const godot_property_set_func = extern struct {
    set_func: ?fn (?*godot_object, ?*anyopaque, ?*anyopaque, [*c]godot_variant) callconv(.C) void,
    method_data: ?*anyopaque,
    free_func: ?fn (?*anyopaque) callconv(.C) void,
};

pub const godot_property_get_func = extern struct {
    get_func: ?fn (?*godot_object, ?*anyopaque, ?*anyopaque) callconv(.C) godot_variant,
    method_data: ?*anyopaque,
    free_func: ?fn (?*anyopaque) callconv(.C) void,
};

pub const godot_signal_argument = extern struct {
    name: godot_string,
    type: godot_int,
    hint: godot_property_hint,
    hint_string: godot_string,
    usage: godot_property_usage_flags,
    default_value: godot_variant,
};

pub const godot_signal = extern struct {
    name: godot_string,
    num_args: c_int,
    args: [*c]godot_signal_argument,
    num_default_args: c_int,
    default_args: [*c]godot_variant,
};

pub const godot_method_arg = extern struct {
    name: godot_string,
    type: godot_variant_type,
    hint: godot_property_hint,
    hint_string: godot_string,
};

pub const godot_instance_binding_functions = extern struct {
    alloc_instance_binding_data: ?fn (?*anyopaque, ?*const anyopaque, ?*godot_object) callconv(.C) ?*anyopaque,
    free_instance_binding_data: ?fn (?*anyopaque, ?*anyopaque) callconv(.C) void,
    refcount_incremented_instance_binding: ?fn (?*anyopaque, ?*godot_object) callconv(.C) void,
    refcount_decremented_instance_binding: ?fn (?*anyopaque, ?*godot_object) callconv(.C) bool,
    data: ?*anyopaque,
    free_func: ?fn (?*anyopaque) callconv(.C) void,
};

// ARVR

pub const godot_arvr_interface_gdnative = extern struct {
    version: godot_gdnative_api_version,
    constructor: ?fn (?*godot_object) callconv(.C) ?*anyopaque,
    destructor: ?fn (?*anyopaque) callconv(.C) void,
    get_name: ?fn (?*const anyopaque) callconv(.C) godot_string,
    get_capabilities: ?fn (?*const anyopaque) callconv(.C) godot_int,
    get_anchor_detection_is_enabled: ?fn (?*const anyopaque) callconv(.C) godot_bool,
    set_anchor_detection_is_enabled: ?fn (?*anyopaque, godot_bool) callconv(.C) void,
    is_stereo: ?fn (?*const anyopaque) callconv(.C) godot_bool,
    is_initialized: ?fn (?*const anyopaque) callconv(.C) godot_bool,
    initialize: ?fn (?*anyopaque) callconv(.C) godot_bool,
    uninitialize: ?fn (?*anyopaque) callconv(.C) void,
    get_render_targetsize: ?fn (?*const anyopaque) callconv(.C) godot_vector2,
    get_transform_for_eye: ?fn (?*anyopaque, godot_int, [*c]godot_transform) callconv(.C) godot_transform,
    fill_projection_for_eye: ?fn (?*anyopaque, [*c]godot_real, godot_int, godot_real, godot_real, godot_real) callconv(.C) void,
    commit_for_eye: ?fn (?*anyopaque, godot_int, [*c]godot_rid, [*c]godot_rect2) callconv(.C) void,
    process: ?fn (?*anyopaque) callconv(.C) void,
    get_external_texture_for_eye: ?fn (?*anyopaque, godot_int) callconv(.C) godot_int,
    notification: ?fn (?*anyopaque, godot_int) callconv(.C) void,
    get_camera_feed_id: ?fn (?*anyopaque) callconv(.C) godot_int,
};

// Net

pub const godot_net_stream_peer = extern struct {
    version: godot_gdnative_api_version,
    data: ?*godot_object,
    get_data: ?fn (?*anyopaque, [*c]u8, c_int) callconv(.C) godot_error,
    get_partial_data: ?fn (?*anyopaque, [*c]u8, c_int, [*c]c_int) callconv(.C) godot_error,
    put_data: ?fn (?*anyopaque, [*c]const u8, c_int) callconv(.C) godot_error,
    put_partial_data: ?fn (?*anyopaque, [*c]const u8, c_int, [*c]c_int) callconv(.C) godot_error,
    get_available_bytes: ?fn (?*const anyopaque) callconv(.C) c_int,
    next: ?*anyopaque,
};

pub const godot_net_packet_peer = extern struct {
    version: godot_gdnative_api_version,
    data: ?*godot_object,
    get_packet: ?fn (?*anyopaque, [*c][*c]const u8, [*c]c_int) callconv(.C) godot_error,
    put_packet: ?fn (?*anyopaque, [*c]const u8, c_int) callconv(.C) godot_error,
    get_available_packet_count: ?fn (?*const anyopaque) callconv(.C) godot_int,
    get_max_packet_size: ?fn (?*const anyopaque) callconv(.C) godot_int,
    next: ?*anyopaque,
};

pub const godot_net_multiplayer_peer = extern struct {
    version: godot_gdnative_api_version,
    data: ?*godot_object,
    get_packet: ?fn (?*anyopaque, [*c][*c]const u8, [*c]c_int) callconv(.C) godot_error,
    put_packet: ?fn (?*anyopaque, [*c]const u8, c_int) callconv(.C) godot_error,
    get_available_packet_count: ?fn (?*const anyopaque) callconv(.C) godot_int,
    get_max_packet_size: ?fn (?*const anyopaque) callconv(.C) godot_int,
    set_transfer_mode: ?fn (?*anyopaque, godot_int) callconv(.C) void,
    get_transfer_mode: ?fn (?*const anyopaque) callconv(.C) godot_int,
    set_target_peer: ?fn (?*anyopaque, godot_int) callconv(.C) void,
    get_packet_peer: ?fn (?*const anyopaque) callconv(.C) godot_int,
    is_server: ?fn (?*const anyopaque) callconv(.C) godot_bool,
    poll: ?fn (?*anyopaque) callconv(.C) void,
    get_unique_id: ?fn (?*const anyopaque) callconv(.C) i32,
    set_refuse_new_connections: ?fn (?*anyopaque, godot_bool) callconv(.C) void,
    is_refusing_new_connections: ?fn (?*const anyopaque) callconv(.C) godot_bool,
    get_connection_status: ?fn (?*const anyopaque) callconv(.C) godot_int,
    next: ?*anyopaque,
};

pub const godot_net_webrtc_library = extern struct {
    version: godot_gdnative_api_version,
    unregistered: ?fn (...) callconv(.C) void,
    create_peer_connection: ?fn (?*godot_object) callconv(.C) godot_error,
    next: ?*anyopaque,
};

pub const godot_net_webrtc_peer_connection = extern struct {
    version: godot_gdnative_api_version,
    data: ?*godot_object,
    get_connection_state: ?fn (?*const anyopaque) callconv(.C) godot_int,
    initialize: ?fn (?*anyopaque, [*c]const godot_dictionary) callconv(.C) godot_error,
    create_data_channel: ?fn (?*anyopaque, [*c]const u8, [*c]const godot_dictionary) callconv(.C) ?*godot_object,
    create_offer: ?fn (?*anyopaque) callconv(.C) godot_error,
    create_answer: ?fn (?*anyopaque) callconv(.C) godot_error,
    set_remote_description: ?fn (?*anyopaque, [*c]const u8, [*c]const u8) callconv(.C) godot_error,
    set_local_description: ?fn (?*anyopaque, [*c]const u8, [*c]const u8) callconv(.C) godot_error,
    add_ice_candidate: ?fn (?*anyopaque, [*c]const u8, c_int, [*c]const u8) callconv(.C) godot_error,
    poll: ?fn (?*anyopaque) callconv(.C) godot_error,
    close: ?fn (?*anyopaque) callconv(.C) void,
    next: ?*anyopaque,
};

pub const godot_net_webrtc_data_channel = extern struct {
    version: godot_gdnative_api_version,
    data: ?*godot_object,
    get_packet: ?fn (?*anyopaque, [*c][*c]const u8, [*c]c_int) callconv(.C) godot_error,
    put_packet: ?fn (?*anyopaque, [*c]const u8, c_int) callconv(.C) godot_error,
    get_available_packet_count: ?fn (?*const anyopaque) callconv(.C) godot_int,
    get_max_packet_size: ?fn (?*const anyopaque) callconv(.C) godot_int,
    set_write_mode: ?fn (?*anyopaque, godot_int) callconv(.C) void,
    get_write_mode: ?fn (?*const anyopaque) callconv(.C) godot_int,
    was_string_packet: ?fn (?*const anyopaque) callconv(.C) bool,
    get_ready_state: ?fn (?*const anyopaque) callconv(.C) godot_int,
    get_label: ?fn (?*const anyopaque) callconv(.C) [*c]const u8,
    is_ordered: ?fn (?*const anyopaque) callconv(.C) bool,
    get_id: ?fn (?*const anyopaque) callconv(.C) c_int,
    get_max_packet_life_time: ?fn (?*const anyopaque) callconv(.C) c_int,
    get_max_retransmits: ?fn (?*const anyopaque) callconv(.C) c_int,
    get_protocol: ?fn (?*const anyopaque) callconv(.C) [*c]const u8,
    is_negotiated: ?fn (?*const anyopaque) callconv(.C) bool,
    poll: ?fn (?*anyopaque) callconv(.C) godot_error,
    close: ?fn (?*anyopaque) callconv(.C) void,
    next: ?*anyopaque,
};

// Pluginscript

pub const godot_pluginscript_instance_data = anyopaque;
pub const godot_pluginscript_script_data = anyopaque;
pub const godot_pluginscript_language_data = anyopaque;

pub const godot_pluginscript_instance_desc = extern struct {
    init: ?fn (?*godot_pluginscript_script_data, ?*godot_object) callconv(.C) ?*godot_pluginscript_instance_data,
    finish: ?fn (?*godot_pluginscript_instance_data) callconv(.C) void,
    set_prop: ?fn (?*godot_pluginscript_instance_data, [*c]const godot_string, [*c]const godot_variant) callconv(.C) godot_bool,
    get_prop: ?fn (?*godot_pluginscript_instance_data, [*c]const godot_string, [*c]godot_variant) callconv(.C) godot_bool,
    call_method: ?fn (?*godot_pluginscript_instance_data, [*c]const godot_string_name, [*c][*c]const godot_variant, c_int, [*c]godot_variant_call_error) callconv(.C) godot_variant,
    notification: ?fn (?*godot_pluginscript_instance_data, c_int) callconv(.C) void,
    get_rpc_mode: ?fn (?*godot_pluginscript_instance_data, [*c]const godot_string) callconv(.C) godot_method_rpc_mode,
    get_rset_mode: ?fn (?*godot_pluginscript_instance_data, [*c]const godot_string) callconv(.C) godot_method_rpc_mode,
    refcount_incremented: ?fn (?*godot_pluginscript_instance_data) callconv(.C) void,
    refcount_decremented: ?fn (?*godot_pluginscript_instance_data) callconv(.C) bool,
};

pub const godot_pluginscript_script_manifest = extern struct {
    data: ?*godot_pluginscript_script_data,
    name: godot_string_name,
    is_tool: godot_bool,
    base: godot_string_name,
    member_lines: godot_dictionary,
    methods: godot_array,
    signals: godot_array,
    properties: godot_array,
};

pub const godot_pluginscript_script_desc = extern struct {
    init: ?fn (?*godot_pluginscript_language_data, [*c]const godot_string, [*c]const godot_string, [*c]godot_error) callconv(.C) godot_pluginscript_script_manifest,
    finish: ?fn (?*godot_pluginscript_script_data) callconv(.C) void,
    instance_desc: godot_pluginscript_instance_desc,
};

pub const godot_pluginscript_profiling_data = extern struct {
    signature: godot_string_name,
    call_count: godot_int,
    total_time: godot_int,
    self_time: godot_int,
};

pub const godot_pluginscript_language_desc = extern struct {
    name: [*c]const u8,
    type: [*c]const u8,
    extension: [*c]const u8,
    recognized_extensions: [*c][*c]const u8,
    init: ?fn (...) callconv(.C) ?*godot_pluginscript_language_data,
    finish: ?fn (?*godot_pluginscript_language_data) callconv(.C) void,
    reserved_words: [*c][*c]const u8,
    comment_delimiters: [*c][*c]const u8,
    string_delimiters: [*c][*c]const u8,
    has_named_classes: godot_bool,
    supports_builtin_mode: godot_bool,
    get_template_source_code: ?fn (?*godot_pluginscript_language_data, [*c]const godot_string, [*c]const godot_string) callconv(.C) godot_string,
    validate: ?fn (?*godot_pluginscript_language_data, [*c]const godot_string, [*c]c_int, [*c]c_int, [*c]godot_string, [*c]const godot_string, [*c]godot_pool_string_array) callconv(.C) godot_bool,
    find_function: ?fn (?*godot_pluginscript_language_data, [*c]const godot_string, [*c]const godot_string) callconv(.C) c_int,
    make_function: ?fn (?*godot_pluginscript_language_data, [*c]const godot_string, [*c]const godot_string, [*c]const godot_pool_string_array) callconv(.C) godot_string,
    complete_code: ?fn (?*godot_pluginscript_language_data, [*c]const godot_string, [*c]const godot_string, ?*godot_object, [*c]godot_array, [*c]godot_bool, [*c]godot_string) callconv(.C) godot_error,
    auto_indent_code: ?fn (?*godot_pluginscript_language_data, [*c]godot_string, c_int, c_int) callconv(.C) void,
    add_global_constant: ?fn (?*godot_pluginscript_language_data, [*c]const godot_string, [*c]const godot_variant) callconv(.C) void,
    debug_get_error: ?fn (?*godot_pluginscript_language_data) callconv(.C) godot_string,
    debug_get_stack_level_count: ?fn (?*godot_pluginscript_language_data) callconv(.C) c_int,
    debug_get_stack_level_line: ?fn (?*godot_pluginscript_language_data, c_int) callconv(.C) c_int,
    debug_get_stack_level_function: ?fn (?*godot_pluginscript_language_data, c_int) callconv(.C) godot_string,
    debug_get_stack_level_source: ?fn (?*godot_pluginscript_language_data, c_int) callconv(.C) godot_string,
    debug_get_stack_level_locals: ?fn (?*godot_pluginscript_language_data, c_int, [*c]godot_pool_string_array, [*c]godot_array, c_int, c_int) callconv(.C) void,
    debug_get_stack_level_members: ?fn (?*godot_pluginscript_language_data, c_int, [*c]godot_pool_string_array, [*c]godot_array, c_int, c_int) callconv(.C) void,
    debug_get_globals: ?fn (?*godot_pluginscript_language_data, [*c]godot_pool_string_array, [*c]godot_array, c_int, c_int) callconv(.C) void,
    debug_parse_stack_level_expression: ?fn (?*godot_pluginscript_language_data, c_int, [*c]const godot_string, c_int, c_int) callconv(.C) godot_string,
    get_public_functions: ?fn (?*godot_pluginscript_language_data, [*c]godot_array) callconv(.C) void,
    get_public_constants: ?fn (?*godot_pluginscript_language_data, [*c]godot_dictionary) callconv(.C) void,
    profiling_start: ?fn (?*godot_pluginscript_language_data) callconv(.C) void,
    profiling_stop: ?fn (?*godot_pluginscript_language_data) callconv(.C) void,
    profiling_get_accumulated_data: ?fn (?*godot_pluginscript_language_data, [*c]godot_pluginscript_profiling_data, c_int) callconv(.C) c_int,
    profiling_get_frame_data: ?fn (?*godot_pluginscript_language_data, [*c]godot_pluginscript_profiling_data, c_int) callconv(.C) c_int,
    profiling_frame: ?fn (?*godot_pluginscript_language_data) callconv(.C) void,
    script_desc: godot_pluginscript_script_desc,
};

// Videodecoder

pub const godot_videodecoder_interface_gdnative = extern struct {
    version: godot_gdnative_api_version,
    next: ?*anyopaque,
    constructor: ?fn (?*godot_object) callconv(.C) ?*anyopaque,
    destructor: ?fn (?*anyopaque) callconv(.C) void,
    get_plugin_name: ?fn () callconv(.C) [*c]const u8,
    get_supported_extensions: ?fn ([*c]c_int) callconv(.C) [*c][*c]const u8,
    open_file: ?fn (?*anyopaque, ?*anyopaque) callconv(.C) godot_bool,
    get_length: ?fn (?*const anyopaque) callconv(.C) godot_real,
    get_playback_position: ?fn (?*const anyopaque) callconv(.C) godot_real,
    seek: ?fn (?*anyopaque, godot_real) callconv(.C) void,
    set_audio_track: ?fn (?*anyopaque, godot_int) callconv(.C) void,
    update: ?fn (?*anyopaque, godot_real) callconv(.C) void,
    get_videoframe: ?fn (?*anyopaque) callconv(.C) [*c]godot_pool_byte_array,
    get_audioframe: ?fn (?*anyopaque, [*c]f32, c_int) callconv(.C) godot_int,
    get_channels: ?fn (?*const anyopaque) callconv(.C) godot_int,
    get_mix_rate: ?fn (?*const anyopaque) callconv(.C) godot_int,
    get_texture_size: ?fn (?*const anyopaque) callconv(.C) godot_vector2,
};

// Android Java

pub const JNIEnv = ?*anyopaque;
pub const jobject = ?*anyopaque;
