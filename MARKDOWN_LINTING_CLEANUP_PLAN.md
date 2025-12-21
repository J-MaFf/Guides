# Markdown Linting Cleanup Plan

## Overview

This document outlines the plan to fix 100+ markdown linting violations across the repository. These violations were discovered when stricter linting rules (MD013, MD031, MD032, MD040) were enabled to improve documentation quality.

## Rules to Fix

### MD013 - Line Length (80 character limit)
**What it enforces:** No line should exceed 80 characters
**Why important:** Better readability, especially in diff viewers and terminals
**Current violations:** ~80 total across all files

### MD031 - Blanks Around Fences
**What it enforces:** Fenced code blocks must have blank lines before and after them
**Why important:** Better visual separation and readability
**Current violations:** ~15 in `github/rules/README.md`, `Status checks/README.md`

### MD032 - Blanks Around Lists
**What it enforces:** Lists must have blank lines before and after them
**Why important:** Better structure and readability
**Current violations:** ~12 across `github/rules/` and `Status checks/` READMEs

### MD040 - Fenced Code Language
**What it enforces:** Fenced code blocks must specify a language
**Why important:** Enables syntax highlighting and proper rendering
**Current violations:** ~5 across `github/rules/` READMEs

---

## Violation Summary by File

### High Priority (Main Content)

#### 1. `Copilot guides/MEMORY_MCP_SERVER_FIX.md` (12 violations)
- **MD013:** Lines 5, 54, 59, 66, 72, 73, 82, 93, 99, 100, 101, 102
- **Strategy:** Break long lines by:
  - Wrapping URLs in separate lines or into footnotes
  - Splitting environment variable descriptions
  - Reformatting inline code examples
- **Estimated time:** 20 minutes

#### 2. `github/rules/github-branch-protection-and-status-checks.md` (44 violations)
- **MD013:** Lines 5, 7, 9, 21, 182, 196, 223, 226, 238, 280, 284-286, 288, 297-300, 308-313, 319-324, 356, 374
- **Strategy:** Systematic line wrapping, especially for:
  - Long headings (reduce verbosity)
  - Long URLs (move to footnotes or shorten descriptions)
  - Command examples (use code blocks with proper line breaks)
- **Estimated time:** 45 minutes

#### 3. `github/rules/README.md` (31 violations)
- **MD013:** Lines 3, 8, 9, 39-42, 65, 66, 265, 286, 288, 290, 292, 294, 325
- **MD031:** Lines 118, 175, 183, 188, 240, 251 (blank lines around code blocks)
- **MD032:** Lines 145, 235, 268 (blank lines around lists)
- **MD040:** Lines 118, 154 (add language to code blocks)
- **Strategy:** 
  - Fix code block spacing first
  - Add language tags to all code blocks
  - Then tackle line length
- **Estimated time:** 60 minutes

#### 4. `github/rules/Status checks/README.md` (19 violations)
- **MD013:** Lines 3, 9, 133, 193
- **MD031:** Line 407 (blank lines around code blocks)
- **MD032:** Lines 268, 285, 363, 372, 382, 394, 401, 447, 474 (blank lines around lists)
- **MD040:** Lines 475, 505 (add language to code blocks)
- **Strategy:** Same as README.md - spacing then language tags then line length
- **Estimated time:** 40 minutes

### Medium Priority (Supporting Docs)

#### 5. Root Level Files
- `README.md` (6 violations - MD013): Lines 3, 11, 12, 26, 36
- `misc/_TEMPLATE_guide.md` (1 violation - MD013): Line 11

#### 6. Windows Hello & Passkeys Guides
- `email.md` (5 violations - MD013): Lines 7, 11, 12, 13, 15
- `Google Passkey setup guide.md` (5 violations - MD013): Lines 5, 10, 17, 23, 47, 49, 56, 57, 60
- `Windows Hello setup guide.md` (1 violation - MD013): Line 15

---

## Recommended Fix Order

### Phase 1: High-Impact Quick Wins (30 min)
1. Add language tags to all code blocks (MD040)
   - Files: `github/rules/README.md`, `Status checks/README.md`
   - Commands: Add `powershell`, `bash`, `json`, `yaml`, etc.

### Phase 2: Fix Spacing Issues (60 min)
2. Add blank lines around code blocks (MD031)
3. Add blank lines around lists (MD032)
   - Files: `github/rules/README.md`, `Status checks/README.md`, `MEMORY_MCP_SERVER_FIX.md`
   - Simple: just add blank lines before/after blocks

### Phase 3: Line Length Reduction (90 min)
4. Fix MD013 violations systematically:
   - Start with `Copilot guides/MEMORY_MCP_SERVER_FIX.md` (smallest)
   - Move to root level files
   - Then tackle larger files

### Phase 4: Large Files (120+ min)
5. Fix `github/rules/github-branch-protection-and-status-checks.md` and `README.md`
   - These have the most violations
   - May require significant restructuring

---

## Tactics for Each Rule

### MD013 - Line Length
```markdown
# BAD (too long)
This is a very long line that talks about something important but goes over 80 characters and needs to be wrapped

# GOOD (wrapped)
This is a very long line that talks about
something important and is now within the
80 character limit
```

**For URLs:** Create footnotes or move to code blocks

```markdown
See the [documentation][1] for more details

[1]: https://very-long-url-here.com/path/to/docs
```

### MD031 - Blanks Around Fences
```markdown
# BAD (no blank before)
Some text
```bash
code
```

# GOOD (blank before and after)
Some text

```bash
code
```

More text
```

### MD032 - Blanks Around Lists
```markdown
# BAD (no blank before)
Some text
- Item 1
- Item 2

# GOOD (blank before and after)
Some text

- Item 1
- Item 2

More text
```

### MD040 - Language in Fences
```markdown
# BAD (no language)
```
code here
```

# GOOD (language specified)
```powershell
code here
```
```

---

## Tools to Use

1. **markdownlint CLI:** `markdownlint '**/*.md' --config misc/.markdownlint.jsonc`
   - Run after each file to verify fixes
   - Only show errors for the rules you're fixing

2. **VS Code Linter:** Real-time feedback as you edit
   - Settings already configured in `.vscode/settings.json`

3. **Search & Replace:** For systematic changes
   - Find patterns and replace globally where applicable

---

## Testing Your Fixes

After fixing each file:

```bash
# Test individual file
markdownlint 'Copilot guides/MEMORY_MCP_SERVER_FIX.md' --config misc/.markdownlint.jsonc

# Test all files to verify no regressions
markdownlint '**/*.md' --config misc/.markdownlint.jsonc
```

---

## Commits Strategy

Use conventional commit messages:

```bash
# For individual files
git commit -m "style: Fix markdown linting in Copilot guides/MEMORY_MCP_SERVER_FIX.md"

# For groups
git commit -m "style: Fix markdown line length violations in github/rules/"

# For large refactoring
git commit -m "refactor: Improve markdown formatting across documentation"
```

---

## Timeline Estimate

- **Phase 1:** 30 minutes
- **Phase 2:** 60 minutes  
- **Phase 3:** 90 minutes
- **Phase 4:** 120+ minutes

**Total:** ~5-6 hours of focused work

Can be split across multiple PRs if preferred.

---

## Notes

- This cleanup makes the repo more maintainable
- New files will already follow the rules (local linter enforces them)
- Focus on readability first, not just "passing the linter"
- Consider simplifying content where lines are too long (better for users too)
