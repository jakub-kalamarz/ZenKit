import CoreText
import Foundation

enum HugeIconFont {
    static let isAvailable: Bool = {
        guard let fontURL = Bundle.module.url(
            forResource: "HugeiconsStrokeRounded.subset",
            withExtension: "ttf"
        ) else {
            assertionFailure("ZenKit HugeIcons font resource is missing")
            return false
        }

        var registrationError: Unmanaged<CFError>?
        let didRegister = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &registrationError)
        if didRegister || availablePostScriptNames.contains(HugeIcon.fontFamily) {
            return true
        }

        let errorDescription = registrationError?.takeRetainedValue().localizedDescription ?? "Unknown error"
        assertionFailure("Could not register ZenKit HugeIcons font: \(errorDescription)")
        return false
    }()

    private static var availablePostScriptNames: Set<String> {
        let names = CTFontManagerCopyAvailablePostScriptNames() as? [String] ?? []
        return Set(names)
    }
}
