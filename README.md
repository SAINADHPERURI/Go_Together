# GoTogether — Project Documentation

> A web and mobile platform for finding compatible travel companions, organised into age communities.
> Flutter (Android · iOS · Web) + Firebase (Auth · Firestore · Cloud Functions · FCM · Storage · Security Rules · App Check).

Live web app: **https://gotogether-b18d2.web.app** (Firebase Hosting, project `gotogether-b18d2`).

---

## 1. Project Abstract

GoTogether is a community platform that helps people find others of a similar age who want to travel to the same place. Many people want to go trekking, visit hill stations, take a road trip or join a yatra, but they don't have a suitable group to go with, and general social networks make it hard to find compatible strangers safely. GoTogether places every user in exactly one age community (18–24, 25–31, 32–40, 41–50 or 51+). The community is derived automatically from the user's date of birth and is enforced on the server. Members discover trips posted by others in their community, search and filter by destination, type, date and starting point, and request to join. The trip's host reviews each request and accepts or declines it. Accepted members join a private group with real-time chat to coordinate independently. GoTogether does not book travel, take payments or collect identity documents. It is a discovery, connection and communication platform built with Flutter and Firebase, and it runs on Android, iOS and the web from a single codebase.

## 2. Problem Statement

* **No group, no trip.** Treks, long road trips and pilgrimages are safer and cheaper in groups, but friends' schedules rarely line up.
* **General platforms aren't built for this.** Social media groups mix every age and interest. Posts get buried, there's no structured way to apply to join, and contact details end up shared publicly.
* **Compatibility matters.** A 22-year-old backpacker and a 60-year-old pilgrim usually want very different pace, comfort and budget. Matching on destination alone produces poor groups.
* **Safety and privacy.** People need to vet strangers before travelling with them, without exposing their phone number, email or date of birth to everyone.
* **Coordination is scattered.** Planning moves to ad-hoc messaging groups, which leak personal numbers to people who may never travel.

## 3. Proposed Solution

GoTogether puts these steps into one product flow:

```
DISCOVER → FIND COMPATIBLE PEOPLE → REQUEST TO JOIN → HOST ACCEPTS → JOIN GROUP → CHAT → COORDINATE → GO TOGETHER
```

1. **Age communities.** On sign-up the user enters a date of birth (kept private). The app derives their community; the Security Rules re-derive it and reject any mismatch. Nobody can pick a different community, and it updates automatically on birthdays.
2. **Personalised dashboard.** Younger communities see Adventure, Trekking, Camping, Climbing and Road trips first. The 51+ community sees Yatra, Pilgrimage, Spiritual journeys, Comfortable travel and Cultural trips, with larger text and touch targets. These categories are recommendations only; every trip type stays discoverable.
3. **Trips.** Any member can host a trip: destination, starting point, dates, type, group size, description and optional members-only meeting details. The trip's community is the host's community.
4. **Join requests.** Compatible members send a request with an optional note. The host sees each requester's public profile and accepts or declines.
5. **Private groups.** Accepted members see the roster, the meeting details and a real-time group chat. Nobody outside the group can read them.
6. **Safety.** Users can report users, trips and messages, and block people. Administrators review reports in a moderation console and can suspend accounts or take trips down.

