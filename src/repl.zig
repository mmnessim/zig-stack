const std = @import("std");

const Stack = @import("stack.zig").Stack;
const tokenize = @import("token.zig").tokenize;
const VM = @import("vm.zig").VM;

pub fn repl(vm: *VM) !void {
    const s = Stack{};
    vm.stack = s;

    var stdout_buf: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    const stdout: *std.Io.Writer = &stdout_writer.interface;

    var stdin_buf: [1024]u8 = undefined;
    var stdin_reader = std.fs.File.stdin().reader(&stdin_buf);
    const stdin: *std.Io.Reader = &stdin_reader.interface;

    while (true) {
        defer stdout.flush() catch {};

        try stdout.writeAll("> ");
        try stdout.flush();

        const bare_line = try stdin.takeDelimiter('\n') orelse break;
        const trimmed = std.mem.trim(u8, bare_line, "\r \t");

        if (trimmed.len == 0) {
            try vm.stack.print_stack(stdout);
            continue;
        }
        const tokens = try tokenize(trimmed, vm.allocator);
        defer vm.allocator.free(tokens);
        vm.eval(tokens) catch |err| {
            std.debug.print("{}\n", .{err});
            continue;
        };
        try vm.stack.print_stack(stdout);
    }
}
