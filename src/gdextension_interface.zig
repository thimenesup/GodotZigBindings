// Ported from Godot's C GDExtension 4.0 gdextension_interface.h //Refer to it for any documentation details

pub const char = c_char;
pub const wchar_t = i16;
pub const char16_t = i16;
pub const char32_t = i32;

pub const GDExtensionVariantType = enum(c_uint) {
    GDEXTENSION_VARIANT_TYPE_NIL,

    GDEXTENSION_VARIANT_TYPE_BOOL,
    GDEXTENSION_VARIANT_TYPE_INT,
    GDEXTENSION_VARIANT_TYPE_FLOAT,
    GDEXTENSION_VARIANT_TYPE_STRING,

    GDEXTENSION_VARIANT_TYPE_VECTOR2,
    GDEXTENSION_VARIANT_TYPE_VECTOR2I,
    GDEXTENSION_VARIANT_TYPE_RECT2,
    GDEXTENSION_VARIANT_TYPE_RECT2I,
    GDEXTENSION_VARIANT_TYPE_VECTOR3,
    GDEXTENSION_VARIANT_TYPE_VECTOR3I,
    GDEXTENSION_VARIANT_TYPE_TRANSFORM2D,
    GDEXTENSION_VARIANT_TYPE_VECTOR4,
    GDEXTENSION_VARIANT_TYPE_VECTOR4I,
    GDEXTENSION_VARIANT_TYPE_PLANE,
    GDEXTENSION_VARIANT_TYPE_QUATERNION,
    GDEXTENSION_VARIANT_TYPE_AABB,
    GDEXTENSION_VARIANT_TYPE_BASIS,
    GDEXTENSION_VARIANT_TYPE_TRANSFORM3D,
    GDEXTENSION_VARIANT_TYPE_PROJECTION,

    GDEXTENSION_VARIANT_TYPE_COLOR,
    GDEXTENSION_VARIANT_TYPE_STRING_NAME,
    GDEXTENSION_VARIANT_TYPE_NODE_PATH,
    GDEXTENSION_VARIANT_TYPE_RID,
    GDEXTENSION_VARIANT_TYPE_OBJECT,
    GDEXTENSION_VARIANT_TYPE_CALLABLE,
    GDEXTENSION_VARIANT_TYPE_SIGNAL,
    GDEXTENSION_VARIANT_TYPE_DICTIONARY,
    GDEXTENSION_VARIANT_TYPE_ARRAY,

    GDEXTENSION_VARIANT_TYPE_PACKED_BYTE_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_INT32_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_INT64_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT32_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_FLOAT64_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_STRING_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR2_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_VECTOR3_ARRAY,
    GDEXTENSION_VARIANT_TYPE_PACKED_COLOR_ARRAY,

    GDEXTENSION_VARIANT_TYPE_VARIANT_MAX
};

pub const GDExtensionVariantOperator = enum(c_uint) {
    GDEXTENSION_VARIANT_OP_EQUAL,
    GDEXTENSION_VARIANT_OP_NOT_EQUAL,
    GDEXTENSION_VARIANT_OP_LESS,
    GDEXTENSION_VARIANT_OP_LESS_EQUAL,
    GDEXTENSION_VARIANT_OP_GREATER,
    GDEXTENSION_VARIANT_OP_GREATER_EQUAL,

    GDEXTENSION_VARIANT_OP_ADD,
    GDEXTENSION_VARIANT_OP_SUBTRACT,
    GDEXTENSION_VARIANT_OP_MULTIPLY,
    GDEXTENSION_VARIANT_OP_DIVIDE,
    GDEXTENSION_VARIANT_OP_NEGATE,
    GDEXTENSION_VARIANT_OP_POSITIVE,
    GDEXTENSION_VARIANT_OP_MODULE,
    GDEXTENSION_VARIANT_OP_POWER,

    GDEXTENSION_VARIANT_OP_SHIFT_LEFT,
    GDEXTENSION_VARIANT_OP_SHIFT_RIGHT,
    GDEXTENSION_VARIANT_OP_BIT_AND,
    GDEXTENSION_VARIANT_OP_BIT_OR,
    GDEXTENSION_VARIANT_OP_BIT_XOR,
    GDEXTENSION_VARIANT_OP_BIT_NEGATE,

    GDEXTENSION_VARIANT_OP_AND,
    GDEXTENSION_VARIANT_OP_OR,
    GDEXTENSION_VARIANT_OP_XOR,
    GDEXTENSION_VARIANT_OP_NOT,

    GDEXTENSION_VARIANT_OP_IN,
    GDEXTENSION_VARIANT_OP_MAX
};

pub const GDExtensionVariantPtr = ?*anyopaque;
pub const GDExtensionConstVariantPtr = ?*const anyopaque;
pub const GDExtensionStringNamePtr = ?*anyopaque;
pub const GDExtensionConstStringNamePtr = ?*const anyopaque;
pub const GDExtensionStringPtr = ?*anyopaque;
pub const GDExtensionConstStringPtr = ?*const anyopaque;
pub const GDExtensionObjectPtr = ?*anyopaque;
pub const GDExtensionConstObjectPtr = ?*const anyopaque;
pub const GDExtensionTypePtr = ?*anyopaque;
pub const GDExtensionConstTypePtr = ?*const anyopaque;
pub const GDExtensionMethodBindPtr = ?*anyopaque;
pub const GDExtensionInt = i64;
pub const GDExtensionBool = bool;
pub const GDObjectInstanceID = u64;
pub const GDExtensionRefPtr = ?*anyopaque;
pub const GDExtensionConstRefPtr = ?*const anyopaque;

