const std = @import("std");

const Token = @import("token.zig").Token;
pub const Lexer = struct {
    input: []const u8,
    position: usize,
    allocator: std.mem.Allocator,

    pub fn tokenize(lexer: *Lexer) ![]Token {
        var tokens = try std.ArrayList(Token).initCapacity(lexer.allocator, 20);
        defer tokens.deinit(lexer.allocator);

        while (lexer.position < lexer.input.len) {
            const tok = try lexer.get_next_token();
            try tokens.append(lexer.allocator, tok);
        }
        try tokens.append(lexer.allocator, .eof);
        return try tokens.toOwnedSlice(lexer.allocator);
    }

    fn skipWhitespace(lexer: *Lexer) void {
        while (lexer.position < lexer.input.len and
            std.ascii.isWhitespace(lexer.input[lexer.position]))
        {
            lexer.position += 1;
        }
    }

    fn get_next_token(lexer: *Lexer) !Token {
        lexer.skipWhitespace();

        if (lexer.position >= lexer.input.len) return .eof;

        const current = lexer.input[lexer.position];

        switch (current) {
            '0'...'9' => {
                const start = lexer.position;
                while (lexer.position < lexer.input.len and
                    std.ascii.isDigit(lexer.input[lexer.position]))
                {
                    lexer.position += 1;
                }
                const num = try std.fmt.parseInt(i64, lexer.input[start..lexer.position], 10);
                return .{ .value = .{ .number = num } };
            },
            '"' => {
                lexer.position += 1; // skip opening quote
                const start = lexer.position;
                while (lexer.position < lexer.input.len and lexer.input[lexer.position] != '"') {
                    lexer.position += 1;
                }
                if (lexer.position >= lexer.input.len) return error.UnterminatedString;
                const str = lexer.input[start..lexer.position];
                lexer.position += 1; // skip closing quote
                return .{ .value = .{ .string = str } };
            },
            else => {
                const start = lexer.position;
                while (lexer.position < lexer.input.len and
                    !std.ascii.isWhitespace(lexer.input[lexer.position]))
                {
                    lexer.position += 1;
                }
                return .{ .word = lexer.input[start..lexer.position] };
            },
        }
    }
};
