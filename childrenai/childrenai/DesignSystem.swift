import SwiftUI

// MARK: - Design System: "The Living Playground"
// Based on Material Design tokens from childrenai-mobileUI

struct DS {
    // MARK: - Colors
    struct Colors {
        // Primary
        static let primary = Color(hex: "0058bc")
        static let primaryContainer = Color(hex: "6d9fff")
        static let onPrimary = Color(hex: "f0f2ff")
        static let onPrimaryContainer = Color(hex: "00214f")
        static let primaryDim = Color(hex: "004ca5")

        // Secondary (柔紫 — 中级)
        static let secondary = Color(hex: "6B5EA8")
        static let secondaryContainer = Color(hex: "E8DEFF")
        static let onSecondary = Color(hex: "F5F0FF")
        static let onSecondaryContainer = Color(hex: "4A3D82")

        // Tertiary (玫瑰 — 高级)
        static let tertiary = Color(hex: "B85A7A")
        static let tertiaryContainer = Color(hex: "FFD8E8")
        static let onTertiary = Color(hex: "FFF0F5")
        static let onTertiaryContainer = Color(hex: "8C3A58")

        // Surface hierarchy
        static let surface = Color(hex: "f7f5ff")
        static let surfaceContainer = Color(hex: "e4e7ff")
        static let surfaceContainerLow = Color(hex: "efefff")
        static let surfaceContainerHigh = Color(hex: "dde1ff")
        static let surfaceContainerHighest = Color(hex: "d5dbff")
        static let surfaceContainerLowest = Color.white
        static let surfaceDim = Color(hex: "cad2ff")
        static let surfaceVariant = Color(hex: "d5dbff")

        // On Surface
        static let onSurface = Color(hex: "242c51")
        static let onSurfaceVariant = Color(hex: "515981")
        static let onBackground = Color(hex: "242c51")

        // Outline
        static let outline = Color(hex: "6c759e")
        static let outlineVariant = Color(hex: "a3abd7")

        // Error
        static let error = Color(hex: "b31b25")
        static let errorContainer = Color(hex: "fb5151")

        // Inverse
        static let inverseSurface = Color(hex: "020a2f")
        static let inversePrimary = Color(hex: "4c8eff")
    }

    // MARK: - Corner Radii
    struct Radius {
        static let sm: CGFloat = 8       // 0.5rem
        static let md: CGFloat = 16      // 1rem (DEFAULT)
        static let lg: CGFloat = 32      // 2rem
        static let xl: CGFloat = 48      // 3rem
        static let full: CGFloat = 9999
    }

    // MARK: - Shadows
    struct Shadow {
        static let ambient = Color(hex: "242c51").opacity(0.06)
        static let ambientRadius: CGFloat = 20
        static let ambientY: CGFloat = 10
    }

    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
}

// MARK: - Color hex extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

// MARK: - Glass Effect Modifier
struct GlassEffect: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
    }
}

// MARK: - Ambient Shadow Modifier
struct AmbientShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(color: DS.Shadow.ambient, radius: DS.Shadow.ambientRadius, y: DS.Shadow.ambientY)
    }
}

extension View {
    func glassEffect() -> some View { modifier(GlassEffect()) }
    func ambientShadow() -> some View { modifier(AmbientShadow()) }
}