pub const GDExtensionCallErrorType = enum(c_uint) {
    GDEXTENSION_CALL_OK,
    GDEXTENSION_CALL_ERROR_INVALID_METHOD,
    GDEXTENSION_CALL_ERROR_INVALID_ARGUMENT,
    GDEXTENSION_CALL_ERROR_TOO_MANY_ARGUMENTS,
    GDEXTENSION_CALL_ERROR_TOO_FEW_ARGUMENTS,
    GDEXTENSION_CALL_ERROR_INSTANCE_IS_NULL,
    GDEXTENSION_CALL_ERROR_METHOD_NOT_CONST,
};

pub const GDExtensionCallError = extern struct {
    _error: GDExtensionCallErrorType,
    argument: i32,
    expected: i32,
};

pub const GDExtensionVariantFromTypeConstructorFunc = ?*const fn (GDExtensionVariantPtr, GDExtensionTypePtr) callconv(.C) void;
pub const GDExtensionTypeFromVariantConstructorFunc = ?*const fn (GDExtensionTypePtr, GDExtensionVariantPtr) callconv(.C) void;
pub const GDExtensionPtrOperatorEvaluator = ?*const fn (GDExtensionConstTypePtr, GDExtensionConstTypePtr, GDExtensionTypePtr) callconv(.C) void;
pub const GDExtensionPtrBuiltInMethod = ?*const fn (GDExtensionTypePtr, [*c]const GDExtensionConstTypePtr, GDExtensionTypePtr, c_int) callconv(.C) void;
pub const GDExtensionPtrConstructor = ?*const fn (GDExtensionTypePtr, [*c]const GDExtensionConstTypePtr) callconv(.C) void;
pub const GDExtensionPtrDestructor = ?*const fn (GDExtensionTypePtr) callconv(.C) void;
pub const GDExtensionPtrSetter = ?*const fn (GDExtensionTypePtr, GDExtensionConstTypePtr) callconv(.C) void;
pub const GDExtensionPtrGetter = ?*const fn (GDExtensionConstTypePtr, GDExtensionTypePtr) callconv(.C) void;
pub const GDExtensionPtrIndexedSetter = ?*const fn (GDExtensionTypePtr, GDExtensionInt, GDExtensionConstTypePtr) callconv(.C) void;
pub const GDExtensionPtrIndexedGetter = ?*const fn (GDExtensionConstTypePtr, GDExtensionInt, GDExtensionTypePtr) callconv(.C) void;
pub const GDExtensionPtrKeyedSetter = ?*const fn (GDExtensionTypePtr, GDExtensionConstTypePtr, GDExtensionConstTypePtr) callconv(.C) void;
pub const GDExtensionPtrKeyedGetter = ?*const fn (GDExtensionConstTypePtr, GDExtensionConstTypePtr, GDExtensionTypePtr) callconv(.C) void;
pub const GDExtensionPtrKeyedChecker = ?*const fn (GDExtensionConstVariantPtr, GDExtensionConstVariantPtr) callconv(.C) u32;
pub const GDExtensionPtrUtilityFunction = ?*const fn (GDExtensionTypePtr, [*c]const GDExtensionConstTypePtr, c_int) callconv(.C) void;

pub const GDExtensionClassConstructor = ?*const fn () callconv(.C) GDExtensionObjectPtr;

pub const GDExtensionInstanceBindingCreateCallback = ?*const fn (?*anyopaque, ?*anyopaque) callconv(.C) ?*anyopaque;
pub const GDExtensionInstanceBindingFreeCallback = ?*const fn (?*anyopaque, ?*anyopaque, ?*anyopaque) callconv(.C) void;
pub const GDExtensionInstanceBindingReferenceCallback = ?*const fn (?*anyopaque, ?*anyopaque, GDExtensionBool) callconv(.C) GDExtensionBool;

pub const GDExtensionInstanceBindingCallbacks = extern struct {
    create_callback: GDExtensionInstanceBindingCreateCallback,
    free_callback: GDExtensionInstanceBindingFreeCallback,
    reference_callback: GDExtensionInstanceBindingReferenceCallback,
};

pub const GDExtensionClassInstancePtr = ?*anyopaque;

pub const GDExtensionClassSet = ?*const fn (GDExtensionClassInstancePtr, GDExtensionConstStringNamePtr, GDExtensionConstVariantPtr) callconv(.C) GDExtensionBool;
pub const GDExtensionClassGet = ?*const fn (GDExtensionClassInstancePtr, GDExtensionConstStringNamePtr, GDExtensionVariantPtr) callconv(.C) GDExtensionBool;
pub const GDExtensionClassGetRID = ?*const fn (GDExtensionClassInstancePtr) callconv(.C) u64;

