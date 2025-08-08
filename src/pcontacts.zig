const std = @import("std");
const ArrayList = std.ArrayList;
const Particle = @import("particle.zig").Particle;
const Vector3 = @import("core.zig").Vector3;

const ParticleContact = struct {
    particle1: Particle,
    particle2: ?Particle,
    restitution: f32,
    contactNormal: Vector3,

    penetration: f32,

    pub fn resolve(self: ParticleContact, duration: f32) void {
        ParticleContact.resolveVelocity(self, duration);
        ParticleContact.resolveInterpenetration(self, duration);
    }

    pub fn calculateSeparatingVelocity(self: ParticleContact) f32 {
        var relativeVelocity = self.particle1.velocity;
        if (self.particle2) |val| {
            relativeVelocity = Vector3.sub(relativeVelocity, val.velocity);
        }
        return Vector3.scalarProduct(relativeVelocity, self.contactNormal);
    }

    pub fn resolveVelocity(self: ParticleContact, duration: f32) void {
        // Find the velocity in the direction of the contact.
        const separatingVelocity = calculateSeparatingVelocity();
        // Check whether it needs to be resolved.
        if (separatingVelocity > 0) {
            // The contact is either separating or stationary - there’s
            // no impulse required.
            return;
        }

        // Calculate the new separating velocity.
        var newSepVelocity = -separatingVelocity * self.restitution;
        // Check the velocity build-up due to acceleration only.
        var accCausedVelocity = self.particle1.acceleration;
        if (self.particle2) |val| {
            accCausedVelocity = Vector3.sub(accCausedVelocity, val.acceleration);
        }
        const accCausedSepVelocity = accCausedVelocity * self.contactNormal * duration;
        // If we’ve got a closing velocity due to acceleration build-up,
        // remove it from the new separating velocity.
        if (accCausedSepVelocity < 0) {
            newSepVelocity += self.restitution * accCausedSepVelocity;
            // Make sure we haven’t removed more than was
            // there to remove.
            if (newSepVelocity < 0) newSepVelocity = 0;
        }

        const deltaVelocity = newSepVelocity - separatingVelocity;
        // We apply the change in velocity to each object in proportion to
        // its inverse mass (i.e., those with lower inverse mass [higher
        // actual mass] get less change in velocity).
        var totalInverseMass = self.particle1.inverseMass;
        if (self.particle2) |val| {
            totalInverseMass += val.inverseMass;
        }
        // If all particles have infinite mass, then impulses have no effect.
        if (totalInverseMass <= 0) {
            return;
        }
        // Calculate the impulse to apply.
        const impulse = deltaVelocity / totalInverseMass;
        // Find the amount of impulse per unit of inverse mass.
        const impulsePerIMass = Vector3.scalarProduct(self.contactNormal, impulse);
        // Apply impulses: they are applied in the direction of the contact,
        // and are proportional to the inverse mass.
        self.particle1.velocity = Vector3(self.particle1.velocity, impulsePerIMass * self.particle1.inverseMass);

        if (self.particle2) |val| {
            val.velocity = Vector3(val.velocity, impulsePerIMass * val.inverseMass);
        }
        // --
    }

    pub fn resolveInterpenetration(self: ParticleContact, _: f32) void {
        // If we don’t have any penetration, skip this step.
        if (self.penetration <= 0) {
            return;
        }
        // The movement of each object is based on its inverse mass, so
        // total that.
        var totalInverseMass = self.particle1.inverseMass;
        if (self.particle2) |val| {
            totalInverseMass += val.inverseMass;
        }
        // If all particles have infinite mass, then we do nothing.
        if (totalInverseMass <= 0) {
            return;
        }
        // Find the amount of penetration resolution per unit of inverse mass.
        const movePerIMass = Vector3.scalarProduct(self.contactNormal, (-self.penetration / totalInverseMass));
        // Apply the penetration resolution.
        self.particle1.position = Vector3.scalarProduct(self.particle1.position, movePerIMass * self.particle1.inverseMass);
        if (self.particle2) |val| {
            val.position = Vector3.scalarProduct(val.position, movePerIMass * val.inverseMass);
        }
    }
};

const ParticleContactReselver = struct {
    iterations: usize,
    iterationsUsed: usize,
    pub fn resolveContacts(self: ParticleContactReselver, contacts: std.ArrayList(ParticleContact), duration: f32) void {
        var iterationsUsed: usize = 0;
        while (iterationsUsed < self.iterations) {
            var max = 0;
            var maxIndex = 0;
            for (contacts, 0..) |val, i| {
                const sepVel = ParticleContact.calculateSeparatingVelocity(val);
                if (sepVel < max) {
                    max = sepVel;
                    maxIndex = i;
                }
            }

            // Resolve this contact.
            ParticleContact.resolve(contacts.items[maxIndex], duration);
            iterationsUsed += 1;
        }
    }
};

const ParticleContactGenerator = struct {
    pub fn addContact(contact: ParticleContact, limit: usize) void {}
};
