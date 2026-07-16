import SwiftUI

// ═══════════════════════════════════════════════════════════════
// YELLOW/GOLD THEME — replaces the original purple theme
// ═══════════════════════════════════════════════════════════════

let CyberBg            = Color(hexARGB: 0xFF06020E)
let CyberSurface       = Color(hexARGB: 0xFF1A1100)
let CyberCardBg        = Color(hexARGB: 0x90332000)
let CyberYellow        = Color(hexARGB: 0xFFFFD700) // Main accent ⭐
let CyberYellowGlow    = Color(hexARGB: 0x33FFD700)
let CyberIceYellow     = Color(hexARGB: 0xFFFFF8E1)
let CyberAmber         = Color(hexARGB: 0xFFFFB300)
let CyberGreen         = Color(hexARGB: 0xFF00FF94)
let CyberTextSecondary = Color(hexARGB: 0xFFFFE0B2)
let CyberTextPrimary   = Color.white
let CyberDarkBorder    = Color(hexARGB: 0xFF4A3000)

// Derived semantic colors
let CyberDarkBg        = Color(hexARGB: 0xFF1A0800)  // replaces 0xFF0F0422
let CyberMediumBg      = Color(hexARGB: 0xFF332000)  // replaces 0xFF241445
let CyberGradientDark  = Color(hexARGB: 0xFF1A0E00) // replaces 0xFF140827
let CyberLockedColor   = Color(hexARGB: 0xFFB8860B)
let CyberProGradStart  = Color(hexARGB: 0xFFCC8800)
let CyberProGradEnd    = Color(hexARGB: 0xFFFFB300)
let CyberToggleTrack   = Color(hexARGB: 0xFF332000)
let CyberToggleGradStart = Color(hexARGB: 0xFFCC9900)
let CyberToggleGradEnd = Color(hexARGB: 0xFFFFD700)

// VIP badge gold gradient — kept as original
let CyberVipGoldStart  = Color(hexARGB: 0xFFFFD54F)
let CyberVipGoldEnd    = Color(hexARGB: 0xFFFF8F00)

// Android-style alpha colors (used for overlays)
func alphaColor(_ hexARGB: UInt32) -> Color { Color(hexARGB: hexARGB) }

extension Color {
    /// Parses ARGB hex as Android Compose does: 0xAARRGGBB
    init(hexARGB: UInt32) {
        let a = Double((hexARGB >> 24) & 0xFF) / 255.0
        let r = Double((hexARGB >> 16) & 0xFF) / 255.0
        let g = Double((hexARGB >> 8) & 0xFF) / 255.0
        let b = Double(hexARGB & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
