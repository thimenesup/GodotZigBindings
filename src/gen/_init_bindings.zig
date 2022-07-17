const Object = @import("object.zig").Object;
const Node = @import("node.zig").Node;
const Node2D = @import("node2d.zig").Node2D;

pub fn initBindings() void {
    Object.initBindings();
    Node.initBindings();
    Node2D.initBindings();
}
