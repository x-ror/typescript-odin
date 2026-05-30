package compiler

Token_Kind :: enum {
	EOF,
	Invalid,

	// 1. Ключові слова (Keywords)
	Keyword_Const,
	Keyword_Let,
	Keyword_Var,
	Keyword_Function,

	// 2. Літерали та ідентифікатори
	Identifier, // total, myVar, console
	Number_Literal, // 5, 10.5
	String_Literal, // "hello", 'world'

	// 3. Оператори присвоєння (Поки базові)
	Assign, // =
	// Інші (+=, -=) додамо пізніше

	// 4. Арифметичні оператори
	Plus, // + (і для додавання, і для унарного)
	Minus, // - (і для віднімання, і для унарного)
	Multiply, // *
	Divide, // /

	// 5. Оператори порівняння та логіки (Базові)
	Strict_Equal, // ===
	Equal, // ==
	Logical_And, // &&
	Logical_Or, // ||

	// 6. Пунктуація та дужки (Обов'язково розділені!)
	Open_Paren, // (
	Close_Paren, // )
	Open_Brace, // {  (Потрібні для тіла функцій та блоків коду)
	Close_Brace, // }
	Open_Bracket, // [
	Close_Bracket, // ]
	Comma, // ,  (Роздільник аргументів у функціях)
	Dot, // .  (Для console.log)
	Semicolon, // ;
	Colon, // :  (Початок типу, наприклад x: number)
	Question, // ?  (Для optional типів x?: number або тернарника)
}

Token :: struct {
	kind: Token_Kind,
	text: string,
	line: int,
	col:  int,
}

Lexer :: struct {
	input_len:     int,
	input:         string, // Весь текст файлу test.ts
	position:      int, // Поточний індекс символу, який ми прочитали (ch)
	read_position: int, // Наступний індекс
	ch:            u8, // Поточний символ у форматі байту (ASCII)
	line:          int, // Для трекінгу помилок
	col:           int, // Для трекінгу помилок
}

init_lexer :: proc(input: string) -> Lexer {
	lexer := Lexer {
		input     = input,
		input_len = len(input),
		line      = 1,
		col       = 0,
	}
	advance_char(&lexer) // Читаємо найперший символ файлу
	return lexer
}

advance_char :: proc(lexer: ^Lexer) {
	if lexer.read_position >= lexer.input_len {
		lexer.ch = 0
	} else {
		lexer.ch = lexer.input[lexer.read_position]
	}

	lexer.position = lexer.read_position
	lexer.read_position += 1
	lexer.col += 1
}

is_whitespace :: proc(ch: u8) -> bool {
	return ch == ' ' || ch == '\t' || ch == 0x0B || ch == 0x0C || ch == 0xA0
}

is_line_terminator :: proc(ch: u8) -> bool {
	return ch == '\r' || ch == '\n'
}

skip_whitespace :: proc(lexer: ^Lexer) {
	for is_whitespace(lexer.ch) || is_line_terminator(lexer.ch) {
		if lexer.ch == '\n' {
			lexer.line += 1
			lexer.col = 0
		}
		advance_char(lexer)
	}
}

is_letter :: proc(ch: u8) -> bool {
	return ('a' <= ch && ch <= 'z' || 'A' <= ch && ch <= 'Z') || ch == '_'
}

is_digit :: proc(ch: u8) -> bool {
	return ch >= '0' && ch <= '9'
}

read_identifier :: proc(lexer: ^Lexer) -> string {
	start := lexer.position

	for is_letter(lexer.ch) || is_digit(lexer.ch) {
		advance_char(lexer)
	}

	return lexer.input[start:lexer.position]
}

