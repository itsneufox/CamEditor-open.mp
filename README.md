# CamEditor - Camera Movement Tool for open.mp

## Overview
CamEditor is a filterscript that allows you to create smooth camera movements directly in-game. This tool makes it easy to design cinematic sequences, cutscenes, and server intros without needing external editing software.

## Features
- **Intuitive 3D Navigation**: Easily fly around your map using an advanced fly mode
- **Point-and-Click Positioning**: Set camera positions with simple mouse clicks
- **Complete Editing Control**: Modify start points, end points, speeds, and rotations at any time
- **Real-Time Preview**: Instantly preview your camera movements before saving
- **Export Functionality**: Save camera movements as ready-to-use code snippets

## Language Support
The filterscript is available in:
- English
- Portuguese

## Installation
1. Download the `cameditor.pwn` file
2. Place it in your server's `filterscripts` folder
3. Compile the script using your preferred compiler
4. Add `cameditor` to your config json

## Commands
- `/cameditor` - Activate the camera editor tool
- `/closecameditor` - Exit the camera editor at any time

## Usage Guide

### Creating a Camera Movement
1. Type `/cameditor` to launch the tool
2. Use W, A, S, D keys (or your configured movement keys) to navigate in 3D space
3. Position your camera at the desired starting point
4. Press the Fire key (usually LMB) to set the starting position
5. Navigate to where you want the camera movement to end
6. Press the Fire key again to set the ending position
7. Configure the movement and rotation speeds in the dialog box
8. Preview, adjust, and save your camera movement

### Editing Options
After setting up a camera movement, you can:
- **Preview**: Watch your camera movement in real-time
- **Modify Start Point**: Reposition the starting camera location
- **Modify End Point**: Reposition the ending camera location
- **Adjust Speeds**: Fine-tune movement and rotation durations
- **Save**: Export your movement as ready-to-use code snippets

## Output Example
When you save a camera movement, the script generates code like this in your `scriptfiles` folder:

```pawn
|----------MyMovement----------|
InterpolateCameraPos(playerid, 575.325988, -1244.656127, 25.845386, 735.324829, -1128.916870, 73.661872, 7777);
InterpolateCameraLookAt(playerid, 571.176696, -1247.412109, 26.278436, 733.528747, -1124.687866, 71.689620, 7777);
```

Simply copy and paste this code into your gamemode or filterscript for perfect camera movements!

## Credits
- **Drebin** - Original creation and concept
- **itsneufox** - Updating for open.mp compatibility
- **h02** - Base flymode functionality

## Feedback and Support
If you encounter any issues or have suggestions for improvement, please create an issue on this GitHub repository or contact me through the open.mp discord.

---

*Note: This tool is designed for server developement. Use in production servers should be restricted to administrators only.*