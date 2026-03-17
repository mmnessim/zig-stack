const std = @import("std");

const lib = @import("lib");
const VM = lib.VM;

const repl = lib.Repl.repl();
pub fn main() !void {
    var gpa = std.heap.DebugAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var vm = VM{ .allocator = allocator };
    try lib.Repl.repl(&vm);
}
