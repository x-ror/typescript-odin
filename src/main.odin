package compiler

import "core:fmt"
import "core:os"

main :: proc() {
	file_path := "src/tests/variables/index.ts"
	file_bytes, err := os.read_entire_file_from_path(file_path, context.allocator)
	
	if err != os.ERROR_NONE {
		fmt.eprintfln("Помилка: Не вдалося прочитати файл. Код помилки: %v", err)
		return
	}

	defer delete(file_bytes, context.allocator)

	file_content := string(file_bytes)
	lexer := init_lexer(file_content)

	fmt.println("--- ЗАПУСК ЛЕКСЕРА ---")
	fmt.printf("%-15s | %-20s | %s\n", "ТИП ТОКЕНА", "ЗНАЧЕННЯ", "РЯДОК:КОЛОНКА")
	fmt.println("---------------------------------------------------------")

	for {
		token := next_token(&lexer)

		fmt.printf("%-15v | %-20s | %d:%d\n", token.kind, token.text, token.line, token.col)

		if token.kind == .EOF {
			break
		}
	}
	
	fmt.println("---------------------------------------------------------")
	fmt.println("Лексичний аналіз завершено успішно!")
}