pub const GDExtensionPropertyInfo = extern struct {
    _type: GDExtensionVariantType,
    name: GDExtensionStringNamePtr,
    class_name: GDExtensionStringNamePtr,
    hint: u32,
    hint_string: GDExtensionStringPtr,
    usage: u32,
};

pub const GDExtensionMethodInfo = extern struct {
    name: GDExtensionStringNamePtr,
    return_value: GDExtensionPropertyInfo,
    flags: u32,
    id: i32,

    argument_count: u32,
    arguments: [*c]GDExtensionPropertyInfo,

    default_argument_count: u32,
    default_arguments: [*c]GDExtensionVariantPtr,
};

pub const GDExtensionClassGetPropertyList = ?*const fn (GDExtensionClassInstancePtr, [*c]u32) callconv(.C) [*c]const GDExtensionPropertyInfo;
pub const GDExtensionClassFreePropertyList = ?*const fn (GDExtensionClassInstancePtr, [*c]const GDExtensionPropertyInfo) callconv(.C) void;
pub const GDExtensionClassPropertyCanRevert = ?*const fn (GDExtensionClassInstancePtr, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionBool;
pub const GDExtensionClassPropertyGetRevert = ?*const fn (GDExtensionClassInstancePtr, GDExtensionConstStringNamePtr, GDExtensionVariantPtr) callconv(.C) GDExtensionBool;
pub const GDExtensionClassNotification = ?*const fn (GDExtensionClassInstancePtr, i32) callconv(.C) void;
pub const GDExtensionClassToString = ?*const fn (GDExtensionClassInstancePtr, [*c]GDExtensionBool, GDExtensionStringPtr) callconv(.C) void;
pub const GDExtensionClassReference = ?*const fn (GDExtensionClassInstancePtr) callconv(.C) void;
pub const GDExtensionClassUnreference = ?*const fn (GDExtensionClassInstancePtr) callconv(.C) void;
pub const GDExtensionClassCallVirtual = ?*const fn (GDExtensionClassInstancePtr, [*c]const GDExtensionConstTypePtr, GDExtensionTypePtr) callconv(.C) void;
pub const GDExtensionClassCreateInstance = ?*const fn (?*anyopaque) callconv(.C) GDExtensionObjectPtr;
pub const GDExtensionClassFreeInstance = ?*const fn (?*anyopaque, GDExtensionClassInstancePtr) callconv(.C) void;
pub const GDExtensionClassGetVirtual = ?*const fn (?*anyopaque, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionClassCallVirtual;

pub const GDExtensionClassCreationInfo = extern struct {
    is_virtual: GDExtensionBool,
    is_abstract: GDExtensionBool,
    set_func: GDExtensionClassSet,
    get_func: GDExtensionClassGet,
    get_property_list_func: GDExtensionClassGetPropertyList,
    free_property_list_func: GDExtensionClassFreePropertyList,
    property_can_revert_func: GDExtensionClassPropertyCanRevert,
    property_get_revert_func: GDExtensionClassPropertyGetRevert,
    notification_func: GDExtensionClassNotification,
    to_string_func: GDExtensionClassToString,
    reference_func: GDExtensionClassReference,
    unreference_func: GDExtensionClassUnreference,
    create_instance_func: GDExtensionClassCreateInstance,
    free_instance_func: GDExtensionClassFreeInstance,
    get_virtual_func: GDExtensionClassGetVirtual,
    get_rid_func: GDExtensionClassGetRID,
    class_userdata: ?*anyopaque,
};

pub const GDExtensionClassLibraryPtr = ?*anyopaque;

pub const GDExtensionClassMethodFlags = enum(c_uint) {
    GDEXTENSION_METHOD_FLAG_NORMAL = 1,
    GDEXTENSION_METHOD_FLAG_EDITOR = 2,
    GDEXTENSION_METHOD_FLAG_CONST = 4,
    GDEXTENSION_METHOD_FLAG_VIRTUAL = 8,
    GDEXTENSION_METHOD_FLAG_VARARG = 16,
    GDEXTENSION_METHOD_FLAG_STATIC = 32,
    GDEXTENSION_METHOD_FLAGS_DEFAULT = GDExtensionClassMethodFlags.GDEXTENSION_METHOD_FLAG_NORMAL,
};

pub const GDExtensionClassMethodArgumentMetadata = enum(c_uint) {
    GDEXTENSION_METHOD_ARGUMENT_METADATA_NONE,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_INT8,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_INT16,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_INT32,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_INT64,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_UINT8,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_UINT16,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_UINT32,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_INT_IS_UINT64,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_REAL_IS_FLOAT,
    GDEXTENSION_METHOD_ARGUMENT_METADATA_REAL_IS_DOUBLE
};

pub const GDExtensionClassMethodCall = ?*const fn (?*anyopaque, GDExtensionClassInstancePtr, [*c]const GDExtensionConstVariantPtr, GDExtensionInt, GDExtensionVariantPtr, [*c]GDExtensionCallError) callconv(.C) void;
pub const GDExtensionClassMethodPtrCall = ?*const fn (?*anyopaque, GDExtensionClassInstancePtr, [*c]const GDExtensionConstTypePtr, GDExtensionTypePtr) callconv(.C) void;

pub const GDExtensionClassMethodInfo = extern struct {
    name: GDExtensionStringNamePtr,
    method_userdata: ?*anyopaque,
    call_func: GDExtensionClassMethodCall,
    ptrcall_func: GDExtensionClassMethodPtrCall,
    method_flags: u32,

    has_return_value: GDExtensionBool,
    return_value_info: [*c]GDExtensionPropertyInfo,
    return_value_metadata: GDExtensionClassMethodArgumentMetadata,

    argument_count: u32,
    arguments_info: [*c]GDExtensionPropertyInfo,
    arguments_metadata: [*c]GDExtensionClassMethodArgumentMetadata,

    default_argument_count: u32,
    default_arguments: [*c]GDExtensionVariantPtr,
};

pub const GDExtensionScriptInstanceDataPtr = ?*anyopaque;

pub const GDExtensionScriptInstanceSet = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionConstStringNamePtr, GDExtensionConstVariantPtr) callconv(.C) GDExtensionBool;
pub const GDExtensionScriptInstanceGet = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionConstStringNamePtr, GDExtensionVariantPtr) callconv(.C) GDExtensionBool;
pub const GDExtensionScriptInstanceGetPropertyList = ?*const fn (GDExtensionScriptInstanceDataPtr, [*c]u32) callconv(.C) [*c]const GDExtensionPropertyInfo;
pub const GDExtensionScriptInstanceFreePropertyList = ?*const fn (GDExtensionScriptInstanceDataPtr, [*c]const GDExtensionPropertyInfo) callconv(.C) void;
pub const GDExtensionScriptInstanceGetPropertyType = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionConstStringNamePtr, [*c]GDExtensionBool) callconv(.C) GDExtensionVariantType;

