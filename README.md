# attendance_flutter

A new Flutter project.

## Architecture

The project is organized using feature-based clean architecture:

```text
lib/
├── app/
├── core/
└── features/
    └── auth/
        ├── data/
        │   ├── data_source/
        │   ├── dto/
        │   ├── model/
        │   └── repository/
        ├── domain/
        │   ├── entity/
        │   ├── repository/
        │   └── usecase/
        └── presentation/
            ├── view/
            ├── view_model/
            │   ├── state/
            │   └── view_model/
            └── widgets/
```

Feature implementations, data-source contracts, repositories, use cases, and
Riverpod view models will be added as each feature is developed.

The shared [`ApiClient`](lib/core/api/api_client.dart) wraps Dio and provides
GET, POST, PUT, PATCH, and DELETE requests, timeout defaults, bearer-token
management, and normalized [`ApiException`](lib/core/api/api_exception.dart)
errors for feature data sources.

Data sources return [`ApiResponse<T>`](lib/core/api/api_response.dart), which
keeps the decoded payload, HTTP status code, and backend success message
together. Error responses are exposed through `ApiException.message`, using
the backend `message` or `error` field when present.

Shared domain failures are defined in
[`failure.dart`](lib/core/error/failure.dart). `ServerFailure` carries the
server status code and defaults to `Failure from server` when no message is
provided. The `dartz` package is available for repository contracts that
return `Either<Failure, T>`.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
