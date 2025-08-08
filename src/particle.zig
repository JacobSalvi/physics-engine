const core = @import("core.zig");
const Vector3 = core.Vector3;
const std = @import("std");
const math = @import("math");

const Particle = struct {
    position: Vector3,
    velocity: Vector3,
    acceleration: Vector3,
    damp: f32,
    inverseMass: f32,
    forceAccum: Vector3,

    pub fn integrate(self: Particle, duration: f32) Particle {
        std.debug.assert(duration > 0);
        const position = Vector3.addScaled(self.position, self.velocity, duration);
        var resultingAcc = self.acceleration;
        resultingAcc = Vector3.addScaled(resultingAcc, self.forceAccum, self.inverseMass);
        var velocity = Vector3.addScaled(self.velocity, resultingAcc, duration);
        velocity = Vector3.scalar_mul(velocity, math.pow(self.damp, duration));
        return Particle{ position, velocity, self.acceleration, self.damp, self.inverseMass, .{} };
    }

    pub fn clearAccumulator(self: Particle) Particle {
        self.forceAccum = .{};
        return self;
    }

    pub fn addForce(self: Particle, force: Vector3) Particle {
        const accumulated = Vector3.add(self.forceAccum, force);
        self.forceAccum = accumulated;
        return self;
    }
};
