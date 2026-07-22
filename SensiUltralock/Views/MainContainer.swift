import SwiftUI

struct MainContainer: View {
    @StateObject private var viewModel = AppViewModel()
    @State private var selectedTab: Int = 0

    var body: some View {
        ZStack {
            CyberTheme.bgGradient.ignoresSafeArea()

            if viewModel.isRestoring {
                SyncLoadingView(progress: viewModel.restoreProgress)
                    .transition(.opacity)
            } else if viewModel.isAuthenticated {
                mainShell
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            } else {
                LoginView(viewModel: viewModel)
                    .transition(.opacity.combined(with: .scale(scale: 0.98)))
            }

            // Toast overlay
            if let toast = viewModel.toast {
                VStack {
                    Spacer()
                    ToastView(text: toast)
                        .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeInOut(duration: 0.45), value: viewModel.isAuthenticated)
        .animation(.easeInOut(duration: 0.3), value: viewModel.toast)
        .task {
            await viewModel.restoreSessionIfNeeded()
        }
    }

    private var mainShell: some View {
        VStack(spacing: 0) {
            topBar

            TabView(selection: $selectedTab) {
                OptimizerView(viewModel: viewModel)
                    .tag(0)

                SystemTabView()
                    .tag(1)

                UserView(viewModel: viewModel)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(CyberTheme.bgGradient.ignoresSafeArea())
    }

    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SENSI ULTRALOCK")
                        .font(.system(.footnote, design: .rounded).weight(.heavy))
                        .foregroundStyle(CyberTheme.textPrimary)
                        .tracking(1.5)
                    Text(viewModel.isVIP ? "VIP EDITION" : (viewModel.isProOrHigher ? "PRO EDITION" : "BASIC EDITION"))
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(viewModel.isVIP ? CyberTheme.cyberGold : (viewModel.isProOrHigher ? CyberTheme.cyberPurple : CyberTheme.cyberCyan))
                        .tracking(1.5)
                }
                Spacer()

                ZStack {
                    Circle()
                        .fill(viewModel.isVIP ? CyberTheme.cyberPurple : CyberTheme.darkBorder)
                        .frame(width: 34, height: 34)
                    Image("Avatar")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                }
                .overlay(
                    Circle().stroke(viewModel.isVIP ? CyberTheme.cyberGold : CyberTheme.cyberCyan, lineWidth: 1.2)
                )
                .cyberGlow(viewModel.isVIP ? CyberTheme.cyberPurple : CyberTheme.cyberCyan, radius: 6, opacity: 0.5)
            }
            .padding(.horizontal, 14)
            .padding(.top, 6)
            .padding(.bottom, 6)

            CyberSegmentedControl(
                items: [("TỐI ƯU", "slider.horizontal.3"), ("HỆ THỐNG", "cpu"), ("THÀNH VIÊN", "person.crop.circle")],
                selection: $selectedTab
            )
            .padding(.horizontal, 14)
            .padding(.bottom, 6)
        }
        .background(CyberTheme.cyberCardBg.opacity(0.85).ignoresSafeArea(edges: .top))
    }
}

// MARK: - Sync Loading

struct SyncLoadingView: View {
    let progress: Double

    var body: some View {
        ZStack {
            CyberGridBackground().ignoresSafeArea()
            VStack(spacing: 16) {
                ShieldLogo(size: 70)
                Text("ĐANG ĐỒNG BỘ HỆ THỐNG NEXORA…")
                    .font(.system(.caption, design: .rounded).weight(.heavy))
                    .foregroundStyle(CyberTheme.cyberCyan)
                    .tracking(1.5)
                    .cyberGlow(CyberTheme.cyberCyan, radius: 4, opacity: 0.4)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CyberTheme.darkBorder)
                            .frame(height: 8)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(CyberTheme.cyanGlowGradient)
                            .frame(width: geo.size.width * progress, height: 8)
                            .cyberGlow(CyberTheme.cyberCyan, radius: 6, opacity: 0.6)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 40)

                Text("\(Int(progress * 100))%")
                    .font(CyberTheme.monoFont.weight(.bold))
                    .foregroundStyle(CyberTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
