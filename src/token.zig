const std = @import("std");

pub const Value = union(enum) {
    number: i64,
    string: []const u8,
    boolean: bool,
};

pub const Token = union(enum) {
    value: Value,
    word: []const u8,
    eof,
};

pub fn tokenize(input: []const u8, allocator: std.mem.Allocator) ![]Token {
    var tokens = try std.ArrayList(Token).initCapacity(allocator, 20);

    var parts = std.mem.splitAny(u8, input, " ");
    while (parts.next()) |part| {
        if (std.fmt.parseInt(i64, part, 10)) |n| {
            try tokens.append(allocator, .{ .value = .{ .number = n } });
        } else |_| {
            try tokens.append(allocator, .{ .word = part });
        }
    }
    try tokens.append(allocator, Token{ .eof = {} });
    return try tokens.toOwnedSlice(allocator);
}
