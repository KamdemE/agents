#  offline skill validators — used by `make check-skills` (called from `make check`).
# Modules: settings (shared config), skill_structure_guard (SKILL.md frontmatter/footer
# structure), skill_content_guard (bundled scripts/references/assets coverage),
# skill_infras_guard (infra skill MANDATORY note + kshrc link coverage, added 2026-08-15),
# check_skills (entrypoint orchestrator, aggregates the other *.py guards, called by the Makefile).
