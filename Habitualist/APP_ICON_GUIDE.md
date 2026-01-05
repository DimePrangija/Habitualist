# App Icon Setup Guide

The app icon is configured in `Habitualist/Assets.xcassets/AppIcon.appiconset/`.

## Current Status

The app icon asset catalog is set up and ready, but no icon images have been added yet.

## How to Add an App Icon

### Option 1: Using Xcode (Recommended)

1. Open the project in Xcode
2. Navigate to `Assets.xcassets` in the Project Navigator
3. Click on `AppIcon`
4. Drag and drop your icon images into the appropriate slots:
   - **Universal**: 1024x1024 px (required for App Store)
   - **Dark Appearance**: 1024x1024 px (optional, for dark mode)
   - **Tinted**: 1024x1024 px (optional, for tinted appearance)

### Option 2: Manual File Placement

1. Create your icon images:
   - `AppIcon-1024x1024.png` (1024x1024 pixels, RGB, no alpha)
   - Optionally: `AppIcon-dark-1024x1024.png` for dark mode
   - Optionally: `AppIcon-tinted-1024x1024.png` for tinted appearance

2. Place the files in: `Habitualist/Assets.xcassets/AppIcon.appiconset/`

3. The `Contents.json` file is already configured correctly - no changes needed.

## Icon Design Tips

For Habitualist, consider:
- **Theme**: Dark background with light blue accent (#A0CCD8)
- **Style**: Modern, minimal, related to habits/tracking
- **Symbols**: Could use a checkmark, calendar, or circular progress indicator
- **Colors**: Match the app's accent color (light blue) or use complementary colors

## Icon Requirements

- **Format**: PNG
- **Size**: 1024x1024 pixels (for App Store submission)
- **Color Space**: RGB
- **Alpha Channel**: Not required for standard icon (but can be used for dark mode variant)

## Design Tools

You can create icons using:
- **Design Software**: Figma, Sketch, Adobe Illustrator, Photoshop
- **Online Tools**: Canva, Icon Generator tools
- **AI Tools**: DALL-E, Midjourney (with refinement)
- **Simple Approach**: Use SF Symbols or system shapes in design tools

## Quick Icon Creation Tips

1. Start with a 1024x1024 canvas
2. Use the app's color scheme (#A0CCD8 accent, #2F2F2F dark background)
3. Keep it simple and recognizable at small sizes
4. Test how it looks on a home screen (use Xcode preview or device)
5. Ensure good contrast and visibility

## Testing the Icon

After adding your icon:
1. Build and run the app on a device/simulator
2. Check the home screen to see how it looks
3. Test on different backgrounds (light/dark)
4. Verify it looks good at various sizes

## Next Steps

Once you have your icon files:
1. Add them to the AppIcon asset catalog in Xcode
2. Build and run to verify
3. The icon will appear on the home screen and in the App Store

Note: For portfolio purposes, even a simple placeholder icon is better than the default Xcode icon!