pub const GDExtensionScriptInstancePropertyCanRevert = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionBool;
pub const GDExtensionScriptInstancePropertyGetRevert = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionConstStringNamePtr, GDExtensionVariantPtr) callconv(.C) GDExtensionBool;

pub const GDExtensionScriptInstanceGetOwner = ?*const fn (GDExtensionScriptInstanceDataPtr) callconv(.C) GDExtensionObjectPtr;
pub const GDExtensionScriptInstancePropertyStateAdd = ?*const fn (GDExtensionConstStringNamePtr, GDExtensionConstVariantPtr, ?*anyopaque) callconv(.C) void;
pub const GDExtensionScriptInstanceGetPropertyState = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionScriptInstancePropertyStateAdd, ?*anyopaque) callconv(.C) void;

pub const GDExtensionScriptInstanceGetMethodList = ?*const fn (GDExtensionScriptInstanceDataPtr, [*c]u32) callconv(.C) [*c]const GDExtensionMethodInfo;
pub const GDExtensionScriptInstanceFreeMethodList = ?*const fn (GDExtensionScriptInstanceDataPtr, [*c]const GDExtensionMethodInfo) callconv(.C) void;

pub const GDExtensionScriptInstanceHasMethod = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionBool;

pub const GDExtensionScriptInstanceCall = ?*const fn (GDExtensionScriptInstanceDataPtr, GDExtensionConstStringNamePtr, [*c]const GDExtensionConstVariantPtr, GDExtensionInt, GDExtensionVariantPtr, [*c]GDExtensionCallError) callconv(.C) void;
pub const GDExtensionScriptInstanceNotification = ?*const fn (GDExtensionScriptInstanceDataPtr, i32) callconv(.C) void;
pub const GDExtensionScriptInstanceToString = ?*const fn (GDExtensionScriptInstanceDataPtr, [*c]GDExtensionBool, GDExtensionStringPtr) callconv(.C) void;

pub const GDExtensionScriptInstanceRefCountIncremented = ?*const fn (GDExtensionScriptInstanceDataPtr) callconv(.C) void;
pub const GDExtensionScriptInstanceRefCountDecremented = ?*const fn (GDExtensionScriptInstanceDataPtr) callconv(.C) GDExtensionBool;

pub const GDExtensionScriptInstanceGetScript = ?*const fn (GDExtensionScriptInstanceDataPtr) callconv(.C) GDExtensionObjectPtr;
pub const GDExtensionScriptInstanceIsPlaceholder = ?*const fn (GDExtensionScriptInstanceDataPtr) callconv(.C) GDExtensionBool;

pub const GDExtensionScriptLanguagePtr = ?*anyopaque;

pub const GDExtensionScriptInstanceGetLanguage = ?*const fn (GDExtensionScriptInstanceDataPtr) callconv(.C) GDExtensionScriptLanguagePtr;

pub const GDExtensionScriptInstanceFree = ?*const fn (GDExtensionScriptInstanceDataPtr) callconv(.C) void;

pub const GDExtensionScriptInstancePtr = ?*anyopaque;

