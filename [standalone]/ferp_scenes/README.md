# FERP Scenes

3D text scene creator with multi-language support. Inspired by and based on concepts from [dpscenes](https://github.com/andristum/dpscenes).

## Requirements

- `qbx_core`
- `ox_lib`
- `ox_target`
- `oxmysql`

 Import `data.sql` into your database

## Configuration

Edit `shared/config.lua` to adjust:

- `Config.Language` - Language (`'en'` or `'pt'`)
- `Config.DefaultDuration` - Default duration in hours
- `Config.MaxScenesPerPlayer` - Scenes limit per player
- `Config.MaxScenesGlobal` - Total scenes limit on server
- `Config.Fonts`, `Config.FontSizes`, `Config.Colors`, `Config.BackgroundStyles` - Available options

## Commands

**Client:**
- `/scene` - Create a new scene (aim at location)
- `/togglescenes` - Toggle scenes visibility

**Server (Admin):**
- `/deletescene [id]` - Delete a specific scene
- `/listscenes` - List all scenes
- `/scenescount` - Show scene count
- `/clearscenes` - Delete all scenes

## How to Use

1. Use `/scene` and aim at the location where you want to create the scene
2. Fill in the data (text, color, font, size, distance, duration, etc)
3. Interact with the scene using `ox_target` to reveal, hide, or delete
4. Hidden scenes are only visible if revealed

## Features

- ✅ Create 3D text scenes with custom styling
- ✅ Custom fonts and backgrounds from stream folder
- ✅ Adjustable background dimensions (width/height)
- ✅ Scene persistence in database
- ✅ Admin and creator-based permissions
- ✅ Auto-cleanup of expired scenes
- ✅ Multi-language support (EN, PT)
- ✅ ox_target integration for scene management

## Permissions

- Admins (groups in `Config.AdminGroups`) can delete and edit any scene
- Creators can delete and edit their own scenes
- Only admins can create scenes if `Config.AdminOnly = true`

## Translation

Add new languages by creating `locale/[code].json` with the required keys and change `Config.Language` in `shared/config.lua`.

## Credits

- **[dpscenes](https://github.com/andristum/dpscenes)**

## License

This project is licensed under the **GNU General Public License v3.0** - see the LICENSE file for details.

### License Summary

You are free to:
- Use this software for any purpose
- Modify the source code
- Distribute modified versions

**Conditions:**
- Include a copy of the license
- Disclose the source code
- State significant changes made
- Use the same license for derivative works
