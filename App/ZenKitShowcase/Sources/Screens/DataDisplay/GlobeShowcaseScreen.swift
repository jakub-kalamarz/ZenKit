import SwiftUI
import ZenKit

struct GlobeShowcaseScreen: View {
    @State private var dark = 0.0
    @State private var spin = true

    private let cities: [ZenGlobeMarker] = [
        ZenGlobeMarker(latitude: 37.7595, longitude: -122.4367, size: 0.05),
        ZenGlobeMarker(latitude: 40.7128, longitude: -74.006, size: 0.07, color: .red),
        ZenGlobeMarker(latitude: 51.5074, longitude: -0.1278, size: 0.05),
        ZenGlobeMarker(latitude: 35.6762, longitude: 139.6503, size: 0.05),
        ZenGlobeMarker(latitude: -33.8688, longitude: 151.2093, size: 0.05),
    ]

    var body: some View {
        ShowcaseScreen(title: "Globe") {
            ZenCard(title: "Default", subtitle: "Pale sphere, soft blue land — adapts to theme") {
                ZenGlobe(markers: cities)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
            }

            ZenCard(title: "Glowing", subtitle: "Glowing land dots on a dark sphere") {
                ZenGlobe(
                    markers: cities,
                    dark: 1,
                    baseColor: .black,
                    dotColor: .zenAccent,
                    glowColor: .zenAccent
                )
                .frame(maxWidth: .infinity)
                .frame(height: 280)
            }

            ZenCard(title: "Interactive", subtitle: "Tune dark mode and rotation") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenGlobe(
                        markers: cities,
                        autoRotate: spin,
                        dark: dark,
                        markerColor: .zenSuccess
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)

                    ZenToggle("Auto-rotate", isOn: $spin)

                    VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                        Text("Dark")
                            .font(.zen(.body2, weight: .medium))
                            .foregroundStyle(Color.zenTextMuted)
                        Slider(value: $dark, in: 0...1)
                    }
                }
            }

            ZenCard(title: "Zoomed", subtitle: "scale > 1 crops into the surface") {
                ZenGlobe(scale: 1.6)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
            }
        }
    }
}

#Preview("Globe Showcase") {
    GlobeShowcaseScreen()
}
