# Sandman - Pattern Library

Patterns and learnings captured during the systematic improvement of this project.

**Created:** 2025-11-19
**Methodology:** Multi-agent code perfection system (cot → cot+ → cot++)

---

## Pattern 1: User-Focused README Structure

**Context:** README.md must clearly communicate what the tool does, not the methodology used to build it.

**Problem:** Original README focused on development methodology instead of user value.

**Solution:**
- Lead with "What is it?" and "Key Features"
- Provide quick start commands for each platform
- Include platform support matrix
- Add troubleshooting section
- Reference methodology in Credits section only

**Application:** Use this structure for all user-facing documentation.

**Files:**
- `README.md` - Main project documentation

---

## Pattern 2: Cross-Platform Path Management

**Context:** Setup scripts need to reference files in organized folder structure.

**Problem:** Setup scripts looked for files in root directory when they were in `scripts/` folder.

**Solution:**
- Check for files in `scripts/` subdirectory
- Provide clear error messages with expected paths
- Document file structure in README

**Application:** Always validate paths in setup/installer scripts.

**Files:**
- `setup.cmd` - Windows setup script
- `setup.sh` - Linux/macOS setup script

---

## Pattern 3: Template-Driven Configuration

**Context:** Users need quick-start configurations for common use cases.

**Problem:** Only one generic template existed.

**Solution:**
- Create templates for different use cases:
  - **Minimal**: Low resources, basic functionality
  - **Secure**: No network, maximum isolation
  - **Development**: High resources, shared folders
  - **Full**: All features enabled

**Application:** Provide templates covering the 80% use cases.

**Files:**
- `templates/minimal-sandbox.wsb`
- `templates/secure-sandbox.wsb`
- `templates/development-sandbox.wsb`
- `templates/Full-Sandbox.wsb`

---

## Pattern 4: Progressive Documentation Structure

**Context:** Different users need different levels of detail.

**Problem:** Single README becomes overwhelming; users can't find what they need.

**Solution:**
Three-tier documentation structure:
1. **README.md**: Overview, quick start, high-level features
2. **QUICK_START.md**: Get running in 5 minutes
3. **USER_GUIDE.md**: Comprehensive feature documentation
4. **CROSS_PLATFORM.md**: Platform-specific details
5. **CONTRIBUTING.md**: Developer guidelines

**Application:** Split documentation by audience and use case.

**Files:**
- `README.md`
- `docs/QUICK_START.md`
- `docs/CONTRIBUTING.md`
- `docs/CROSS_PLATFORM.md`

---

## Pattern 5: Configuration with Sane Defaults

**Context:** Configuration files should work out-of-the-box but be customizable.

**Problem:** Users need to configure everything before use.

**Solution:**
- Provide `config.json` with working defaults
- Support platform-specific paths
- Include `includeCoAuthoredBy: false` as requested
- Document all options in comments or separate guide

**Application:** Always ship with working defaults.

**Files:**
- `config.json`

---

## Pattern 6: Repository Hygiene

**Context:** Clean repositories are easier to maintain and contribute to.

**Problem:** Duplicate files, no .gitignore, no LICENSE.

**Solution:**
- Remove duplicate files
- Add comprehensive `.gitignore`
- Add LICENSE file (MIT)
- Clean up temporary/generated files
- Document file structure

**Application:** Use `.gitignore` patterns for all temp files.

**Files:**
- `.gitignore`
- `LICENSE`

---

## Pattern 7: Platform-Specific Launchers

**Context:** Different platforms require different entry points.

**Problem:** Confusion about which script to run on which platform.

**Solution:**
- **Windows**: `sandman.ps1` (launcher) → `scripts/wsb-manager-enhanced.ps1`
- **Linux/macOS**: `scripts/sandman.sh` (direct script)
- **Setup**: `setup.cmd` (Windows), `setup.sh` (Linux/macOS)

**Application:** Provide clear, platform-specific entry points.

**Files:**
- `sandman.ps1`
- `scripts/sandman.sh`
- `setup.cmd`
- `setup.sh`

---

## Pattern 8: Validation Before Execution

**Context:** Sandboxes may fail to launch if configuration is invalid.

**Problem:** Users waste time launching sandboxes that can't work.

