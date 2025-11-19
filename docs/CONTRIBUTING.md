# Contributing to Sandman

Thank you for your interest in contributing to Sandman! This document provides guidelines and information for contributors.

---

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors.

### Expected Behavior

- Be respectful and considerate
- Provide constructive feedback
- Focus on what is best for the project
- Show empathy towards other contributors

### Unacceptable Behavior

- Harassment or discriminatory language
- Personal attacks
- Trolling or inflammatory comments
- Publishing others' private information

---

## How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Create a new issue** with:
   - Clear, descriptive title
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment (OS, version, etc.)
   - Screenshots if applicable

### Suggesting Features

1. **Search existing feature requests**
2. **Create a new issue** with:
   - Clear description of the feature
   - Use case and benefits
   - Possible implementation approach
   - Any relevant examples

### Pull Requests

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/your-feature-name`
3. **Make your changes**
4. **Test thoroughly** on all platforms if possible
5. **Commit with clear messages**
6. **Push to your fork**
7. **Create a pull request**

---

## Development Workflow

### Setting Up Development Environment

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/Sandman.git
cd Sandman

# Add upstream remote
git remote add upstream https://github.com/shadowdevnotreal/Sandman.git

# Create a branch
git checkout -b feature/my-feature
```

### Making Changes

1. **Write clear code**
   - Follow existing code style
   - Add comments for complex logic
   - Keep functions focused and small

2. **Test your changes**
   - Test on your platform
   - If possible, test on multiple platforms
   - Validate sandbox configurations work

3. **Update documentation**
   - Update README if needed
   - Add/update docs in `docs/` folder
   - Update CHANGELOG.md

### Commit Messages

Follow this format:

```
type: brief description

Detailed explanation if needed

Fixes #issue_number
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding/updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat: add template export feature

Added ability to export pre-configured sandbox templates
for quick setup.

Fixes #42
```

```
fix: correct setup.cmd path references

Updated setup.cmd to reference scripts in the scripts/ folder
instead of root directory.

Fixes #15
```

### Syncing with Upstream

```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream main into your branch
git checkout main
git merge upstream/main

# Rebase your feature branch
git checkout feature/my-feature
git rebase main
```

---

## Code Style Guidelines

### PowerShell

- Use clear, descriptive variable names
- Add comments for complex logic
- Use proper error handling (`try/catch`)
- Follow existing indentation (2 spaces)

```powershell
# Good
function Get-SandboxConfig {
    param([string]$ConfigPath)

    try {
        $config = Get-Content $ConfigPath
        return $config
    } catch {
        Write-Error "Failed to load config: $_"
        return $null
    }
}
```

### Bash

- Use `set -e` for error handling
- Quote variables: `"$variable"`
- Use functions for repeated logic
- Follow existing indentation (2 spaces)

```bash
# Good
load_config() {
    local config_file="$1"

    if [[ ! -f "$config_file" ]]; then
        echo "Error: Config file not found"
        return 1
    fi

    source "$config_file"
}
```

### Documentation

- Use clear, concise language
- Include examples
- Keep line length reasonable (80-100 characters)
- Use proper markdown formatting

---

## Testing

### Manual Testing Checklist

- [ ] Script runs without errors
- [ ] All menu options work
- [ ] Configurations are created correctly
- [ ] Validation catches errors
- [ ] Sandboxes launch successfully
- [ ] Backups are created when expected

### Platform-Specific Testing

**Windows:**
- Test with PowerShell 5.1 and 7+
- Verify Windows Sandbox launches
- Check `.wsb` XML validation

**Linux:**
- Test with Docker backend
- Test with systemd-nspawn (if available)
- Verify `.sandbox` file format

**macOS:**
- Test with Docker Desktop
- Verify path handling
- Check file permissions

---

## Pull Request Process

### Before Submitting

1. **Rebase on latest main**
2. **Run all tests**
3. **Update documentation**
4. **Check code style**
5. **Write clear PR description**

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation update
- [ ] Refactoring
- [ ] Other (specify)

## Testing
- [ ] Tested on Windows
- [ ] Tested on Linux
- [ ] Tested on macOS

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Commits have clear messages
```

### Review Process

1. Maintainers will review your PR
2. Address any feedback
3. Once approved, PR will be merged
4. Your contribution will be credited!

---

## Development Methodology

This project follows a systematic approach:

### Planning
- **Clarity before Velocity**: Understand the problem fully before coding
- **Structure before Dialogue**: Plan the architecture and approach

### Implementation
- **One Thing at a Time**: Focus on completing one feature fully
- **Test Immediately**: Validate each change before moving forward

### Quality
- **Learn and Apply**: Capture patterns for future use
- **Clean as You Go**: Leave code better than you found it

---

## Project Structure

```
Sandman/
├── scripts/          # Platform-specific scripts
│   ├── wsb-manager-enhanced.ps1  # PowerShell (Windows)
│   └── sandman.sh                 # Bash (Linux/macOS)
├── templates/        # Sandbox templates
├── docs/             # Documentation
├── config.json       # Configuration file
└── setup.*           # Setup scripts
```

---

## Recognition

Contributors will be:
- Listed in project credits
- Mentioned in CHANGELOG.md
- Thanked in release notes

---

## Questions?

- **Create an issue** for general questions
- **Start a discussion** for ideas and proposals
- **Check docs** for technical information

---

## License

By contributing to Sandman, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Sandman! Your efforts make this project better for everyone.**
