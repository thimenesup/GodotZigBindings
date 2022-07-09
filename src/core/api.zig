pub const c = @cImport({
    @cInclude("gdnative_api_struct.gen.h");
});

pub var api: [*c]const c.godot_gdnative_core_api_struct = null;
pub var api_1_1: [*c]const c.godot_gdnative_core_1_1_api_struct = null;
pub var api_1_2: [*c]const c.godot_gdnative_core_1_2_api_struct = null;
pub var nativescript_api: [*c]const c.godot_gdnative_ext_nativescript_api_struct = null;

pub fn gdnative_init(p_options: [*c]c.godot_gdnative_init_options) void {
    api = p_options.*.api_struct;

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
            },
            else => {},
        }
    }
}

pub fn gdnative_terminate(p_options: [*c]c.godot_gdnative_terminate_options) void {
    _ = p_options;

    api = null;
    api_1_1 = null;
    api_1_2 = null;
    nativescript_api = null;
}
