<img width="350" alt="Navi_package_logo_cropped" src="https://github.com/user-attachments/assets/817f6e98-da67-4bf0-94eb-01448a7148a1" />

**A lightweight, Swift 6 native navigation package for SwiftUI's NavigationStack**

`Navi` is a **simple, lightweight Swift package** that makes working with **SwiftUI's `NavigationStack`** easier, cleaner, and more flexible — **without imposing any architecture or heavy abstractions**.

It provides a small set of utilities that help developers handle **more complex navigation flows out of the box**, while staying **pure SwiftUI**, **easy to understand**, and **safe to use in any environment**.

Whether you're building a **small pet project** or a **production-grade app**, Navi aims to reduce navigation boilerplate while keeping your code expressive and predictable.

---

## ✨ Features

- ✅ **Built on SwiftUI's `NavigationStack`**
- ✅ **Pure Swift 6**
- ✅ **Lightweight & minimal API**
- ✅ **No architecture enforcement**
- ✅ **Works with any app structure**
- ✅ **Easy to reason about and debug**
- ✅ **Production-ready**
- ✅ **MIT licensed**

---

## 🚀 Motivation

SwiftUI navigation has evolved significantly, but handling **non-trivial navigation flows** (deep links, programmatic navigation, pop back to specific screen, etc.) can still lead to:

- Scattered navigation logic
- Tight coupling between views
- Boilerplate-heavy `NavigationPath` handling

**Navi** exists to **simplify navigation logic** while staying **close to SwiftUI's mental model** — no magic, no hidden behavior, just helpful abstractions.

---

## 🤔 Why Navi vs. Native NavigationStack?

SwiftUI's `NavigationStack` is powerful, but as your app grows, you may encounter some friction:

| Challenge | Native NavigationStack | Navi |
|:----------|:---------------------:|:------:|
| **Boilerplate** | Requires manual `NavigationPath` management | Handles path management for you |
| **Programmatic navigation** | Verbose, requires passing bindings | Simple, centralized API |
| **Type safety** | Easy to lose type info with `NavigationPath` | Maintains type-safe navigation |
| **Deep linking** | Manual setup required | Easier to implement |
| **Multi-step flows** | Complex state management | Streamlined handling |
| **Decoupling views** | Views often know about destinations | Views stay focused on their content |
| **Testing** | Navigation logic embedded in views | Navigation logic can be isolated |

### In short:

**Navi** helps when your navigation logic grows beyond a few screens — without forcing you into a specific architecture.

Navi doesn't replace `NavigationStack` — it **enhances** it.

---

## 📦 Installation

### Swift Package Manager (SPM)

Add Navi to your project via Xcode:

1. Open your project in Xcode
2. Go to **File → Add Packages…**
3. Enter the repository URL: https://github.com/SwiftMates/Navi
4. Select the version you want (recommended: latest)

Or add it directly to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/SwiftMates/Navi.git", from: "1.0.0")
]
```

## 🧩 Basic Usage

// TODO

## 🛠 Advanced Navigation

// TODO

## 🧪 Example Use Cases

// TODO

## 🧠 Design Philosophy

Navi follows a few simple principles:
- Minimal API surface — Learn it in minutes
- No forced architecture — Use with MVVM, Coordinators, TCA, or plain SwiftUI
- Composable & flexible — Use only what you need
- Easy to remove or replace — No lock-in
- No runtime magic — Predictable behavior

If you understand SwiftUI navigation, you already understand Navi.

## 📚 Documentation

- Inline documentation is provided throughout the source code
- Public APIs are intentionally small and easy to explore
- The repository itself serves as the best reference

More examples and guides may be added over time.

## 🧑‍💻 Requirements

| Requirement | Version |
| ----------- | ------- |
| iOS | 16.0+ |
| macOS | 13.0+ |
| Swift | 6.0+ |
| XCode | 16.0+ |

## 🤝 Contributing

### Contributions are welcome!

1. If you'd like to help improve Navi:
2. Fork the repository
3. Create a new branch (git checkout -b feature/amazing-feature)
4. Make your changes
5. Commit your changes (git commit -m 'Add amazing feature')
6. Push to the branch (git push origin feature/amazing-feature)
7. Open a Pull Request

Bug reports, feature suggestions, and improvements are all appreciated.

## 📄 License

Navi is available under the MIT License.
You are free to use it in personal, open-source, and commercial projects.
See the LICENSE file for more details.

## ⭐ Show Your Support

If you find Navi helpful, please consider:
- Giving it a ⭐ on GitHub
- Sharing it with fellow developers
- Contributing to its development

## ❤️ Acknowledgements

Created and maintained by SwiftMates

Built with love for the SwiftUI community 💙

Made with ☕ and Swift
