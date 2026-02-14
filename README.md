# pbrich

Like `pbcopy`, but with support for arbitrary pasteboard types. Copy HTML, RTF, or any other content type to the macOS clipboard.

## Installation

```sh
brew install waynehoover/tap/pbrich
```

Or build from source:

```sh
make install
```

## Usage

Drop-in replacement for `pbcopy`:

```sh
echo "hello" | pbrich
```

Copy HTML with a plain text fallback:

```sh
echo '<a href="https://example.com">Link</a>' | pbrich -t public.html -p "https://example.com"
```

Copy RTF:

```sh
cat document.rtf | pbrich -t public.rtf
```

Set multiple types at once:

```sh
echo "<b>bold</b>" | pbrich -t public.html -t public.rtf
```

List common pasteboard types:

```sh
pbrich --list-types
```

## Options

| Flag | Description |
| --- | --- |
| `-t`, `--type` | Pasteboard type UTI (can be repeated) |
| `-p`, `--plain` | Plain text fallback (requires `--type`) |
| `-l`, `--list-types` | List common pasteboard types |
| `-v`, `--version` | Show version |
| `-h`, `--help` | Show help |

When no `--type` is specified, pbrich behaves like `pbcopy` and copies stdin as plain text.

## History

View the [changelog](CHANGELOG.md).

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/waynehoover/pbrich/issues)
- Fix bugs and [submit pull requests](https://github.com/waynehoover/pbrich/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

## License

MIT
