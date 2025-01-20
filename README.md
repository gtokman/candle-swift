# Candle Swift SDK

This repo contains Candle's Swift SDK and all associated example apps.

## Get Started

### Opening a session

To use the Candle SDK, first open a Candle session by calling `Session.open()` with an instance of `AppUser`. To obtain an app key & secret, sign up for a free Candle developer account at [candle.fi](https://candle.fi).

The first time you call `Session.open()` on a device, your `AppUser` will be registered with Candle. You can correlate user events with your own users by setting `AppUser.appUserID`.

**Future calls to `Session.open()` on the same device will grant access to the same registered `AppUser`**, including their linked provider accounts and automation history.

> [!NOTE]
> iOS retains keychain data on-device even after an app is uninstalled, so `AppUser`s will be persisted even if your app is uninstalled & reinstalled.

### Deleting the user

To clear the user's linked provider accounts and automation history, call `deleteUser()` on your `Session`. Then, use `Session.open()` to register a new `AppUser`.

Deleting your `AppUser` will securely unlink all the user's provider accounts. However, for legal reasons, the user's account & automation history may be retained indefinitely by Candle.

> [!WARNING]
> You must be able to successfully open a session before deleting your `AppUser`. If you want to swap out your app key on devices with active sessions, you must open sessions using the old app key before creating a new session using the new app key.

### Keeping the session open

Your Candle session may be closed if the user's device loses its connection to the internet, the session has been open for more than 2 hours, or for other reasons. **Register an `onClose` callback when you call `Session.open()`** to be alerted as soon as this happens. Call `Session.open()` again to re-open your Candle session.

> [!WARNING]
> You can only have one open Candle session at a time. Attempting to open additional sessions by calling `Session.open()` while there is already an open session will result in `Models.OpenSession.Error.sessionAlreadyOpen`. Sessions are automatically closed as soon as there is no longer [a reference](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/) to them.

## Link Provider Accounts

### Demo provider

Experiment with the Candle SDK's functionality & APIs without linking a real service account by calling `linkAccount()` on your `Session` with an instance of `ProviderCredentials.demo()`, which retrieves data from the free, public [JSONPlaceholder](https://jsonplaceholder.typicode.com) service.

**To link a demo account**, specify the `username` of a [JSONPlaceholder user](https://jsonplaceholder.typicode.com/users). To allow you to test different MFA flows, some users require you to call `submitMFA()` on your `Session` to finish linking the account.

- Users 1-4 **do not require MFA** and will be linked immediately.
- Users 5-7 **require "login code" MFA**. The "code" is the `address.geo.lat` of the [JSONPlaceholder user](https://jsonplaceholder.typicode.com/users), without the decimal point (e.g. for a user with `"lat": "43.9509"`, the code is `439509`).
- Users 8-10 **require "magic link" MFA**. The "link" is the `website` of the [JSONPlaceholder user](https://jsonplaceholder.typicode.com/users).

Other JSONPlaceholder resources are mapped to data returned by the Candle SDK as follows:

- Fiat accounts returned by `session.getFiatAccounts()` are [JSONPlaceholder albums](https://jsonplaceholder.typicode.com/albums)
- Asset accounts returned by `session.getAssetAccounts()` are [JSONPlaceholder posts](https://jsonplaceholder.typicode.com/posts)
- Transactions and orders returned by `session.getActivity()` are [JSONPlaceholder photos](https://jsonplaceholder.typicode.com/photos) and [JSONPlaceholder comments](https://jsonplaceholder.typicode.com/comments) respectively.

### Apple Wallet provider

The Candle SDK connects to Apple Wallet on-device using Apple's [FinanceKit](https://developer.apple.com/financekit/) API. **Do not attempt to call `Session.linkAccount()` with an instance of `ProviderCredentials.apple()`** until you complete the following steps or your app will exit unexpectedly.

1. Request the FinanceKit entitlement for your bundle ID by [contacting Apple](https://developer.apple.com/contact/request/financekit).
1. On the `Signing & Capabilities` tab for your app target, add the `FinanceKit` entitlement.
1. In your Info.plist, add a value for `NSFinancialDataUsageDescription`

> [!WARNING]
> The FinanceKit entitlement will only appear as an option in the entitlements menu once it has been granted for your bundle ID by Apple. Nonetheless, you will still need to manually add it in your Xcode project.

### Handling inactive links

The Candle SDK maintains provider account links in an `active` state for as long as it can, including by automatically refreshing sessions. However, if a user explicitly revokes the session from their provider's app or website, or takes an action (e.g. changing their password) that causes active sessions to be revoked, the link will enter an `inactive` state.

You can check for `inactive` links by calling `getLinkedAccounts()` on your `Session` and filtering to accounts with their `details` set to the `inactive` case.

- To re-link the account, collect the appropriate credentials from the user and call `linkAccount()` on your `Session` with an instance of `LinkRequest.inactive()`.
- To unlink the account completely, call `unlinkAccount()` on your `Session`.

**All other `Session` methods (e.g. `getFiatAccounts`) ignore `inactive` links** and will successfully return data from the user's other linked accounts (if any).

> [!WARNING]: attempting to re-link an account by calling `linkAccount()` with an instance of `LinkRequest.credentials()` will result in `LinkError.alreadyLinked`.
