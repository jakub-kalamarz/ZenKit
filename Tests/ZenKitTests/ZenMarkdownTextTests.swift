import Testing
@testable import ZenKit

@Suite struct ZenMarkdownTextTests {
    @Test func parsesBlockStructure() {
        let blocks = ZenMarkdownText.parse("""
        ## Dinner ideas
        Here are **three** options:
        - Quick pasta
        - Cheap soup
        1. First
        2. Second
        > Tip
        ```
        let x = 1
        ```
        """)

        #expect(blocks.count == 8)
        guard case .heading(let level, _) = blocks[0] else { Issue.record("expected heading"); return }
        #expect(level == 2)
        guard case .paragraph = blocks[1] else { Issue.record("expected paragraph"); return }
        guard case .listItem(let m1, let d1, _) = blocks[2] else { Issue.record("expected list"); return }
        #expect(m1 == "•" && d1 == 0)
        guard case .listItem(let m3, _, _) = blocks[4] else { Issue.record("expected ordered list"); return }
        #expect(m3 == "1.")
        guard case .listItem(let m4, _, _) = blocks[5] else { Issue.record("expected ordered list"); return }
        #expect(m4 == "2.")
        guard case .quote = blocks[6] else { Issue.record("expected quote"); return }
        guard case .codeBlock(let code) = blocks[7] else { Issue.record("expected code"); return }
        #expect(code == "let x = 1")
    }

    @Test func plainTextIsOneParagraph() {
        #expect(ZenMarkdownText.parse("Just a sentence.").count == 1)
    }
}
