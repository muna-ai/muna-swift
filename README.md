# Muna for Swift

![Muna logo](https://raw.githubusercontent.com/fxnai/.github/main/logo_wide.png)

Run AI models anywhere.

> [!NOTE]
> Muna requires iOS 15+.

## Installing Muna
Muna is distributed as a SwiftPM package, and can be added as a dependency in an Xcode project or in a SwiftPM package:

### In Xcode
In your project editor, open the `Package Dependencies` tab, search 
for https://github.com/muna-ai/muna-swift.git and add the package to your project:

![Xcode2](https://github.com/user-attachments/assets/dc1468bd-04d9-40bf-b15b-4fa261848aae)

### In Swift Package Manager
Add the following dependency to your `Package.swift` file:
```swift
let package = Package(
    name: "MySwiftPackage",
    dependencies: [
        .package(url: "https://github.com/muna-ai/muna-swift.git", from: "0.0.1"),
    ],
    targets: [
        .target(name: "MySwiftPackage", dependencies: ["Muna"]),
    ]
)
```

## Retrieving your Access Key
Before creating predictions, you will need to [create a Muna account](https://muna.ai).
Once you do, generate an access key:

![generate access key](https://raw.githubusercontent.com/muna-ai/.github/main/access_key.gif)

## Making a Prediction
First, create a Muna client:
```swift
import Muna

// 💥 Create a Muna client
let muna = Muna(accessKey: "...")
```

Then make a prediction:
```swift
// 🔥 Make a prediction
let prediction = try await muna.predictions.create(
    tag: "@fxn/greeting",
    inputs: ["name": "Sam"]
)
```

Finally, use the prediction results:
```swift
// 🚀 Use the results
print("Prediction result: \(prediction.results![0]!)")
```

## Embedding Predictors
Muna normally works by downloading and executing prediction functions at runtime. But because iOS requires 
strict sandboxing, you must download and embed predictors at build-time instead.

### Specifying Predictors to Embed
First, create an `muna.config.swift` file at the root of your target directory:
```swift
import Muna

let config = Muna.Configuration(
    // add all predictor tags to be embedded here
    tags: [
        "@fxn/greeting"
    ]
)
```

### Embedding the Predictors
You can embed the predictors using the context menu by right-clicking on your project and selecting the 
`Embed Predictors` command:

![Embed](https://github.com/user-attachments/assets/fba1e234-d178-41ee-8843-202ea87aeab0)

You can also use the Swift CLI:
```sh
# Embed predictors
swift package --allow-writing-to-package-directory muna-embed
```

> [!NOTE]
> Embedding predictors requires internet and file system access to download and embed the prediction function into your Xcode project.

> [!IMPORTANT]
> After embedding, Xcode might prompt you to either reload the project from disk or keep the current version in memory. **Always reload your project from disk**.

## Useful Links
- [Discover predictors to use in your apps](https://muna.ai/explore).
- [Join our Slack community](https://muna.ai/slack).
- [Check out our docs](https://docs.muna.ai).
- Learn more about us [on our blog](https://blog.muna.ai).
- Reach out to us at [hi@muna.ai](mailto:hi@muna.ai).

Muna is a product of [NatML Inc](https://github.com/natmlx).
