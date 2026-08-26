# LaunchDarkly mPAY Demo

## Location

Open **mPAY Demo** from the home screen quick actions, or navigate directly to
`/launchdarkly-mpay-demo`. The feature is isolated under
`lib/features/launchdarkly_mpay_demo/` and uses the app's existing Provider,
GoRouter, `LDService`, and AIS theme.

## LaunchDarkly configuration

Use the existing LaunchDarkly client-side connection in the app. For Flutter
SDK v4, provide a mobile key for Android/iOS/desktop or a client-side ID for
the web build. The app reads the credential from the existing `LDService`
configuration/profile flow.

Create these flags and make them available to the relevant mobile/client-side
SDKs:

The repository script includes the mPAY connector flag. Set a LaunchDarkly Writer
API token and run `python scripts/create_ld_flags.py`; existing flags are
reported as skipped by the script.

| Key | Type | Variations | Fallback |
| --- | --- | --- | --- |
| `mpay-api-v2` | Boolean | `false` = API V1, `true` = API V2 | `false` |
| `mpay-connector-v2` | Boolean | `false` = Connector V1, `true` = Connector V2 | `false` |
| `payment-flow-v2` | Boolean | `false` = Payment V1, `true` = Payment V2 | `false` |

Both payment implementations are shipped in the same Flutter binary. The
The three flags select the payment experience, API contract, and Backend
Connector implementation; changing a flag in LaunchDarkly does not require a
new APK/IPA build. Payment V2 is ready only when all three flags are true.

## Context attributes

The demo uses synthetic, stable contexts only:

| Demo identity | Key | `userType` | `merchantId` | Country |
| --- | --- | --- | --- | --- |
| Internal Tester | `employee-001` | `internal` | `MPAY-INTERNAL` | `TH` |
| Beta Merchant | `merchant-001` | `merchant` | `201` | `TH` |
| Normal Customer A | `customer-001` | `customer` | `MERCHANT-001` | `TH` |
| Normal Customer B | `customer-002` | `customer` | `MERCHANT-002` | `TH` |

The app version is sent as `appVersion` and defaults to the current app
version (`1.0.0+1`); override it at build time with `--dart-define=APP_VERSION=...`.

## API routing playground

The mPAY page also includes an API Routing Playground based on the presentation's
production rule:

```text
merchant key == "201" AND requested apiVersion == "v2" -> API V2
otherwise -> API V1
```

It shows the live LaunchDarkly evaluation, the selected route, the request
contract (`Authorization`, `X-Requested-Api-Version`, `Idempotency-Key`, and
`X-Request-Id`), and a compact routing test matrix. If the SDK is unavailable,
the route is forced to API V1 as a safe default.

The request preview intentionally uses synthetic values. It does not call a
real payment gateway and never exposes a real credential. For the presentation,
start with merchant key `201` and requested version `v2`, then try `1` or `v1`
to show the safe V1 route.

## Suggested targeting rules

Configure all three flags with the same targeting rules in this order:

1. `userType` is `internal` → `true` (internal targeting).
2. `merchantId` is `201` → `true` (merchant targeting).
3. Percentage rollout → choose the desired percentage of remaining contexts,
   for example 10% or 25% → `true`.
4. Fallthrough → `false` for all three flags.

The rollout population uses `customer-001` through `customer-020`. LaunchDarkly
owns the percentage assignment; the app never generates a random result.
Stable context keys make the result consistent between evaluations.

## Backend Connector API rollout and kill switch

The payment screen stays the same while LaunchDarkly selects two backend
components: `API V1`/`API V2` is the API contract, while
`Connector V1`/`Connector V2` is the Backend Connector implementation. A new
bank capability may require both components to move to V2 because V1 does not
handle the new contract well.

The **Simulate Connector API V2 failure** switch is local to the demo and
simulates a connector/application failure only. With API V2 and Connector V2
selected, progress the payment to Processing to see the failure. Then turn
all three V2 flags off in LaunchDarkly.
The SDK flag update re-evaluates the screen, which shows **Emergency fallback:
API V1 + Connector V1 active** without rebuilding the app.

## Offline/fallback behavior

If the SDK is disconnected, cannot initialize, or an evaluation throws, the
demo uses `false` for all three flags and shows **LaunchDarkly unavailable —
Fallback: API V1 + Connector V1**. It does not locally simulate a LaunchDarkly rollout.

## Presenter flow

1. Select **Normal Customer A** → show API V1 + Connector V1.
2. Select **Internal Tester** → show API V2 + Connector V2 when the internal rule is enabled.
3. Select **Beta Merchant** → show API V2 + Connector V2 when the merchant rule is enabled.
4. Enable **Simulate Connector API V2 failure** and process a payment.
5. Turn all three V2 flags **OFF** in LaunchDarkly.
6. Show the immediate fallback to API V1 + Connector V1 and the emergency fallback banner.
