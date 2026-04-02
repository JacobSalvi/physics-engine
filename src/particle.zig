const core = @import("core.zig");
const std = @import("std");
const math = std.math;
const Vector3 = @import("raylib").Vector3;

pub const Particle = struct {
    position: Vector3,
    velocity: Vector3,
    acceleration: Vector3,
    damp: f32,
    inverseMass: f32,
    forceAccum: Vector3,

    pub fn integrate(self: *Particle, duration: f32) void {
        std.debug.assert(duration > 0);
        self.position = core.add_scaled_vector(self.position, self.velocity, duration);
        var resultingAcc = self.acceleration;
        resultingAcc = core.add_scaled_vector(resultingAcc, self.forceAccum, self.inverseMass);
        self.velocity = core.add_scaled_vector(self.velocity, resultingAcc, duration);
        self.velocity = Vector3.scale(self.velocity, math.pow(f32, self.damp, duration));
        self.clearAccumulator();
    }

    pub fn setMass(self: *Particle, mass: f32) void {
        self.inverseMass = 1.0 / mass;
    }

    pub fn clearAccumulator(self: *Particle) void {
        self.forceAccum = .{ .x = 0, .y = 0, .z = 0 };
    }

    // pub fn addForce(self: Particle, force: Vector3) Particle {
    //     const accumulated = Vector3.add(self.forceAccum, force);
    //     self.forceAccum = accumulated;
    //     return self;
    // }
};
