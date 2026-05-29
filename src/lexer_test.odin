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
