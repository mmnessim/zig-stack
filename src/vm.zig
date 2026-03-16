const std = @import("std");
const Stack = @import("stack.zig").Stack;

pub const VM = struct {
    stack: Stack = Stack{},
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) VM {
        return .{ .allocator = allocator };
    }
};

// pub const Word = struct {
//     literal: []const u8,
//     block: *const fn (*VM) anyerror!void,
// };