pub const GDExtensionScriptInstanceInfo = extern struct {
    set_func: GDExtensionScriptInstanceSet,
    get_func: GDExtensionScriptInstanceGet,
    get_property_list_func: GDExtensionScriptInstanceGetPropertyList,
    free_property_list_func: GDExtensionScriptInstanceFreePropertyList,

    property_can_revert_func: GDExtensionScriptInstancePropertyCanRevert,
    property_get_revert_func: GDExtensionScriptInstancePropertyGetRevert,

    get_owner_func: GDExtensionScriptInstanceGetOwner,
    get_property_state_func: GDExtensionScriptInstanceGetPropertyState,

    get_method_list_func: GDExtensionScriptInstanceGetMethodList,
    free_method_list_func: GDExtensionScriptInstanceFreeMethodList,
    get_property_type_func: GDExtensionScriptInstanceGetPropertyType,

    has_method_func: GDExtensionScriptInstanceHasMethod,

    call_func: GDExtensionScriptInstanceCall,
    notification_func: GDExtensionScriptInstanceNotification,

    to_string_func: GDExtensionScriptInstanceToString,

    refcount_incremented_func: GDExtensionScriptInstanceRefCountIncremented,
    refcount_decremented_func: GDExtensionScriptInstanceRefCountDecremented,

    get_script_func: GDExtensionScriptInstanceGetScript,

    is_placeholder_func: GDExtensionScriptInstanceIsPlaceholder,

    set_fallback_func: GDExtensionScriptInstanceSet,
    get_fallback_func: GDExtensionScriptInstanceGet,

    get_language_func: GDExtensionScriptInstanceGetLanguage,

    free_func: GDExtensionScriptInstanceFree,
};

