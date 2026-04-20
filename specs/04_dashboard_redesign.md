# Spec 04: Dashboard Redesign (Focus on Consistency)

This specification defines the transformation of the Dashboard from a purely data-driven list into a behavioral tool that promotes the habit of regular blood pressure monitoring.

## 1. Goal
To incentivize the user to measure their blood pressure regularly by providing visual feedback on their "constancy" (habit) and simplifying the interpretation of their health status.

## 2. New Components

### A. Habit Heatmap (Consistency Grid)
- **Visual**: A grid of small squares (representing the last **30 days**, providing a monthly focus).
- **Logic**:
    - **Empty**: No readings on that day.
    - **Colored**: At least one reading. Color intensity could vary if the user measures multiple times (e.g., Morning/Night).
- **Impact**: Makes "missing a day" visually noticeable, encouraging the user to maintain their "Streak".

### B. Gamified Metrics (Streaks)
- **Metric**: "Current Streak" (Consecutive days with at least 1 reading).
- **UI**: A small flame icon with the number of days, prominent in the header.

### C. Stability Indicator (Trend Summary)
- **Calculation**: Compare the average of the last 7 days with the average of the 7 days prior.
- **Output**: 
    - "Stable" (Difference < 5%)
    - "Improving" (Average moving towards Normal range)
    - "Varying" (High standard deviation/volatility)

### D. Range Bar Chart (Interval Visual)
- **Visual**: Vertical "floating" bars for each measurement.
    - **Top**: Systolic value.
    - **Bottom**: Diastolic value.
- **Color Logic**: The bar is colored based on its classification (Green, Yellow, Red).
- **Purpose**: Instead of treating Sys/Dia as separate lines, it shows the "pressure interval" in a single clinical block, making it much easier to read the pulse pressure and overall level.

## 3. Technical Changes
- **Local Logic**: New utility in `BloodPressureLogic` to calculate Streaks and Stability.
- **Dependencies**: Add `heatmap_calendar_flutter` (or custom painter) for the consistency grid.
- **UI layout**:
    - Header: Streak & Health Summary.
    - Section 1: Consistency Heatmap (30 days).
    - Section 2: Range Bar Chart with Zoned Background.
    - Section 3: Recent Activity (Timeline style section with clear header).

## 4. User Experience (UX)
- Celebration animation (Lottie or simple UI pop) when a new reading extends a streak.
- Clear terminology: "Consistent usage" instead of just "Reading History".
