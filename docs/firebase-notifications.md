# Firebase attendance notifications

The mobile app uses `firebase_messaging` 17's `register()` / `onRegistered`
installation-ID API. Android displays foreground messages through a native
platform channel; no local-notification package or device scheduler is used.

## API contract

The authenticated API client sends:

- `POST /api/v1/notifications/register`
- `DELETE /api/v1/notifications/unregister`

Both use JSON `{ "installationId": "<Firebase installation ID>" }` and the
current user's Bearer JWT. Both expect `{ "success": true, "message": "..." }`.
Paths are centralized in `lib/core/api/api_endpoints.dart`.

These are **Firebase installation IDs**, not legacy FCM registration tokens.
The server sender must use Firebase's installation-ID/direct-send API compatible
with this SDK. Do not pass these IDs to a legacy token-only send method.

## Architecture and lifecycle

- `core/service/notifications`: Firebase platform adapter and background handler.
- `features/notifications/data`: HTTP/local data sources, Firebase message mapping,
  and the repository implementation.
- `features/notifications/domain`: notification entity, repository contract, and
  register/unregister use cases; no Flutter/Firebase imports.
- `features/notifications/presentation`: Riverpod providers, session coordination,
  foreground UI and authenticated reminder navigation.

After login or session restoration, the app asks for notification permission once
and registers the installation. Registration changes are synchronized with the
server. Failures retry up to three times at ten-second intervals and again when
the app resumes. Denied permissions do not prevent login; users can enable them
in their system settings, then return to the app.

Attempted IDs are persisted before HTTP upload because a lost response does not
prove the server failed to save them. A replacement ID is uploaded before old
IDs are removed. Operations are serialized with logout.

Logout removes saved installation mappings while authentication is still valid,
then disables Firebase registration, then calls the auth logout endpoint. If
server detachment fails, the session remains signed in and the existing logout
error UI asks the user to retry. If auth logout fails after detachment, notification
registration is restored. The server should also remove obsolete/unregistered
installations when a send reports them invalid.

## Sender payload and scheduling

The backend schedules clock-in/out reminders and sends a **notification payload**
plus data such as:

```json
{
  "notification": {
    "title": "Clock-in reminder",
    "body": "Your workday is starting. Please clock in."
  },
  "data": {
    "type": "clock_in"
  }
}
```

Use `clock_out` for clock-out reminders. Taps open the dashboard's attendance
tab after startup/login; they never record attendance automatically. Unknown
types do not trigger navigation. For Android, the optional sender channel ID is
`attendance_notifications`. The application creates this high-importance channel
for Firebase-delivered notifications.

If reminders should exclude employees already clocked in/out, the backend must
check attendance before selecting recipients. No server scheduler or sender is
present in this Flutter repository. Configure schedules in the backend timezone
(for example `Asia/Kathmandu`) and give reminders a suitable expiry.

Android displays remote notification payloads while backgrounded. In the
foreground the app posts the received message to Android's notification panel
through `AndroidNotificationService` and `MainActivity`. Taps are handled for
both an existing activity and a cold launch. If system notification display is
disabled or unavailable, the app falls back to a SnackBar with an Open action.
iOS uses native remote
notification foreground presentation. Delivery requires connectivity and is not
an exact-time alarm. Data-only payloads do not automatically display an OS alert.

Login and logout do not post device notifications. After successful sign-out,
Android silently clears existing app notifications, and the device registration
is removed from the signed-out account. Clock-in/out confirmations and attendance
reminders continue to display normally. Signing out does not clock the employee out.

## Platform configuration

Android permissions, notification icon, and channel are configured in the app.
Installation-ID registration is explicitly enabled by
`firebase_messaging_installation_id_enabled` in the Android manifest and
`FirebaseMessagingInstallationIdEnabled` in the iOS plist. Changes to these native
settings require a full rebuild/restart; hot reload is insufficient.
Firebase auto-initialization defaults to disabled until authenticated registration.

iOS includes the push entitlement and remote-notification background mode. On a
Mac, select your signing team, enable Push Notifications for the app identifier
and provisioning profile, and upload an APNs key to the matching Firebase project.
Xcode distribution signing must use the appropriate production APNs entitlement.
Keep Firebase method swizzling enabled. The current Windows environment cannot
verify an iOS build or Apple provisioning.

This integration targets Android and iOS. Web and desktop skip registration;
web push requires separate service-worker/VAPID setup.

## Verification

Run `flutter test` and `flutter analyze --no-pub`. Device checks still required:

1. Sign in and grant permission; verify the server stores an installation ID.
2. Send a test reminder from the server while foregrounded, backgrounded, and
   normally terminated; verify alert display and navigation.
3. Sign out; verify DELETE runs before auth logout and the device mapping is gone.
4. Deny/revoke permission and re-enable it in Settings; verify sync on app resume.
5. Test the actual server schedule and attendance-based recipient filtering.

References: [Firebase Messaging API](https://pub.dev/documentation/firebase_messaging/latest/firebase_messaging/FirebaseMessaging-class.html),
[Flutter message handling](https://firebase.google.com/docs/cloud-messaging/flutter/receive-messages).
# Admin request decisions

The app also accepts `leave_approved`, `leave_rejected`, `overtime_approved`,
`overtime_rejected`, `missing_attendance_approved`, and
`missing_attendance_rejected`. Titles and bodies come from the backend.
Tapping a notification opens and refreshes the corresponding request tab.
The backend `eventId`, when supplied, is used as the Android foreground
notification identifier so retries replace the same entry.
See `attendance_backend/docs/admin-notifications.md` for queue migration,
worker deployment, retries, and delivery diagnostics.