pub const GDExtensionInterface = extern struct {
    version_major: u32,
    version_minor: u32,
    version_patch: u32,
    version_string: [*c]const char,

    mem_alloc: ?*const fn (usize) callconv(.C) ?*anyopaque,
    mem_realloc: ?*const fn (?*anyopaque, usize) callconv(.C) ?*anyopaque,
    mem_free: ?*const fn (?*anyopaque) callconv(.C) void,

    print_error: ?*const fn ([*c]const char, [*c]const char, [*c]const char, i32, GDExtensionBool) callconv(.C) void,
    print_error_with_message: ?*const fn ([*c]const char, [*c]const char, [*c]const char, [*c]const char, i32, GDExtensionBool) callconv(.C) void,
    print_warning: ?*const fn ([*c]const char, [*c]const char, [*c]const char, i32, GDExtensionBool) callconv(.C) void,
    print_warning_with_message: ?*const fn ([*c]const char, [*c]const char, [*c]const char, [*c]const char, i32, GDExtensionBool) callconv(.C) void,
    print_script_error: ?*const fn ([*c]const char, [*c]const char, [*c]const char, i32, GDExtensionBool) callconv(.C) void,
    print_script_error_with_message: ?*const fn ([*c]const char, [*c]const char, [*c]const char, [*c]const char, i32, GDExtensionBool) callconv(.C) void,

    get_native_struct_size: ?*const fn (GDExtensionConstStringNamePtr) callconv(.C) u64,

    variant_new_copy: ?*const fn (GDExtensionVariantPtr, GDExtensionConstVariantPtr) callconv(.C) void,
    variant_new_nil: ?*const fn (GDExtensionVariantPtr) callconv(.C) void,
    variant_destroy: ?*const fn (GDExtensionVariantPtr) callconv(.C) void,

    variant_call: ?*const fn (GDExtensionVariantPtr, GDExtensionConstStringNamePtr, [*c]const GDExtensionConstVariantPtr , GDExtensionInt, GDExtensionVariantPtr, [*c]GDExtensionCallError) callconv(.C) void,
    variant_call_static: ?*const fn (GDExtensionVariantType, GDExtensionConstStringNamePtr, [*c]const GDExtensionConstVariantPtr, GDExtensionInt, GDExtensionVariantPtr, [*c]GDExtensionCallError) callconv(.C) void,
    variant_evaluate: ?*const fn (GDExtensionVariantOperator, GDExtensionConstVariantPtr, GDExtensionConstVariantPtr, GDExtensionVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_set: ?*const fn (GDExtensionVariantPtr, GDExtensionConstVariantPtr, GDExtensionConstVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_set_named: ?*const fn (GDExtensionVariantPtr, GDExtensionConstStringNamePtr, GDExtensionConstVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_set_keyed: ?*const fn (GDExtensionVariantPtr, GDExtensionConstVariantPtr, GDExtensionConstVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_set_indexed: ?*const fn (GDExtensionVariantPtr, GDExtensionInt, GDExtensionConstVariantPtr, [*c]GDExtensionBool, [*c]GDExtensionBool) callconv(.C) void,
    variant_get: ?*const fn (GDExtensionConstVariantPtr, GDExtensionConstVariantPtr, GDExtensionVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_get_named: ?*const fn (GDExtensionConstVariantPtr, GDExtensionConstStringNamePtr, GDExtensionVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_get_keyed: ?*const fn (GDExtensionConstVariantPtr, GDExtensionConstVariantPtr, GDExtensionVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_get_indexed: ?*const fn (GDExtensionConstVariantPtr, GDExtensionInt, GDExtensionVariantPtr, [*c]GDExtensionBool, [*c]GDExtensionBool) callconv(.C) void,
    variant_iter_init: ?*const fn (GDExtensionConstVariantPtr, GDExtensionVariantPtr, [*c]GDExtensionBool) callconv(.C) GDExtensionBool,
    variant_iter_next: ?*const fn (GDExtensionConstVariantPtr, GDExtensionVariantPtr, [*c]GDExtensionBool) callconv(.C) GDExtensionBool,
    variant_iter_get: ?*const fn (GDExtensionConstVariantPtr, GDExtensionVariantPtr, GDExtensionVariantPtr, [*c]GDExtensionBool) callconv(.C) void,
    variant_hash: ?*const fn (GDExtensionConstVariantPtr) callconv(.C) GDExtensionInt,
    variant_recursive_hash: ?*const fn (GDExtensionConstVariantPtr, GDExtensionInt) callconv(.C) GDExtensionInt,
    variant_hash_compare: ?*const fn (GDExtensionConstVariantPtr, GDExtensionConstVariantPtr) callconv(.C) GDExtensionBool,
    variant_booleanize: ?*const fn (GDExtensionConstVariantPtr) callconv(.C) GDExtensionBool,
    variant_duplicate: ?*const fn (GDExtensionConstVariantPtr, GDExtensionVariantPtr, GDExtensionBool) callconv(.C) void,
    variant_stringify: ?*const fn (GDExtensionConstVariantPtr, GDExtensionStringPtr) callconv(.C) void,

    variant_get_type: ?*const fn (GDExtensionConstVariantPtr) callconv(.C) GDExtensionVariantType,
    variant_has_method: ?*const fn (GDExtensionConstVariantPtr, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionBool,
    variant_has_member: ?*const fn (GDExtensionVariantType, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionBool,
    variant_has_key: ?*const fn (GDExtensionConstVariantPtr, GDExtensionConstVariantPtr, [*c]GDExtensionBool) callconv(.C) GDExtensionBool,
    variant_get_type_name: ?*const fn (GDExtensionVariantType, GDExtensionStringPtr) callconv(.C) void,
    variant_can_convert: ?*const fn (GDExtensionVariantType, GDExtensionVariantType) callconv(.C) GDExtensionBool,
    variant_can_convert_strict: ?*const fn (GDExtensionVariantType, GDExtensionVariantType) callconv(.C) GDExtensionBool,

    get_variant_from_type_constructor: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionVariantFromTypeConstructorFunc,
    get_variant_to_type_constructor: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionTypeFromVariantConstructorFunc,
    variant_get_ptr_operator_evaluator: ?*const fn (GDExtensionVariantOperator, GDExtensionVariantType, GDExtensionVariantType) callconv(.C) GDExtensionPtrOperatorEvaluator,
    variant_get_ptr_builtin_method: ?*const fn (GDExtensionVariantType, GDExtensionConstStringNamePtr, GDExtensionInt) callconv(.C) GDExtensionPtrBuiltInMethod,
    variant_get_ptr_constructor: ?*const fn (GDExtensionVariantType, i32) callconv(.C) GDExtensionPtrConstructor,
    variant_get_ptr_destructor: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionPtrDestructor,
    variant_construct: ?*const fn (GDExtensionVariantType, GDExtensionVariantPtr, [*c]const GDExtensionConstVariantPtr, i32, [*c]GDExtensionCallError) callconv(.C) void,
    variant_get_ptr_setter: ?*const fn (GDExtensionVariantType, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionPtrSetter,
    variant_get_ptr_getter: ?*const fn (GDExtensionVariantType, GDExtensionConstStringNamePtr) callconv(.C) GDExtensionPtrGetter,
    variant_get_ptr_indexed_setter: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionPtrIndexedSetter,
    variant_get_ptr_indexed_getter: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionPtrIndexedGetter,
    variant_get_ptr_keyed_setter: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionPtrKeyedSetter,
    variant_get_ptr_keyed_getter: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionPtrKeyedGetter,
    variant_get_ptr_keyed_checker: ?*const fn (GDExtensionVariantType) callconv(.C) GDExtensionPtrKeyedChecker,
    variant_get_constant_value: ?*const fn (GDExtensionVariantType, GDExtensionConstStringNamePtr, GDExtensionVariantPtr) callconv(.C) void,
    variant_get_ptr_utility_function: ?*const fn (GDExtensionConstStringNamePtr, GDExtensionInt) callconv(.C) GDExtensionPtrUtilityFunction,

    string_new_with_latin1_chars: ?*const fn (GDExtensionStringPtr, [*c]const char) callconv(.C) void,
    string_new_with_utf8_chars: ?*const fn (GDExtensionStringPtr, [*c]const char) callconv(.C) void,
    string_new_with_utf16_chars: ?*const fn (GDExtensionStringPtr, [*c]const char16_t) callconv(.C) void,
    string_new_with_utf32_chars: ?*const fn (GDExtensionStringPtr, [*c]const char32_t) callconv(.C) void,
    string_new_with_wide_chars: ?*const fn (GDExtensionStringPtr, [*c]const wchar_t) callconv(.C) void,
    string_new_with_latin1_chars_and_len: ?*const fn (GDExtensionStringPtr, [*c]const char, GDExtensionInt) callconv(.C) void,
    string_new_with_utf8_chars_and_len: ?*const fn (GDExtensionStringPtr, [*c]const char, GDExtensionInt) callconv(.C) void,
    string_new_with_utf16_chars_and_len: ?*const fn (GDExtensionStringPtr, [*c]const char16_t, GDExtensionInt) callconv(.C) void,
    string_new_with_utf32_chars_and_len: ?*const fn (GDExtensionStringPtr, [*c]const char32_t, GDExtensionInt) callconv(.C) void,
    string_new_with_wide_chars_and_len: ?*const fn (GDExtensionStringPtr, [*c]const wchar_t, GDExtensionInt) callconv(.C) void,

    string_to_latin1_chars: ?*const fn (GDExtensionConstStringPtr, [*c]char, GDExtensionInt) callconv(.C) GDExtensionInt,
    string_to_utf8_chars: ?*const fn (GDExtensionConstStringPtr, [*c]char, GDExtensionInt) callconv(.C) GDExtensionInt,
    string_to_utf16_chars: ?*const fn (GDExtensionConstStringPtr, [*c]char16_t, GDExtensionInt) callconv(.C) GDExtensionInt,
    string_to_utf32_chars: ?*const fn (GDExtensionConstStringPtr, [*c]char32_t, GDExtensionInt) callconv(.C) GDExtensionInt,
    string_to_wide_chars: ?*const fn (GDExtensionConstStringPtr, [*c]wchar_t, GDExtensionInt) callconv(.C) GDExtensionInt,
    string_operator_index: ?*const fn (GDExtensionStringPtr, GDExtensionInt) callconv(.C) [*c]char32_t,
    string_operator_index_const: ?*const fn (GDExtensionConstStringPtr, GDExtensionInt) callconv(.C) [*c]const char32_t,

    string_operator_plus_eq_string: ?*const fn (GDExtensionStringPtr, GDExtensionConstStringPtr) callconv(.C) void,
    string_operator_plus_eq_char: ?*const fn (GDExtensionStringPtr, char32_t) callconv(.C) void,
    string_operator_plus_eq_cstr: ?*const fn (GDExtensionStringPtr, [*c]const char) callconv(.C) void,
    string_operator_plus_eq_wcstr: ?*const fn (GDExtensionStringPtr, [*c]const wchar_t) callconv(.C) void,
    string_operator_plus_eq_c32str: ?*const fn (GDExtensionStringPtr, [*c]const char32_t) callconv(.C) void,

    xml_parser_open_buffer: ?*const fn (GDExtensionObjectPtr, [*c]const u8, usize) callconv(.C) GDExtensionInt,

    file_access_store_buffer: ?*const fn (GDExtensionObjectPtr, [*c]const u8, u64) callconv(.C) void,
    file_access_get_buffer: ?*const fn (GDExtensionConstObjectPtr, [*c]u8, u64) callconv(.C) u64,

    worker_thread_pool_add_native_group_task: ?*const fn (GDExtensionObjectPtr, ?*const fn (?*anyopaque, u32) callconv(.C) void, ?*anyopaque, c_int, c_int, GDExtensionBool, GDExtensionConstStringPtr) callconv(.C) i64,
    worker_thread_pool_add_native_task: ?*const fn (GDExtensionObjectPtr, ?*const fn (?*anyopaque) callconv(.C) void, ?*anyopaque, GDExtensionBool, GDExtensionConstStringPtr) callconv(.C) i64,

    packed_byte_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) [*c]u8,
    packed_byte_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) [*c]const u8,

    packed_color_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) GDExtensionTypePtr,
    packed_color_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) GDExtensionTypePtr,

    packed_float32_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) [*c]f32,
    packed_float32_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) [*c]const f32,
    packed_float64_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) [*c]f64,
    packed_float64_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) [*c]const f64,

    packed_int32_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) [*c]i32,
    packed_int32_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) [*c]const i32,
    packed_int64_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) [*c]i64,
    packed_int64_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) [*c]const i64,

    packed_string_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) GDExtensionStringPtr,
    packed_string_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) GDExtensionStringPtr,

    packed_vector2_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) GDExtensionTypePtr,
    packed_vector2_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) GDExtensionTypePtr,
    packed_vector3_array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) GDExtensionTypePtr,
    packed_vector3_array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) GDExtensionTypePtr,

    array_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionInt) callconv(.C) GDExtensionVariantPtr,
    array_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionInt) callconv(.C) GDExtensionVariantPtr,
    array_ref: ?*const fn (GDExtensionTypePtr, GDExtensionConstTypePtr) callconv(.C) void,
    array_set_typed: ?*const fn (GDExtensionTypePtr, GDExtensionVariantType, GDExtensionConstStringNamePtr, GDExtensionConstVariantPtr) callconv(.C) void,

    dictionary_operator_index: ?*const fn (GDExtensionTypePtr, GDExtensionConstVariantPtr) callconv(.C) GDExtensionVariantPtr,
    dictionary_operator_index_const: ?*const fn (GDExtensionConstTypePtr, GDExtensionConstVariantPtr) callconv(.C) GDExtensionVariantPtr,

    object_method_bind_call: ?*const fn (GDExtensionMethodBindPtr, GDExtensionObjectPtr, [*c]const GDExtensionConstVariantPtr, GDExtensionInt, GDExtensionVariantPtr, [*c]GDExtensionCallError) callconv(.C) void,
    object_method_bind_ptrcall: ?*const fn (GDExtensionMethodBindPtr, GDExtensionObjectPtr, [*c]const GDExtensionConstTypePtr, GDExtensionTypePtr) callconv(.C) void,
    object_destroy: ?*const fn (GDExtensionObjectPtr) callconv(.C) void,
    global_get_singleton: ?*const fn (GDExtensionConstStringNamePtr) callconv(.C) GDExtensionObjectPtr,

    object_get_instance_binding: ?*const fn (GDExtensionObjectPtr, ?*anyopaque, [*c]const GDExtensionInstanceBindingCallbacks) callconv(.C) ?*anyopaque,
    object_set_instance_binding: ?*const fn (GDExtensionObjectPtr, ?*anyopaque, ?*anyopaque, [*c]const GDExtensionInstanceBindingCallbacks) callconv(.C) void,

    object_set_instance: ?*const fn (GDExtensionObjectPtr, GDExtensionConstStringNamePtr, GDExtensionClassInstancePtr) callconv(.C) void,

    object_cast_to: ?*const fn (GDExtensionConstObjectPtr, ?*anyopaque) callconv(.C) GDExtensionObjectPtr,
    object_get_instance_from_id: ?*const fn (GDObjectInstanceID) callconv(.C) GDExtensionObjectPtr,
    object_get_instance_id: ?*const fn (GDExtensionConstObjectPtr) callconv(.C) GDObjectInstanceID,

    ref_get_object: ?*const fn (GDExtensionConstRefPtr) callconv(.C) GDExtensionObjectPtr,
    ref_set_object: ?*const fn (GDExtensionRefPtr, GDExtensionObjectPtr) callconv(.C) void,

    script_instance_create: ?*const fn ([*c]const GDExtensionScriptInstanceInfo, GDExtensionScriptInstanceDataPtr) callconv(.C) GDExtensionScriptInstancePtr,

    classdb_construct_object: ?*const fn (GDExtensionConstStringNamePtr) callconv(.C) GDExtensionObjectPtr,
    classdb_get_method_bind: ?*const fn (GDExtensionConstStringNamePtr, GDExtensionConstStringNamePtr, GDExtensionInt) callconv(.C) GDExtensionMethodBindPtr,
    classdb_get_class_tag: ?*const fn (GDExtensionConstStringNamePtr) callconv(.C) ?*anyopaque,

    classdb_register_extension_class: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr, GDExtensionConstStringNamePtr, [*c]const GDExtensionClassCreationInfo) callconv(.C) void,
    classdb_register_extension_class_method: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr, [*c]const GDExtensionClassMethodInfo) callconv(.C) void,
    classdb_register_extension_class_integer_constant: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr, GDExtensionConstStringNamePtr, GDExtensionConstStringNamePtr, GDExtensionInt, GDExtensionBool) callconv(.C) void,
    classdb_register_extension_class_property: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr, [*c]const GDExtensionPropertyInfo, GDExtensionConstStringNamePtr, GDExtensionConstStringNamePtr) callconv(.C) void,
    classdb_register_extension_class_property_group: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr, GDExtensionConstStringPtr, GDExtensionConstStringPtr) callconv(.C) void,
    classdb_register_extension_class_property_subgroup: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr, GDExtensionConstStringPtr, GDExtensionConstStringPtr) callconv(.C) void,
    classdb_register_extension_class_signal: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr, GDExtensionConstStringNamePtr, [*c]const GDExtensionPropertyInfo, GDExtensionInt) callconv(.C) void,
    classdb_unregister_extension_class: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionConstStringNamePtr) callconv(.C) void,

    get_library_path: ?*const fn (GDExtensionClassLibraryPtr, GDExtensionStringPtr) callconv(.C) void,
};

pub const GDExtensionInitializationLevel = enum(c_uint) {
    GDEXTENSION_INITIALIZATION_CORE,
    GDEXTENSION_INITIALIZATION_SERVERS,
    GDEXTENSION_INITIALIZATION_SCENE,
    GDEXTENSION_INITIALIZATION_EDITOR,
    GDEXTENSION_MAX_INITIALIZATION_LEVEL,
};

pub const GDExtensionInitialization = extern struct {
    minimum_initialization_level: GDExtensionInitializationLevel,

    userdata: ?*anyopaque,

    initialize: ?*const fn (?*anyopaque, GDExtensionInitializationLevel) callconv(.C) void,
    deinitialize: ?*const fn (?*anyopaque, GDExtensionInitializationLevel) callconv(.C) void,
};

pub const GDExtensionInitializationFunction = ?*const fn ([*c]const GDExtensionInterface, GDExtensionClassLibraryPtr, [*c]GDExtensionInitialization) callconv(.C) GDExtensionBool;
