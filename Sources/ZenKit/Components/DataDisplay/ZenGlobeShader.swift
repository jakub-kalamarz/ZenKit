#if canImport(MetalKit)
import Foundation

/// Metal Shading Language source for ``ZenGlobe``, compiled at runtime via
/// `device.makeLibrary(source:)`. Shipped as an embedded string (rather than a `.metal`
/// resource) so the package needs no resource bundle and works the same for any consumer.
///
/// This is a near-verbatim port of cobe's `globe.vert.glslx` + `globe.frag.glslx`: a
/// full-screen-quad fragment program that raymarches a sphere and renders a spherical
/// Fibonacci dot lattice whose per-dot brightness comes from the embedded land mask, plus a
/// glow halo. See `nearestFibonacciLattice` (Keinert et al. 2015) for the O(1) lookup.
enum ZenGlobeShader {
    static let source = """
    #include <metal_stdlib>
    using namespace metal;

    struct GlobeUniforms {
        float4 resolutionOffset;    // (resX, resY, offsetX, offsetY)
        float4 rotationDotsScale;   // (phi, theta, dots, scale)
        float4 baseColor;           // sphere body color (r, g, b, _)
        float4 glowColor;           // (r, g, b, _)
        float4 renderParams;        // (mapBrightness, diffuse, dark, opacity)
        float4 misc;                // (mapBaseBrightness, _, _, _)
        float4 dotColor;            // land-dot color (r, g, b, _)
    };

    struct VSOut {
        float4 position [[position]];
    };

    vertex VSOut zenGlobeVertex(uint vid [[vertex_id]],
                                const device float2 *positions [[buffer(0)]]) {
        VSOut out;
        out.position = float4(positions[vid], 0.0, 1.0);
        return out;
    }

    constant float sqrt5 = 2.236068;
    constant float kPI = 3.141593;
    constant float kTau = 6.283185;
    constant float kPhi = 1.618034;
    constant float kR = 0.8;

    static float3x3 rotate(float theta, float phi) {
        float cx = cos(theta);
        float cy = cos(phi);
        float sx = sin(theta);
        float sy = sin(phi);
        // GLSL mat3(...) and Metal float3x3(...) are both column-major, so cobe's argument
        // grouping maps directly: each float3 below is one column, verbatim from cobe.
        return float3x3(
            float3(cy, sy * sx, -sy * cx),
            float3(0.0, cx, sx),
            float3(sy, cy * -sx, cy * cx)
        );
    }

    // O(1) inverse spherical-Fibonacci lookup (Keinert et al. 2015), ported from cobe.
    static float3 nearestFibonacciLattice(float3 p, float dots, float byDots, thread float &m) {
        p = p.xzy;

        float k = max(2.0, floor(log2(sqrt5 * dots * kPI * (1.0 - p.z * p.z)) * 0.72021));

        float2 f = floor(pow(kPhi, k) / sqrt5 * float2(1.0, kPhi) + 0.5);
        float2 br1 = fract((f + 1.0) * (kPhi - 1.0)) * kTau - 3.883222;
        float2 br2 = -2.0 * f;
        float2 sp = float2(atan2(p.y, p.x), p.z - 1.0);
        float2 c = floor(float2(br2.y * sp.x - br1.y * (sp.y * dots + 1.0),
                                -br2.x * sp.x + br1.x * (sp.y * dots + 1.0))
                         / (br1.x * br2.y - br2.x * br1.y));

        float mindist = kPI;
        float3 minip = float3(0.0);
        for (float s = 0.0; s < 4.0; s += 1.0) {
            float2 o = float2(fmod(s, 2.0), floor(s * 0.5));
            float idx = dot(f, c + o);
            if (idx > dots) continue;

            float a = idx, b = 0.0;
            if (a >= 16384.0) { a -= 16384.0; b += 0.868872; }
            if (a >= 8192.0)  { a -= 8192.0;  b += 0.934436; }
            if (a >= 4096.0)  { a -= 4096.0;  b += 0.467218; }
            if (a >= 2048.0)  { a -= 2048.0;  b += 0.733609; }
            if (a >= 1024.0)  { a -= 1024.0;  b += 0.866804; }
            if (a >= 512.0)   { a -= 512.0;   b += 0.433402; }
            if (a >= 256.0)   { a -= 256.0;   b += 0.216701; }
            if (a >= 128.0)   { a -= 128.0;   b += 0.108351; }
            if (a >= 64.0)    { a -= 64.0;    b += 0.554175; }
            if (a >= 32.0)    { a -= 32.0;    b += 0.777088; }
            if (a >= 16.0)    { a -= 16.0;    b += 0.888544; }
            if (a >= 8.0)     { a -= 8.0;     b += 0.944272; }
            if (a >= 4.0)     { a -= 4.0;     b += 0.472136; }
            if (a >= 2.0)     { a -= 2.0;     b += 0.236068; }
            if (a >= 1.0)     { a -= 1.0;     b += 0.618034; }

            float theta = fract(b) * kTau;

            float cosphi = 1.0 - 2.0 * idx * byDots;
            float sinphi = sqrt(1.0 - cosphi * cosphi);
            float3 smp = float3(cos(theta) * sinphi, sin(theta) * sinphi, cosphi);

            float dist = length(p - smp);
            if (dist < mindist) {
                mindist = dist;
                minip = smp;
            }
        }

        m = mindist;
        return minip.xzy;
    }

    fragment float4 zenGlobeFragment(VSOut in [[stage_in]],
                                     constant GlobeUniforms &u [[buffer(0)]],
                                     texture2d<float> uTexture [[texture(0)]],
                                     sampler texSampler [[sampler(0)]]) {
        float2 resolution = u.resolutionOffset.xy;
        float2 offset = u.resolutionOffset.zw;
        float2 rotation = u.rotationDotsScale.xy;
        float dots = u.rotationDotsScale.z;
        float scale = u.rotationDotsScale.w;
        float byDots = 1.0 / dots;

        // Flip Y so the top-left Metal frag coord matches WebGL's bottom-left gl_FragCoord.
        float2 fragCoord = float2(in.position.x, resolution.y - in.position.y);
        float2 invResolution = 1.0 / resolution;

        float2 uv = ((fragCoord * invResolution) * 2.0 - 1.0) / scale
            - offset * float2(1.0, -1.0) * invResolution;
        uv.x *= resolution.x * invResolution.y;

        float l = dot(uv, uv);
        float glowFactor = 0.0;

        float4 color = float4(0.0);
        float3 baseColor = u.baseColor.xyz;
        float3 glowColor = u.glowColor.xyz;
        float3 dotColor = u.dotColor.xyz;

        if (l <= kR * kR) {
            float dis;
            float4 layer = float4(0.0);
            float3 p = normalize(float3(uv, sqrt(kR * kR - l)));
            float3x3 rot = rotate(rotation.y, rotation.x);
            float dotNL = p.z;

            float3 gP = nearestFibonacciLattice(p * rot, dots, byDots, dis);

            float gPhi = asin(gP.y);
            float gTheta = acos(-gP.x / cos(gPhi));
            if (gP.z < 0.0) gTheta = -gTheta;

            float mapColor = max(uTexture.sample(texSampler,
                float2((gTheta * 0.5) / kPI, -(gPhi / kPI + 0.5))).x, u.misc.x);

            float smp = mapColor
                * smoothstep(0.008, 0.0, dis)
                * pow(dotNL, u.renderParams.y)
                * u.renderParams.x;
            float coverage = clamp(smp, 0.0, 1.0);   // 1 at lit land-dot centers
            float dark = u.renderParams.z;

            // Light style: a lit `baseColor` sphere body with `dotColor` land dots painted on
            // top — gives the white-sphere / soft-blue-continents look.
            float3 lit = baseColor * (pow(dotNL, 0.4) + 0.1);
            float3 lightStyle = mix(lit, dotColor, coverage);
            // Dark style: `dotColor` land dots glowing over an empty body (cobe's classic globe).
            float3 darkStyle = dotColor * coverage;

            float3 surface = mix(lightStyle, darkStyle, dark)
                + pow(1.0 - dotNL, 4.0) * glowColor;
            layer += float4(surface, 1.0);

            color += layer * (1.0 + u.renderParams.w) * 0.5;

            glowFactor = (1.0 - l) * (1.0 - l) * smoothstep(0.0, 1.0, 0.2 / (l - kR * kR));
        } else {
            float outD = sqrt(0.2 / (l - kR * kR));
            glowFactor = smoothstep(0.5, 1.0, outD / (outD + 1.0));
        }

        return color + float4(glowFactor * glowColor, glowFactor);
    }
    """
}
#endif
