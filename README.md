A inlineable TabBarView animating height taken by the widget without hacks. Creates a custom render object that mimics the default [TabBarView](https://api.flutter.dev/flutter/material/TabBarView-class.html) behavior that does not try to take up the entire available height.

[<img src="asset/showcase.gif" height="200"/>](asset/showcase.webm)

This avoids hacky tricks like detecting the child height during widget build and allows for smooth animation. With this focus on quality full test coverage and documentation is provided.

## Usage

You can use the widget similar to the original widget like this:

```dart
InlineTabView(
  controller: controller,
  children: [
    FirstChild(),
    SecondChild(),
    // Add other children to match [controller.length]
  ],
),
```

Check out the app in the `/example` folder for more complex use cases and an interactive demo.
