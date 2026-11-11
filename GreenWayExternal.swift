import SwiftUI

@main
struct GreenWayExternalApp: App {
    var body: some Scene {
        WindowGroup {
            GreenWayWindow()
                .preferredColorScheme(.dark)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}

struct GreenWayWindow: View {
    @State private var selectedPage: Page = .home
    @State private var showPlayerPanel = true
    @State private var showNameLabels = true
    @State private var compactMode = false
    @State private var launchAtLogin = false

    private let green = Color(red: 0.25, green: 0.88, blue: 0.48)

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            Rectangle().fill(.white.opacity(0.07)).frame(width: 1)
            VStack(spacing: 0) {
                header
                ScrollView {
                    Group {
                        switch selectedPage {
                        case .home: homePage
                        case .visuals: visualsPage
                        case .settings: settingsPage
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(24)
                }
            }
        }
        .frame(width: 860, height: 560)
        .background(Color(red: 0.055, green: 0.075, blue: 0.065))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(.white.opacity(0.08), lineWidth: 1))
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(green)
                    Image(systemName: "leaf.fill").font(.system(size: 18, weight: .bold)).foregroundStyle(.black)
                }
                .frame(width: 38, height: 38)
                VStack(alignment: .leading, spacing: 2) {
                    Text("GREENWAY").font(.system(size: 14, weight: .black, design: .rounded)).tracking(1.2)
                    Text("DESKTOP COMPANION").font(.system(size: 8, weight: .bold)).tracking(1.1).foregroundStyle(.white.opacity(0.42))
                }
            }
            .padding(.bottom, 28)

            navButton(.home, icon: "square.grid.2x2.fill", title: "Dashboard")
            navButton(.visuals, icon: "eye.fill", title: "Visuals")
            navButton(.settings, icon: "gearshape.fill", title: "Settings")

            Spacer()

