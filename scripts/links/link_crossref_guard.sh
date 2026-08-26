#!/usr/bin/env bash
# ============================================================
# link_crossref_guard.sh — sub-check: links.jsonc ↔ services.jsonc (by unit)
# ============================================================
# Part of check-links.sh (modular split). Direct systemd unit links and service
# registry entries form one bidirectional contract. For every pair sharing a
# unit name, this guard validates canonical asset path, owning skill, expected
# deployment source (derived from service type), and infra scope as unordered
# sets. The service deployment mode is declarative: `symlink` (default) needs
# exactly one link; `copy` needs none. It detects orphan links, orphan services,
# duplicate unit declarations, and scope drift without hardcoding unit types.
# ============================================================

# shellcheck disable=SC1090
source "$SCRIPT_DIR/lib.sh"

# link_crossref_guard <LINKS_OBJ> <SERVICES_OBJ>
#   appends to $CROSS / $CROSS_MISSING counters
link_crossref_guard() {
  local links_obj="$1" services_obj="$2"
  local kind first second
  CROSS=0
  CROSS_MISSING=0

  # shellcheck disable=SC2016,SC2026
  while IFS=$'\t' read -r kind first second; do
    case "$kind" in
      ERROR)
        echo "  ✗ CROSS-REF: $first"
        ;;
      SUMMARY)
        CROSS="$first"
        CROSS_MISSING="$second"
        ;;
    esac
  done < <(LINKS_OBJ="$links_obj" SERVICES_OBJ="$services_obj" python3 -c '
import json
import os

links = json.loads(os.environ["LINKS_OBJ"]).get("links", {})
services = json.loads(os.environ["SERVICES_OBJ"]).get("services", {})
user_prefix = "$HOME/.config/systemd/user/"
system_prefix = "/etc/systemd/system/"
errors = []

def report(message):
    errors.append(message)
    print(f"ERROR\t{message}")

def scope(value, label):
    if not isinstance(value, list) or any(not isinstance(item, str) or not item for item in value):
        report(f"{label} has invalid infras data")
        return None
    values = set(value)
    if len(values) != len(value):
        report(f"{label} has duplicate infra values")
    return values

def direct_unit_source(source):
    for prefix in (user_prefix, system_prefix):
        if source.startswith(prefix):
            unit = source[len(prefix):]
            if unit and "/" not in unit:
                return unit
    return None

def deployment(service, label):
    mode = service.get("deployment", "symlink")
    if mode not in {"symlink", "copy"}:
        report(f"service {label!r} has invalid deployment {mode!r}")
        return None
    return mode

unit_links = {}
for link_name, link in links.items():
    if not isinstance(link, dict):
        report(f"links.jsonc key {link_name!r} is not an object")
        continue
    source = link.get("source", "")
    unit = direct_unit_source(source) if isinstance(source, str) else None
    if unit:
        unit_links.setdefault(unit, []).append((link_name, link))

unit_services = {}
for service_name, service in services.items():
    if not isinstance(service, dict):
        report(f"services.jsonc key {service_name!r} is not an object")
        continue
    unit = service.get("unit", "")
    if not isinstance(unit, str) or not unit:
        report(f"services.jsonc key {service_name!r} has no unit")
        continue
    unit_services.setdefault(unit, []).append((service_name, service))

checked = 0
for unit in sorted(set(unit_links) | set(unit_services)):
    links_for_unit = unit_links.get(unit, [])
    services_for_unit = unit_services.get(unit, [])
    checked += max(len(links_for_unit), len(services_for_unit))
    if len(services_for_unit) != 1:
        report(f"unit {unit!r} has {len(services_for_unit)} services.jsonc registration(s), expected 1")
        continue
    service_name, service = services_for_unit[0]
    mode = deployment(service, service_name)
    if mode is None:
        continue
    if mode == "copy":
        if links_for_unit:
            report(f"unit {unit!r}: service {service_name!r} deployment is copy but has {len(links_for_unit)} direct systemd link registration(s)")
        continue
    if len(links_for_unit) != 1:
        report(f"unit {unit!r} has {len(links_for_unit)} direct systemd link registration(s), expected 1 for symlink deployment")
        continue

    link_name, link = links_for_unit[0]
    expected_source = user_prefix + unit if service.get("type") == "user" else system_prefix + unit
    if link.get("source") != expected_source:
        report(f"unit {unit!r}: link {link_name!r} source {link.get('source')!r} != expected {expected_source!r} from service {service_name!r}")
    if link.get("target") != service.get("path"):
        report(f"unit {unit!r}: link {link_name!r} target != service {service_name!r} canonical path")
    if link.get("skill") != service.get("skill"):
        report(f"unit {unit!r}: link {link_name!r} skill != service {service_name!r} skill")
    link_scope = scope(link.get("infras"), f"link {link_name!r}")
    service_scope = scope(service.get("infras"), f"service {service_name!r}")
    if link_scope is not None and service_scope is not None and link_scope != service_scope:
        report(f"unit {unit!r}: link {link_name!r} infras {sorted(link_scope)!r} != service {service_name!r} infras {sorted(service_scope)!r}")

print(f"SUMMARY\t{checked}\t{len(errors)}")
')
  echo "check-links cross-ref: $CROSS systemd-unit contract(s), $CROSS_MISSING violation(s)"
}
