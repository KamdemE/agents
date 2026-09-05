#!/usr/bin/env python3
"""pdf-structure.py — produce a page-by-page structure tree from Docling JSON.

    uv run python scripts/pdf-structure.py <docling_output_dir> <output_file>

Example:
    uv run python scripts/pdf-structure.py /tmp/pdf-full/dclt /tmp/structure.txt
"""

import json
import sys
from pathlib import Path

LABEL_ICONS = {
    "section_header": "section_header",
    "text": "text",
    "table": "table",
    "picture": "picture",
    "footnote": "footnote",
    "page_footer": "page_footer",
    "page_header": "page_header",
    "caption": "caption",
    "document_index": "document_index",
    "list_item": "list_item",
}


def extract_pages(json_path: Path) -> dict:
    with open(json_path) as f:
        data = json.load(f)

    pages = {}
    for key in ["texts", "tables", "pictures"]:
        for i, item in enumerate(data.get(key, [])):
            prov = item.get("prov", [{}])
            if prov:
                prov = prov[0]
            else:
                prov = {}
            page = prov.get("page_no", "?")
            label = item.get("label", key)
            txt = item.get("text", "")[:120] if item.get("text") else ""
            if page not in pages:
                pages[page] = []
            pages[page].append((key, i, label, txt))
    return pages


def page_title(pages: dict, page_num: int) -> str:
    """Heuristic: use first section_header on the page as title."""
    if page_num not in pages:
        return ""
    for key, idx, label, txt in pages[page_num]:
        if label == "section_header" and txt:
            return txt[:60]
    return ""


def render_tree(pages: dict) -> str:
    lines = []
    for p in sorted(pages.keys()):
        title = page_title(pages, p)
        header = f"PAGE {p}"
        if title:
            header += f"  ({title})"
        lines.append(header)

        entries = pages[p]
        last_idx = len(entries) - 1
        for i, (key, idx, label, txt) in enumerate(entries):
            connector = "└──" if i == last_idx else "├──"
            icon = LABEL_ICONS.get(label, label)
            if txt:
                display = f'"{txt}"'
            else:
                display = "(visual)"
            lines.append(f"  {connector} {key}/{idx:3d}  {icon:20s}  {display}")

        lines.append("")

    return "\n".join(lines)


def render_meta(json_path: Path) -> str:
    with open(json_path) as f:
        data = json.load(f)

    lines = ["", "=" * 60, "META"]
    lines.append(f"Schema: {data.get('schema_name', '?')}")
    lines.append(f"Version: {data.get('version', '?')}")

    body = data.get("body", {})
    children = body.get("children", [])
    counts = {}
    for c in children:
        ref = c.get("$ref", "")
        kind = ref.split("/")[1] if "/" in ref else "?"
        counts[kind] = counts.get(kind, 0) + 1

    lines.append(f"Body children: {len(children)}")
    for kind, count in sorted(counts.items()):
        lines.append(f"  {kind}: {count}")

    lines.append(f"Total texts: {len(data.get('texts', []))}")
    lines.append(f"Total tables: {len(data.get('tables', []))}")
    lines.append(f"Total pictures: {len(data.get('pictures', []))}")

    lines.append("=" * 60)
    return "\n".join(lines)


def main():
    if len(sys.argv) < 3:
        print("Usage: pdf-structure.py <docling_output_dir> <output_file>")
        sys.exit(1)

    input_dir = Path(sys.argv[1])
    output_file = Path(sys.argv[2])

    json_files = list(input_dir.glob("*.json"))
    if not json_files:
        print(f"Error: no .json file found in {input_dir}")
        sys.exit(1)

    json_path = json_files[0]
    pages = extract_pages(json_path)
    tree = render_tree(pages)
    meta = render_meta(json_path)
    result = tree + "\n" + meta

    output_file.parent.mkdir(parents=True, exist_ok=True)
    with open(output_file, "w") as f:
        f.write(result)

    print(f"Structure written to {output_file}")
    print(f"  Pages: {len(pages)}")
    print(f"  Total blocks: {sum(len(v) for v in pages.values())}")


if __name__ == "__main__":
    main()