            HStack(spacing: 8) {
                Circle().fill(green).frame(width: 7, height: 7)
                Text("APP READY").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundStyle(.white.opacity(0.55))
            }
            .padding(.bottom, 4)
        }
        .padding(20)
        .frame(width: 205, alignment: .leading)
        .background(Color.black.opacity(0.16))
    }

    private func navButton(_ page: Page, icon: String, title: String) -> some View {
        Button {
            selectedPage = page
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).frame(width: 18)
                Text(title).font(.system(size: 13, weight: .semibold))
                Spacer()
                if selectedPage == page {
                    RoundedRectangle(cornerRadius: 2).fill(green).frame(width: 3, height: 18)
                }
            }
            .foregroundStyle(selectedPage == page ? green : .white.opacity(0.58))
            .padding(.horizontal, 12)
            .padding(.vertical, 11)
            .background(selectedPage == page ? green.opacity(0.10) : .clear)
            .clipShape(RoundedRectangle(cornerRadius: 9))
        }
        .buttonStyle(.plain)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(selectedPage.title.uppercased())
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .tracking(1.6).foregroundStyle(green)
                Text(selectedPage.subtitle)
                    .font(.system(size: 19, weight: .bold))
            }
            Spacer()
            Text("v1.0.0")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(.white.opacity(0.38))
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(.white.opacity(0.06))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 26).padding(.vertical, 20)
        .background(.white.opacity(0.025))
    }

    private var homePage: some View {
        VStack(alignment: .leading, spacing: 20) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 16).fill(
                    LinearGradient(colors: [green.opacity(0.22), Color(red: 0.10, green: 0.18, blue: 0.13)], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                Circle().fill(green.opacity(0.10)).frame(width: 190).offset(x: 490, y: -35)
                VStack(alignment: .leading, spacing: 9) {
                    Text("WELCOME TO GREENWAY").font(.system(size: 10, weight: .black, design: .monospaced)).tracking(1.8).foregroundStyle(green)
                    Text("Your space.\nYour settings.").font(.system(size: 28, weight: .bold, design: .rounded))
                    Text("A lightweight desktop companion for your setup.")
                        .font(.system(size: 12)).foregroundStyle(.white.opacity(0.58))
                }
                .padding(24)
            }
            .frame(height: 170)
            HStack(spacing: 12) {
                statCard(title: "BUILD", value: "1.0.0", detail: "Initial release", icon: "shippingbox.fill")
                statCard(title: "PLATFORM", value: "macOS", detail: "Native SwiftUI app", icon: "desktopcomputer")
                statCard(title: "STATUS", value: "Ready", detail: "Running locally", icon: "checkmark.circle.fill")
            }
            sectionTitle("QUICK ACCESS", subtitle: "Manage your local app preferences")
            HStack(spacing: 12) {
                actionTile(icon: "eye.fill", title: "Visual preferences", detail: "Customize the companion", page: .visuals)
                actionTile(icon: "slider.horizontal.3", title: "App settings", detail: "Adjust your experience", page: .settings)
            }
            Text("GreenWay is a standalone desktop companion. Its settings do not modify Roblox or interact with other players' games.")
                .font(.system(size: 10)).foregroundStyle(.white.opacity(0.38))
                .padding(.top, 4)
        }
    }

    private var visualsPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("APPEARANCE OPTIONS", subtitle: "These preferences apply only inside this companion app.")
            settingRow("Show player panel preview", detail: "Display the local interface preview.", value: $showPlayerPanel)
            settingRow("Show name labels preview", detail: "Show sample labels in the preview area.", value: $showNameLabels)
            previewCard
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("LOCAL PREVIEW").font(.system(size: 10, weight: .bold, design: .monospaced)).tracking(1.2).foregroundStyle(green)
            if showPlayerPanel {
                HStack {
                    Image(systemName: "person.crop.circle.fill").font(.system(size: 28)).foregroundStyle(green)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(showNameLabels ? "Sample profile" : "Profile hidden").font(.system(size: 12, weight: .semibold))
                        Text("Preview only").font(.system(size: 10)).foregroundStyle(.white.opacity(0.4))
                    }
                    Spacer()
                    Text("LOCAL").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(green)
                }
                .padding(13).background(.white.opacity(0.045)).clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Text("Panel preview is hidden.").font(.system(size: 12)).foregroundStyle(.white.opacity(0.45))
            }
        }
        .padding(16).background(.white.opacity(0.025)).clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(.white.opacity(0.07), lineWidth: 1))
    }

    private var settingsPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            sectionTitle("PREFERENCES", subtitle: "Settings are stored for this app session.")
            settingRow("Compact layout", detail: "Use a denser layout in supported panels.", value: $compactMode)
            settingRow("Launch at login (preview)", detail: "Preference toggle only; login launch is not configured.", value: $launchAtLogin)
            HStack {
                Image(systemName: "info.circle.fill").foregroundStyle(green)
                Text("GreenWay currently runs as a standalone macOS app. No injector or game-process modification is included.")
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.6))
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .background(green.opacity(0.08)).clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 11, weight: .black, design: .monospaced)).tracking(1.3).foregroundStyle(green)
            Text(subtitle).font(.system(size: 12)).foregroundStyle(.white.opacity(0.48))
        }
    }

    private func statCard(title: String, value: String, detail: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(green).font(.system(size: 15))
            Text(value).font(.system(size: 18, weight: .bold, design: .rounded))
            Text(title).font(.system(size: 9, weight: .black, design: .monospaced)).tracking(1).foregroundStyle(.white.opacity(0.45))
            Text(detail).font(.system(size: 10)).foregroundStyle(.white.opacity(0.38))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14).background(.white.opacity(0.035)).clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.white.opacity(0.06), lineWidth: 1))
    }

    private func actionTile(icon: String, title: String, detail: String, page: Page) -> some View {
        Button { selectedPage = page } label: {
            HStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 16)).foregroundStyle(green)
                    .frame(width: 38, height: 38).background(green.opacity(0.10)).clipShape(RoundedRectangle(cornerRadius: 9))
                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                    Text(detail).font(.system(size: 10)).foregroundStyle(.white.opacity(0.42))
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 10, weight: .bold)).foregroundStyle(.white.opacity(0.35))
            }
            .padding(13).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.035)).clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private func settingRow(_ title: String, detail: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 12, weight: .semibold))
                Text(detail).font(.system(size: 10)).foregroundStyle(.white.opacity(0.42))
            }
            Spacer()
            Toggle("", isOn: value).labelsHidden().tint(green).scaleEffect(0.85)
        }
        .padding(15).background(.white.opacity(0.035)).clipShape(RoundedRectangle(cornerRadius: 11))
    }
}

enum Page {
    case home, visuals, settings
    var title: String {
        switch self { case .home: "Dashboard"; case .visuals: "Visuals"; case .settings: "Settings" }
    }
    var subtitle: String {
        switch self {
        case .home: "Overview"
        case .visuals: "Local preview controls"
        case .settings: "Application preferences"
        }
    }
}
