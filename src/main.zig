const std = @import("std");
const lib = @import("lib");

pub fn main() !void {
    var s = lib.Stack{};
    try s.push(10);
    try s.push(20);

    const a = try s.pop();
    const b = try s.pop();
    try s.push(a + b);

    const res = try s.peek();
    std.debug.print("Top: {}\n", .{res});
    try lib.Repl.repl();
}
