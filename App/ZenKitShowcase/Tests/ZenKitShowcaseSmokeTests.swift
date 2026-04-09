import XCTest
@testable import ZenKitShowcase

final class ZenKitShowcaseSmokeTests: XCTestCase {
    func test_catalog_contains_foundations_section() {
        XCTAssertTrue(ShowcaseSection.defaultSections.contains(where: { $0.title == "Foundations" }))
    }

    func test_inputs_section_contains_buttons_demo() {
        let inputs = ShowcaseSection.defaultSections.first(where: { $0.id == "inputs" })
        XCTAssertTrue(inputs?.entries.contains(where: { $0.screenID == .buttons }) == true)
    }

    func test_inputs_section_contains_login_demo() {
        let inputs = ShowcaseSection.defaultSections.first(where: { $0.id == "inputs" })
        XCTAssertTrue(inputs?.entries.contains(where: { $0.screenID == .login }) == true)
    }

    func test_inputs_section_contains_select_card_demo() {
        let inputs = ShowcaseSection.defaultSections.first(where: { $0.id == "inputs" })
        XCTAssertTrue(inputs?.entries.contains(where: { $0.screenID == .selectCard }) == true)
    }

    func test_surfaces_section_contains_sheet_demo() {
        let surfaces = ShowcaseSection.defaultSections.first(where: { $0.id == "surfaces" })
        XCTAssertTrue(surfaces?.entries.contains(where: { $0.screenID == .sheet }) == true)
    }

    func test_surfaces_section_contains_section_demo() {
        let surfaces = ShowcaseSection.defaultSections.first(where: { $0.id == "surfaces" })
        XCTAssertTrue(surfaces?.entries.contains(where: { $0.screenID == .section }) == true)
    }
}
