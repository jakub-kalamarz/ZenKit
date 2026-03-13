import Foundation

public enum InitialsFormatter {
    public static func initials(for source: String?) -> String {
        let trimmed = source?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else {
            return "?"
        }

        let words = trimmed
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }

        if words.count >= 2 {
            return String(words[0].prefix(1) + words[1].prefix(1)).uppercased()
        }

        return String(trimmed.prefix(2)).uppercased()
    }
}
