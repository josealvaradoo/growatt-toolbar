import Foundation

public enum DotEnv {
    /// Loads a `.env` file from the given path and exports variables
    /// into the current process environment. Silently skips missing files
    /// (e.g. release builds where env is set by launchd).
    public static func loadDotenv(path: String? = nil) {
        let envPath = path
            ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appendingPathComponent(".env").path

        guard let contents = try? String(contentsOfFile: envPath, encoding: .utf8) else { return }

        for line in contents.components(separatedBy: .newlines) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }
            let parts = trimmed.split(separator: "=", maxSplits: 2).map(String.init)
            guard parts.count == 2 else { continue }
            setenv(parts[0], parts[1], 0)
        }
    }
}
