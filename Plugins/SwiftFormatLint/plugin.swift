import Foundation
import PackagePlugin

@main
struct SwiftFormatLintPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sources = target as? SourceModuleTarget else { return [] }
        let files = sources.sourceFiles(withSuffix: "swift").map { $0.url.path() }
        guard !files.isEmpty else { return [] }

        // Toolchain binary via xcrun — no extra SPM dependency.
        // Requires Xcode 16+ / Swift 6 toolchain.
        let executable = URL(fileURLWithPath: "/usr/bin/xcrun")
        var args = ["swift-format", "lint", "--parallel"]
        // Use repo config when present; swift-format would also discover it by walking parents.
        let config = context.package.directoryURL.appendingPathComponent(".swift-format")
        if FileManager.default.fileExists(atPath: config.path()) {
            args += ["--configuration", config.path()]
        }
        // Warning-only by default. Set SWIFTFORMAT_STRICT=1 to fail the build (--strict).
        if ProcessInfo.processInfo.environment["SWIFTFORMAT_STRICT"] != nil {
            args.append("--strict")
        }
        args += files

        return [
            .prebuildCommand(
                displayName: "swift-format lint \(target.name)",
                executable: executable,
                arguments: args,
                outputFilesDirectory: context.pluginWorkDirectoryURL
            )
        ]
    }
}
