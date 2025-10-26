# Quick Read - News App

A Flutter news application that provides real-time news from various categories with bookmark and reading history features.

## Features

- **Home Screen**: Browse latest news by category
- **Bookmarks**: Save articles for later reading
- **History**: Track your reading activity
- **Settings**: Manage preferences and categories
- **Article Details**: Full article view with sharing

## Development Status

⚠️ **This app is in development - not all features are fully functional**

## Setup & Installation

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- News API key from [newsapi.org](https://newsapi.org)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd quick_read
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Key**
   - Get your free API key from [newsapi.org](https://newsapi.org)
   - The `.env` file already exists with a development key
   - Replace the key in `.env` if needed:
     ```
     NEWS_API_KEY=your_api_key_here
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Login Credentials

For testing, use any username/password combination - the app will create a new user account automatically.

## Project Structure

```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # API services
├── database/        # SQLite database
└── main.dart        # App entry point
```

## Known Issues

- Some UI elements may not be fully responsive
- Error handling could be improved
- Testing coverage is incomplete

## UI


![Login](/readme/images/Simulator%20Screenshot%20-%20iPhone%2016.png)
![Home](/readme/images/Simulator%20Screenshot%20-%20iPhone%2016%20-%202025-10-26%20at%2013.03.56.png)
![History](/readme/images/Simulator%20Screenshot%20-%20iPhone%2016%20-%202025-10-26%20at%2013.03.46.png)
![Settings](/readme/images/Simulator%20Screenshot%20-%20iPhone%2016%20-%202025-10-26%20at%2013.04.21.png)
![History](/readme/images/Simulator%20Screenshot%20-%20iPhone%2016%20-%202025-10-26%20at%2013.28.26.png)

## Contributing

This is a development project. Feel free to report issues or suggest improvements.