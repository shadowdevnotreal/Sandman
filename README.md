# Sandman - Multi-Agent Sandbox Management System

> **Measure twice, cut once** - A systematic approach to sandbox configuration perfection

## Overview

Sandman is an advanced, cross-platform sandbox management system powered by a multi-agent architecture (cot → cot+ → cot++). It combines the power of Windows Sandbox configuration with a systematic code quality framework that ensures precision, reliability, and continuous improvement.

---

## Multi-Agent Architecture

### Philosophy: Measure Twice, Cut Once

The system employs three sequential teams that transform chaos into systematic excellence:

```
┌─────────────────────────────────────────────────────────────┐
│  cot (Design)  →  cot+ (Implementation)  →  cot++ (Audit)  │
└─────────────────────────────────────────────────────────────┘
     Analysis           Execution              Verification
```

### The Three Phases

#### Phase 1: cot (Design Team)

**Agents:**
- **Scout**: Detects all issues across the codebase
  - Output: `issues-inventory.json` (P0/P1/P2/P3 priority)
  - Identifies bugs, inefficiencies, security concerns, and design flaws

- **Architect**: Maps dependencies and execution order
  - Output: `dependency-graph.json`
  - Prevents conflicts, ensures logical flow

- **Strategist**: Prioritizes and batches work
  - Output: `execution-plan.json`
  - Groups by feature/page for efficient execution
  - Priority formula: `(Urgency×10) + (Impact×5) - (Complexity×2) + (Enables×3)`

**Handoff**: Analysis complete, plan approved → cot+

---

#### Phase 2: cot+ (Implementation Team)

**Agents:**
- **Executor**: Implements one batch at a time
  - Completes entire batch before moving to next
  - Applies learned patterns from previous batches

- **Validator**: Tests immediately after each change
  - Blocks progression if any gate fails
  - Gates: Functionality ✓ No regressions ✓ Design match ✓ Responsive ✓ Performance ✓

- **Documenter**: Records patterns to `pattern-library.md`
  - Captures successful solutions
  - Accelerates future batches through pattern reuse

**Handoff**: All batches complete, tests passing → cot++

---

#### Phase 3: cot++ (Audit Team)

**Agents:**
- **Auditor**: Verifies all issues resolved
  - Cross-references against original `issues-inventory.json`
  - Ensures no new critical issues introduced

- **Regression**: Tests untouched areas
  - Full test suite execution
  - Visual diff comparison

- **Certifier**: Final approval and cleanup
  - Deletes temporary files
  - Generates `project-resolution-log.md`
  - Issues APPROVE or BLOCK decision

**Output**: Only `project-resolution-log.md` remains

---

## Incremental Logic Chain

```
Scout → Architect → Strategist → Executor → Validator → Documenter
  ↓        ↓           ↓            ↓          ↓           ↓
Plan   Structure   Prioritize   Implement   Test    Learn & Apply
  ↓                                                        ↓
(cot) ─────────────────────────────────────────────────→ (cot+) → (cot++)
                                                           ↓
                                            Patterns feed back to next cycle
```

**Key Insight**: The Documenter's patterns feed into the next Strategist cycle, creating a learning loop that accelerates work and reduces rework.

---

## Platform Support

Sandman works on **all major platforms**:

- **Windows**: PowerShell scripts + Windows Sandbox (.wsb)
- **Linux**: Bash scripts + systemd-nspawn / Docker
- **macOS**: Bash scripts + Docker / VM solutions

---

## Quick Start

### Windows (PowerShell)

```powershell
# Run the enhanced manager
PowerShell -ExecutionPolicy Bypass -File .\sandman.ps1

# Or with multi-agent system
.\multi-agent-orchestrator.ps1
```

### Linux/macOS (Bash)

```bash
# Make executable
chmod +x sandman.sh

# Run the manager
./sandman.sh

# Or with multi-agent system
./multi-agent-orchestrator.sh
```

---

## Features

### Core Capabilities

- **Create** sandbox configurations with guided wizards
- **List** all sandbox configurations with metadata
- **Edit** configurations in your preferred editor
- **Validate** configurations before deployment
- **Modify** configurations with interactive menus
- **Launch** sandboxes with pre-flight validation
- **Multi-change mode** for batch modifications

### Multi-Agent Features

