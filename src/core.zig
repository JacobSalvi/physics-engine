const math = @import("math");

const Vector3 = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,

    pub fn new(x: f32, y: f32, z: f32) Vector3 {
        return .{ x, y, z };
    }

    pub fn invert(self: Vector3) Vector3 {
        return .{ -self.x, -self.y, -self.z };
    }

    pub fn magnitude(self: Vector3) f32 {
        math.sqrt(self.x * self.x + self.y * self.y + self.z + self.z);
    }

    pub fn squaredMagnitude(self: Vector3) f32 {
        self.x * self.x + self.y * self.y + self.z * self.z;
    }

    pub fn normalize(self: Vector3) Vector3 {
        const l = Vector3.magnitude(self);
        if (l > 0) {
            return .{ self.x / l, self.y / l, self.z / l };
        }
        return self;
    }

    pub fn scalar_mul(self: Vector3, scalar: f32) Vector3 {
        .{ self.x * scalar, self.y * scalar, self.z * scalar };
    }

    pub fn add(self: Vector3, other: Vector3) Vector3 {
        .{ self.x + other.x, self.y + other.y, self.z + other.z };
    }

    pub fn sub(self: Vector3, other: Vector3) Vector3 {
        .{ self.x - other.x, self.y - other.y, self.z - other.z };
    }

    pub fn addScaled(self: Vector3, other: Vector3, scalar: f32) Vector3 {
        .{ self.x + other.x * scalar, self.y + other.y * scalar, self.z + other.z * scalar };
    }

    pub fn componentProduct(self: Vector3, other: Vector3) Vector3 {
        .{ self.x * other.x, self.y * other.y, self.z * other.z };
    }

    pub fn scalarProduct(self: Vector3, other: Vector3) f32 {
        .{self.x * other.x + self.y * other.y + self.z * other.z};
    }

    pub fn crossProduct(self: Vector3, other: Vector3) f32 {
        .{ self.y * other.z - self.z * other.y, self.z * other.x - self.x - other.z, self.x * other.y - self.y * other.x };
    }
};
