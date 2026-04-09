# CONTRACT

This document is the non-negotiable source of truth for the project contract.

If implementation, wrappers, or docs conflict with this contract, this contract wins.

---

## 1) Metadata

- `schema_version`: `<project>.contract.v1`
- `contract_version`: `1.0.0`

Keep the same metadata in `pyproject.toml` or `package.json` under a dedicated tool/config section.

---

## 2) Conventions

- Envelope shape (if programmatic transports exist).
- Naming conventions for operations.
- Time units (`*_ms`, `*_s`) and IDs (`req_*`, `sess_*`).

---

## 3) Shared types

Define all public request/response payload types and field semantics.

---

## 4) Error model

List canonical error codes and stable meaning.

---

## 5) Internal API

For each operation:

- Purpose
- Input schema (with examples)
- Output schema (with examples)

---

## 6) Transport mappings

Map each transport command/tool/frame to exactly one internal API operation.

---

## 7) Compliance rules

- Wrappers must not alter business semantics.
- Wrappers must not remap canonical error codes.
- Any breaking change requires `schema_version` major bump.
