# pbrich

Like `pbcopy`, but with support for arbitrary pasteboard types. Copy HTML, RTF, images, PDFs, or any other content type to the macOS clipboard.

Auto-detects PNG, JPEG, PDF, TIFF, and RTF from content. No flags needed for common formats.

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

Copy an image to the clipboard (auto-detected):

```sh
cat screenshot.png | pbrich
```

Paste it directly into Slack, email, or any app that accepts images.

Copy a PDF (auto-detected):

```sh
cat report.pdf | pbrich
```

Copy RTF (auto-detected):

```sh
cat document.rtf | pbrich
```

Copy a clickable link (paste into Slack, Notion, etc.):

```sh
echo '<a href="https://github.com/waynehoover/pbrich">pbrich</a>' | pbrich -t public.html -p "https://github.com/waynehoover/pbrich"
```

Copy a URL (recognized as a link by browsers and Finder):

```sh
echo -n "https://github.com" | pbrich -t public.url
```

Set multiple types at once:

```sh
echo "<b>bold</b>" | pbrich -t public.html -t public.rtf
```

Combine with other tools:

```sh
# Screenshot a window and copy to clipboard
screencapture -w -o /tmp/shot.png && cat /tmp/shot.png | pbrich

# Copy curl response as HTML
curl -s https://example.com | pbrich -t public.html

# Convert markdown to HTML and copy as rich text
echo "**bold** and *italic*" | pandoc -f markdown -t html | pbrich -t public.html -p "bold and italic"
```

## Auto-Detection

When no `--type` is specified, pbrich detects the format from the content:

| Format | Magic Bytes | Detected Type |
| --- | --- | --- |
| PNG | `89 50 4E 47` | `public.png` |
| JPEG | `FF D8 FF` | `public.jpeg` |
| PDF | `%PDF` | `com.adobe.pdf` |
| TIFF | `49 49 2A 00` / `4D 4D 00 2A` | `public.tiff` |
| RTF | `{\rtf` | `public.rtf` |
| Everything else | | `public.utf8-plain-text` |

Use `-t` to override detection or for formats without magic bytes (HTML, JSON, XML, etc.).

## Options

| Flag | Description |
| --- | --- |
| `-t`, `--type` | Pasteboard type UTI (can be repeated). Overrides auto-detection |
| `-p`, `--plain` | Also set a plain text fallback |
| `-l`, `--list-types` | List common pasteboard types |
| `-v`, `--version` | Show version |
| `-h`, `--help` | Show help |

## Supported Types

Any [Uniform Type Identifier](https://developer.apple.com/documentation/uniformtypeidentifiers) works. Common ones:

| Type | Description | Example |
| --- | --- | --- |
| `public.utf8-plain-text` | Plain text (default) | `echo "hi" \| pbrich` |
| `public.html` | HTML | `echo "<b>bold</b>" \| pbrich -t public.html` |
| `public.rtf` | Rich Text Format | `cat doc.rtf \| pbrich` |
| `public.png` | PNG image | `cat img.png \| pbrich` |
| `public.jpeg` | JPEG image | `cat photo.jpg \| pbrich` |
| `public.tiff` | TIFF image | `cat img.tiff \| pbrich` |
| `com.adobe.pdf` | PDF document | `cat doc.pdf \| pbrich` |
| `public.url` | URL | `echo -n "https://x.com" \| pbrich -t public.url` |
| `public.file-url` | File URL | `echo -n "file:///tmp/f" \| pbrich -t public.file-url` |
| `public.json` | JSON | `echo '{"a":1}' \| pbrich -t public.json` |
| `public.xml` | XML | `cat data.xml \| pbrich -t public.xml` |

Run `pbrich --list-types` to see this list in your terminal.

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
