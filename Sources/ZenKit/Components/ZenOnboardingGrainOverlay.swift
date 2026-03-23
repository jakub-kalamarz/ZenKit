import SwiftUI

struct ZenOnboardingGrainOverlay: View {
    let pageIndex: Int
    let style: ZenOnboardingBackgroundStyle

    var body: some View {
        Canvas(rendersAsynchronously: true) { context, size in
            let cells = grainCells(for: size)
            let opacityScale = style.intensity == .expressive ? 1.25 : 1.0

            for cell in cells {
                let rect = CGRect(
                    x: cell.x,
                    y: cell.y,
                    width: cell.diameter,
                    height: cell.diameter
                )
                let alpha = min(cell.opacity * opacityScale, 0.22)
                context.opacity = alpha
                context.fill(Path(ellipseIn: rect), with: .color(.white))
            }
        }
        .blendMode(.overlay)
        .opacity(style.intensity == .expressive ? 0.24 : 0.16)
        .allowsHitTesting(false)
    }

    private func grainCells(for size: CGSize) -> [GrainCell] {
        let cellSize: CGFloat = style.intensity == .expressive ? 34 : 42
        let columns = max(8, Int(ceil(size.width / cellSize)))
        let rows = max(10, Int(ceil(size.height / cellSize)))
        let seed = pageIndex &* 53

        return (0..<(rows * columns)).map { index in
            let row = index / columns
            let column = index % columns
            let localSeed = seed &+ index &* 17

            let xJitter = seededUnitValue(localSeed, salt: 3)
            let yJitter = seededUnitValue(localSeed, salt: 11)
            let diameter = 0.9 + seededUnitValue(localSeed, salt: 19) * 1.4
            let opacity = 0.03 + seededUnitValue(localSeed, salt: 29) * 0.05

            return GrainCell(
                x: CGFloat(column) * cellSize + CGFloat(xJitter) * (cellSize * 0.65),
                y: CGFloat(row) * cellSize + CGFloat(yJitter) * (cellSize * 0.65),
                diameter: diameter,
                opacity: opacity
            )
        }
    }

    private func seededUnitValue(_ seed: Int, salt: Int) -> Double {
        let value = abs(seed &* 1103515245 &+ salt &* 12345)
        return Double(value % 1000) / 1000.0
    }
}

private struct GrainCell {
    let x: CGFloat
    let y: CGFloat
    let diameter: CGFloat
    let opacity: CGFloat
}
