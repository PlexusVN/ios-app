import SwiftUI
import UIKit
import QuartzCore

// MARK: - 120fps Adaptive Animation Driver

struct AnimationClock: ViewModifier {
    let fps: Double
    @State private var phase: Double = 0
    @State private var displayLink: DisplayLink?

    func body(content: Content) -> some View {
        content
            .onAppear {
                displayLink = DisplayLink(fps: fps) { dt in
                    phase += dt * fps
                }
            }
    }
}

final class DisplayLink: NSObject {
    private var link: CADisplayLink?
    private let handler: (Double) -> Void
    private var last: CFTimeInterval = 0

    init(fps: Double, handler: @escaping (Double) -> Void) {
        self.handler = handler
        super.init()
        link = CADisplayLink(target: self, selector: #selector(tick))
        link?.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: Float(fps), preferred: Float(fps))
        link?.add(to: .main, forMode: .common)
    }

    @objc private func tick(_ sender: CADisplayLink) {
        let now = sender.timestamp
        if last == 0 { last = now; return }
        let dt = now - last
        last = now
        handler(min(dt, 0.033))
    }

    deinit { link?.invalidate() }
}

// MARK: - Floating 3D Particles

struct FloatingParticles: View {
    let count: Int
    let color: Color
    let speed: Double

    @State private var particles: [Particle3D] = []
    private let timer = Timer.publish(every: 1/120, on: .main, in: .common).autoconnect()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/120)) { timeline in
            Canvas { context, size in
                for i in particles.indices {
                    var p = particles[i]
                    let dt = 1.0 / 120.0
                    p.x += cos(p.angle + p.z) * p.speed * dt * 60
                    p.y += sin(p.angle) * p.speed * dt * 60
                    p.z += 0.02 * dt * 60
                    if p.z > .pi * 2 { p.z = 0 }
                    if p.x < 0 { p.x = size.width }
                    if p.x > size.width { p.x = 0 }
                    if p.y < 0 { p.y = size.height }
                    if p.y > size.height { p.y = 0 }

                    let depth = 0.3 + 0.7 * ((sin(p.z) + 1) / 2)
                    let px = p.x
                    let py = p.y
                    let r = p.baseR * depth

                    let alpha = depth * 0.6
                    let c = color.opacity(Double(alpha))
                    context.fill(Path(ellipseIn: CGRect(x: px - r, y: py - r, width: r * 2, height: r * 2)), with: .color(c))

                    if depth > 0.7 {
                        let g = color.opacity(Double(depth * 0.3))
                        context.fill(Path(ellipseIn: CGRect(x: px - r * 2, y: py - r * 2, width: r * 4, height: r * 4)), with: .color(g))
                    }

                    particles[i] = p
                }
            }
            .onAppear {
                particles = (0..<count).map { _ in Particle3D(
                    x: CGFloat.random(in: 0...400),
                    y: CGFloat.random(in: 0...900),
                    z: CGFloat.random(in: 0...(.pi * 2)),
                    speed: CGFloat(0.3 + Double.random(in: 0.3...speed)),
                    angle: CGFloat.random(in: 0...(.pi * 2)),
                    baseR: CGFloat.random(in: 1.0...3.0)
                )}
            }
        }
    }
}

struct Particle3D {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat
    let speed: CGFloat
    let angle: CGFloat
    let baseR: CGFloat
}

// MARK: - Matrix Rain Effect

struct MatrixRainEffect: View {
    let opacity: Double
    @State private var drops: [MatrixDrop] = []

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, size in
                let chars = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789ABCDEF"
                let fontSize: CGFloat = 10
                let cols = Int(size.width / fontSize)

                if drops.isEmpty {
                    drops = (0..<cols).map { col in MatrixDrop(
                        x: CGFloat(col) * fontSize,
                        y: CGFloat.random(in: -size.height...0),
                        speed: CGFloat.random(in: 1.0...3.0),
                        length: Int.random(in: 5...20)
                    )}
                }

                for i in drops.indices {
                    var d = drops[i]
                    d.y += d.speed

                    if d.y > size.height + CGFloat(d.length) * fontSize {
                        d.y = -CGFloat(d.length) * fontSize
                        d.speed = CGFloat.random(in: 1.0...3.0)
                        d.length = Int.random(in: 5...20)
                    }

                    for j in 0..<d.length {
                        let cy = d.y - CGFloat(j) * fontSize
                        guard cy >= 0 && cy <= size.height else { continue }
                        let char = String(chars.randomElement() ?? "A")
                        let alpha: Double
                        if j == 0 {
                            alpha = opacity * 0.9
                        } else {
                            alpha = opacity * max(0.05, 0.5 - Double(j) / Double(d.length) * 0.5)
                        }
                        let c = Color(red: 0, green: 1, blue: 0.3, opacity: alpha)
                        context.draw(Text(char).font(.system(size: fontSize, weight: .bold)).foregroundColor(c), at: CGPoint(x: d.x + fontSize / 2, y: cy + fontSize / 2))
                    }
                    drops[i] = d
                }
            }
        }
    }
}

struct MatrixDrop {
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
    var length: Int
}

// MARK: - Scanline Overlay

