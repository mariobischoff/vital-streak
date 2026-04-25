# Spec 07: UI Refactoring - Vital Streak Integration

This specification defines the migration of existing app screens to the new **Vital Streak Visual Language System** defined in `Spec 06`.

## 1. Goal
Refactor all user-facing screens to utilize the new design tokens (`AppColors`, `AppTypography`), the global theme (`AppTheme`), and custom widgets (`AppCard`, `AppButton`), ensuring a consistent, premium experience.

## 2. Refactoring Principles
- **Replace standard Cards**: Use `AppCard` for all section containers.
- **Replace Buttons**: Use `AppButton` for primary and secondary actions.
- **Consistency**: Ensure all text uses the defined `textTheme` (Outfit for titles, Inter for body).
- **Spaciousness**: Align margins and padding to the 8px grid (20px-24px standard padding for cards).

## 3. Targeted Screens

### A. Dashboard Screen
- **Header**: Refactor the streak header to use a gradient background with soft shadows and `Outfit` font for the "Days" count.
- **Sections**: Use `AppCard` for the "Consistency Grid" and "Trends Chart".
- **History**: Use `AppCard` for individual history items if they are currently separate, or a grouped list style with clean dividers.
- **FAB**: Style the Floating Action Button to match the primary Coral Red.

### B. Auth Screens (Login, Signup)
- **Input Fields**: Update `InputDecoration` to use smooth rounded corners and consistent label styles.
- **Actions**: Replace standard buttons with `AppButton`.
- **Typography**: Use `Outfit` for "Login" / "Create Account" titles.

### C. Profile Screen
- **User Info**: Use `AppCard` to group profile settings and user information.
- **Log out**: Use a secondary `AppButton` style.

### D. Manual Entry Screen
- **Form Layout**: Wrap the form sections in `AppCard`.
- **Input Style**: Consistent with Auth screens.

### E. Camera Scanner Screen
- **Overlays**: Refactor the scanning overlay and result confirmation dialogs to use the Vital Streak style.

## 4. Chart Enhancements
- **Fluidity**: Update `LineChart` in the Dashboard to use `isCurved: true` and gradient preenchimento (Coral Red to transparent).
- **Interactivity**: Add horizontal "Normal Zone" lines with subtle styling.

## 5. Transition Plan
1.  **Dashboard Refactor**: High impact, priority 1.
2.  **Auth & Profile Refactor**: Consistency, priority 2.
3.  **Input/Forms Refactor**: Priority 3.
