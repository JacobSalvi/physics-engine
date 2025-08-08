const RigidBody = @import("body.zig").RigidBody;

const PotentialContact = struct { first_body: RigidBody, second_body: RigidBody };

const BVHNode = struct {
    const Self = @This();
    first_child: BVHNode,
    second_child: BVHNode,
    // volume: BoundingVolumeClass,

    body: ?RigidBody,

    pub fn isLeaf(self: Self) bool {
        if (self.body) |_| {
            return true;
        }
        return false;
    }
};
