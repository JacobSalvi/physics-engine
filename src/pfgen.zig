const std = @import("std");
const math = @import("math");

const Particle = @import("particle.zig").Particle;

const Vector3 = @import("core.zig").Vector3;

const ParticleForceGenerator = struct {
    ctx: *anyopaque,
    updateForceFn: fn (ctx: *anyopaque, p: *Particle, duration: f32) void,

    pub fn updateForce(self: ParticleForceGenerator, p: *Particle, dt: f32) void {
        self.updateForceFn(self.ctx, p, dt);
    }
};

const ParticleForceRegistry = struct {
    registry: std.ArrayList(.{ Particle, ParticleForceGenerator }),

    pub fn add(self: ParticleForceRegistry, particle: Particle, fg: ParticleForceGenerator) void {
        self.registry.append(.{ particle, fg });
    }

    pub fn remove(self: ParticleForceRegistry, particle: Particle, fg: ParticleForceGenerator) void {
        for (self.registry.items, 0..) |item, i| {
            if (item == .{ particle, fg }) {
                self.registry.swapRemove(i);
                break;
            }
        }
    }

    pub fn clear(self: ParticleForceRegistry) void {
        self.registry.clearAndFree();
    }

    pub fn updateForces(self: ParticleForceRegistry, duration: f32) void {
        for (self.registry.items) |item| {
            // item.updateForces(self: ParticleForceRegistry, duration: f32).;
            item;
            duration;
            item[1].updateForce(&item[0], duration);
        }
    }
};

fn addGravity(gravity: Vector3, p: *Particle, _: f32) void {
    if (!Particle.hasFiniteMass()) {
        return;
    }
    Particle.addForce(p, gravity * p.mass);
}

const ParticleGravity = ParticleForceGenerator{ .ctx = .{
    .ctx = Vector3{ 0, -10, 0 },
}, .updateForceFn = addGravity };

fn addDrag(ctx: struct { f32, f32 }, p: *Particle, _: f32) void {
    const force = p.velocity;
    var dragCoeff = Vector3.magnitude(force);
    dragCoeff = ctx[0] * dragCoeff + ctx[1] * dragCoeff * dragCoeff;
    const normalizedForce = Vector3.normalize(force);
    const inverted = Vector3.scalar_mul(normalizedForce, dragCoeff);
    Particle.addForce(p, inverted);
}

const ParticleDrag = ParticleForceGenerator{ .ctx = .{}, .updateForceFn = addDrag };

fn addSpringSimple(ctx: .{ Particle, f32, f32 }, p: *Particle, _: f32) void {
    var force = p.position;
    force = Vector3.sub(force, ctx[0]);

    var magnitude = Vector3.magnitude(force);
    magnitude = math.abs(magnitude - ctx[1]);
    magnitude *= ctx[2];

    var normalized = Vector3.normalize(force);
    normalized = Vector3.scalar_mul(normalized, -magnitude);
    p.addForce(normalized);
}