- **Automated issue detection** across entire project
- **Dependency mapping** to prevent conflicts
- **Smart prioritization** based on impact and urgency
- **Pattern learning** that accelerates future work
- **Comprehensive validation** at every step
- **Regression testing** to ensure quality
- **Audit trail** in `project-resolution-log.md`

---

## Configuration

### Configuration File: `config.json`

```json
{
  "version": "1.0.0",
  "workspace": {
    "windows": "%USERPROFILE%\\Documents\\wsb-files",
    "linux": "~/.local/share/sandman",
    "macos": "~/Library/Application Support/Sandman"
  },
  "git": {
    "includeCoAuthoredBy": false,
    "autoCommit": false,
    "commitTemplate": "feat: ${description}"
  },
  "editor": {
    "windows": "notepad.exe",
    "linux": "nano",
    "macos": "nano"
  },
  "sandbox": {
    "defaultMemoryMB": 4096,
    "defaultNetworking": "Default",
    "autoBackup": true
  },
  "multiAgent": {
    "enabled": true,
    "cleanupTempFiles": true,
    "keepResolutionLog": true,
    "priorityFormula": {
      "urgency": 10,
      "impact": 5,
      "complexity": -2,
      "enables": 3
    }
  }
}
```

### Customizing Paths

Edit `.cmd` or `.sh` files to match your local system:

**Windows** (`setup.cmd`):
```batch
@echo off
REM Edit these paths for your system
SET SANDMAN_HOME=C:\Tools\Sandman
SET WORKSPACE=%USERPROFILE%\Documents\wsb-files

REM Add pre-installed tools here
choco install -y git nodejs python
```

**Linux/macOS** (`setup.sh`):
```bash
#!/bin/bash
# Edit these paths for your system
export SANDMAN_HOME="$HOME/.local/share/sandman"
export WORKSPACE="$HOME/.local/share/sandman/workspaces"

# Add pre-installed tools here
sudo apt-get install -y git nodejs python3 docker.io
```

---

## File Structure

```
Sandman/
├── README.md                          # This file
├── config.json                        # Configuration file
├── sandman.ps1                        # Main PowerShell script
├── sandman.sh                         # Main Bash script
├── multi-agent-orchestrator.ps1       # Multi-agent system (Windows)
├── multi-agent-orchestrator.sh        # Multi-agent system (Linux/macOS)
├── setup.cmd                          # Windows installer
├── setup.sh                           # Linux/macOS installer
│
├── agents/                            # Multi-agent system modules
│   ├── scout.ps1 / scout.sh          # Issue detection
│   ├── architect.ps1 / architect.sh  # Dependency mapping
│   ├── strategist.ps1 / strategist.sh # Prioritization
│   ├── executor.ps1 / executor.sh    # Implementation
│   ├── validator.ps1 / validator.sh  # Testing & validation
│   ├── documenter.ps1 / documenter.sh # Pattern recording
│   ├── auditor.ps1 / auditor.sh      # Final verification
│   ├── regression.ps1 / regression.sh # Regression testing
│   └── certifier.ps1 / certifier.sh  # Cleanup & certification
│
├── templates/                         # Sandbox templates
│   ├── full-sandbox.wsb              # Full-featured template
│   ├── secure-sandbox.wsb            # Security-focused template
│   └── minimal-sandbox.wsb           # Minimal template
│
├── docs/                             # Documentation
│   ├── MULTI_AGENT_GUIDE.md         # Multi-agent system guide
│   ├── QUICK_REFERENCE.md           # Quick reference
│   ├── CROSS_PLATFORM.md            # Cross-platform notes
│   └── CONTRIBUTING.md              # Contribution guidelines
│
└── Win-Sand-Box/                     # Legacy Windows-specific files
    ├── wsb-manager-fixed.ps1
    ├── wsb-manager-enhanced.ps1
    └── [documentation files]
```

---

## The Discipline of Command

### The Three Laws

1. **Clarity before Velocity**
   - Sharpen your command until confusion is impossible

2. **Structure before Dialogue**
   - Every great prompt: Context → Goal → Process → Output → Tone → Constraints

3. **Reflection before Closure**
   - Ask: "What pattern did this reveal?" Insight is recursive

### Disciplines of Directed Dialogue

- Speak with purpose, not confusion
- Establish authority early
- Demand reflection, not regurgitation

