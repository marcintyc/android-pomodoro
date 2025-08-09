# Focus Vibe Pomodoro

Advanced Pomodoro timer with calendar heatmap tracking, built with Flutter. Deploys automatically to GitHub Pages.

## Run locally

- Install Flutter (stable channel) and enable web support:
  - `flutter --version`
  - `flutter config --enable-web`
- Install dependencies:
  - `flutter pub get`
- Run:
  - `flutter run -d chrome`

## Deploy to GitHub Pages

- Ensure your default branch is `main` (or update the workflow trigger).
- Push this repository to GitHub.
- The workflow `.github/workflows/deploy.yml` builds the web app and deploys it to GitHub Pages.
- The base href is set automatically from the repository name.
- After the first deploy, enable Pages in your repo settings if needed.

## Features

- Pomodoro cycles with configurable durations
- Auto-start focus/breaks
- Calendar heatmap tracking of focused minutes per day
- Clean, dark, focus-themed UI

## Data

- All usage data is stored locally via `shared_preferences` (browser local storage for web).