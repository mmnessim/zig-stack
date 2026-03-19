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

// fn get() !void {
//     var writer_buffer: [8 * 1024]u8 = undefined;
//     var redirect_buffer: [8 * 1024]u8 = undefined;

//     var writer = std.fs.File.stdout().writer(&writer_buffer);

//     var gpa: std.heap.DebugAllocator(.{}) = .init;
//     defer _ = gpa.deinit();
//     const allocator = gpa.allocator();

//     const uri = try std.Uri.parse("https://mnessim.com");

//     var client: std.http.Client = .{ .allocator = allocator };
//     defer client.deinit();

//     const result = try client.fetch(.{
//         .location = .{ .uri = uri },
//         .method = .GET,
//         .redirect_buffer = &redirect_buffer,
//         .response_writer = &writer.interface,
//     });

//     // _ = result;
//     try writer.interface.flush();
//     std.debug.print("{d}\n", .{result.status});
// }
