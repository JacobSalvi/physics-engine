const std = @import("std");
const Particle = @import("particle.zig").Particle;
const ParticleContact = @import("pcontacts.zig").ParticleContact;
const ParticleForceRegistry = @import("pfgen.zig").ParticleForceRegistry;
const ParticleContactResolver = @import("pcontacts.zig").ParticleContactResolver;
const ParticleContactGenerator = @import("pcontacts.zig").ParticleContactGenerator;

const ParticleWorld = struct {
    registrations: std.DoublyLinkedList(Particle),
    registry: ParticleForceRegistry,
    resolver: ParticleContactResolver,
    firstContactGen: std.DoublyLinkedList(ParticleContactGenerator),
    contacts: std.ArrayList(ParticleContact),
    maxContacts: usize,

    pub fn startFrame(self: ParticleWorld) void {
        var reg = self.registrations.first;
        while (reg) |val| : (reg = val.next) {
            val.data.clearAccumulator();
        }
    }

    pub fn generateContacts(self: ParticleWorld) usize {
        var limit = self.maxContacts;
        var reg = self.firstContactGen.first;
        var nextContact = self.contacts.items[0];
        var index = 0;
        while (reg) |val| : (reg = val.next) {
            const used = val.data.addContact(nextContact, limit);
            index += used;
            nextContact = self.contacts.items[index];
            limit -= used;
            if (limit <= 0) {
                break;
            }
        }
        return self.maxContacts - limit;
    }

    pub fn integrate(self: ParticleWorld, duration: f32) void {
        var reg = self.registrations.first;
        while (reg) |val| : (reg = val.next) {
            reg.particle.integrate(duration);
        }
    }

    pub fn runPhysics(self: ParticleWorld, duration: f32) void {
        // First apply the force generators.
        self.registry.updateForces(duration);
        // Then integrate the objects.
        self.integrate(duration);
        // Generate contacts.
        const usedContacts = self.generateContacts();
        const calculateIterations = true;
        if (calculateIterations) {
            self.resolver.setIterations(usedContacts * 2);
        }
        self.resolver.resolveContacts(self.contacts, usedContacts, duration);
    }
};
