import XCTest
@testable import ZenKitShowcase

final class ZenKitShowcaseSmokeTests: XCTestCase {
    func test_catalog_contains_foundations_section() {
        XCTAssertTrue(ShowcaseSection.defaultSections.contains(where: { $0.title == "Foundations" }))
    }

    func test_inputs_section_contains_buttons_demo() {
        let inputs = ShowcaseSection.defaultSections.first(where: { $0.id == "inputs" })
        XCTAssertEqual(inputs?.entries.map(\.title), ["Buttons"])
    }
}
