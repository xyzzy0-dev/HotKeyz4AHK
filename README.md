# HotKeyz4AHK

A comprehensive GUI-based hotkey and hotstring manager for AutoHotkey v2.0 that allows you to easily create, edit, and manage keyboard shortcuts and text expansions.

## Features

- **Dual Management Interface**: Separate sections for managing both hotkeys and hotstrings
- **Visual List Views**: See all your shortcuts at a glance with description, trigger, and expansion text
- **Easy Editing**: Double-click any entry to edit it, or use the dedicated Edit buttons
- **JSON Configuration**: All settings stored in a human-readable `config.json` file
- **No Restart Required**: Add, edit, or delete shortcuts on the fly without restarting
- **Duplicate Prevention**: Built-in validation prevents conflicting shortcuts
- **User-Friendly Display**: Hotkeys shown in readable format (e.g., "Ctrl-Shift-A" instead of "^+a")

## Requirements

- AutoHotkey v2.0
- JSON.ahk library (must be in your Lib folder)

## Installation

1. Ensure AutoHotkey v2.0 is installed on your system
2. Place the `JSON.ahk` library in your AutoHotkey Lib folder
3. Save the script as `HotKeyz4AHK.ahk`
4. Run the script

On first run, if no `config.json` exists, you'll be prompted to create one automatically.

## Usage

### Adding a Hotkey

1. Click the **Add Hotkey** button
2. Enter a description (e.g., "Email signature")
3. Press your desired key combination in the Hotkey field
4. Enter the text you want to insert
5. Click **Save Hotkey**

### Adding a Hotstring

1. Click the **Add Hotstring** button
2. Enter a description (e.g., "BTW expansion")
3. Type the trigger text (e.g., "btw")
4. Enter the replacement text (e.g., "by the way")
5. Click **Save Hotstring**

### Editing Entries

- Double-click any entry in either list, or
- Select an entry and click the **Edit** button

### Deleting Entries

1. Select an entry in either list
2. Click the **Delete** button
3. Confirm the deletion

## Configuration File

The `config.json` file stores all your hotkeys and hotstrings in the following format:

```json
{
  "hotkeys": {
    "^+a": {
      "text": "expansion text here",
      "description": "My hotkey description"
    }
  },
  "hotstrings": {
    ":T:btw": {
      "text": "by the way",
      "description": "BTW expansion"
    }
  }
}
```

## Hotkey Format

When entering hotkeys, use standard AutoHotkey modifier symbols:
- **Ctrl**: Press and hold Ctrl while pressing another key
- **Alt**: Press and hold Alt while pressing another key
- **Shift**: Press and hold Shift while pressing another key
- **Win**: Press and hold Windows key while pressing another key

The display automatically formats these as "Ctrl-", "Alt-", "Shift-", and "Win-" for readability.

## Hotstring Behavior

All hotstrings use the `:T:` option, which sends the replacement text in text mode (raw characters) rather than as simulated keystrokes. This prevents issues with special characters being misinterpreted. Hotstrings will trigger after you type an ending character (like Space, Enter, or punctuation).

## Tips

- Use descriptive names to easily identify your shortcuts
- Test your hotkeys after creation to ensure they work as expected
- Back up your `config.json` file to preserve your configuration
- Avoid using hotkeys that conflict with system or frequently-used application shortcuts

## Troubleshooting

**Script won't start**: Ensure you have AutoHotkey v2.0 (not v1.1) and the JSON.ahk library is properly installed.

**Hotkeys not working**: Check that another application isn't already using the same key combination.

**Config file errors**: Delete `config.json` and restart the script to create a fresh configuration file.

## License

MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
