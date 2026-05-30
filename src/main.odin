package compiler

import "core:fmt"
import "core:mem"
import "core:os"

main :: proc() {
	file_path := "./examples/00.lang"
	output_path := "./dist/00.lang.js"

	file_bytes, err := os.read_entire_file_from_path(file_path, context.allocator)

	if err != os.ERROR_NONE {
		fmt.eprintfln(
			"Помилка: Не вдалося прочитати файл. Код помилки: %v",
			err,
		)
		return
	}

	defer delete(file_bytes, context.allocator)

	file_content := string(file_bytes)

	arena: mem.Arena
	arena_buffer := make([]byte, 10 * 1024 * 1024, context.allocator)
	defer delete(arena_buffer, context.allocator)

	mem.arena_init(&arena, arena_buffer)
	arena_allocator := mem.arena_allocator(&arena)

	lexer := init_lexer(file_content)
	parser := init_parser(lexer, arena_allocator)


	ast_root := parse_program(&parser)
	js_code := generate_js(ast_root)

	write_err := os.write_entire_file(output_path, translocate_to_bytes(js_code))
	if write_err == os.ERROR_NONE {
		fmt.printfln("Успіх! Оптимізований код записано у файл: %s", output_path)
	} else {
		fmt.eprintfln("Помилка запису файлу: %v", write_err)
	}

	// Очищаємо Арену пам'яті
	mem.arena_free_all(&arena)
	fmt.println("Роботу завершено.")
}

translocate_to_bytes :: proc(s: string) -> []byte {
	return ([^]byte)(raw_data(s))[:len(s)]
}
