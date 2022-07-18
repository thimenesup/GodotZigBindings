const ClassDB = @import("../core/class_db.zig");

const typeId = @import("../core/typeid.zig").typeId;

const Object = @import("object.zig").Object;
const Node = @import("node.zig").Node;
const Node2D = @import("node2d.zig").Node2D;

pub fn registerTypes() void {
    ClassDB.registerGlobalType("Object", typeId(Object), 0);
    ClassDB.registerGlobalType("Node", typeId(Node), typeId(Object));
    ClassDB.registerGlobalType("Node2D", typeId(Node2D), typeId(Node));
}
