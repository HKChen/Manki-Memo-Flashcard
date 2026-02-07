import SwiftUI

struct AppTheme {
    struct Colors {
        // Muji/Fuji inspired palette
        static let background = Color(hex: "F9F9F7") ?? Color.white // Soft off-white
        static let surface = Color(hex: "FFFFFF") ?? Color.white     // Pure white for cards
        static let primaryText = Color(hex: "333333") ?? Color.black // Soft black
        static let secondaryText = Color(hex: "666666") ?? Color.gray // Dark gray
        static let accent = Color(hex: "B94047") ?? Color.red      // Muted Red (Stamp/Seal color)
        static let border = Color(hex: "E5E5E5") ?? Color.gray      // Light gray border
        static let divider = Color(hex: "E0E0E0") ?? Color.gray
    }
}


