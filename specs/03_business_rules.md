# Spec 03: Business Rules

This document defines the core health logic of the application. All code and tests must strictly adhere to these definitions.

## 1. Pressure Classification (Adults)
The application categorizes readings based on the standard blood pressure ranges. If Systolic and Diastolic fall into different categories, the higher (more severe) category is chosen.

| Category | Systolic (mmHg) | | Diastolic (mmHg) | Color |
| :--- | :--- | :--- | :--- | :--- |
| **Normal** | < 120 | AND | < 80 | Green |
| **Elevated** | 120 - 129 | AND | < 80 | Amber |
| **Hypertension Stage 1** | 130 - 139 | OR | 80 - 89 | Orange |
| **Hypertension Stage 2+** | ≥ 140 | OR | ≥ 90 | Red |

## 2. Validation Constraints
Readings that do not meet these criteria should be rejected as invalid (likely OCR errors).

- **Consistency**: Systolic must ALWAYS be greater than Diastolic.
- **Range (SYS)**: Must be between 70 and 250 mmHg.
- **Range (DIA)**: Must be between 40 and 140 mmHg.

## 3. UI Indications
- **Trend Up/Down**: Comparison between the latest reading and the average of the current filter period.
- **Severity Colors**: UI elements (cards, chart dots) must match the colors defined in section 1.
