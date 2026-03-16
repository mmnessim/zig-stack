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
        if (builtins.get(word)) |op| {
            try op(self);
        } else {
            return error.UnknownWord;
        }
    }
};

const builtins = std.StaticStringMap(*const fn (*VM) anyerror!void).initComptime(.{
    .{ "+", &opAdd },
    .{ "-", &opSubtract },
    .{ "*", &opMult },
    .{ "/", &opDiv },
    .{ ".", &opDot },
    .{ "dup", &opDup },
    .{ "swap", &opSwap },
    .{ "clear", &opClear },
    .{ "bye", &opQuit },
});

fn opDot(vm: *VM) !void {
    std.debug.print("{}\n", .{try vm.stack.pop()});
}

fn opQuit(vm: *VM) !void {
    _ = vm; // autofix
    std.process.exit(0);
}

fn opDup(vm: *VM) !void {
    try vm.stack.push(try vm.stack.peek());
}

fn opSwap(vm: *VM) !void {
    try vm.stack.swap();
}

fn opClear(vm: *VM) !void {
    vm.stack.top = 0;
}

fn opAdd(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(x + y);
}

fn opSubtract(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(x - y);
}

fn opMult(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(x * y);
}

fn opDiv(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(@divTrunc(x, y));
}