## 4. System Architecture

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          Flutter client (one codebase)                    │
│            Android app  ·  iOS app  ·  Web app (Firebase Hosting)         │
│                                                                          │
│  Presentation  lib/ui/        screens, design system, go_router          │
│        │                                                                 │
│  State         lib/state/     Riverpod providers (streams, session)      │
│        │                                                                 │
│  Domain        lib/domain/    models, age groups, policy, validation,    │
│        │                      repository interfaces (pure Dart)          │
│  Data          lib/data/      Firebase repository implementations        │
└────────┬──────────────┬──────────────┬───────────────┬───────────────────┘
         │ ID token     │ realtime     │ uploads       │ push tokens
         ▼              ▼              ▼               ▼
  ┌────────────┐ ┌──────────────┐ ┌─────────────┐ ┌──────────────┐
  │ Firebase   │ │ Cloud        │ │ Cloud       │ │ Firebase     │
  │ Auth       │ │ Firestore    │ │ Storage     │ │ Cloud        │
  │ (email,    │ │ + Security   │ │ + Storage   │ │ Messaging    │
  │  Google)   │ │   Rules      │ │   Rules     │ │ (FCM)        │
  └─────┬──────┘ └──────┬───────┘ └─────────────┘ └──────▲───────┘
        │               │ document triggers               │ sends
        │               ▼                                 │
        │        ┌──────────────────────────────────────────┴─────┐
        └──────► │ Cloud Functions (Node 22, TypeScript, Admin SDK)│
   onDelete      │ notifications · push fan-out · topic sync ·     │
                 │ nightly lifecycle · suspension · cleanup · roles│
                 └─────────────────────────────────────────────────┘
  App Check (Play Integrity / App Attest / reCAPTCHA) attests genuine clients.
  Analytics + Crashlytics provide production monitoring.