read_number :: proc(lexer: ^Lexer) -> string {
	start := lexer.position

	// 1. Читаємо цілу частину числа
	for is_digit(lexer.ch) {
		advance_char(lexer)
	}

	// 2. Обробка дробової частини (Float), наприклад: 3.14
	if lexer.ch == '.' {
		next_ch := peek_next_char(lexer)
		if is_digit(next_ch) {
			advance_char(lexer) // З'їдаємо крапку '.'
			for is_digit(lexer.ch) {
				advance_char(lexer)
			}
		}
	}

	if lexer.ch == 'e' || lexer.ch == 'E' {
		next_ch := peek_next_char(lexer)
		is_sign := next_ch == '+' || next_ch == '-'

		after_sign_ch: u8 = 0
		if is_sign && lexer.read_position + 1 < lexer.input_len {
			after_sign_ch = lexer.input[lexer.read_position + 1]
		}

		if is_digit(next_ch) || (is_sign && is_digit(after_sign_ch)) {
			advance_char(lexer)

			if lexer.ch == '+' || lexer.ch == '-' {
				advance_char(lexer)
			}

			for is_digit(lexer.ch) {
				advance_char(lexer)
			}
		}
	}

	return lexer.input[start:lexer.position]
}

peek_next_char :: proc(lexer: ^Lexer) -> u8 {
	if lexer.read_position >= lexer.input_len {
		return 0
	}
	return lexer.input[lexer.read_position]
}

read_string_literal :: proc(lexer: ^Lexer) -> string {
	quote_char := lexer.ch
	start := lexer.position

	advance_char(lexer)

	for lexer.ch != 0 {
		if lexer.ch == '\\' {
			advance_char(lexer)

			if lexer.ch != 0 {
				advance_char(lexer)
			}
			continue
		}

		if lexer.ch == quote_char {
			advance_char(lexer)
			break
		}

		advance_char(lexer)
	}

	return lexer.input[start:lexer.position]
}


lookup_identifier :: proc(keyword: string) -> Token_Kind {
	switch keyword {
	case "const":
		return .Keyword_Const
	case "let":
		return .Keyword_Let
	case "var":
		return .Keyword_Var
	case "function":
		return .Keyword_Function
	case:
		return .Identifier
	}
}

next_token :: proc(lexer: ^Lexer) -> Token {
	skip_whitespace(lexer)

	start := lexer.position
	token: Token = {
		line = lexer.line,
		col  = lexer.col,
	}

	if lexer.ch == 0 {
		token.kind = .EOF
		token.text = ""
		return token
	}

	switch lexer.ch {
	case '+':
		token.kind = .Plus
	case '-':
		token.kind = .Minus
	case ':':
		token.kind = .Colon
	case '?':
		token.kind = .Question
	case '*':
		token.kind = .Multiply
	case '/':
		token.kind = .Divide
	case ';':
		token.kind = .Semicolon
	case ',':
		token.kind = .Comma
	case '(':
		token.kind = .Open_Paren
	case ')':
		token.kind = .Close_Paren
	case '{':
		token.kind = .Open_Brace
	case '}':
		token.kind = .Close_Brace
	case '[':
		token.kind = .Open_Bracket
	case ']':
		token.kind = .Close_Bracket
	case '=':
		if peek_next_char(lexer) == '=' {
			advance_char(lexer)

			if peek_next_char(lexer) == '=' {
				advance_char(lexer)
				token.kind = .Strict_Equal
			} else {
				token.kind = .Equal
			}
		} else {
			token.kind = .Assign
		}
	case '&':
		if peek_next_char(lexer) == '&' {
			advance_char(lexer)
			token.kind = .Logical_And
		} else {
			token.kind = .Invalid
		}
	case '|':
		if peek_next_char(lexer) == '|' {
			advance_char(lexer)
			token.kind = .Logical_Or
		} else {
			token.kind = .Invalid
		}
	case '.':
		token.kind = .Dot
	case '"', '\'':
		token.kind = .String_Literal
		token.text = read_string_literal(lexer)
		return token
	case:
		if is_letter(lexer.ch) {
			token.text = read_identifier(lexer)
			token.kind = lookup_identifier(token.text)
			return token
		} else if is_digit(lexer.ch) {
			token.text = read_number(lexer)
			token.kind = .Number_Literal
			return token
		} else {
			token.kind = .Invalid
		}
	}

	token.text = lexer.input[start:lexer.read_position]
	advance_char(lexer)
	return token
}
