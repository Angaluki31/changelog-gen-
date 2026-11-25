# Changelog Generator

A Bash script that turns a Git repository's history into a Markdown changelog, grouped by release tag and by type of change.

## Usage 

```bash
bash changelog.sh                  # print the changelog for the current repo 
bash changelog.sh path/to/repo     # another repo
bash changelog.sh -o CHANGELOG.md  # write to a file
```

## How commits are grouped

Both commit styles are understood:

| Commit message | Section |
|----------------|---------|
| `feat: ...`, `Add ...`, `Create ...` | Added |
| `fix: ...`, `Fix ...` | Fixed |
| `update: ...`, `Update ...`, `Improve ...`, `refactor: ...` | Changed |
| `remove: ...`, `Remove ...` | Removed |
| `docs: ...` | Documentation |
| `test: ...` `chore: ...`, `ci: ...` | Maintenance |
| anything else | Other |

## Releases

Each Git tag becomes a release section. Commits after the newest tag appear under **Unreleased**.

```bash
git tag v1.0.0
```

## Requirements

Bash and Git (Git Bash on Windows)