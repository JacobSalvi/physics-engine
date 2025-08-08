const std = @import("std");
const Contact = @import("contacts.zig").Contact;

const CollisionData = struct { contacts: std.ArrayList(Contact), contactsLeft: usize };
