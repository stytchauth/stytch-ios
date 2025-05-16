# Localization

The Stytch iOS SDK provides full support for **localization**, making it easy to adapt the prebuilt UI text to your users’ preferred language. This ensures a smoother, more native experience for international audiences using Stytch’s prebuilt UI components.

You can support **any language** by including the appropriate translation files in your app bundle. You can also customize the default English strings by overriding any keys of your choice using `.strings` or `.xcstrings` files. For more information on how to localize your app, see the [Apple Developer Localization documentation](https://developer.apple.com/localization/).

The [`LocalizationManager`](../Sources/StytchUI/Localization/LocalizationManager.swift) class is the source of truth for all default localization values in code.

## Key Naming and Scope

We’ve named the localization keys to reflect their context within the prebuilt UI. Some keys are specific to the **consumer prebuilt UI**, others are specific to the **B2B prebuilt UI**, and some are **shared across both experiences**.

If you find that you need more granular control than what is currently provided, please open a GitHub issue or submit a pull request describing your use case. We’re happy to review and add additional keys as needed.

## Implementation Instructions

To add support for a new language or customize existing strings, use the sample file at [`Localization-Sample-File/Localizable.strings`](../Localization-Sample-File/Localizable.strings) as a reference for all available localization keys.

---
_* NOTE: There are no hardcoded strings in our UI components, and as such they are fully customizable as described above. However, there may be instances where strings are returned from the network (in the case of an API error, ZXCVBN feedback, etc) which are not currently customizable. We are actively working to ensure that these are customizable in the future._
