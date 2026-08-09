import SwiftUI

// MARK: - Color Palette

extension Color {
    // Primary brand colors
    static let yhPrimary = Color(red: 1.0, green: 0.38, blue: 0.28)       // Vibrant coral
    static let yhPrimaryDark = Color(red: 0.91, green: 0.27, blue: 0.18)  // Deeper coral
    static let yhSecondary = Color(red: 0.38, green: 0.35, blue: 0.95)    // Purple-blue
    static let yhAccent = Color(red: 1.0, green: 0.58, blue: 0.0)         // Warm amber

    // Backgrounds
    static let yhBackground = Color(UIColor.systemGroupedBackground)
    static let yhSurface = Color(UIColor.secondarySystemGroupedBackground)
    static let yhCardBackground = Color(UIColor.systemBackground)

    // Text
    static let yhTextPrimary = Color(UIColor.label)
    static let yhTextSecondary = Color(UIColor.secondaryLabel)
    static let yhTextTertiary = Color(UIColor.tertiaryLabel)

    // Semantic
    static let yhLikeActive = Color(red: 1.0, green: 0.25, blue: 0.35)
    static let yhSuccess = Color(red: 0.2, green: 0.78, blue: 0.45)
    static let yhError = Color(red: 0.95, green: 0.25, blue: 0.25)

    // Comment dot colors (vibrant, distinct palette for spatial markers)
    static let commentDotColors: [Color] = [
        Color(red: 1.0, green: 0.38, blue: 0.28),   // Coral
        Color(red: 0.38, green: 0.35, blue: 0.95),   // Purple
        Color(red: 0.0, green: 0.78, blue: 0.65),    // Teal
        Color(red: 1.0, green: 0.58, blue: 0.0),     // Amber
        Color(red: 0.85, green: 0.25, blue: 0.65),   // Magenta
        Color(red: 0.18, green: 0.62, blue: 1.0),    // Sky blue
        Color(red: 0.55, green: 0.82, blue: 0.15),   // Lime
        Color(red: 1.0, green: 0.35, blue: 0.55),    // Pink
    ]
}

// MARK: - Gradients

extension LinearGradient {
    static let yhPrimaryGradient = LinearGradient(
        colors: [Color.yhPrimary, Color.yhAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let yhSecondaryGradient = LinearGradient(
        colors: [Color.yhSecondary, Color(red: 0.55, green: 0.35, blue: 1.0)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Typography

struct YHFont {
    static func title(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }

    static func headline(_ size: CGFloat = 18) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }

    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular)
    }

    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .medium)
    }

    static func small(_ size: CGFloat = 11) -> Font {
        .system(size: size, weight: .regular)
    }
}

// MARK: - Spacing & Layout

struct YHSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

struct YHRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 999
}

// MARK: - View Modifiers

struct YHCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.yhCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: YHRadius.md))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

struct YHPrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(YHFont.headline(16))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, YHSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: YHRadius.md)
                    .fill(isDisabled ? Color.gray.opacity(0.4) : Color.yhPrimary)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func yhCard() -> some View {
        modifier(YHCardModifier())
    }
}
