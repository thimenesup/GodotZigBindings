const gd = @import("gdnative_types.zig");
const api = @import("api.zig");

const Array = @import("array.zig").Array;

pub const PoolByteArray = struct {

    godot_array: gd.godot_pool_byte_array,

    pub const Read = struct {

        read_access: gd.godot_pool_byte_array_read_access,

        const ReadSelf = @This();

        pub inline fn deinit(self: *ReadSelf) void {
            api.core.godot_pool_byte_array_read_access_destroy.?(&self.read_access);
        }

        pub inline fn init(array: *const PoolByteArray) ReadSelf {
            var self = ReadSelf {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_byte_array_read.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Read) ReadSelf {
            var self = Self {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_byte_array_read_access_copy.?(&other.read_access);

            return self;
        }

        pub inline fn ptr(self: *const ReadSelf) [*]const u8 {
            return api.core.godot_pool_byte_array_read_access_ptr.?(&self.read_access);
        }

    };

    pub const Write = struct {

        write_access: gd.godot_pool_byte_array_write_access,

        const WriteSelf = @This();

        pub inline fn deinit(self: *WriteSelf) void {
            api.core.godot_pool_byte_array_write_access_destroy.?(&self.write_access);
        }

        pub inline fn init(array: *const PoolByteArray) WriteSelf {
            var self = WriteSelf {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_byte_array_write.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Write) WriteSelf {
            var self = Self {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_byte_array_write_access_copy.?(&other.write_access);

            return self;
        }

        pub inline fn ptr(self: *const WriteSelf) [*]u8 {
            return api.core.godot_pool_byte_array_write_access_ptr.?(&self.write_access);
        }
    };

    const Self = @This();

    pub fn deinit(self: *Self) void {
        api.core.godot_pool_byte_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_byte_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotPoolByteArray(godot_array: gd.godot_pool_byte_array) Self {
        const self = Self {
            .godot_array = godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const PoolByteArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_byte_array_new_copy.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn initArray(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_byte_array_new_with_array.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn read(self: *const Self) Read { // Make sure you call .deinit() on returned struct
        return Read.init(self);
    }

    pub fn write(self: *const Self) Write { // Make sure you call .deinit() on returned struct
        return Write.init(self);
    }

    pub fn append(self: *Self, data: u8) void {
        api.core.godot_pool_byte_array_append.?(&self.godot_array, data);
    }

    pub fn appendArray(self: *Self, array: *const PoolByteArray) void {
        api.core.godot_pool_byte_array_append_array.?(&self.godot_array, &array.godot_array);
    }

    pub fn insert(self: *Self, index: i32, data: u8) i32 {
        return api.core.godot_pool_byte_array_insert.?(&self.godot_array, index, data);
    }

    pub fn invert(self: *Self) void {
        api.core.godot_pool_byte_array_invert.?(&self.godot_array);
    }

    pub fn pushBack(self: *Self, data: u8) void {
        api.core.godot_pool_byte_array_push_back.?(&self.godot_array, data);
    }

    pub fn remove(self: *Self, index: i32) void {
        return api.core.godot_pool_byte_array_remove.?(&self.godot_array, index);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        return api.core.godot_pool_byte_array_resize.?(&self.godot_array, p_size);
    }

    pub fn set(self: *Self, index: i32, data: u8) void {
        api.core.godot_pool_byte_array_set.?(&self.godot_array, index, data);
    }

    pub fn get(self: *const Self, index: i32) u8 {
        return api.core.godot_pool_byte_array_get.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return api.core.godot_pool_byte_array_get.?(&self.godot_array);
    }

};

pub const PoolIntArray = struct {

    godot_array: gd.godot_pool_int_array,

    pub const Read = struct {

        read_access: gd.godot_pool_int_array_read_access,

        const ReadSelf = @This();

        pub inline fn deinit(self: *ReadSelf) void {
            api.core.godot_pool_int_array_read_access_destroy.?(&self.read_access);
        }

        pub inline fn init(array: *const PoolIntArray) ReadSelf {
            var self = ReadSelf {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_int_array_read.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Read) ReadSelf {
            var self = Self {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_int_array_read_access_copy.?(&other.read_access);

            return self;
        }

        pub inline fn ptr(self: *const ReadSelf) [*]const u8 {
            return api.core.godot_pool_int_array_read_access_ptr.?(&self.read_access);
        }

    };

    pub const Write = struct {

        write_access: gd.godot_pool_int_array_write_access,

        const WriteSelf = @This();

        pub inline fn deinit(self: *WriteSelf) void {
            api.core.godot_pool_int_array_write_access_destroy.?(&self.write_access);
        }

        pub inline fn init(array: *const PoolIntArray) WriteSelf {
            var self = WriteSelf {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_int_array_write.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Write) WriteSelf {
            var self = Self {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_int_array_write_access_copy.?(&other.write_access);

            return self;
        }

        pub inline fn ptr(self: *const WriteSelf) [*]u8 {
            return api.core.godot_pool_int_array_write_access_ptr.?(&self.write_access);
        }
    };

    const Self = @This();

    pub fn deinit(self: *Self) void {
        api.core.godot_pool_int_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_int_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotPoolIntArray(godot_array: gd.godot_pool_int_array) Self {
        const self = Self {
            .godot_array = godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const PoolIntArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_int_array_new_copy.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn initArray(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_int_array_new_with_array.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn read(self: *const Self) Read { // Make sure you call .deinit() on returned struct
        return Read.init(self);
    }

    pub fn write(self: *const Self) Write { // Make sure you call .deinit() on returned struct
        return Write.init(self);
    }

    pub fn append(self: *Self, data: u8) void {
        api.core.godot_pool_int_array_append.?(&self.godot_array, data);
    }

    pub fn appendArray(self: *Self, array: *const PoolIntArray) void {
        api.core.godot_pool_int_array_append_array.?(&self.godot_array, &array.godot_array);
    }

    pub fn insert(self: *Self, index: i32, data: u8) i32 {
        return api.core.godot_pool_int_array_insert.?(&self.godot_array, index, data);
    }

    pub fn invert(self: *Self) void {
        api.core.godot_pool_int_array_invert.?(&self.godot_array);
    }

    pub fn pushBack(self: *Self, data: u8) void {
        api.core.godot_pool_int_array_push_back.?(&self.godot_array, data);
    }

    pub fn remove(self: *Self, index: i32) void {
        return api.core.godot_pool_int_array_remove.?(&self.godot_array, index);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        return api.core.godot_pool_int_array_resize.?(&self.godot_array, p_size);
    }

    pub fn set(self: *Self, index: i32, data: u8) void {
        api.core.godot_pool_int_array_set.?(&self.godot_array, index, data);
    }

    pub fn get(self: *const Self, index: i32) u8 {
        return api.core.godot_pool_int_array_get.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return api.core.godot_pool_int_array_get.?(&self.godot_array);
    }

};

pub const PoolRealArray = struct {

    godot_array: gd.godot_pool_real_array,

    pub const Read = struct {

        read_access: gd.godot_pool_real_array_read_access,

        const ReadSelf = @This();

        pub inline fn deinit(self: *ReadSelf) void {
            api.core.godot_pool_real_array_read_access_destroy.?(&self.read_access);
        }

        pub inline fn init(array: *const PoolRealArray) ReadSelf {
            var self = ReadSelf {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_real_array_read.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Read) ReadSelf {
            var self = Self {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_real_array_read_access_copy.?(&other.read_access);

            return self;
        }

        pub inline fn ptr(self: *const ReadSelf) [*]const u8 {
            return api.core.godot_pool_real_array_read_access_ptr.?(&self.read_access);
        }

    };

    pub const Write = struct {

        write_access: gd.godot_pool_real_array_write_access,

        const WriteSelf = @This();

        pub inline fn deinit(self: *WriteSelf) void {
            api.core.godot_pool_real_array_write_access_destroy.?(&self.write_access);
        }

        pub inline fn init(array: *const PoolRealArray) WriteSelf {
            var self = WriteSelf {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_real_array_write.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Write) WriteSelf {
            var self = Self {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_real_array_write_access_copy.?(&other.write_access);

            return self;
        }

        pub inline fn ptr(self: *const WriteSelf) [*]u8 {
            return api.core.godot_pool_real_array_write_access_ptr.?(&self.write_access);
        }
    };

    const Self = @This();

    pub fn deinit(self: *Self) void {
        api.core.godot_pool_real_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_real_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotPoolRealArray(godot_array: gd.godot_pool_real_array) Self {
        const self = Self {
            .godot_array = godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const PoolRealArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_real_array_new_copy.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn initArray(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_real_array_new_with_array.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn read(self: *const Self) Read { // Make sure you call .deinit() on returned struct
        return Read.init(self);
    }

    pub fn write(self: *const Self) Write { // Make sure you call .deinit() on returned struct
        return Write.init(self);
    }

    pub fn append(self: *Self, data: u8) void {
        api.core.godot_pool_real_array_append.?(&self.godot_array, data);
    }

    pub fn appendArray(self: *Self, array: *const PoolRealArray) void {
        api.core.godot_pool_real_array_append_array.?(&self.godot_array, &array.godot_array);
    }

    pub fn insert(self: *Self, index: i32, data: u8) i32 {
        return api.core.godot_pool_real_array_insert.?(&self.godot_array, index, data);
    }

    pub fn invert(self: *Self) void {
        api.core.godot_pool_real_array_invert.?(&self.godot_array);
    }

    pub fn pushBack(self: *Self, data: u8) void {
        api.core.godot_pool_real_array_push_back.?(&self.godot_array, data);
    }

    pub fn remove(self: *Self, index: i32) void {
        return api.core.godot_pool_real_array_remove.?(&self.godot_array, index);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        return api.core.godot_pool_real_array_resize.?(&self.godot_array, p_size);
    }

    pub fn set(self: *Self, index: i32, data: u8) void {
        api.core.godot_pool_real_array_set.?(&self.godot_array, index, data);
    }

    pub fn get(self: *const Self, index: i32) u8 {
        return api.core.godot_pool_real_array_get.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return api.core.godot_pool_real_array_get.?(&self.godot_array);
    }

};

pub const PoolStringArray = struct {

    godot_array: gd.godot_pool_string_array,

    pub const Read = struct {

        read_access: gd.godot_pool_string_array_read_access,

        const ReadSelf = @This();

        pub inline fn deinit(self: *ReadSelf) void {
            api.core.godot_pool_string_array_read_access_destroy.?(&self.read_access);
        }

        pub inline fn init(array: *const PoolStringArray) ReadSelf {
            var self = ReadSelf {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_string_array_read.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Read) ReadSelf {
            var self = Self {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_string_array_read_access_copy.?(&other.read_access);

            return self;
        }

        pub inline fn ptr(self: *const ReadSelf) [*]const u8 {
            return api.core.godot_pool_string_array_read_access_ptr.?(&self.read_access);
        }

    };

    pub const Write = struct {

        write_access: gd.godot_pool_string_array_write_access,

        const WriteSelf = @This();

        pub inline fn deinit(self: *WriteSelf) void {
            api.core.godot_pool_string_array_write_access_destroy.?(&self.write_access);
        }

        pub inline fn init(array: *const PoolStringArray) WriteSelf {
            var self = WriteSelf {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_string_array_write.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Write) WriteSelf {
            var self = Self {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_string_array_write_access_copy.?(&other.write_access);

            return self;
        }

        pub inline fn ptr(self: *const WriteSelf) [*]u8 {
            return api.core.godot_pool_string_array_write_access_ptr.?(&self.write_access);
        }
    };

    const Self = @This();

    pub fn deinit(self: *Self) void {
        api.core.godot_pool_string_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_string_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotPoolStringArray(godot_array: gd.godot_pool_string_array) Self {
        const self = Self {
            .godot_array = godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const PoolStringArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_string_array_new_copy.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn initArray(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_string_array_new_with_array.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn read(self: *const Self) Read { // Make sure you call .deinit() on returned struct
        return Read.init(self);
    }

    pub fn write(self: *const Self) Write { // Make sure you call .deinit() on returned struct
        return Write.init(self);
    }

    pub fn append(self: *Self, data: u8) void {
        api.core.godot_pool_string_array_append.?(&self.godot_array, data);
    }

    pub fn appendArray(self: *Self, array: *const PoolStringArray) void {
        api.core.godot_pool_string_array_append_array.?(&self.godot_array, &array.godot_array);
    }

    pub fn insert(self: *Self, index: i32, data: u8) i32 {
        return api.core.godot_pool_string_array_insert.?(&self.godot_array, index, data);
    }

    pub fn invert(self: *Self) void {
        api.core.godot_pool_string_array_invert.?(&self.godot_array);
    }

    pub fn pushBack(self: *Self, data: u8) void {
        api.core.godot_pool_string_array_push_back.?(&self.godot_array, data);
    }

    pub fn remove(self: *Self, index: i32) void {
        return api.core.godot_pool_string_array_remove.?(&self.godot_array, index);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        return api.core.godot_pool_string_array_resize.?(&self.godot_array, p_size);
    }

    pub fn set(self: *Self, index: i32, data: u8) void {
        api.core.godot_pool_string_array_set.?(&self.godot_array, index, data);
    }

    pub fn get(self: *const Self, index: i32) u8 {
        return api.core.godot_pool_string_array_get.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return api.core.godot_pool_string_array_get.?(&self.godot_array);
    }

};

pub const PoolVector2Array = struct {

    godot_array: gd.godot_pool_vector2_array,

    pub const Read = struct {

        read_access: gd.godot_pool_vector2_array_read_access,

        const ReadSelf = @This();

        pub inline fn deinit(self: *ReadSelf) void {
            api.core.godot_pool_vector2_array_read_access_destroy.?(&self.read_access);
        }

        pub inline fn init(array: *const PoolVector2Array) ReadSelf {
            var self = ReadSelf {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_vector2_array_read.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Read) ReadSelf {
            var self = Self {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_vector2_array_read_access_copy.?(&other.read_access);

            return self;
        }

        pub inline fn ptr(self: *const ReadSelf) [*]const u8 {
            return api.core.godot_pool_vector2_array_read_access_ptr.?(&self.read_access);
        }

    };

    pub const Write = struct {

        write_access: gd.godot_pool_vector2_array_write_access,

        const WriteSelf = @This();

        pub inline fn deinit(self: *WriteSelf) void {
            api.core.godot_pool_vector2_array_write_access_destroy.?(&self.write_access);
        }

        pub inline fn init(array: *const PoolVector2Array) WriteSelf {
            var self = WriteSelf {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_vector2_array_write.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Write) WriteSelf {
            var self = Self {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_vector2_array_write_access_copy.?(&other.write_access);

            return self;
        }

        pub inline fn ptr(self: *const WriteSelf) [*]u8 {
            return api.core.godot_pool_vector2_array_write_access_ptr.?(&self.write_access);
        }
    };

    const Self = @This();

    pub fn deinit(self: *Self) void {
        api.core.godot_pool_vector2_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_vector2_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotPoolVector2Array(godot_array: gd.godot_pool_vector2_array) Self {
        const self = Self {
            .godot_array = godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const PoolVector2Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_vector2_array_new_copy.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn initArray(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_vector2_array_new_with_array.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn read(self: *const Self) Read { // Make sure you call .deinit() on returned struct
        return Read.init(self);
    }

    pub fn write(self: *const Self) Write { // Make sure you call .deinit() on returned struct
        return Write.init(self);
    }

    pub fn append(self: *Self, data: u8) void {
        api.core.godot_pool_vector2_array_append.?(&self.godot_array, data);
    }

    pub fn appendArray(self: *Self, array: *const PoolVector2Array) void {
        api.core.godot_pool_vector2_array_append_array.?(&self.godot_array, &array.godot_array);
    }

    pub fn insert(self: *Self, index: i32, data: u8) i32 {
        return api.core.godot_pool_vector2_array_insert.?(&self.godot_array, index, data);
    }

    pub fn invert(self: *Self) void {
        api.core.godot_pool_vector2_array_invert.?(&self.godot_array);
    }

    pub fn pushBack(self: *Self, data: u8) void {
        api.core.godot_pool_vector2_array_push_back.?(&self.godot_array, data);
    }

    pub fn remove(self: *Self, index: i32) void {
        return api.core.godot_pool_vector2_array_remove.?(&self.godot_array, index);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        return api.core.godot_pool_vector2_array_resize.?(&self.godot_array, p_size);
    }

    pub fn set(self: *Self, index: i32, data: u8) void {
        api.core.godot_pool_vector2_array_set.?(&self.godot_array, index, data);
    }

    pub fn get(self: *const Self, index: i32) u8 {
        return api.core.godot_pool_vector2_array_get.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return api.core.godot_pool_vector2_array_get.?(&self.godot_array);
    }

};

pub const PoolVector3Array = struct {

    godot_array: gd.godot_pool_vector3_array,

    pub const Read = struct {

        read_access: gd.godot_pool_vector3_array_read_access,

        const ReadSelf = @This();

        pub inline fn deinit(self: *ReadSelf) void {
            api.core.godot_pool_vector3_array_read_access_destroy.?(&self.read_access);
        }

        pub inline fn init(array: *const PoolVector3Array) ReadSelf {
            var self = ReadSelf {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_vector3_array_read.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Read) ReadSelf {
            var self = Self {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_vector3_array_read_access_copy.?(&other.read_access);

            return self;
        }

        pub inline fn ptr(self: *const ReadSelf) [*]const u8 {
            return api.core.godot_pool_vector3_array_read_access_ptr.?(&self.read_access);
        }

    };

    pub const Write = struct {

        write_access: gd.godot_pool_vector3_array_write_access,

        const WriteSelf = @This();

        pub inline fn deinit(self: *WriteSelf) void {
            api.core.godot_pool_vector3_array_write_access_destroy.?(&self.write_access);
        }

        pub inline fn init(array: *const PoolVector3Array) WriteSelf {
            var self = WriteSelf {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_vector3_array_write.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Write) WriteSelf {
            var self = Self {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_vector3_array_write_access_copy.?(&other.write_access);

            return self;
        }

        pub inline fn ptr(self: *const WriteSelf) [*]u8 {
            return api.core.godot_pool_vector3_array_write_access_ptr.?(&self.write_access);
        }
    };

    const Self = @This();

    pub fn deinit(self: *Self) void {
        api.core.godot_pool_vector3_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_vector3_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotPoolVector3Array(godot_array: gd.godot_pool_vector3_array) Self {
        const self = Self {
            .godot_array = godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const PoolVector3Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_vector3_array_new_copy.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn initArray(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_vector3_array_new_with_array.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn read(self: *const Self) Read { // Make sure you call .deinit() on returned struct
        return Read.init(self);
    }

    pub fn write(self: *const Self) Write { // Make sure you call .deinit() on returned struct
        return Write.init(self);
    }

    pub fn append(self: *Self, data: u8) void {
        api.core.godot_pool_vector3_array_append.?(&self.godot_array, data);
    }

    pub fn appendArray(self: *Self, array: *const PoolVector3Array) void {
        api.core.godot_pool_vector3_array_append_array.?(&self.godot_array, &array.godot_array);
    }

    pub fn insert(self: *Self, index: i32, data: u8) i32 {
        return api.core.godot_pool_vector3_array_insert.?(&self.godot_array, index, data);
    }

    pub fn invert(self: *Self) void {
        api.core.godot_pool_vector3_array_invert.?(&self.godot_array);
    }

    pub fn pushBack(self: *Self, data: u8) void {
        api.core.godot_pool_vector3_array_push_back.?(&self.godot_array, data);
    }

    pub fn remove(self: *Self, index: i32) void {
        return api.core.godot_pool_vector3_array_remove.?(&self.godot_array, index);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        return api.core.godot_pool_vector3_array_resize.?(&self.godot_array, p_size);
    }

    pub fn set(self: *Self, index: i32, data: u8) void {
        api.core.godot_pool_vector3_array_set.?(&self.godot_array, index, data);
    }

    pub fn get(self: *const Self, index: i32) u8 {
        return api.core.godot_pool_vector3_array_get.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return api.core.godot_pool_vector3_array_get.?(&self.godot_array);
    }

};

pub const PoolColorArray = struct {

    godot_array: gd.godot_pool_color_array,

    pub const Read = struct {

        read_access: gd.godot_pool_color_array_read_access,

        const ReadSelf = @This();

        pub inline fn deinit(self: *ReadSelf) void {
            api.core.godot_pool_color_array_read_access_destroy.?(&self.read_access);
        }

        pub inline fn init(array: *const PoolColorArray) ReadSelf {
            var self = ReadSelf {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_color_array_read.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Read) ReadSelf {
            var self = Self {
                .read_access = undefined,
            };

            self.read_access = api.core.godot_pool_color_array_read_access_copy.?(&other.read_access);

            return self;
        }

        pub inline fn ptr(self: *const ReadSelf) [*]const u8 {
            return api.core.godot_pool_color_array_read_access_ptr.?(&self.read_access);
        }

    };

    pub const Write = struct {

        write_access: gd.godot_pool_color_array_write_access,

        const WriteSelf = @This();

        pub inline fn deinit(self: *WriteSelf) void {
            api.core.godot_pool_color_array_write_access_destroy.?(&self.write_access);
        }

        pub inline fn init(array: *const PoolColorArray) WriteSelf {
            var self = WriteSelf {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_color_array_write.?(&array.godot_array);

            return self;
        }

        pub inline fn initCopy(other: *const Write) WriteSelf {
            var self = Self {
                .write_access = undefined,
            };

            self.write_access = api.core.godot_pool_color_array_write_access_copy.?(&other.write_access);

            return self;
        }

        pub inline fn ptr(self: *const WriteSelf) [*]u8 {
            return api.core.godot_pool_color_array_write_access_ptr.?(&self.write_access);
        }
    };

    const Self = @This();

    pub fn deinit(self: *Self) void {
        api.core.godot_pool_color_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_color_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotPoolColorArray(godot_array: gd.godot_pool_color_array) Self {
        const self = Self {
            .godot_array = godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const PoolColorArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_color_array_new_copy.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn initArray(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        api.core.godot_pool_color_array_new_with_array.?(&self.godot_array, other.godot_array);

        return self;
    }

    pub fn read(self: *const Self) Read { // Make sure you call .deinit() on returned struct
        return Read.init(self);
    }

    pub fn write(self: *const Self) Write { // Make sure you call .deinit() on returned struct
        return Write.init(self);
    }

    pub fn append(self: *Self, data: u8) void {
        api.core.godot_pool_color_array_append.?(&self.godot_array, data);
    }

    pub fn appendArray(self: *Self, array: *const PoolColorArray) void {
        api.core.godot_pool_color_array_append_array.?(&self.godot_array, &array.godot_array);
    }

    pub fn insert(self: *Self, index: i32, data: u8) i32 {
        return api.core.godot_pool_color_array_insert.?(&self.godot_array, index, data);
    }

    pub fn invert(self: *Self) void {
        api.core.godot_pool_color_array_invert.?(&self.godot_array);
    }

    pub fn pushBack(self: *Self, data: u8) void {
        api.core.godot_pool_color_array_push_back.?(&self.godot_array, data);
    }

    pub fn remove(self: *Self, index: i32) void {
        return api.core.godot_pool_color_array_remove.?(&self.godot_array, index);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        return api.core.godot_pool_color_array_resize.?(&self.godot_array, p_size);
    }

    pub fn set(self: *Self, index: i32, data: u8) void {
        api.core.godot_pool_color_array_set.?(&self.godot_array, index, data);
    }

    pub fn get(self: *const Self, index: i32) u8 {
        return api.core.godot_pool_color_array_get.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return api.core.godot_pool_color_array_get.?(&self.godot_array);
    }

};
