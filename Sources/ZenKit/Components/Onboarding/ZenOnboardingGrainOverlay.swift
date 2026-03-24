import SwiftUI

struct ZenOnboardingGrainOverlay: View {
    let pattern: GrainPattern

    var body: some View {
        Canvas(rendersAsynchronously: true) { context, size in
            for cell in pattern.cells {
                let rect = CGRect(
                    x: cell.position.x * size.width,
                    y: cell.position.y * size.height,
                    width: cell.diameter,
                    height: cell.diameter
                )
                context.opacity = cell.opacity
                context.fill(Path(ellipseIn: rect), with: .color(.white))
            }
        }
        .blendMode(.overlay)
        .opacity(pattern.opacity)
        .allowsHitTesting(false)
    }
}

struct GrainPattern {
    let cells: [GrainCell]
    let opacity: Double

    static func make(pageIndex: Int, style: ZenOnboardingBackgroundStyle, size: CGSize) -> Self {
        let cellSize: CGFloat = style.intensity == .expressive ? 34 : 42
        let columns = max(8, Int(ceil(max(size.width, cellSize) / cellSize)))
        let rows = max(10, Int(ceil(max(size.height, cellSize) / cellSize)))
        let seed = pageIndex &* 53
        let total = rows * columns
        let opacity: Double = style.intensity == .expressive ? 0.24 : 0.16

        let cells = (0..<total).map { index in
            let row = index / columns
            let column = index % columns
            let localSeed = seed &+ index &* 17

            let xJitter = seededUnitValue(localSeed, salt: 3)
            let yJitter = seededUnitValue(localSeed, salt: 11)
            let diameter = 0.9 + seededUnitValue(localSeed, salt: 19) * 1.4
            let cellOpacity = 0.03 + seededUnitValue(localSeed, salt: 29) * 0.05

            return GrainCell(
                position: CGPoint(
                    x: min(0.98, (CGFloat(column) * cellSize + CGFloat(xJitter) * (cellSize * 0.65)) / max(size.width, 1)),
                    y: min(0.98, (CGFloat(row) * cellSize + CGFloat(yJitter) * (cellSize * 0.65)) / max(size.height, 1))
                ),
                diameter: diameter,
                opacity: min(cellOpacity, 0.11)
            )
        }

        return Self(cells: cells, opacity: opacity)
    }

    private static func seededUnitValue(_ seed: Int, salt: Int) -> Double {
        let value = abs(seed &* 1103515245 &+ salt &* 12345)
        return Double(value % 1000) / 1000.0
    }
}

struct GrainCell {
    let position: CGPoint
    let diameter: CGFloat
    let opacity: CGFloat
}
