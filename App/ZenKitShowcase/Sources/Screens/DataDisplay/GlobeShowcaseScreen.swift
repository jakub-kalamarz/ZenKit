import SwiftUI
import ZenKit
import CoreLocation

struct GlobeShowcaseScreen: View {
    @State private var dark = 0.0
    @State private var spin = true
    @State private var tappedPlace = "Tap the globe, or pick a country below"
    @State private var selection: ZenGlobeSelection?
    private let geocoder = CLGeocoder()

    /// Countries a developer can fly to programmatically.
    private let destinations: [(name: String, flag: String, lat: Double, lon: Double)] = [
        ("Brazil", "🇧🇷", -14.24, -51.93),
        ("Egypt", "🇪🇬", 26.82, 30.80),
        ("Japan", "🇯🇵", 36.20, 138.25),
        ("Australia", "🇦🇺", -25.27, 133.78),
    ]

    private let cities: [ZenGlobeMarker] = [
        ZenGlobeMarker(latitude: 37.7595, longitude: -122.4367, size: 0.05),
        ZenGlobeMarker(latitude: 40.7128, longitude: -74.006, size: 0.07, color: .red),
        ZenGlobeMarker(latitude: 51.5074, longitude: -0.1278, size: 0.05),
        ZenGlobeMarker(latitude: 35.6762, longitude: 139.6503, size: 0.05),
        ZenGlobeMarker(latitude: -33.8688, longitude: 151.2093, size: 0.05),
    ]

    /// Emoji sticker per city, matched to the `cities` array order.
    private let cityEmoji = ["🌉", "🗽", "🎡", "🗼", "🦘"]

    private func emoji(for marker: ZenGlobeMarker) -> String {
        cities.firstIndex(where: { $0.id == marker.id }).map { cityEmoji[$0] } ?? "📍"
    }

    private func detectCountry(_ tap: ZenGlobeTap) {
        let coord = String(format: "%.1f°, %.1f°", tap.latitude, tap.longitude)
        tappedPlace = "Locating \(coord)…"
        geocoder.cancelGeocode()
        let location = CLLocation(latitude: tap.latitude, longitude: tap.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, _ in
            if let place = placemarks?.first, let country = place.country {
                let flag = place.isoCountryCode.map(Self.flag) ?? ""
                tappedPlace = "\(flag) \(country)  ·  \(coord)"
            } else {
                tappedPlace = "🌊 Open ocean  ·  \(coord)"
            }
        }
    }

    /// ISO country code → flag emoji (regional indicator symbols).
    private static func flag(_ iso: String) -> String {
        iso.uppercased().unicodeScalars.compactMap {
            Unicode.Scalar(127397 + $0.value).map(String.init)
        }.joined()
    }

    private let routes: [ZenGlobeArc] = [
        ZenGlobeArc(from: (37.7595, -122.4367), to: (40.7128, -74.006)),
        ZenGlobeArc(from: (40.7128, -74.006), to: (51.5074, -0.1278), color: .orange),
        ZenGlobeArc(from: (51.5074, -0.1278), to: (35.6762, 139.6503)),
        ZenGlobeArc(from: (35.6762, 139.6503), to: (-33.8688, 151.2093)),
    ]

    var body: some View {
        ShowcaseScreen(title: "Globe") {
            ZenCard(title: "Default", subtitle: "Pale sphere, soft blue land — adapts to theme") {
                ZenGlobe(markers: cities)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
            }

            ZenCard(title: "Arcs", subtitle: "Great-circle routes between cities") {
                ZenGlobe(markers: cities, arcs: routes)
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
            }

            ZenCard(title: "Select & fly to", subtitle: "Pick a country or tap the globe — it flies there and marks it selected") {
                VStack(spacing: ZenSpacing.medium) {
                    ZenGlobe(
                        markers: cities,
                        autoRotate: false,
                        onTapLocation: { tap in detectCountry(tap) },
                        selection: $selection,
                        countryHighlightColor: .orange
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)

                    Text(tappedPlace)
                        .font(.zen(.body2, weight: .medium))
                        .foregroundStyle(Color.zenTextMuted)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    HStack(spacing: ZenSpacing.small) {
                        ForEach(destinations, id: \.name) { d in
                            Button {
                                selection = ZenGlobeSelection(latitude: d.lat, longitude: d.lon)
                                tappedPlace = "\(d.flag) \(d.name)"
                            } label: {
                                Text("\(d.flag) \(d.name)")
                                    .font(.zen(.body2, weight: .medium))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, ZenSpacing.xSmall)
                                    .background(Color.zenSurfaceMuted, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            ZenCard(title: "Labels", subtitle: "Emoji stickers anchored to markers") {
                ZenGlobe(
                    markers: cities,
                    markerLabel: { marker in
                        AnyView(
                            Text(emoji(for: marker))
                                .font(.system(size: 22))
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(.white))
                                .overlay(Circle().stroke(.white, lineWidth: 3))
                                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                                .offset(y: -22)
                        )
                    }
                )
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
