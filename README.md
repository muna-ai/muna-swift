# Function for iOS

![function logo](https://raw.githubusercontent.com/fxnai/.github/main/logo_wide.png)

[![Dynamic JSON Badge](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fdiscord.com%2Fapi%2Finvites%2Fy5vwgXkz2f%3Fwith_counts%3Dtrue&query=%24.approximate_member_count&logo=discord&logoColor=white&label=Function%20community)](https://fxn.ai/community)

Run Python functions (a.k.a "predictors") locally in your iOS apps, with 
full GPU acceleration and zero dependencies.

> [!TIP]
> [Join our waitlist](https://fxn.ai/waitlist) to bring your custom Python functions and run them on-device across Android, iOS, macOS, Linux, web, and Windows.

> [!NOTE]
> Function requires iOS 15+.

## Installing Function
Function is distributed as a SwiftPM package, and can be added as a dependency in an Xcode project or in a SwiftPM package:

### In Xcode
In your project editor, open the `Package Dependencies` tab, search 
for `https://github.com/fxnai/fxnios.git` and add the package to your project:

[GIF here]

### In Swift Package Manager
Add the following dependency to your `Package.swift` file:
```swift
let package = Package(
    name: "MyAwesomeApp",
    dependencies: [
        .package(url: "https://github.com/fxnai/fxnios.git", from: "0.0.1"),
    ],
    targets: [
        .target(name: "MyAwesomeApp", dependencies: ["FunctionSwift"]),
    ]
)
```

## Retrieving your Access Key
Before creating predictions, you will need to [create a Function account](https://fxn.ai).
Once you do, generate an access key:

![generate access key](https://raw.githubusercontent.com/fxnai/.github/main/access_key.gif)

Next, create an `fxn.xcconfig` build configuration file and enter your access key:
```bash
# Function access key
FXN_ACCESS_KEY="<ACCESS KEY>"
```

> [!CAUTION]
> Make sure that your `fxn.xcconfig` file is excluded from source control by adding it to your `.gitignore` file. Never share your access key.

## Making a Prediction
First, create a Function client:
```swift
import FunctionSwift;

// 💥 Create a Function client
let fxn = Function(accessKey: "...")
```
Then make a prediction:
```swift
// Make a prediction
let prediction = try await fxn.predictions.create(
    tag: "@fxn/greeting",
    inputs: ["name": "Sam"]
)
```
Finally, use the prediction results:
```swift
// Print
print("Prediction result: \(prediction.results![0]!)")
```

## Useful Links
- [Discover predictors to use in your apps](https://fxn.ai/explore).
- [Join our Discord community](https://discord.gg/fxn).
- [Check out our docs](https://docs.fxn.ai).
- Learn more about us [on our blog](https://blog.fxn.ai).
- Reach out to us at [stdin@fxn.ai](mailto:stdin@fxn.ai).

Function is a product of [NatML Inc](https://github.com/natmlx).