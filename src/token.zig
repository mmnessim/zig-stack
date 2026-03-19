const std = @import("std");

pub const Value = union(enum) {
    number: i64,
    string: []const u8,
    boolean: bool,
    pub fn format(self: Value, writer: *std.Io.Writer) !void {
        switch (self) {
            .number => |n| try writer.print("{}", .{n}),
            .string => |s| try writer.print("{s}", .{s}),
            .boolean => |b| try writer.print("{}", .{b}),
        }
    }
};

pub const Token = union(enum) {
    value: Value,
    word: []const u8,
    eof,
};
