package compiler

import "base:runtime"
import "core:fmt"
import "core:mem"

Parser :: struct {
	lexer:         Lexer,
	current_token: Token,
	peek_token:    Token,
	allocator:     mem.Allocator,
}


Node :: struct {
	derived: Node_Data,
}

Node_Data :: union {
	^Program_Statement,
	^Var_Decl_Statement,
	^Binary_Expression,
	^Number_Literal_Node,
	^String_Literal_Node,
	^Identifier_Literal,
}

Program_Statement :: struct {
	statements: [dynamic]Node,
}

Var_Decl_Statement :: struct {
	decl_type: string,
	name:      string,
	value:     Node,
}

Binary_Expression :: struct {
	left:     Node,
	operator: string,
	right:    Node,
}

Number_Literal_Node :: struct {
	value: string,
}

Identifier_Literal :: struct {
	name: string,
}

String_Literal_Node :: struct {
	value: string,
}

Precedence :: enum {
	LOWEST,       // Базовий рівень
	EQUALS,       // ==, ===
	LESS_GREATER, // >, <, >=, <=
	SUM,          // + або -
	PRODUCT,      // * або /
}

get_token_precedence :: proc(kind: Token_Kind) -> Precedence {
	switch kind {
	case .Plus, .Minus: 
		return .SUM
	// Коли ти додаси Multiply (*) та Divide (/) у свій Token_Kind:
	// case .Multiply, .Divide: return .PRODUCT
	case: 
		return .LOWEST
	}
}


parse_statement :: proc(parser: ^Parser) -> Node {
	#partial switch parser.current_token.kind {
	case .Keyword_Let, .Keyword_Const, .Keyword_Var:
		return parse_var_declaration(parser)
	case:
		return parse_expression(parser)
	}
}

parse_expression :: proc(parser: ^Parser) -> Node {
	if parser.current_token.kind == .Number_Literal {
		num_node := new(Number_Literal_Node, parser.allocator)
		num_node.value = parser.current_token.text
		return Node{derived = num_node}
	}

	if parser.current_token.kind == .String_Literal {
		str_node := new(String_Literal_Node, parser.allocator)
		str_node.value = parser.current_token.text
		return Node{derived = str_node}
	}

	if parser.current_token.kind == .Identifier {
		ident_node := new(Identifier_Literal, parser.allocator)
		ident_node.name = parser.current_token.text
		return Node{derived = ident_node}
	}

	return Node{}
}

parse_var_declaration :: proc(parser: ^Parser) -> Node {
	stmt := new(Var_Decl_Statement, parser.allocator)
	stmt.decl_type = parser.current_token.text

	advance_token(parser)

	if parser.current_token.kind != .Identifier {
		fmt.eprintfln(
			"Помилка синтаксису: Очікувалось ім'я змінної, але знайдено %v",
			parser.current_token.kind,
		)
		return Node{}
	}

	stmt.name = parser.current_token.text

	if parser.peek_token.kind == .Colon {
		advance_token(parser)

		for parser.peek_token.kind != .Assign && parser.peek_token.kind != .EOF {
			advance_token(parser)
		}
	}

	if parser.peek_token.kind != .Assign {
		fmt.eprintfln(
			"Помилка синтаксису: Очікувався знак '=' після імені змінної %s",
			stmt.name,
		)
		return Node{}
	}

	advance_token(parser)
	advance_token(parser)
	stmt.value = parse_expression(parser)

	if parser.peek_token.kind == .Semicolon {
		advance_token(parser)
	}


	return Node{derived = stmt}
}

init_parser :: proc(lexer: Lexer, allocator: mem.Allocator) -> Parser {
	parser := Parser {
		lexer     = lexer,
		allocator = allocator,
	}

	parser.current_token = next_token(&parser.lexer)
	parser.peek_token = next_token(&parser.lexer)

	return parser
}


advance_token :: proc(parser: ^Parser) {
	parser.current_token = parser.peek_token
	parser.peek_token = next_token(&parser.lexer)
}

parse_program :: proc(parser: ^Parser) -> Node {
	program_node := new(Program_Statement, parser.allocator)

	program_node.statements = make([dynamic]Node, parser.allocator)

	for parser.current_token.kind != .EOF {
		statement := parse_statement(parser)

		if statement.derived != nil {
			append(&program_node.statements, statement)
		}

		advance_token(parser)
	}

	return Node{derived = program_node}
}
