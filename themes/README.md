# Sandman Themes

Custom terminal themes for the Sandman UI.

## Available Themes

| Theme | Description | Style |
|-------|-------------|-------|
| **default** | Professional theme with balanced colors | Default |
| **cyberpunk** | Neon-lit futuristic theme | 🌃 Neon |
| **matrix** | Green on black Matrix-style | 💚 Hacker |
| **minimalist** | Clean black and white | ⬜ Simple |
| **ocean** | Calming ocean blue theme | 🌊 Peaceful |

## How to Use

### PowerShell Version

Edit `config.json` and set the theme:

```json
{
  "ui": {
    "theme": "cyberpunk"
  }
}
```

### Python/Web Version

Themes are automatically detected and can be selected in the web UI.

## Creating Custom Themes

Create a new JSON file in the `themes/` directory:

```json
{
  "name": "MyTheme",
  "description": "My custom theme",
  "colors": {
    "primary": "#hexcode",
    "success": "#hexcode",
    "danger": "#hexcode",
    "warning": "#hexcode",
    "info": "#hexcode",
    "muted": "#hexcode",
    "background": "#hexcode",
    "foreground": "#hexcode"
  },
  "prompts": {
    "info": "[i]",
    "success": "[+]",
    "error": "[!]",
    "warning": "[~]",
    "question": "[?]"
  }
}
```

## Theme Properties

- **colors**: Color scheme for UI elements
- **prompts**: Custom prompt symbols
- **ascii_art** (optional): ASCII art for headers/banners

## Examples

### Cyberpunk Theme
```
[>] Loading Sandman...
[√] Configuration loaded
[X] Error occurred
```

### Matrix Theme
```
>>> Initializing...
[OK] Ready
[ERR] Failed
```

### Ocean Theme
```
🌊 Welcome to Sandman
✓ Success
✗ Error
```

## Contributing

Create your own theme and share it! Themes should:
- Have good contrast
- Be readable
- Follow the JSON schema
- Include a clear description
