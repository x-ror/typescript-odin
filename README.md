# typescript-odin

A small Odin project starter.

## Requirements

- Odin compiler available as `odin`
- Optional: Odin Language Server available as `ols` for editor support

## Commands

```sh
make run
make build
make debug
make check
make test
```

The compiled binary is written to `bin/typescript-odin`.
The debug binary is written to `bin/typescript-odin-debug`.

## Editor Support

This project includes `ols.json` at the workspace root so OLS can check the
`src` package and provide editor features such as hover, document symbols,
semantic tokens, references, snippets, and formatting.

On macOS with Homebrew:

```sh
brew install ols
```

## Debugging

For VS Code, install the recommended LLVM LLDB DAP extension when prompted:

```text
llvm-vs-code-extensions.lldb-dap
```

The workspace includes a `Debug Odin` launch configuration that builds with
`odin build src -debug` before starting LLDB.

Keep `"type": "lldb-dap"` in `.vscode/launch.json`. If VS Code says the debug
type is not recognized, the LLVM LLDB DAP extension is not installed or not
enabled. `"type": "node"` is only for JavaScript/TypeScript programs and will
not debug an Odin binary.
