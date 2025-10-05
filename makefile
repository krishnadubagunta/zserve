# Makefile for Zig project
# Usage:
#   make build     → build debug binary
#   make release   → build optimized release binary
#   make run       → build and run
#   make clean     → remove zig cache and output

ZIG ?= zig
TARGET ?= native
BUILD_DIR ?= zig-out
EXE_NAME ?= zserve

SRC := src/main.zig

.PHONY: all build release run clean install uninstall

all: build

bbuild:
	$(ZIG) build

release:
	$(ZIG) build -Doptimize=ReleaseFast

run: build
	./$(BUILD_DIR)/bin/$(EXE_NAME)

clean:
	rm -rf $(BUILD_DIR) .zig-cache

install: release
	install -d /usr/local/bin
	install $(BUILD_DIR)/bin/$(EXE_NAME) /usr/local/bin/$(EXE_NAME)

uninstall:
	rm -f /usr/local/bin/$(EXE_NAME)
