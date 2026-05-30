package compiler

import "core:testing"

@(test)
test_is_digit :: proc(t: ^testing.T) {
	testing.expect(t, is_digit('0'))
	testing.expect(t, is_digit('9'))
	testing.expect(t, !is_digit('a'))
	testing.expect(t, !is_digit('_'))
}

@(test)
test_is_letter :: proc(t: ^testing.T) {
	testing.expect(t, is_letter('a'))
	testing.expect(t, is_letter('Z'))
	testing.expect(t, is_letter('_'))
	testing.expect(t, !is_letter('0'))
	testing.expect(t, !is_letter('-'))
}

@(test)
test_whitespace_and_line_terminators :: proc(t: ^testing.T) {
	testing.expect(t, is_whitespace(' '))
	testing.expect(t, is_whitespace('\t'))
	testing.expect(t, is_whitespace(0x0B))
	testing.expect(t, is_whitespace(0x0C))
	testing.expect(t, is_whitespace(0xA0))
	testing.expect(t, !is_whitespace('\n'))
	testing.expect(t, !is_whitespace('\r'))

	testing.expect(t, is_line_terminator('\n'))
	testing.expect(t, is_line_terminator('\r'))
	testing.expect(t, !is_line_terminator(' '))
}

@(test)
test_read_identifier :: proc(t: ^testing.T) {
	lexer := init_lexer("myVar1 = 10")

	text := read_identifier(&lexer)

	testing.expect_value(t, text, "myVar1")
	testing.expect_value(t, lexer.ch, u8(' '))
}

@(test)
test_read_number :: proc(t: ^testing.T) {
	lexer := init_lexer("123;")

	text := read_number(&lexer)

	testing.expect_value(t, text, "123")
	testing.expect_value(t, lexer.ch, u8(';'))
}

@(test)
test_read_number_float :: proc(t: ^testing.T) {
	lexer := init_lexer("10.5;")

	text := read_number(&lexer)

	testing.expect_value(t, text, "10.5")
	testing.expect_value(t, lexer.ch, u8(';'))
}

@(test)
test_read_number_exponent :: proc(t: ^testing.T) {
	lexer := init_lexer("10e-2;")

	text := read_number(&lexer)

	testing.expect_value(t, text, "10e-2")
	testing.expect_value(t, lexer.ch, u8(';'))
}

@(test)
test_read_string_literal_with_escaped_quote :: proc(t: ^testing.T) {
	lexer := init_lexer("\"Hello \\\"World\\\"\";")

	text := read_string_literal(&lexer)

	testing.expect_value(t, text, "\"Hello \\\"World\\\"\"")
	testing.expect_value(t, lexer.ch, u8(';'))
}

@(test)
test_peek_next_char :: proc(t: ^testing.T) {
	lexer := init_lexer("ab")

	testing.expect_value(t, lexer.ch, u8('a'))
	testing.expect_value(t, peek_next_char(&lexer), u8('b'))
}

@(test)
test_lookup_identifier :: proc(t: ^testing.T) {
	testing.expect_value(t, lookup_identifier("const"), Token_Kind.Keyword_Const)
	testing.expect_value(t, lookup_identifier("let"), Token_Kind.Keyword_Let)
	testing.expect_value(t, lookup_identifier("var"), Token_Kind.Keyword_Var)
	testing.expect_value(t, lookup_identifier("function"), Token_Kind.Keyword_Function)
	testing.expect_value(t, lookup_identifier("myVar"), Token_Kind.Identifier)
}

@(test)
test_next_token_punctuation_and_operators :: proc(t: ^testing.T) {
	lexer := init_lexer("(){}[],:? == === && || = + - * / . ;")

	expected_kinds := [?]Token_Kind {
		.Open_Paren,
		.Close_Paren,
		.Open_Brace,
		.Close_Brace,
		.Open_Bracket,
		.Close_Bracket,
		.Comma,
		.Colon,
		.Question,
		.Equal,
		.Strict_Equal,
		.Logical_And,
		.Logical_Or,
		.Assign,
		.Plus,
		.Minus,
		.Multiply,
		.Divide,
		.Dot,
		.Semicolon,
		.EOF,
	}

	expected_texts := [?]string {
		"(",
		")",
		"{",
		"}",
		"[",
		"]",
		",",
		":",
		"?",
		"==",
		"===",
		"&&",
		"||",
		"=",
		"+",
		"-",
		"*",
		"/",
		".",
		";",
		"",
	}

	for kind, index in expected_kinds {
		token := next_token(&lexer)

		testing.expect_value(t, token.kind, kind)
		testing.expect_value(t, token.text, expected_texts[index])
	}
}
