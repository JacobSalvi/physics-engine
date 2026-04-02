const ParticleModule = @import("../particle.zig");
const Particle = ParticleModule.Particle;
const raylib = @import("raylib");
const Vector3 = @import("raylib").Vector3;

const ShotType = enum(u8) { UNUSED, PISTOL, ARTILLERY, FIREBALL, LASER };

const AmmoRound = struct {
    particle: Particle,
    type: ShotType,
    startTime: f64,

    pub fn render(self: *const AmmoRound) void {
        // assumes inside BeginMode3D() ... EndMode3D()
        const position = self.particle.position;
        raylib.drawSphere(.{ .x = position.x, .y = position.y, .z = position.z }, 0.3, raylib.Color.black);

        // gray flattened “shadow” at ground (y = 0)
        raylib.drawCylinder(Vector3{ .x = position.x, .y = 0, .z = position.z }, 0.6, 0.6, 0.1, 16, raylib.Color.light_gray);
    }
};

pub const BallisticDemo = struct {
    const ammoRounds = 16;
    ammo: [ammoRounds]AmmoRound,
    currentShotType: ShotType,

    pub fn new() BallisticDemo {
        var b = BallisticDemo{ .currentShotType = ShotType.UNUSED, .ammo = [_]AmmoRound{undefined} ** ammoRounds };
        for (&b.ammo) |*a| {
            a.type = ShotType.UNUSED;
        }
        return b;
    }

    fn fire(self: *BallisticDemo) void {
        const shot: *AmmoRound = for (&self.ammo) |*a| {
            if (a.type == ShotType.UNUSED) {
                break a;
            }
        } else {
            return;
        };

        switch (self.currentShotType) {
            ShotType.PISTOL => {
                shot.particle.setMass(2.0);
                shot.particle.velocity = Vector3{ .x = 0, .y = 0, .z = 35 };
                shot.particle.acceleration = Vector3{ .x = 0, .y = -1, .z = 0 };
                shot.particle.damp = 0.99;
            },
            ShotType.ARTILLERY => {
                shot.particle.setMass(200.0);
                shot.particle.velocity = Vector3{ .x = 0, .y = 30, .z = 40 };
                shot.particle.acceleration = Vector3{ .x = 0, .y = -20, .z = 0 };
                shot.particle.damp = 0.99;
            },
            ShotType.FIREBALL => {
                shot.particle.setMass(1.0);
                shot.particle.velocity = Vector3{ .x = 0, .y = 0, .z = 10 };
                shot.particle.acceleration = Vector3{ .x = 0, .y = 0.6, .z = 0 };
                shot.particle.damp = 0.9;
            },
            ShotType.LASER => {
                shot.particle.setMass(0.1);
                shot.particle.velocity = Vector3{ .x = 0, .y = 0, .z = 100 };
                shot.particle.acceleration = Vector3{ .x = 0, .y = 0, .z = 0 };
                shot.particle.damp = 0.99;
            },
            ShotType.UNUSED => {},
        }

        shot.particle.position = Vector3{ .x = 0, .y = 1.5, .z = 0 };
        // timing
        shot.startTime = raylib.getTime();
        shot.type = self.currentShotType;
        shot.particle.clearAccumulator();
    }

    pub fn update(self: *BallisticDemo, duration: f32) void {
        if (duration < 0) {
            return;
        }

        for (&self.ammo) |*ammo| {
            if (ammo.type == ShotType.UNUSED) {
                continue;
            }
            (&ammo.particle).integrate(duration);
            if (ammo.particle.position.y < 0 or ammo.particle.position.z > 200 or ammo.startTime + 5.0 < raylib.getTime()) {
                ammo.type = ShotType.UNUSED;
            }
        }
    }

    pub fn display(self: *const BallisticDemo) void {
        const camera = raylib.Camera3D{
            .position = .{ .x = -25.0, .y = 8.0, .z = 5.0 },
            .target = .{ .x = 0.0, .y = 5.0, .z = 22.0 },
            .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
            .fovy = 60.0,
            .projection = raylib.CameraProjection.perspective,
        };

        raylib.beginMode3D(camera);
        defer raylib.endMode3D();

        // Firing point sphere
        raylib.drawSphere(.{ .x = 0.0, .y = 1.5, .z = 0.0 }, 0.1, raylib.Color.black);

        // "Shadow" (flattened sphere)
        raylib.drawSphere(.{ .x = 0.0, .y = 0.1, .z = 0.0 }, 0.1, raylib.Color.gray);

        // Scale lines
        var i: u32 = 0;
        while (i < 200) : (i += 10) {
            raylib.drawLine3D(
                .{ .x = -5.0, .y = 0.0, .z = @floatFromInt(i) },
                .{ .x = 5.0, .y = 0.0, .z = @floatFromInt(i) },
                raylib.Color.gray,
            );
        }

        // Render particles
        for (&self.ammo) |*shot| {
            if (shot.type != .UNUSED) {
                shot.render();
            }
        }

        raylib.endMode3D();

        // UI text
        raylib.drawText("Click: Fire\n1-4: Select Ammo", 10, 34, 20, raylib.Color.black);

        const label = switch (self.currentShotType) {
            .PISTOL => "Current Ammo: Pistol",
            .ARTILLERY => "Current Ammo: Artillery",
            .FIREBALL => "Current Ammo: Fireball",
            .LASER => "Current Ammo: Laser",
            .UNUSED => "Current Ammo: error",
        };

        raylib.drawText(label, 10, 10, 20, raylib.Color.black);
    }

    pub fn mouse(self: *BallisticDemo) void {
        // Mouse input
        if (raylib.isMouseButtonPressed(raylib.MouseButton.left)) {
            self.fire();
        }
    }

    pub fn key(self: *BallisticDemo) void {
        self.currentShotType = switch (raylib.getKeyPressed()) {
            raylib.KeyboardKey.one => .PISTOL,
            raylib.KeyboardKey.two => .ARTILLERY,
            raylib.KeyboardKey.three => .FIREBALL,
            raylib.KeyboardKey.four => .LASER,
            else => self.currentShotType,
        };
    }
};
