ODIN ?= odin
SRC_DIR := src
BIN_DIR := bin
APP_NAME := typescript-odin

.PHONY: run build debug check test clean

run:
	$(ODIN) run $(SRC_DIR)

build:
	mkdir -p $(BIN_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(BIN_DIR)/$(APP_NAME)

debug:
	mkdir -p $(BIN_DIR)
	$(ODIN) build $(SRC_DIR) -debug -out:$(BIN_DIR)/$(APP_NAME)-debug

check:
	$(ODIN) check $(SRC_DIR)

test:
	$(ODIN) test $(SRC_DIR)

clean:
	rm -rf $(BIN_DIR)
