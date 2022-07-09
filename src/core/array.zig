const gd = @import("api.zig");
const c = gd.c;

const Variant = @import("variant.zig").Variant;
const PoolArrays = @import("pool_arrays.zig");
const PoolByteArray = PoolArrays.PoolByteArray;
const PoolIntArray = PoolArrays.PoolIntArray;
const PoolRealArray = PoolArrays.PoolRealArray;
const PoolStringArray = PoolArrays.PoolStringArray;
const PoolVector2Array = PoolArrays.PoolVector2Array;
const PoolVector3Array = PoolArrays.PoolVector3Array;
const PoolColorArray = PoolArrays.PoolColorArray;

pub const Array = struct {

    godot_array: c.godot_array,
    
    const Self = @This();

    pub fn deinit(self: *Self) void {
        gd.api.*.godot_array_destroy.?(&self.godot_array);
    }

    pub fn init() Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new.?(&self.godot_array);

        return self;
    }

    pub fn initGodotArray(p_godot_array: c.godot_array) Self {
        var self = Self {
            .godot_array = p_godot_array,
        };

        return self;
    }

    pub fn initCopy(other: *const Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_copy.?(&self.godot_array, &other.godot_array);

        return self;
    }

    pub fn initPoolByteArray(other: *const PoolByteArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_pool_byte_array.?(&self.godot_array, &other.godot_pool_byte_array);

        return self;
    }

    pub fn initPoolIntArray(other: *const PoolIntArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_pool_int_array.?(&self.godot_array, &other.godot_pool_int_array);

        return self;
    }

    pub fn initPoolRealArray(other: *const PoolRealArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_pool_real_array.?(&self.godot_array, &other.godot_pool_real_array);

        return self;
    }

    pub fn initPoolStringArray(other: *const PoolStringArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_pool_string_array.?(&self.godot_array, &other.godot_pool_string_array);

        return self;
    }

    pub fn initPoolVector2Array(other: *const PoolVector2Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_pool_vector2_array.?(&self.godot_array, &other.godot_pool_vector2_array);

        return self;
    }

    pub fn initPoolVector3Array(other: *const PoolVector3Array) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_pool_vector3_array.?(&self.godot_array, &other.godot_pool_vector3_array);

        return self;
    }

    pub fn initPoolColorArray(other: *const PoolColorArray) Self {
        var self = Self {
            .godot_array = undefined,
        };

        gd.api.*.godot_array_new_pool_color_array.?(&self.godot_array, &other.godot_pool_color_array);

        return self;
    }

    pub fn get(self: *const Self, index: i32) Variant {
        const godot_variant = gd.api.*.godot_array_operator_index.?(&self.godot_array, index);

        const variant = Variant {
            .godot_variant = godot_variant.*,
        };

        return variant;
    }

    pub fn append(self: *Self, variant: *const Variant) void {
        gd.api.*.godot_array_append.?(&self.godot_array, &variant.godot_variant);
    }

    pub fn clear(self: *Self) void {
        gd.api.*.godot_array_clear.?(&self.godot_array);
    }

    pub fn count(self: *const Self, variant: *const Variant) i32 {
        return gd.api.*.godot_array_count.?(&self.godot_array, &variant.godot_variant);
    }

    pub fn empty(self: *const Self) bool {
        return gd.api.*.godot_array_empty.?(&self.godot_array);
    }

    pub fn erase(self: *Self, variant: *const Variant) void {
        gd.api.*.godot_array_erase.?(&self.godot_array, &variant.godot_variant);
    }

    pub fn front(self: *const Self) Variant {
        const godot_variant = gd.api.*.godot_array_front.?(&self.godot_array);

        const variant = Variant {
            .godot_variant = godot_variant,
        };

        return variant;
    }

    pub fn back(self: *const Self) Variant {
        const godot_variant = gd.api.*.godot_array_back.?(&self.godot_array);

        const variant = Variant {
            .godot_variant = godot_variant,
        };

        return variant;
    }

    pub fn find(self: *const Self, variant: *const Variant, from: i32) i32 {
        return gd.api.*.godot_array_find.?(&self.godot_array, &variant.godot_variant, from);
    }

    pub fn findLast(self: *const Self, variant: *const Variant) i32 {
        return gd.api.*.godot_array_find_last.?(&self.godot_array, &variant.godot_variant);
    }

    pub fn has(self: *const Self, variant: *const Variant) bool {
        return gd.api.*.godot_array_has.?(&self.godot_array, &variant.godot_variant);
    }

    pub fn hash(self: *const Self) u32 {
        return gd.api.*.godot_array_find_hash.?(&self.godot_array);
    }

    pub fn insert(self: *const Self, index: i32, variant: *const Variant) void {
        gd.api.*.godot_array_insert.?(&self.godot_array, index, &variant.godot_variant);
    }

    pub fn invert(self: *Self) void {
        return gd.api.*.godot_array_invert.?(&self.godot_array);
    }

    pub fn popBack(self: *Self) Variant {
        const godot_variant = gd.api.*.godot_array_pop_back.?(&self.godot_array);

        const variant = Variant {
            .godot_variant = godot_variant,
        };

        return variant;
    }

    pub fn popFront(self: *Self) Variant {
        const godot_variant = gd.api.*.godot_array_pop_front.?(&self.godot_array);

        const variant = Variant {
            .godot_variant = godot_variant,
        };

        return variant;
    }

    pub fn pushBack(self: *Self, variant: *const Variant) void {
        gd.api.*.godot_array_push_back.?(&self.godot_array, &variant.godot_variant);
    }

    pub fn pushFront(self: *Self, variant: *const Variant) void {
        gd.api.*.godot_array_push_front.?(&self.godot_array, &variant.godot_variant);
    }

    pub fn remove(self: *Self, index: i32) void {
        gd.api.*.godot_array_remove.?(&self.godot_array, index);
    }

    pub fn size(self: *const Self) i32 {
        return gd.api.*.godot_array_size.?(&self.godot_array);
    }

    pub fn resize(self: *Self, p_size: i32) void {
        gd.api.*.godot_array_resize.?(&self.godot_array, p_size);
    }

    pub fn rfind(self: *const Self, variant: *const Variant, from: i32) i32 {
        return gd.api.*.godot_array_rfind.?(&self.godot_array, &variant.godot_variant, from);
    }

    pub fn sort(self: *Self) void {
        gd.api.*.godot_array_sort.?(&self.godot_array);
    }

    // pub fn sortCustom(self: *Self, obj: *Object, func: *const String) void {
    //     gd.api.*.godot_array_sort_custom.?(&self.godot_array, @ptrCast(*c.godot_object, obj), &func.godot_string);
    // }

    pub fn bsearch(self: *const Self, variant: *const Variant, before: bool) i32 {
        return gd.api.*.godot_array_bsearch.?(&self.godot_array, &variant.godot_variant, before);
    }

    // pub fn bsearchCustom(self: *const Self, variant: *const Variant, obj: *Object, func: *const String, before: bool) i32 {
    //     return gd.api.*.godot_array_bsearch_custom.?(&self.godot_array, &variant.godot_variant, @ptrCast(*c.godot_object, obj), &func.godot_string, before);
    // }

    pub fn duplicate(self: *const Self, deep: bool) Array {
        const godot_array = gd.api_1_1.*.godot_array_duplicate.?(&self.godot_array, deep);

        const array = Array {
            .godot_array = godot_array,
        };

        return array;
    }

    pub fn max(self: *const Self) Variant {
        const godot_variant = gd.api_1_1.*.godot_array_max.?(&self.godot_array);

        const variant = Variant {
            .godot_variant = godot_variant,
        };

        return variant;
    }

    pub fn min(self: *const Self) Variant {
        const godot_variant = gd.api_1_1.*.godot_array_min.?(&self.godot_array);

        const variant = Variant {
            .godot_variant = godot_variant,
        };

        return variant;
    }

    pub fn shuffle(self: *Self) void {
        gd.api_1_1.*.godot_array_shuffle.?(&self.godot_array);
    }

};
