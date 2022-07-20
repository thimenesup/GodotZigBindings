pub const Wrapped = @import("wrapped.zig").Wrapped;
pub const Variant = @import("variant.zig").Variant;
pub const AABB = @import("aabb.zig").AABB;
pub const Basis = @import("basis.zig").Basis;
pub const Plane = @import("plane.zig").Plane;
pub const Quat = @import("quat.zig").Quat;
pub const Rect2 = @import("rect2.zig").Rect2;
pub const Transform = @import("transform.zig").Transform;
pub const Transform2D = @import("transform2d.zig").Transform2D;
pub const Vector2 = @import("vector2.zig").Vector2;
pub const Vector3 = @import("vector3.zig").Vector3;
pub const Color = @import("color.zig").Color;
pub const NodePath = @import("node_path.zig").NodePath;
pub const RID = @import("rid.zig").RID;
pub const Dictionary = @import("dictionary.zig").Dictionary;
pub const Array = @import("array.zig").Array;
pub const String = @import("string.zig").String;
pub const PoolArrays = @import("pool_arrays.zig");
pub const PoolByteArray = PoolArrays.PoolByteArray;
pub const PoolIntArray = PoolArrays.PoolIntArray;
pub const PoolRealArray = PoolArrays.PoolRealArray;
pub const PoolStringArray = PoolArrays.PoolStringArray;
pub const PoolVector2Array = PoolArrays.PoolVector2Array;
pub const PoolVector3Array = PoolArrays.PoolVector3Array;
pub const PoolColorArray = PoolArrays.PoolColorArray;

pub const Error = enum(i64) {
    OK,
    FAILED, //< Generic fail error
    ERR_UNAVAILABLE, //< What is requested is unsupported/unavailable
    ERR_UNCONFIGURED, //< The object being used hasnt been properly set up yet
    ERR_UNAUTHORIZED, //< Missing credentials for requested resource
    ERR_PARAMETER_RANGE_ERROR, //< Parameter given out of range (5)
    ERR_OUT_OF_MEMORY, //< Out of memory
    ERR_FILE_NOT_FOUND,
    ERR_FILE_BAD_DRIVE,
    ERR_FILE_BAD_PATH,
    ERR_FILE_NO_PERMISSION, // (10)
    ERR_FILE_ALREADY_IN_USE,
    ERR_FILE_CANT_OPEN,
    ERR_FILE_CANT_WRITE,
    ERR_FILE_CANT_READ,
    ERR_FILE_UNRECOGNIZED, // (15)
    ERR_FILE_CORRUPT,
    ERR_FILE_MISSING_DEPENDENCIES,
    ERR_FILE_EOF,
    ERR_CANT_OPEN, //< Can't open a resource/socket/file
    ERR_CANT_CREATE, // (20)
    ERR_QUERY_FAILED,
    ERR_ALREADY_IN_USE,
    ERR_LOCKED, //< resource is locked
    ERR_TIMEOUT,
    ERR_CANT_CONNECT, // (25)
    ERR_CANT_RESOLVE,
    ERR_CONNECTION_ERROR,
    ERR_CANT_AQUIRE_RESOURCE,
    ERR_CANT_FORK,
    ERR_INVALID_DATA, //< Data passed is invalid	(30)
    ERR_INVALID_PARAMETER, //< Parameter passed is invalid
    ERR_ALREADY_EXISTS, //< When adding, item already exists
    ERR_DOES_NOT_EXIST, //< When retrieving/erasing, it item does not exist
    ERR_DATABASE_CANT_READ, //< database is full
    ERR_DATABASE_CANT_WRITE, //< database is full	(35)
    ERR_COMPILATION_FAILED,
    ERR_METHOD_NOT_FOUND,
    ERR_LINK_FAILED,
    ERR_SCRIPT_FAILED,
    ERR_CYCLIC_LINK, // (40)
    ERR_INVALID_DECLARATION,
    ERR_DUPLICATE_SYMBOL,
    ERR_PARSE_ERROR,
    ERR_BUSY,
    ERR_SKIP, // (45)
    ERR_HELP, //< user requested help!!
    ERR_BUG, //< a bug in the software certainly happened, due to a double check failing or unexpected behavior.
    ERR_PRINTER_ON_FIRE, // the parallel port printer is engulfed in flames
    ERR_OMFG_THIS_IS_VERY_VERY_BAD, // (49) //< shit happens, has never been used, though
    ERR_WTF = 49, //ERR_OMFG_THIS_IS_VERY_VERY_BAD //< short version of the above
};
