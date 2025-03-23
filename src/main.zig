const std = @import("std");
const bytecode = @import("bytecode/bytecode.zig");
const interpreter = @import("bytecode/interpreter.zig");
const debug = @import("bytecode/debug.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var instance = interpreter.Interpreter{};
    @memset(&instance.registers, 0);
    defer instance.deinit(allocator);

    try instance.instructions.appendSlice(allocator, &[_]u8{
        @intFromEnum(bytecode.OpCodes.LOAD_IMMEDIATE),
        0x01, // Register 1,
        0x00, // ->
        0x01, // 0x0001
    });

    try instance.instructions.appendSlice(allocator, &[_]u8{
        @intFromEnum(bytecode.OpCodes.LOAD_IMMEDIATE),
        0x02, // Register 2,
        0x00, // ->
        0x01, // 0x0001
    });

    try instance.instructions.appendSlice(allocator, &[_]u8{
        @intFromEnum(bytecode.OpCodes.ADD),
        0x03, // dst -> r3
        0x01, // src1 -> r1
        0x02, // src2 -> r2
    });

    try instance.instructions.appendSlice(allocator, &[_]u8{
        @intFromEnum(bytecode.OpCodes.HALT),
        0x00,
        0x00,
        0x00,
    });

    // instance.dump(&allocator);
    var disasm = debug.Dissassembler{ .instructions = instance.instructions };
    const stdin = std.io.getStdIn();
    const writer = stdin.writer();

    while (disasm.has_next()) {
        try disasm.dissassembleNextInstruction(writer);
    }

    // var result: interpreter.InterpretResult = undefined;
    // while (result == .OK) {
    //     result = instance.run(&allocator);
    //     std.debug.print("Run result: {any}\n", .{result});
    // }

    // std.log.info("Program exited with: {any}\n", .{result});

    return;
}
