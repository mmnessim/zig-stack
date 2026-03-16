const std = @import("std");
const lib = @import("lib");
const repl = lib.Repl.repl();
const VM = lib.VM;

pub fn main() !void {
    var s = lib.Stack{};
    try s.push(10);
    try s.push(20);

    const a = try s.pop();
    const b = try s.pop();
    try s.push(a + b);

    const res = try s.peek();
    std.debug.print("Top: {}\n", .{res});
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var vm = VM{ .allocator = allocator };
    try lib.Repl.repl(&vm);
}
