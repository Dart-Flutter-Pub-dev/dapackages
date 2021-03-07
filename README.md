# Dapackages

A *Dart* package to automatically update your pubspec dependencies in your project.

## Installation

Add the following dependency to your `pubspec.yaml`:

```yaml
dev_dependencies:
  dapackages: ^1.6.0
```

#### Run the updater

```bash
flutter pub pub run dapackages:dapackages.dart PUBSPEC_FILE_PATH
```

For example:

```bash
flutter pub pub run dapackages:dapackages.dart ./pubspec.yaml
```

## Alternative

You can also run:
```bash
flutter pub outdated
```