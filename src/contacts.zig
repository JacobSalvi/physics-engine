const Vector3 = @import("core.zig").Vector3;

const Contact = struct { contactPoint: Vector3, contactNormal: Vector3, penetration: f32 };
