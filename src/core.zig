const math = @import("math");
const Vector3 = @import("raylib").Vector3;

pub fn add_scaled_vector(v1: Vector3, v2: Vector3, scale: f32) Vector3 {
    return Vector3.add(v1, Vector3.scale(v2, scale));
}

pub fn component_product(v1: Vector3, v2: Vector3) Vector3 {
    return Vector3{ v1.x * v2.x, v1.y * v2.y, v1.z * v2.z };
}
