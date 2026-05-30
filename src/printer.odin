package compiler

import "core:strings"

generate_js :: proc(ast_root: Node) -> string {
	builder := strings.builder_make()

	print_node(&builder, ast_root)

	return strings.to_string(builder)
}

print_node :: proc(builder: ^strings.Builder, node: Node) {
	if node.derived == nil do return

	switch stmt in node.derived {

	case ^Program_Statement:
		for stmt_node in stmt.statements {
			print_node(builder, stmt_node)
		}

	case ^Var_Decl_Statement:
		strings.write_string(builder, stmt.decl_type)
		strings.write_string(builder, " ")
		strings.write_string(builder, stmt.name)
		strings.write_string(builder, "=")

		print_node(builder, stmt.value)

		strings.write_string(builder, ";\n")

	case ^Number_Literal_Node:
		strings.write_string(builder, stmt.value)
	case ^String_Literal_Node:
		strings.write_string(builder, stmt.value)
	case ^Identifier_Literal:
		strings.write_string(builder, stmt.name)

	case ^Binary_Expression:
		print_node(builder, stmt.left)
		strings.write_string(builder, stmt.operator)
		print_node(builder, stmt.right)
	}
}