struct ScanlineOverlay: View {
    let opacity: Double

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/120)) { timeline in
            Canvas { context, size in
                let spacing: CGFloat = 3
                var y: CGFloat = 0
                while y < size.height {
                    let path = Path(CGRect(x: 0, y: y, width: size.width, height: 1))
                    context.fill(path, with: .color(.black.opacity(opacity)))
                    y += spacing
                }
            }
            .allowsHitTesting(false)
        }
    }
}

// MARK: - Glitch Text Effect

struct GlitchText: View {
    let text: String
    let size: CGFloat
    let color: Color
    let glitchColor1: Color
    let glitchColor2: Color
    let intensity: Double
    let weight: Font.Weight

    @State private var offsetX1: CGFloat = 0
    @State private var offsetX2: CGFloat = 0
    @State private var showGlitch = false
    @State private var sliceY: CGFloat = 0

    var body: some View {
        ZStack {
            Text(text)
                .font(.system(size: size, weight: weight))
                .foregroundColor(color)

            if showGlitch {
                Text(text)
                    .font(.system(size: size, weight: weight))
                    .foregroundColor(glitchColor1)
                    .offset(x: offsetX1, y: 0)
                    .mask(
                        Rectangle()
                            .frame(height: size * 0.3)
                            .offset(y: sliceY - size * 0.15)
                    )

                Text(text)
                    .font(.system(size: size, weight: weight))
                    .foregroundColor(glitchColor2)
                    .offset(x: offsetX2, y: 0)
                    .mask(
                        Rectangle()
                            .frame(height: size * 0.25)
                            .offset(y: -sliceY + size * 0.1)
                    )
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.05 + Double.random(in: 0...2), repeats: true) { t in
                guard Double.random(in: 0...1) < intensity else { return }
                showGlitch = true
                offsetX1 = CGFloat.random(in: -4...4)
                offsetX2 = CGFloat.random(in: -3...3)
                sliceY = CGFloat.random(in: 0...size)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                    showGlitch = false
                }
            }
        }
    }
}

// MARK: - Neon Glow Modifier

struct NeonGlow: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(intensity * 0.8), radius: radius)
            .shadow(color: color.opacity(intensity * 0.5), radius: radius * 2)
            .shadow(color: color.opacity(intensity * 0.3), radius: radius * 3)
    }
}

extension View {
    func neonGlow(color: Color = CyberYellow, radius: CGFloat = 8, intensity: Double = 1.0) -> some View {
        modifier(NeonGlow(color: color, radius: radius, intensity: intensity))
    }
}

// MARK: - Holographic Border

struct HolographicBorder: ViewModifier {
    let color: Color
    let animate: Bool

    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content.modifier(HoloBorderInner(color: color, phase: phase, animate: animate))
    }
}

struct HoloBorderInner: ViewModifier {
    let color: Color
    let phase: CGFloat
    let animate: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.6),
                                color.opacity(0.2),
                                color.opacity(0.8),
                                color.opacity(0.3),
                                color.opacity(0.6)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .onAppear {
                guard animate else { return }
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    // phase drives gradient shift implicitly
                }
            }
    }
}

// MARK: - Animated Grid Background

struct AnimatedGridBackground: View {
    let color: Color
    let opacity: Double
    let animate: Bool

    @State private var offset: CGFloat = 0
    private let gridSpacing: CGFloat = 40

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/60)) { timeline in
            Canvas { context, size in
                let spacing = gridSpacing
                let o = animate ? offset : 0

                for x in stride(from: -spacing + o.truncatingRemainder(dividingBy: spacing), through: size.width + spacing, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: 0.5)
                }

                for y in stride(from: -spacing + o.truncatingRemainder(dividingBy: spacing), through: size.height + spacing, by: spacing) {
                    var path = Path()
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    context.stroke(path, with: .color(color.opacity(opacity)), lineWidth: 0.5)
                }
            }
            .onAppear {
                guard animate else { return }
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    offset = gridSpacing
                }
            }
        }
    }
}

// MARK: - Pulsing Rings (3D radar effect)

struct PulsingRadar: View {
    let color: Color
    let count: Int
    let maxRadius: CGFloat

    @State private var phase: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/120)) { timeline in
            Canvas { context, size in
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let now = timeline.date.timeIntervalSinceReferenceDate

                for i in 0..<count {
                    let t = (now * 0.5 + Double(i) / Double(count)).truncatingRemainder(dividingBy: 1.0)
                    let r = maxRadius * CGFloat(t)
                    let alpha = Double(max(0, 1 - t * 1.5))

                    let path = Path(ellipseIn: CGRect(
                        x: center.x - r, y: center.y - r,
                        width: r * 2, height: r * 2
                    ))
                    context.stroke(path, with: .color(color.opacity(alpha)), lineWidth: 1)
                }
            }
        }
    }
}

// MARK: - 3D Perspective Card

struct PerspectiveCard<Content: View>: View {
    let content: Content
    let height: CGFloat
    @State private var perspective: CGFloat = 0

    init(height: CGFloat, @ViewBuilder content: () -> Content) {
        self.height = height
        self.content = content()
    }

    var body: some View {
        content
            .frame(height: height)
            .rotation3DEffect(.degrees(perspective * 2), axis: (x: 1, y: 0, z: 0))
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    perspective = 0
                }
            }
    }
}
