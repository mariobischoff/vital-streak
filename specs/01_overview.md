# Spec 01: Project Overview

## 1. Vision
The **Blood Pressure Log** is a mobile application designed to simplify the recording of cardiovascular health data. By using Multimodal AI (Gemini), the app removes the friction of manual data entry, enabling users to log their readings simply by taking a photo of their digital blood pressure monitor.

## 2. Target Audience
- Individuals with hypertension or hypotension who need frequent monitoring.
- Elderly users who may find small screen typing difficult.
- Health-conscious users wanting a digital backup of their physical device logs.

## 3. Core Features
- **Smart Scanner**: Camera-based OCR using Gemini 2.5 Flash for high-precision extraction from 7-segment displays.
- **Interactive Dashboard**: Health visualization with temporal filters and statistical averages.
- **Cloud Sync**: Secure data persistence and multi-device access via Supabase.
- **Biometric/Social Auth**: Seamless login experience.

## 4. User Flows
1. **Onboarding**: Login -> Profile Setup.
2. **Recording**: Dashboard -> Scan -> Gemini Interpretation -> Confirmation -> Save.
3. **Reviewing**: Filter Dashboard -> View Charts -> Analyze History.
