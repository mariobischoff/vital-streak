# Spec 06: Visual Language System - Vital Streak

This specification defines the unified visual identity for the 'Vital Streak' app, ensuring a premium, modern, and wellness-centered experience.

## 1. Design Philosophy
- **Minimalistic & Modern**: Clean layouts with significant white space to reduce cognitive load.
- **Wellness & Energy**: Balancing clinical reliability with gamified motivation.
- **Fluidity**: Transitions and visual elements should feel alive and continuous.

## 2. UI/UX Components
### Squircular Corners
- All cards, buttons, and containers MUST use **squircular corners** (continuous curves/superellipse) rather than standard border-radius.
- In Flutter, use `SmoothRectangleBorder` or custom paths to achieve the "Apple-style" curvature.

### Elevation & Depth
- **Soft Shadows**: Use diffused, low-opacity shadows to indicate proximity.
- Avoid high elevation or harsh offsets. The goal is a subtle "floating" effect on the light background.

### Layout
- **Spaciousness**: Generous padding and margins (base 8px grid, but with 24px-32px margins for main containers).
- **Surface**: Use solid white surfaces (`#FFFFFF`) on a light grey-white background (`#FAFAFB`) to create depth without lines.

## 3. Color Palette
| Token | Hex | Usage |
| :--- | :--- | :--- |
| **Primary (Energy)** | `#FF4B4B` | Vital energy, primary actions, coral highlights, streaks. |
| **Secondary (Health)** | `#2ECC71` | Health status (Normal), positive trends, success indicators. |
| **Background** | `#FAFAFB` | Main app background, super-clean light grey-white. |
| **Surface** | `#FFFFFF` | Cards, bottom sheets, and interactive surfaces. |
| **Text Primary** | `#1A1A1A` | Dark charcoal for high-contrast headers and body text. |
| **Text Secondary** | `#757575` | Grey for metadata, labels, and less prominent information. |

## 4. Typography
- **Titles & Headers**: `Outfit`
    - Clean, humanist sans-serif.
    - Used for H1-H4, large stats, and prominent UI labels.
- **Body & Numbers**: `Inter`
    - Optimized for legibility.
    - Used for paragraphs, button text, and small numerical data.
- **Tone**: Professional yet friendly. Priority on legibility and clear hierarchy.

## 5. Iconography
- **Style**: Modern **Duotone** (outlined or refined filled).
- **Colors**: Consistent use of Coral Red (`#FF4B4B`) for the accent part and Charcoal/Grey for the base.
- **Constraint**: Avoid stock Material Icons. Use curated sets that feel premium and custom.

## 6. Charts & Data Visualization
- **Type**: Fluid **Line Charts** (replacing or augmenting bar charts where flow is prioritized).
- **Visuals**:
    - Smooth, curved lines (Catmull-Rom or Cubic Splines).
    - **Gradient Fills**: Use a vertical gradient from Coral Red (top) to transparent/surface color (bottom).
    - **Interactivity**: Smooth transitions when switching timeframes or filtering data.
- **Implementation**: Utilize `fl_chart` with custom `LineChartBarData` configurations for "flow" aesthetics.
