import SwiftUI

// Single source of truth for all design tokens.
// LoginTheme and ErrorTheme are thin aliases kept for backward compatibility.

enum AppTheme {

    // MARK: - Colors

    enum Colors {
        // Backgrounds
        static let background    = Color(red: 0.039, green: 0.024, blue: 0.086) // #0A0618
        static let surface       = Color(red: 0.071, green: 0.047, blue: 0.149) // #120C26
        static let surfaceGlass  = Color.white.opacity(0.07)                    // glass buttons

        // Accent (violet)
        static let accent        = Color(red: 0.655, green: 0.545, blue: 0.980) // #A78BFA
        static let accentSubtle  = Color(red: 0.345, green: 0.267, blue: 0.518)
        static let label         = Color(red: 0.502, green: 0.424, blue: 0.686)

        // Borders
        static let border        = Color(red: 0.216, green: 0.149, blue: 0.373) // #37266F

        // Gradient (login / primary CTA violet)
        static let gradientStart = Color(red: 0.427, green: 0.157, blue: 0.851) // #6D28D9
        static let gradientEnd   = Color(red: 0.655, green: 0.545, blue: 0.980) // #A78BFA

        // Primary action (play button — blue)
        static let primary       = Color(red: 0.231, green: 0.553, blue: 0.937) // #3B8DEF

        // Danger / error (rouge)
        static let danger        = Color(red: 0.941, green: 0.337, blue: 0.337) // #F05757

        // Badges
        static let badgeHDR      = Color(red: 0.231, green: 0.553, blue: 0.937) // bleu = primary
        static let badgeNew      = Color(red: 0.298, green: 0.686, blue: 0.314) // #4CAF50 vert
        static let badgeRating   = Color(red: 0.655, green: 0.545, blue: 0.980) // violet = accent
        static let badgeNeutral  = Color.white.opacity(0.12)
    }

    // MARK: - Typography
    // Police cible : Nunito (à embarquer en ressource).
    // En attendant, .system avec les bonnes graisses est utilisé.

    enum Typography {
        static let display        : Font = .system(size: 36, weight: .heavy)
        static let heading1       : Font = .system(size: 17, weight: .bold)
        static let heading2       : Font = .system(size: 15, weight: .bold)
        static let heading2bis    : Font = .system(size: 15, weight: .semibold)
        static let heading3       : Font = .system(size: 13, weight: .semibold)
        static let strong         : Font = .system(size: 13, weight: .semibold)
        static let body           : Font = .system(size: 13, weight: .regular)
        static let tiny           : Font = .system(size: 11, weight: .regular)
        static let numberCalendar : Font = .system(size: 13, weight: .semibold)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat =  8
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 30
        static let xl: CGFloat = 40
    }

    // MARK: - Corner radius

    enum Radius {
        static let button : CGFloat = 14
        static let card   : CGFloat = 12
        static let icon   : CGFloat = 12
        static let badge  : CGFloat =  8
        static let pill   : CGFloat = 100 // full pill
    }
}
