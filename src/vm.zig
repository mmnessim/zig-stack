const std = @import("std");
const eql = std.mem.eql;

const Stack = @import("stack.zig").Stack;
const Token = @import("token.zig").Token;

pub const VM = struct {
    stack: Stack = Stack{},
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) VM {
        return .{ .allocator = allocator };
    }

    pub fn eval(self: *VM, tokens: []Token) !void {
        for (tokens) |tok| {
            switch (tok) {
                .number => |n| try self.stack.push(n),
                .word => |w| try self.execWord(w),
                .eof => break,
            }
        }
    }

    pub fn execWord(self: *VM, word: []const u8) !void {
        if (eql(u8, word, "+")) {
            const x = try self.stack.pop();
            const y = try self.stack.pop();
            try self.stack.push(x + y);
        } else {
            return error.unknownWord;
        }
    }
};

// pub const Word = struct {
//     literal: []const u8,
//     block: *const fn (*VM) anyerror!void,
// };