*These aren't prompts. They're protocols — a language of command for cognition.*

---

## Usage Examples

### Basic Usage

```powershell
# Windows - Create a new sandbox
.\sandman.ps1
# Press [1] Create new .wsb
# Follow the prompts

# Linux/macOS - List all sandboxes
./sandman.sh
# Press [2] List sandbox configurations
```

### Multi-Agent Workflow

```bash
# Run the complete multi-agent system
./multi-agent-orchestrator.sh

# The system will:
# 1. Scout for issues → issues-inventory.json
# 2. Map dependencies → dependency-graph.json
# 3. Create execution plan → execution-plan.json
# 4. Execute batch by batch
# 5. Validate each change
# 6. Document patterns → pattern-library.md
# 7. Audit final state
# 8. Generate project-resolution-log.md
```

### Advanced Configuration

```powershell
# Modify sandbox with multiple changes
.\sandman.ps1
# Press [5] Modify
# Select sandbox
# Make multiple changes
# Press [11] SAVE & EXIT
```

---

## Quality Gates

Every change must pass these gates:

1. **Functionality** ✓ - Works as intended
2. **No Regressions** ✓ - Existing features still work
3. **Design Match** ✓ - Follows design specifications
4. **Responsive** ✓ - Works across devices/platforms
5. **Performance** ✓ - Meets performance benchmarks

---

## Final Principles

- **Measure Twice, Cut Once**: Thorough planning prevents rework
- **One Thing at a Time**: Complete batches fully before advancing
- **Learn and Apply**: Capture patterns, accelerate future work
- **Clean as You Go**: Leave no mess behind
- **Document Concisely**: Minimal but sufficient for continuation
- **Quality Over Speed**: But achieve both through systematic approach

---

## Installation

### Windows

```powershell
# Clone or download the repository
git clone https://github.com/yourusername/sandman.git
cd sandman

# Run setup (installs dependencies, creates workspace)
.\setup.cmd

# Start using Sandman
.\sandman.ps1
```

### Linux

```bash
# Clone the repository
git clone https://github.com/yourusername/sandman.git
cd sandman

# Run setup
chmod +x setup.sh
./setup.sh

# Start using Sandman
./sandman.sh
```

### macOS

```bash
# Clone the repository
git clone https://github.com/yourusername/sandman.git
cd sandman

# Run setup
chmod +x setup.sh
./setup.sh

# Start using Sandman
./sandman.sh
```

---

## Roadmap

### Current (v1.0)

- [x] Windows Sandbox manager
- [x] Multi-modification mode
- [x] Live configuration preview
- [x] Validation system
- [x] Comprehensive documentation

### Next (v2.0)

- [ ] Cross-platform shell scripts
- [ ] Multi-agent orchestrator
- [ ] Pattern learning system
- [ ] Automated dependency mapping
- [ ] Configuration management

### Future (v3.0)

- [ ] Template marketplace
- [ ] Cloud sandbox support
- [ ] Team collaboration features
- [ ] CI/CD integration
- [ ] Advanced security scanning

---

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the multi-agent system to validate
5. Submit a pull request

---

## Support

### Documentation

- [Multi-Agent Guide](docs/MULTI_AGENT_GUIDE.md) - Deep dive into the multi-agent system
- [Quick Reference](docs/QUICK_REFERENCE.md) - Common commands and options
- [Cross-Platform Notes](docs/CROSS_PLATFORM.md) - Platform-specific information

### Getting Help

1. Check the documentation in `docs/`
2. Review error messages and validation output
3. Run the validator: Option [4]
4. Open an issue on GitHub

---

## License

MIT License - See LICENSE file for details

---

## Credits

Built with the multi-agent code perfection framework:
- **Design Team** (cot): Scout, Architect, Strategist
- **Implementation Team** (cot+): Executor, Validator, Documenter
- **Audit Team** (cot++): Auditor, Regression, Certifier

*Measure twice, cut once.*

---

## Version History

### v1.0.0 (Current)
- Initial release with Windows Sandbox support
- Multi-modification mode
- Enhanced validation system
- Comprehensive documentation

### v2.0.0 (In Progress)
- Cross-platform support
- Multi-agent orchestrator
- Configuration management
- Automated installation

---

**Made with precision and care by the Sandman team.**
