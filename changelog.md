## 0.2.0

- 💥 Avoid app extension restricted APIs

  Migration Guide:

  You now need to specifically need to opt in to registering the `WKWebView` with the first window of the shared application. The reasoning for this is that it's a restricted API that isn't available when writing an App Extension.

  Look at the added section in the readme for the two lines of code you need to add to your `AppDelegate`.

## 0.1.2

- 🎉 Add support for registering functions

## 0.1.1

- 🎉 Expose all constructor options

## 0.1.0

- 🎉 Add initial implementation
