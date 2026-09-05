#!/usr/bin/env python3
"""pdf-fonts.py — produce a font audit table from a PDF.

    uv run --with pdfminer.six python scripts/pdf-fonts.py <input.pdf> <output_file>

Example:
    uv run --with pdfminer.six python scripts/pdf-fonts.py main.pdf /tmp/fonts.txt
"""

import sys
from pathlib import Path


def extract_fonts(pdf_path: Path) -> list[tuple[str, float, int]]:
    from pdfminer.high_level import extract_pages
    from pdfminer.layout import LTChar, LTTextLine

    sizes: dict[tuple[str, float], int] = {}
    for page_layout in extract_pages(str(pdf_path)):
        for element in page_layout:
            if hasattr(element, "get_text"):
                for text_line in element:
                    if isinstance(text_line, LTTextLine):
                        for char in text_line:
                            if isinstance(char, LTChar):
                                fname = char.fontname
                                fsize = round(char.size, 1)
                                key = (fname, fsize)
                                sizes[key] = sizes.get(key, 0) + 1
    return [
        (fname, fsize, count)
        for (fname, fsize), count in sorted(sizes.items(), key=lambda x: -x[1])
    ]


def heuristic_usage(fname: str, fsize: float, count: int, max_count: int) -> str:
    """Guess the role of each font/size combination."""
    bold = "Bold" in fname or "bold" in fname
    italic = "Ital" in fname or "ital" in fname
    mono = "Mono" in fname or "mono" in fname

    if fsize >= 20:
        return "Section titles"
    elif fsize >= 14:
        return "Part titles" if bold else "Titles"
    elif fsize >= 12 and bold:
        return "Bold large"
    elif fsize <= 8.5:
        return "Notes / captions"
    elif fsize <= 9.5:
        return "Footnotes" if not mono else "Code / mono"
    elif mono:
        return "Code / mono"
    elif italic:
        return "Italic"
    elif bold:
        return "Bold in text"
    elif count == max_count:
        return "Body text (main paragraphs)"
    elif count > max_count * 0.05:
        return "Table text"
    else:
        return "Secondary text"


def render_table(fonts: list[tuple[str, float, int]]) -> str:
    if not fonts:
        return "No fonts found."

    max_count = fonts[0][2]
    lines = []

    header = f"{'Font':<35} {'Size':>8} {'Occurrences':>12}  {'Usage'}"
    lines.append(header)
    lines.append("─" * 35 + "─" * 8 + "─" * 12 + "  " + "─" * 35)

    for fname, fsize, count in fonts:
        usage = heuristic_usage(fname, fsize, count, max_count)
        count_str = f"{count:,}".replace(",", " ")
        lines.append(f"{fname:<35} {fsize:>7.1f}pt {count_str:>12}  {usage}")

    total = sum(c for _, _, c in fonts)
    lines.append("─" * 35 + "─" * 8 + "─" * 12 + "  " + "─" * 35)
    lines.append(f"{'TOTAL':<35} {'':>8} {f'{total:,}'.replace(',', ' '):>12}")

    return "\n".join(lines)


def main():
    if len(sys.argv) < 3:
        print("Usage: pdf-fonts.py <input.pdf> <output_file>")
        sys.exit(1)

    pdf_path = Path(sys.argv[1])
    output_file = Path(sys.argv[2])

    fonts = extract_fonts(pdf_path)
    table = render_table(fonts)

    output_file.parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w") as f:
        f.write(table)

    print(f"Font audit written to {output_file}")
    print(f"  {len(fonts)} font/size combinations found")


if __name__ == "__main__":
    main()
