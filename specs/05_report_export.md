# Spec 05: Blood Pressure Report Export (PDF/CSV)

This specification defines the functionality to export blood pressure data into a professional PDF report, enabling users to share their history with medical professionals.

## 1. Goal
To provide a clear, structured, and clinically relevant document that summarizes the user's blood pressure trends, averages, and individual readings over a specific period (default: 30 days).

## 2. Report Structure (PDF)

### A. Header
- Title: "Blood Pressure Monitoring Report".
- Generation Date: Date when the report was created.
- User Identification: Placeholder for Name (optional for now).

### B. Executive Summary (Metrics)
- **Period**: Start Date to End Date.
- **Averages**: Average Systolic / Average Diastolic.
- **Range**: Maximum and Minimum recorded values.
- **Classification Distribution**: A summary of how many readings fell into each category (Normal, Elevated, Stage 1, etc.).

### C. Visual Trends
- An image capture of the **Range Bar Chart** showing the trends for the period.

### D. Detailed History Table
- A multi-page table containing:
    - Date & Time.
    - Systolic (mmHg).
    - Diastolic (mmHg).
    - Category (Label).

## 3. Technical Implementation

### A. Dependencies
- `pdf`: For generating the PDF document.
- `printing`: For printing support or direct PDF viewing.
- `share_plus`: For sharing the file via system dialog.
- `path_provider`: For temporary file storage before sharing.
- `screenshot`: To capture the dashboard chart and embed it in the PDF.

### B. Logic Flow
1. User clicks the "Share/Export" icon in the Dashboard.
2. The app captures the current chart as an image.
3. The `ExportService` gathers the last 30 days of data.
4. A PDF document is generated in memory using a defined template.
5. The document is saved to a temporary local file.
6. `share_plus` is called with the file path to open the native sharing menu.

## 4. User Experience (UX)
- **Trigger**: A "Share" icon in the Dashboard AppBar.
- **Feedback**: A Loading Overlay while the PDF is being generated.
- **Format**: Initially PDF (most requested by doctors). CSV can be added as a secondary option for power users.
