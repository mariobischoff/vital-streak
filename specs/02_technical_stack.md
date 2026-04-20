# Spec 02: Technical Stack

## 1. Frontend Framework: Flutter
- **State Management**: Riverpod (with Generator) for reactive UI and dependency injection.
- **Navigation**: GoRouter for declarative routing.
- **UI Components**: Material 3 with custom brand elements and `fl_chart` for visualization.

## 2. Backend: Supabase
- **Database**: PostgreSQL with Row Level Security (RLS) to ensure user data isolation.
- **Authentication**: Supabase Auth (Email/Password or Social Providers).
- **Storage**: (Pending) Used for profile pictures or temporary scanner debug images.

## 3. Intelligence: Google Gemini API
- **Model**: `gemini-2.5-flash`.
- **Function**: Multimodal Vision API to interpret LCD displays from images.
- **Optimization**: Client-side image resizing and compression before upload.

## 4. Architecture: Feature-based Clean Architecture
Organized into `features/`:
- `data/`: Repositories, API services, and DTOs.
- `domain/`: Business logic, entities, and validation rules.
- `presentation/`: Widgets, Controllers (StateNotifiers), and UI Logic.
