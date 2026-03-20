const std = @import("std");

const VM = @import("../vm.zig").VM;

pub const http_words = std.StaticStringMap(*const fn (*VM) anyerror!void).initComptime(.{
    .{ "get", &opGet },
});

fn opGet(vm: *VM) !void {
    if (vm.stack.top == 0) {
        std.debug.print("get ( url -- code response )\n", .{});
        return error.StackUnderflow;
    }
    const url = try vm.stack.pop();
    if (url != .string) {
        std.debug.print("top stack value \"{f}\" has type of \"{s}\", expected string\n", .{ url, url.typeof() });

        return error.TypeError;
    }

    var redirect_buffer: [8 * 1024]u8 = undefined;

    const uri = try std.Uri.parse(url.string);

    var client: std.http.Client = .{ .allocator = vm.allocator };
    defer client.deinit();

    var response_body = try std.ArrayList(u8).initCapacity(vm.allocator, 1024);
    defer response_body.deinit(vm.allocator);

    var writer = std.Io.Writer.Allocating.init(vm.allocator);

    const result = client.fetch(.{
        .location = .{ .uri = uri },
        .method = .GET,
        .redirect_buffer = &redirect_buffer,
        .response_writer = &writer.writer,
    }) catch |err| {
        std.debug.print("Error fetching {f}: {any}", .{ url, err });
        return;
    };

    const body = try writer.toOwnedSlice();
    try vm.stack.push(.{ .number = @intFromEnum(result.status) });
    try vm.stack.push(.{ .string = body });
}
