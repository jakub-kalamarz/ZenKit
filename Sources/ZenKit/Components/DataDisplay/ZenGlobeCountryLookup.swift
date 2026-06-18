import Foundation

#if canImport(CoreGraphics)
import CoreGraphics
import ImageIO

/// CPU-side lookups against the embedded country-index map — the same data the globe shader
/// samples on the GPU, decoded once so taps and programmatic selections can resolve a country
/// (its index, ISO code, or a fly-to centroid) entirely offline.
extension ZenGlobeCountryMap {
    /// Decoded 8-bit index buffer (row-major, top = north), with dimensions. Built lazily once.
    private static let raster: (px: [UInt8], w: Int, h: Int)? = {
        guard let src = CGImageSourceCreateWithData(pngData as CFData, nil),
              let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else { return nil }
        let w = cg.width, h = cg.height
        var px = [UInt8](repeating: 0, count: w * h)
        guard let ctx = CGContext(
            data: &px, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        ) else { return nil }
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        return (px, w, h)
    }()

    /// Country index at a lat/lon (0 = ocean/none). Matches the shader's UV mapping exactly.
    public static func index(latitude lat: Double, longitude lon: Double) -> Int {
        guard let r = raster else { return 0 }
        let u = (lon / 360 + 0.5).truncatingRemainder(dividingBy: 1)
        let uu = u < 0 ? u + 1 : u
        var col = Int(uu * Double(r.w)); col = min(max(col, 0), r.w - 1)
        var row = Int((0.5 - lat / 180) * Double(r.h)); row = min(max(row, 0), r.h - 1)
        return Int(r.px[row * r.w + col])
    }

    /// ISO alpha-2 code at a lat/lon, or nil over open ocean.
    public static func iso(latitude lat: Double, longitude lon: Double) -> String? {
        legend[index(latitude: lat, longitude: lon)]
    }

    /// Representative lat/lon (pixel centroid) for an ISO code, for flying to a country.
    /// Longitudes are averaged on the unit circle so antimeridian-spanning countries don't skew.
    public static func centroid(iso: String) -> (latitude: Double, longitude: Double)? {
        guard let r = raster, let idx = indexByISO[iso.uppercased()] else { return nil }
        let target = UInt8(clamping: idx)
        var sx = 0.0, sy = 0.0, sumLat = 0.0, n = 0.0
        for row in 0..<r.h {
            let lat = 90 - (Double(row) + 0.5) / Double(r.h) * 180
            let base = row * r.w
            for col in 0..<r.w where r.px[base + col] == target {
                let lon = ((Double(col) + 0.5) / Double(r.w) - 0.5) * 360
                let a = lon * .pi / 180
                sx += cos(a); sy += sin(a); sumLat += lat; n += 1
            }
        }
        guard n > 0 else { return nil }
        let lon = atan2(sy / n, sx / n) * 180 / .pi
        return (sumLat / n, lon)
    }
}
#endif
