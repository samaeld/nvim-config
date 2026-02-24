# Neovim Configuration

## External Dependencies

These are system-level tools required by the configuration that are **not** managed by lazy.nvim or mason.nvim.

### Quick Install

**Core (required for basic functionality):**
```bash
sudo pacman -S git gcc make fzf ripgrep fd kitty
```

**All optional tools (recommended for full experience):**
```bash
sudo pacman -S git gcc make fzf ripgrep fd kitty \
  clang python python-black python-isort python-pytest \
  nodejs npm go rustup cmake universal-ctags

yay -S stylua gersemi pyside6 kotlin flutter
```

---

### Dependency Details

| Tool | Package | Used By | Notes |
|------|---------|---------|-------|
| `git` | `pacman -S git` | lazy.nvim bootstrap, gitsigns, diffview, telescope | Required |
| `gcc` / `make` | `pacman -S gcc make` | nvim-treesitter (compiles parsers), fzf-native | Required |
| `fzf` | `pacman -S fzf` | telescope-fzf-native | Recommended |
| `ripgrep` | `pacman -S ripgrep` | telescope live_grep | Recommended |
| `fd` | `pacman -S fd` | telescope file finder | Recommended |
| `kitty` | `pacman -S kitty` | floating terminal, theme switching | Optional |
| `clang` / `clang-format` | `pacman -S clang` | C/C++ formatting via conform.nvim | C/C++ dev |
| `python` | `pacman -S python` | pyright/ruff LSP, nvim-dap-python | Python dev |
| `black` | `pacman -S python-black` | Python formatting via conform.nvim | Python dev |
| `isort` | `pacman -S python-isort` | Python import sorting via conform.nvim | Python dev |
| `pytest` | `pacman -S python-pytest` | nvim-dap-python test runner | Python dev |
| `stylua` | `yay -S stylua` | Lua formatting via conform.nvim | Lua dev |
| `nodejs` / `npm` | `pacman -S nodejs npm` | bash-language-server, ts_ls | JS/TS/Bash dev |
| `go` | `pacman -S go` | gopls LSP | Go dev |
| `rustup` | `pacman -S rustup` | rust-analyzer LSP | Rust dev |
| `cmake` | `pacman -S cmake` | neocmake LSP | CMake dev |
| `universal-ctags` | `pacman -S universal-ctags` | tagbar plugin | Optional |
| `gersemi` | `yay -S gersemi` | CMake formatting via conform.nvim | CMake dev |
| `pyside6` | `yay -S pyside6` | qmlls (QML language server) | QML dev |
| `kotlin` | `yay -S kotlin` | kotlin_lsp | Kotlin dev |
| `flutter` | `yay -S flutter` | flutter-tools.nvim | Flutter/Dart dev |


---

Useful links:
- [kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim)
- [LunarVim](https://github.com/LunarVim/LunarVim)
