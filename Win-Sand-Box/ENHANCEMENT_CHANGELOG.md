# Windows Sandbox Manager - Enhanced Version (v3)

## 🎉 What's New

### Major UX Improvements

#### 1. **Multi-Modification Mode** 🔄
**Before:**
- Make ONE change → Save → Back to main menu
- Want to make 5 changes? Go through the selection process 5 times

**After:**
- Select a file once
- Make unlimited changes
- See live preview of current configuration
- Choose when to save or discard
- Much faster workflow!

#### 2. **Live Configuration Preview** 👁️
Every time you return to the modification menu, you see:
```
=== Current Configuration ===
Memory: 4096 MB
Networking: Default
VGpu: Default
...
Mapped Folders:
  [1] C:\myshare (ReadOnly: true)
==============================
```

#### 3. **Better Menu Options**
New modification menu includes:
- `[11] --- SAVE & EXIT ---` - Save all changes and return to main menu
- `[12] --- DISCARD & EXIT ---` - Abandon all changes with confirmation
- `[13] Open raw file in Notepad` - Edit XML directly, with save/reload options

#### 4. **Change Tracking** ⚠️
- Clear indicator when you have unsaved changes
- Confirmation before discarding changes
- No accidental data loss

#### 5. **Current Value Display** 📊
When modifying settings, you see the current value:
```
Memory MB (current: 4096) [256-131072]:
Networking (current: Default) [Default/Disable]:
```

#### 6. **Visual Feedback** ✅
After each modification:
```
✓ ProtectedClient=Enable
✓ Memory set to 8192 MB
✓ Added mapped folder
```

---

## 🐛 Bug Fixes

### 1. **Backup File Error** (Fixed)
**Before:**
```
Copy-Item : Could not find file 'C:\...\file.wsb.bak'
```

**After:**
- Added try-catch error handling
- Graceful degradation if backup fails
- Warning message instead of crash

### 2. **Better Error Messages**
- More informative error messages
- Color-coded warnings and errors
- Suggested actions for problems

---

## 📋 Complete Enhancement List

### Functional Improvements
1. ✅ Multi-modification loop - make multiple changes before saving
2. ✅ Live configuration preview after each change
3. ✅ Unsaved changes indicator
4. ✅ Confirmation before discarding changes
5. ✅ Current value display in prompts
6. ✅ Enhanced save/discard workflow
7. ✅ Backup error handling with try-catch
8. ✅ Visual feedback with checkmarks
9. ✅ Brief pause after changes for readability

### UX Improvements
1. ✅ Clear screen between modifications (less clutter)
2. ✅ File name displayed at top of modify screen
3. ✅ Color-coded status messages (Green=success, Yellow=warning, Red=error)
4. ✅ Better menu organization with separators
5. ✅ Consistent prompt formatting

### Technical Improvements
1. ✅ Added `Show-CurrentConfig` helper function
2. ✅ Improved state management in Action-Modify
3. ✅ Better error handling throughout
4. ✅ Cleaner code organization

---

## 🎯 Usage Example

### Old Workflow (v2):
```
1. Select option [5] Modify
2. Choose file #2
3. Toggle ProtectedClient → Saves immediately
4. Back to main menu
5. Select option [5] Modify again
6. Choose file #2 again
7. Set Memory → Saves immediately
8. Back to main menu
9. Select option [5] Modify again...
```

### New Workflow (v3):
```
1. Select option [5] Modify
2. Choose file #2
3. See current configuration
4. Toggle ProtectedClient ✓
5. See updated configuration
6. Set Memory ✓
7. See updated configuration
8. Add mapped folder ✓
9. See updated configuration
10. Select [11] SAVE & EXIT
11. All changes saved at once!
```

**Result:** Much faster and more intuitive! 🚀

---

## 🔧 How to Use Enhanced Version

### Installation
1. Replace your current `wsb-manager.ps1` with `wsb-manager-enhanced.ps1`
2. Run: `PowerShell -ExecutionPolicy Bypass -File .\wsb-manager-enhanced.ps1`

### Key Features to Try

**Multi-Change Session:**
```
1. Choose [5] Modify
2. Select your file
3. Make multiple changes
4. Review the live preview after each change
5. Choose [11] to save everything or [12] to discard
```

**Edit and Reload:**
```
1. In modify mode, choose [13] Open raw file
2. Edit XML directly in Notepad
3. Save and close Notepad
4. Choose 'y' to reload the file
5. Continue making changes in the UI
```

**Current Value Reference:**
Every prompt now shows you the current setting, so you know what you're changing from.

---

## 🆚 Version Comparison

| Feature | v2 (Original) | v3 (Enhanced) |
|---------|--------------|---------------|
| Changes per session | 1 | Unlimited |
| Live preview | ❌ | ✅ |
| Current value display | ❌ | ✅ |
| Save confirmation | Auto-save | User choice |
| Discard option | ❌ | ✅ with warning |
| Change tracking | ❌ | ✅ |
| Visual feedback | Minimal | ✅ Checkmarks & colors |
| Backup error handling | Crash | ✅ Graceful |
| File name display | ❌ | ✅ |
| Clear screen | ❌ | ✅ |

---

## 💡 Tips & Best Practices

1. **Use Multi-Change Mode** - Plan your changes and do them all at once
2. **Check the Preview** - Review the configuration before saving
3. **Save Frequently** - Use [11] to save after major changes
4. **Use [12] Discard** - If you mess up, just discard and start over
5. **Combine UI + Notepad** - Use [13] for complex XML edits when needed

---

## 🔮 Future Enhancement Ideas

Potential improvements for v4:
- Undo/Redo functionality
- Bulk operations across multiple files
- Configuration templates
- Import/Export profiles
- Keyboard shortcuts (arrow key navigation)
- Search/filter for large file lists
- Configuration diff viewer
- Quick-edit mode for common changes

---

## 📝 Technical Notes

### Error Handling
All file operations now have try-catch blocks and provide meaningful error messages instead of crashing.

### State Management
The `$changesMade` flag tracks whether any modifications have been made, enabling:
- Unsaved changes warning
- Smart save/discard logic
- Skip save if no changes

### Performance
Brief pauses (500ms) after each change provide visual feedback without being annoying.

---

## 🙏 Credits

**v3 Enhanced** - Improved UX, multi-modification mode, better error handling
**v2 Fixed** - Fixed syntax errors (Unicode dashes, extra parenthesis)
**v1 Original** - Core functionality

---

## 📞 Support

If you encounter issues:
1. Check that you're using PowerShell 5.1+
2. Ensure Windows Sandbox is enabled
3. Verify execution policy allows script execution
4. Check that the workspace directory exists and is writable

---

**Enjoy the enhanced Windows Sandbox Manager! 🎉**
