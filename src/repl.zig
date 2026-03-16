const std = @import("std");
const Stack = @import("stack.zig").Stack;

pub fn repl() !void {
    var s = Stack{};

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

        if (trimmed.len == 0) continue;
        if (std.mem.eql(u8, trimmed, "bye")) break;
        if (std.mem.eql(u8, trimmed, ".")) {
            const val = s.pop() catch |err| {
                std.debug.print("{}\n", .{err});
                continue;
            };
            try stdout.print("{}\n", .{val});
            continue;
        }

        const parsed: i64 = std.fmt.parseInt(i64, trimmed, 10) catch |err| {
            std.debug.print("{}\n", .{err});
            continue;
        };
        try s.push(parsed);
        std.debug.print("{}\n", .{try s.peek()});
    }
}
