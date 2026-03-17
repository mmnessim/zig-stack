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
    .{ "mod", &opMod },
    .{ "=", &opEq },
    .{ "<", &opLessThan },
    .{ "<=", &opLessThanEq },
    .{ ">", &opGreaterThan },
    .{ ">=", &opGreaterThanEq },
    .{ "!=", &opNotEq },
    .{ ".", &opDot },
    .{ "dup", &opDup },
    .{ "swap", &opSwap },
    .{ "drop", &opDrop },
    .{ "over", &opOver },
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

fn opDrop(vm: *VM) !void {
    _ = try vm.stack.pop();
}

fn opOver(vm: *VM) !void {
    if (vm.stack.top < 2) return error.StackUnderflow;
    try vm.stack.push(vm.stack.items[vm.stack.top - 2]);
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
    try vm.stack.push(y + x);
}

fn opSubtract(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(y - x);
}

fn opMult(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(x * y);
}

fn opDiv(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(@divTrunc(y, x));
}

fn opMod(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(@rem(y, x));
}

fn opEq(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    const res: i64 = if (y == x) 1 else 0;
    try vm.stack.push(res);
}

fn opLessThan(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    const res: i64 = if (y < x) 1 else 0;
    try vm.stack.push(res);
}

fn opGreaterThan(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    const res: i64 = if (x > y) 1 else 0;
    try vm.stack.push(res);
}

fn opLessThanEq(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    const res: i64 = if (y <= x) 1 else 0;
    try vm.stack.push(res);
}

fn opGreaterThanEq(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    const res: i64 = if (y >= x) 1 else 0;
    try vm.stack.push(res);
}

fn opNotEq(vm: *VM) !void {
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    const res: i64 = if (y != x) 1 else 0;
    try vm.stack.push(res);
}
