const rl = @import("raylib");
const p = @import("particle.zig");
const ballistic = @import("demo/ballistic.zig");
const std = @import("std");

pub fn main() anyerror!void {
    const screenWidth = 1280;
    const screenHeight = 640;
    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    var b = ballistic.BallisticDemo.new();

    // Main game loop
    while (!rl.windowShouldClose()) {
        const delta = rl.getFrameTime();
        b.key();
        b.mouse();
        b.update(delta);

        rl.beginDrawing();
        rl.clearBackground(.white);
        b.display();
        defer rl.endDrawing();
    }
}
