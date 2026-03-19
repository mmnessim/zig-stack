const std = @import("std");
const eql = std.mem.eql;

const Stack = @import("stack.zig").Stack;
const Token = @import("token.zig").Token;
const Value = @import("token.zig").Value;

pub const VM = struct {
    stack: Stack = Stack{},
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) VM {
        return .{ .allocator = allocator };
    }

    pub fn eval(self: *VM, tokens: []Token) !void {
        for (tokens) |tok| {
            switch (tok) {
                .value => |v| {
                    try self.stack.push(v);
                },
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
    std.debug.print("{f}\n", .{try vm.stack.pop()});
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
    if (vm.stack.top < 2) return error.StackUnderflow;
    try vm.stack.swap();
}

fn opClear(vm: *VM) !void {
    vm.stack.top = 0;
}

fn opAdd(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .number = v.y + v.x });
}

fn opSubtract(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .number = v.y + v.x });
}

fn opMult(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .number = v.y * v.x });
}

fn opDiv(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .number = @divTrunc(v.y, v.x) });
}

fn opMod(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .number = @rem(v.y, v.x) });
}

fn opEq(vm: *VM) !void {
    if (vm.stack.top < 2) return error.StackUnderflow;
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(Value{ .boolean = std.meta.eql(x, y) });
}

fn opLessThan(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .boolean = v.y < v.x });
}

fn opGreaterThan(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .boolean = v.y > v.x });
}

fn opLessThanEq(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .boolean = v.y <= v.x });
}

fn opGreaterThanEq(vm: *VM) !void {
    const v = try popTwo(vm, i64);
    try vm.stack.push(Value{ .boolean = v.y <= v.x });
}

fn opNotEq(vm: *VM) !void {
    if (vm.stack.top < 2) return error.StackUnderflow;
    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    try vm.stack.push(Value{ .boolean = !std.meta.eql(x, y) });
}

fn popTwo(vm: *VM, comptime T: type) !struct { x: T, y: T } {
    if (vm.stack.top < 2) return error.StackUnderflow;

    const x = try vm.stack.pop();
    const y = try vm.stack.pop();
    switch (T) {
        i64 => {
            if (x != .number or y != .number) return error.TypeError;
            return .{ .x = x.number, .y = y.number };
        },
        []const u8 => {
            if (x != .string or y != .string) return error.TypeError;
            return .{ .x = x.string, .y = y.string };
        },
        else => @compileError("unsupported type"),
    }
}
