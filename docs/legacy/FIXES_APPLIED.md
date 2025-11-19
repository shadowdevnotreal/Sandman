# PowerShell Script Fixes Applied

## Summary
Fixed 3 syntax errors in `wsb-manager.ps1` that were preventing script execution.

---

## Errors Fixed

### 1. Line 137 - Unicode En-Dash Character
**Error Type:** Character encoding issue  
**Symptom:** `Unexpected token '$MaxMemoryMB' in expression or statement`

**BEFORE (broken):**
```powershell
$errs += "MemoryInMB out of range ($MinMemoryMB–$MaxMemoryMB): $m"
                                               ↑ Unicode en-dash (U+2013)
```

**AFTER (fixed):**
```powershell
$errs += "MemoryInMB out of range ($MinMemoryMB-$MaxMemoryMB): $m"
                                               ↑ ASCII hyphen
```

---

### 2. Line 303 - Unicode En-Dash Character
**Error Type:** Character encoding issue  
**Symptom:** Parser confusion with special character

**BEFORE (broken):**
```powershell
$m = Read-Host "Memory MB ($MinMemoryMB–$MaxMemoryMB)"
                                      ↑ Unicode en-dash (U+2013)
```

**AFTER (fixed):**
```powershell
$m = Read-Host "Memory MB ($MinMemoryMB-$MaxMemoryMB)"
                                      ↑ ASCII hyphen
```

---

### 3. Line 372 - Extra Closing Parenthesis
**Error Type:** Syntax error  
**Symptom:** `Missing statement block after if ( condition )`

**BEFORE (broken):**
```powershell
if (Confirm-Y "Validation passed. Launch Sandbox with this file? (y/N)")) {
                                                                       ↑↑ Extra parenthesis
```

**AFTER (fixed):**
```powershell
if (Confirm-Y "Validation passed. Launch Sandbox with this file? (y/N)") {
                                                                       ↑ Single parenthesis
```

---

## Root Causes

1. **Character Encoding Issues**: Unicode en-dash characters (–) were used instead of ASCII hyphens (-), likely from:
   - Copy/paste from formatted documents (Word, PDF, web pages)
   - Text editors with "smart typography" features
   - Encoding conversion during file transfer

2. **Typo**: Extra closing parenthesis in if statement condition

---

## How to Use the Fixed Script

1. **Download the fixed file**: `wsb-manager-fixed.ps1`

2. **Run with bypass** (one-time execution):
   ```powershell
   PowerShell -ExecutionPolicy Bypass -File .\wsb-manager-fixed.ps1
   ```

3. **OR unblock the file** (for repeated use):
   ```powershell
   Unblock-File -Path .\wsb-manager-fixed.ps1
   .\wsb-manager-fixed.ps1
   ```

4. **OR set execution policy** (permanent solution):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   .\wsb-manager-fixed.ps1
   ```

---

## Script Purpose
Windows Sandbox (.wsb) configuration manager that provides:
- Create new sandbox configurations
- List existing .wsb files
- Edit configurations in Notepad
- Validate configuration files
- Modify settings (memory, networking, vGPU, mapped folders)
- Export sample templates
- Launch sandbox with validation

---

## Verification
All syntax errors have been resolved. The script should now:
✅ Parse without errors
✅ Execute properly with correct execution policy
✅ Provide interactive menu for sandbox management
