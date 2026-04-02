const Quaternion = @import("raylib").Quaternion;
const Matrix = @import("raylib").Matrix;
const Vector3 = @import("raylib").Vector3;

const RigidBody = struct {
    const Self = @This();
    inverseMass: f32,
    position: Vector3,
    orientation: Quaternion,
    velocity: Vector3,
    rotation: Vector3,
    transfomMatrix: Matrix,
    inverseInertialTensor: Matrix,

    forceAccum: Vector3,
    angularDamping: f32,

    fn _calculateTransformMatrix(transformMatrix: Matrix, _: Vector3, _: Quaternion) Matrix {
        // TODO: implement this.
        return transformMatrix;
    }

    pub fn calculateDerivedData(self: Self) void {
        self._calculateTransformMatrix(self.transfomMatrix, self.position, self.orientation);
    }

    pub fn addForce(self: Self, force: Vector3) void {
        self.forceAccum = Vector3.add(self.forceAccum, force);
    }

    pub fn clearAccumulators(self: Self) void {
        self.forceAccum = Vector3{};
    }

    pub fn addForceAtBodyPoint(force: Vector3, point: Vector3) void {
        // Convert to coordinates relative to the center of mass.
        const pt = getPointInWorldSpace(point);
        addForceAtPoint(force, pt);
    }
};