```

**Key design choice:** ordinary reads and writes go **directly from the client to Firestore**, and **Security Rules** decide whether each one is allowed. Cloud Functions handle only the work that needs elevated privileges or must run without a client: notifications, scheduled jobs, disabling suspended accounts, and cleanup after account deletion. The core product therefore still works while the Functions are not deployed.

## 5. Tech Stack Used

| Technology | Role | Why it was chosen |
|---|---|---|
| **Flutter 3.47 / Dart 3.13** | UI for Android, iOS and Web | One codebase and one design system on every platform. Compiled to native ARM code and JS/Wasm. Strong accessibility (text scaling, semantics). |
| **Riverpod 3** | State management & dependency injection | Compile-safe providers, first-class stream support for Firestore listeners, auto-dispose of unused listeners, and easy overrides in tests. One consistent approach across the app. |
| **go_router 18** | Navigation | URL-based routing, which the web needs for deep links like `/trip/{id}`. Supports redirect guards (signed-out → welcome, not onboarded → onboarding, suspended → restricted) and nested tab navigation. |
| **Firebase Authentication** | Identity | Managed email/password and Google sign-in, secure token refresh, and session persistence on all platforms. Tokens carry the `admin` custom claim. |
| **Cloud Firestore** | Database | Real-time listeners (chat, live trip state), offline cache and queued writes, horizontal scaling, and declarative Security Rules close to the data. |
| **Firestore Security Rules** | Server-side authorisation & validation | Enforce ownership, age-community compatibility, capacity, membership and field validation on Google's servers, independently of the client. |
| **Cloud Functions (2nd gen, TypeScript)** | Trusted backend logic | Event-driven (no servers to run) and uses the Admin SDK for privileged work: notifications, scheduled jobs, account suspension and cleanup. |
| **Firebase Cloud Messaging** | Push notifications | Free, cross-platform push (Android, iOS, Web), with topics for community-wide broadcasts. |
| **Cloud Storage for Firebase** | Profile photos | Direct, resumable uploads governed by Storage Rules (own folder only, images only, under 5 MB). |
| **Firebase App Check** | Abuse protection | Confirms that requests come from the genuine app (Play Integrity, App Attest, reCAPTCHA v3). |
| **Firebase Analytics & Crashlytics** | Monitoring | Screen-view analytics through the router observer, plus crash reporting on mobile. |
| **Firebase Hosting** | Web delivery | Global CDN, HTTPS, single-page-app rewrites and security headers. |
| **Emulator Suite + @firebase/rules-unit-testing** | Testing | Proves the Security Rules against a real rules engine locally. |

## 6. Database Design

All timestamps are Firestore `Timestamp`s. Writes use `serverTimestamp()`, and the Rules check `== request.time` so clients can't backdate data.

### `users/{uid}` — public profile (readable by signed-in users)
| Field | Type | Notes |
|---|---|---|
| displayName | string (2–50) | |
| photoUrl | string? (https) | |
| city | string? (≤60) | `null` when the user hides their city |
| bio | string (≤300) | |
| languages | string[] (≤8) | |
| interests | string[] (≤12) | |
| tripPreferences | string[] (≤14) | trip type ids |
| ageGroup | `18_24`/`25_31`/`32_40`/`41_50`/`51_plus` | **derived; Rules verify it against the DOB** |
| status | `active` / `suspended` | only admins may change it |
| createdAt, updatedAt | timestamp | |

### `users/{uid}/private/account` — owner-only
| Field | Type | Notes |
|---|---|---|
| birthDate | timestamp (UTC midnight) | immutable; must be ≥18 and <111 years ago |
| email | string? | must equal the auth token's email |
| city | string? | always kept here so hiding it is reversible |
| privacy | map `{showCity: bool}` | |
| notifications | map of bool | joinRequests, requestUpdates, messages, tripUpdates, newTrips |

### `users/{uid}/devices/{fcmToken}` — owner-only; `{token, platform, updatedAt}`
### `users/{uid}/notifications/{id}` — written by Functions only; the owner can mark them read or delete them
`{type, title, body, tripId?, actorId?, read, createdAt}`
### `users/{uid}/blocks/{blockedUid}` — owner-only; `{displayName, createdAt}`

### `trips/{tripId}` — listing (readable by signed-in users)
| Field | Type | Notes |
|---|---|---|
| title | string 3–60 | |
| destination, startLocation | string 2–60 | |
| startDate, endDate | timestamp (UTC midnight) | end ≥ start, at most 60 days, starts within 2 years |
| type | enum of 14 trip types | |
| description | string 20–1000 | |
| maxMembers | int 2–20 | |
| memberCount | int | always equals `memberIds.length` |
| memberIds | string[] | host + accepted members; drives all group authorisation |
| ageGroup | community id | equals the host's community |
| hostId, hostName, hostPhotoUrl | | `hostName` must match the host's profile |
| status | `open`/`full`/`closed`/`completed`/`cancelled` | |
| searchKeywords | string[] (≤120) | lowercase prefixes for `array-contains` search |
| lastMessageAt, lastMessagePreview | | chat preview, updated by members |
| createdAt, updatedAt | timestamp | |

### Sub-collections of a trip
* `private/details` — `{meetingPoint?, meetingNotes?}`, **members only**.
* `members/{uid}` — `{displayName, photoUrl, role: host|member, joinedAt}`, **members only**.
* `joinRequests/{requesterUid}` — `{tripId, userId, hostId, displayName, photoUrl, city, ageGroup, message, status: pending|accepted|rejected|cancelled, tripTitle, tripDestination, tripStartDate, createdAt, updatedAt}`. **The document id is the requester's uid, so duplicate requests are impossible.**
* `messages/{id}` — `{senderId, senderName, senderPhotoUrl, text (1–1000), type: 'text', deleted, createdAt}`, **members only**.

### `reports/{id}` — create: any active user; read/update: admins
`{reporterId, targetType: user|trip|message, targetId, targetLabel, tripId?, reason, details?, status: open|actioned|dismissed, resolutionNote?, createdAt, resolvedAt?}`

### Relationships
```
users 1 ─── 1 private/account
users 1 ─── * trips (as host)          trips.hostId
users * ─── * trips (as member)        trips.memberIds + trips/{id}/members
users 1 ─── * joinRequests             trips/{id}/joinRequests/{uid}
trips 1 ─── * messages                 trips/{id}/messages
```

### Indexes (`firestore.indexes.json`)
| Query | Index |
|---|---|
| Discover feed | `trips: ageGroup ↑, status ↑, startDate ↑` |
| Discover + type | `ageGroup, status, type, startDate` |
| Discover + search | `ageGroup, status, searchKeywords (array-contains), startDate` |
| Discover + type + search | `ageGroup, status, type, searchKeywords, startDate` |
| My trips | `memberIds (array-contains), startDate ↓` |
| Nightly completion job | `status, endDate` |
| Host's pending requests | `joinRequests: status, createdAt` |
| "My requests" (collection group) | `joinRequests: userId, updatedAt ↓` and `userId, status` |
| Moderation queue | `reports: status, createdAt ↓` |
| Anonymise on deletion | collection-group override on `messages.senderId` |

**Denormalisation:** `hostName/hostPhotoUrl` on trips, requester details on join requests, and sender details on messages are copied deliberately, so lists render from one query without N+1 profile reads. The Rules verify the copied names against the source profile, so they can't be spoofed.

## 7. Module Description

* **Authentication** (`auth_screens.dart`, `auth_repository_impl.dart`). Email/password sign-up (8+ characters, with a letter and a number), sign-in, password reset (without revealing whether an account exists), email verification banner, and Google sign-in (popup on web, native provider flow on mobile). Firebase errors are mapped to clear messages.
* **Onboarding** (`onboarding_screen.dart`). Four steps: name and date of birth (shows which community the user will join and why it's fixed), city and language selection with a privacy toggle, trip preferences, interests and bio, and an optional photo. Everything is written in one atomic batch.
* **Profile** (`profile_screens.dart`). Own profile, a public view of other members (with Report and Block), and Edit profile. Upload failures keep the previous photo.
* **Age-group classification** (`domain/age_group.dart`, mirrored in `firestore.rules → ageGroupFor` and `functions/src/copy.ts`). Bands are non-overlapping and evaluated on UTC calendar dates on every side. `sessionMaintenanceProvider` and the nightly `refreshAgeGroups` function move people to their next community after a birthday.
* **Dashboard** (`home_screen.dart`). Greeting, community badge, "your next trip" card with the latest chat preview, community-specific categories (larger tiles for 51+), and upcoming trips from the user's community.
* **Trip discovery & search** (`discover_screen.dart`). Debounced destination search (Firestore `array-contains` on prefix tokens, refined on the client for multi-word queries), type chips, and a filter sheet for date range, starting city and open spots only. Results are paginated, with skeleton, empty and error states. Results are always scoped to the user's community, and blocked hosts are hidden.
* **Trip creation** (`trip_form_screen.dart`). Validates every field (shared `TripDraftValidator`) with inline errors, group-size stepper, date-range picker, and a locked community badge. The trip, host member entry and private details are written in one batch.
* **Join requests** (`join_request_repository_impl.dart`). Eligibility (`TripPolicy.joinEligibility`) gives a precise reason when someone can't join (host, member, pending, declined, wrong community, full, closed, ended, suspended). Users can withdraw a request and ask again.
* **Host management** (`manage_trip_screen.dart`). Requests tab (accept/decline, with a warning when the group is full), Members tab (remove), Settings tab (edit, close, reopen, cancel, complete), each with a confirmation.
* **Trip groups.** Membership lives in `memberIds` plus the `members` sub-collection. Members see meeting details and the roster; others see a locked explanation.
* **Real-time chat** (`chat_screen.dart`). Firestore listener with growing-window pagination (40 messages per page), grouped bubbles, day separators, host badge, "Sending…" for offline-queued messages, failed sends returned to the composer, delete-for-everyone, report message, and a read-only state for cancelled trips.
* **Notifications** (`push_service.dart`, `inbox_screen.dart`, Functions). Inbox items for requests, decisions, removals and trip changes. Push for those plus chat messages and new community trips. Respects per-category settings and OS/browser permission, and prunes stale tokens.
* **Settings** (`settings_screens.dart`). Notification toggles, privacy overview, blocked list, community guidelines, sign-out (unregisters the device), and account deletion.
* **Safety / moderation** (`safety.dart`, `admin_screen.dart`). Report (user, trip or message), block/unblock, a moderation console for users with the `admin` claim (suspend, reinstate, take down a trip, remove a message, dismiss), and an automatic auth disable when an account is suspended.

## 8. Firebase Architecture

**Firebase Authentication.** Holds identities for email/password and Google. The SDK keeps a refreshable ID token, and every Firestore/Storage request carries it, so `request.auth.uid` in the Rules is trustworthy. Admins are marked with a custom claim (`admin: true`) set only through the Admin SDK (`functions/scripts/grant-admin.mjs` or the `setAdminRole` callable). This makes the role tamper-proof on the client.

**Cloud Firestore.** A document database with real-time listeners. The app subscribes to streams (trip, chat, requests, notifications), so changes appear instantly on every device. Offline persistence is enabled (100 MB cache): reads come from cache when offline and writes are queued, which is why chat shows "Sending…".

**Cloud Functions** (`functions/src/index.ts`, region `asia-south1`):

| Function | Trigger | Purpose |
|---|---|---|
| `onJoinRequestWritten` | joinRequests write | Notifies the host of a new request, and the requester when accepted, declined or removed |
| `onMessageCreated` | message create | Push to the other members (collapsed per trip) |
| `onTripCreated` | trip create | Broadcast to the `community_<group>` FCM topic |
| `onTripUpdated` | trip update | Notify members of cancellation or material edits |
| `onDeviceWritten`, `onAccountSettingsUpdated`, `onUserUpdated` | various | Keep topic subscriptions in sync; disable/enable auth when suspended |
| `completeFinishedTrips` | daily 03:00 IST | Mark ended trips completed |
| `refreshAgeGroups` | daily 00:30 UTC | Move users to their next community after birthdays |
| `onAuthUserDeleted` | Auth delete (v1) | Anonymise the user's chat messages, remove leftovers |
| `setAdminRole` | callable | Admin-only role management |

**Cloud Storage.** Only profile photos, at `users/{uid}/avatar/{timestamp}.jpg|png`.

**FCM.** Device tokens are stored per user and device. Direct sends go to tokens for personal events, and topics are used for community announcements. On the web, `web/firebase-messaging-sw.js` shows notifications in the background, and taps open the trip or chat link.

**Security Rules.** See §9. The Rules are the authorisation layer, and **48 automated tests** run them on the emulator.

**App Check.** Activated on mobile (Play Integrity / App Attest, debug provider in debug builds) and on web when `APP_CHECK_WEB_KEY` (reCAPTCHA v3) is supplied. Turn on enforcement in the console once the providers are registered.

## 9. Security & Privacy Implementation

* **Authentication flow.** Firebase Auth issues short-lived ID tokens. The router guards every route by session state (`signedOut`, `needsOnboarding`, `suspended`, `ready`), and the Rules require `request.auth` for every read.
* **Authorisation is server-side.** Every invariant is enforced in `firestore.rules`:
  * **Ownership.** Users write only their own profile, account, devices and blocks.
  * **Age community.** Profiles must carry `ageGroup == ageGroupFor(birthDate)`, the DOB is immutable, trips must use the host's community, and join requests are only accepted when the requester's community equals the trip's.
  * **Membership.** The roster changes only in validated shapes. When a host accepts, exactly one uid is appended, that user's request moves `pending → accepted` **in the same transaction**, a member document appears (`getAfter`/`existsAfter`), and `memberCount ≤ maxMembers`. Leaving or removal deletes exactly one uid, never the host, and only by the host or that member. Nobody can add themselves.
  * **Capacity & state.** Requests require `status == open` and spare capacity. Status transitions are whitelisted, and trips are never deletable.
  * **Duplicates.** The join request id is the requester's uid.
  * **Blocking.** A request is refused when the host has blocked the requester.
  * **Suspension.** `isActive()` gates creating trips, requests, messages and reports, and the Function also disables sign-in.
* **Storage Rules.** Users can write only `users/{their uid}/avatar/`, only JPEG/PNG/WebP images under 5 MB, and everything else is denied.
* **Role-based access.** User, Host (implicit: `trips.hostId == uid`, scoped to that trip only) and Admin (custom claim, checked with `request.auth.token.get('admin', false)`).
* **Chat security.** Only `memberIds` can read or post. Sender id and name must match the signed-in user, messages are 1–1000 characters, only the sender can delete their own message (soft delete), and cancelled trips are read-only.
* **Data minimisation.** The DOB and email live in an owner-only document and are never shown; only the community label is public. City is optional and can be hidden. Phone numbers are never collected. There are no government IDs and no payments. Meeting details and member lists are hidden until a user is accepted.
* **Reporting & blocking.** Reports are confidential (only admins can read them) and blocks are private.
* **Platform hardening.** Android backups of session data are disabled. Hosting sends HSTS, `nosniff`, Referrer-Policy and Permissions-Policy headers. Signing keys and service accounts are git-ignored, and Admin credentials come from Application Default Credentials only.

## 10. Deployment Architecture

```
 Android / iOS app ──HTTPS(gRPC/WebChannel)──► Firestore ◄── Security Rules
 Web app (Hosting CDN, https://gotogether-b18d2.web.app) ─┘      │ triggers
        │  Firebase Auth (ID token)                              ▼
        │  FCM token ◄──────────── push ◄──────────── Cloud Functions (asia-south1)
        └─ Storage (photos) ◄── Storage Rules
```

Each client is initialised from `lib/firebase_options.dart` (public client identifiers; they are not secrets). The SDKs talk directly to the managed Firebase endpoints over TLS, with no custom server in between.

**Build & deploy commands**
```bash
flutter analyze && flutter test                         # static checks + 72 tests
(cd functions && npm ci && npm test)                    # Functions unit tests
(cd tests/rules && npm ci && npm test)                  # Security Rules tests (needs Java 11+)

flutter build web --release
flutter build apk --release
flutter build appbundle --release                       # Play Store upload

firebase deploy --only firestore:rules,firestore:indexes,hosting
firebase deploy --only storage,functions                # requires the Blaze plan (see below)
```

**Release signing (Android).** Create an upload key and `android/key.properties` (both git-ignored):
```
keytool -genkey -v -keystore ~/gotogether-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
# android/key.properties
storePassword=…  keyPassword=…  keyAlias=upload  storeFile=C:/path/gotogether-upload.jks
```
Without that file, release builds fall back to the debug key (fine for testing, not accepted by Play).

**Optional build-time keys:** `--dart-define=APP_CHECK_WEB_KEY=<reCAPTCHA v3 site key>` and `--dart-define=FCM_VAPID_KEY=<Web Push certificate key>`.

**First administrator:** `cd functions && npm run grant-admin -- you@example.com` (after `gcloud auth application-default login`).

**Current deployment status** (verified by command output):
| Component | Status |
|---|---|
| Firestore Rules + Indexes | Deployed |
| Web app on Hosting | Deployed — https://gotogether-b18d2.web.app |
| Email/Password + Google sign-in providers | Enabled in project |
| Cloud Functions | **Not deployed** — the project is on the Spark plan; Functions require Blaze |
| Storage bucket + rules | **Not deployed** — Storage hasn't been set up in the console (new buckets also require Blaze) |

Until those two are enabled, everything else works fully (auth, onboarding, discovery, requests, membership, chat, in-app safety tools). Photo uploads show a friendly "upload failed" message (Google profile photos still appear), and push/inbox notifications and the nightly jobs stay inactive.

## 11. Future Enhancements

1. **Optional verified badges.** Phone-number verification via Firebase Phone Auth, shown as a trust badge without exposing the number.
2. **Trip reviews and host ratings** after completion, to build reputation within communities.
3. **Smarter matching.** Rank trips by overlap in languages, interests and starting city, and use full-text search (e.g. Algolia/Typesense via an extension) for typo-tolerant destination search.
4. **Shared trip planning tools.** Itinerary checklist, packing lists and polls inside the group.
5. **Multilingual UI** (Hindi, Tamil, Telugu…) using Flutter's `intl`, plus voice input for the 51+ community.

---

### Appendix — Repository layout
```
lib/
  domain/        age_group.dart, enums.dart, policy.dart, repositories.dart, models/
  data/          Firebase implementations, error mapping, push service
  state/         providers.dart (Riverpod)
  ui/            theme/, widgets/, screens/, router.dart, shell.dart
functions/       Cloud Functions (TypeScript) + tests + grant-admin script
tests/rules/     Firestore & Storage rules tests (emulator)
test/            Flutter unit & widget tests
integration_test/ end-to-end test against emulators
firestore.rules · storage.rules · firestore.indexes.json · firebase.json
```

