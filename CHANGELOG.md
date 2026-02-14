## 1.2.0 (2026-02-13)

- Add `-f`/`--file` flag to copy file references to the clipboard (like Cmd+C in Finder)
- Supports multiple files (`-f a.png -f b.pdf`)
- Works with `--plain` for text fallback
- Add Similar Projects section to README
- 7 new unit tests (29 total)

## 1.1.0 (2026-02-13)

- Auto-detect PNG, JPEG, PDF, TIFF, and RTF from content magic bytes
- No `-t` flag needed for common binary formats
- `--plain` no longer requires `--type`
- Extract library target (`PBRichCore`) for testability
- Add 22 unit tests covering parsing, detection, and pasteboard behavior

## 1.0.0 (2026-02-13)

- Initial release
- Support for arbitrary pasteboard types via `--type`
- Plain text fallback via `--plain`
- Drop-in `pbcopy` replacement when used without flags
- List common pasteboard types with `--list-types`