**Solution:**
- Validate memory ranges (256 MB - 131072 MB)
- Check that shared folders exist
- Validate allowed values for settings
- Offer to create missing folders
- Show validation results before launch

**Application:** Always validate before execution.

**Files:**
- All manager scripts include validation functions

---

## Pattern 9: Incremental Modification with Preview

**Context:** Making multiple changes to a configuration is tedious.

**Problem:** Each change required re-selecting the file.

**Solution:**
- Multi-modification mode: make multiple changes in one session
- Live preview: show current configuration after each change
- Save/Discard options: commit all changes or cancel
- Visual feedback: checkmarks for completed changes

**Application:** Batch UI operations for better UX.

**Files:**
- `scripts/wsb-manager-enhanced.ps1`

---

## Pattern 10: Systematic Issue Resolution

**Context:** Complex projects need systematic approach to improvements.

**Problem:** Ad-hoc fixes lead to incomplete solutions and rework.

**Solution:**
Multi-agent methodology:
1. **Scout**: Detect all issues, prioritize (P0-P3)
2. **Architect**: Map dependencies, determine execution order
3. **Strategist**: Create execution plan with priority scores
4. **Executor**: Implement batch by batch
5. **Validator**: Test after each change
6. **Documenter**: Capture patterns (this file!)
7. **Auditor**: Verify all issues resolved
8. **Certifier**: Clean up, final review

Formula: `(Urgency×10) + (Impact×5) - (Complexity×2) + (Enables×3)`

**Application:** Use for any non-trivial improvement project.

**Files:**
- `issues-inventory.json` (temp)
- `dependency-graph.json` (temp)
- `execution-plan.json` (temp)
- `pattern-library.md` (this file - kept)
- `project-resolution-log.md` (final output)

---

## Pattern 11: Context-Aware Error Messages

**Context:** Errors should guide users to solutions.

**Problem:** Generic error messages don't help users fix issues.

**Solution:**
- Specific error message: "Windows Sandbox is not available"
- Include cause: "Requires Windows 10 Pro/Enterprise or Windows 11"
- Provide fix: Step-by-step enable instructions or links
- Platform-specific solutions

**Application:** Every error should include the solution.

**Files:**
- All scripts
- `docs/QUICK_START.md` (troubleshooting section)

---

## Pattern 12: Comprehensive File Structure Documentation

**Context:** Users and contributors need to understand project organization.

**Problem:** Files scattered without clear purpose.

**Solution:**
- Document complete file tree in README
- Explain purpose of each directory
- Show which files users interact with
- Indicate platform-specific files

**Application:** Always include file structure diagram.

**Files:**
- `README.md` (File Structure section)

---

## Patterns Summary

| Pattern | Category | Impact | Reusability |
|---------|----------|--------|-------------|
| User-Focused README | Documentation | High | Very High |
| Cross-Platform Paths | Setup | Medium | High |
| Template-Driven Config | UX | High | Very High |
| Progressive Documentation | Documentation | High | Very High |
| Sane Defaults | Configuration | Medium | Very High |
| Repository Hygiene | Maintenance | Low | Very High |
| Platform-Specific Launchers | UX | Medium | High |
| Validation Before Execution | Reliability | High | Very High |
| Incremental Modification | UX | High | Medium |
| Systematic Issue Resolution | Process | Very High | Very High |
| Context-Aware Errors | UX | Medium | Very High |
| File Structure Documentation | Documentation | Medium | Very High |

---

## Lessons Learned

1. **User documentation ≠ Development methodology**: Users care about what the tool does, not how it was built.

2. **File organization matters**: Scattered files confuse users and break setup scripts.

3. **Templates accelerate adoption**: Pre-configured examples help users get started quickly.

4. **Validation saves time**: Catching errors before launch prevents frustration.

5. **Systematic > Ad-hoc**: Taking time to plan prevents rework and ensures completeness.

6. **Patterns compound**: Each pattern captured accelerates future work.

---

## Future Pattern Opportunities

- **Automated testing**: Pattern for cross-platform testing
- **Configuration migration**: Pattern for converting between .wsb and .sandbox formats
- **Template marketplace**: Pattern for sharing community templates
- **CI/CD integration**: Pattern for automated validation

---

**These patterns were discovered through systematic analysis and implementation. They represent reusable solutions for similar projects.**
