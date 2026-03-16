const std = @import("std");

pub const Stack = struct {
    items: [256]i64 = undefined,
    top: usize = 0, // next position to be filled

    pub fn push(self: *Stack, val: i64) !void {
        if (self.top >= self.items.len) return error.StackOverflow;
        self.items[self.top] = val;
        self.top += 1;
    }

    pub fn pop(self: *Stack) !i64 {
        if (self.top == 0) return error.StackUnderflow;
        self.top -= 1;
        return self.items[self.top];
    }

    pub fn peek(self: *Stack) !i64 {
        if (self.top == 0) return error.StackUnderflow;
        return self.items[self.top - 1];
    }

    pub fn swap(self: *Stack) !void {
        if (self.top < 2) return error.StackUnderflow;
        std.mem.swap(i64, &self.items[self.top - 1], &self.items[self.top - 2]);
    }

    pub fn add(self: *Stack) !void {
        if (self.top < 1) return error.StackUnderflow;
        const x = try self.pop();
        const y = try self.pop();
        try self.push(x + y);
    }

    pub fn print_stack(self: *Stack) !void {
        if (self.top == 0) return;
        for (self.items[0..self.top]) |item| {
            std.debug.print("{} ", .{item});
        }
        std.debug.print("\n", .{});
    }
};

test "push and pop" {
    var s = Stack{};
    try s.push(100);
    try std.testing.expectEqual(@as(i64, 100), try s.pop());
}

test "stack overflow" {
    var s = Stack{};
    for (0..256) |i| try s.push(@intCast(i));
    try std.testing.expectError(error.StackOverflow, s.push(100));
}

test "stack underflow" {
    var s = Stack{};
    try std.testing.expectError(error.StackUnderflow, s.pop());
}

test "swap" {
    var s = Stack{};
    try s.push(1); //
    try s.push(2); //
    try s.swap(); //
    try std.testing.expectEqual(@as(i64, 1), try s.pop());
    try std.testing.expectEqual(@as(i64, 2), try s.pop());
}
