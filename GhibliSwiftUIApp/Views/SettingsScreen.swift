//
//  SettingsScreen.swift
//  GhibliSwiftUIApp
//
//  Created by Julius Alibrown on 22/10/2026.
//

import SwiftUI

struct SettingsScreen: View {

    @Environment(\.theme) private var theme

    @AppStorage(UserDefaultsKeys.appearanceTheme)
    private var appearanceTheme: AppearanceTheme = .system

    @AppStorage(UserDefaultsKeys.username)
    private var username: String = ""

    @AppStorage(UserDefaultsKeys.itemsPerPage)
    private var itemsPerPage: Int = 20

    @AppStorage(UserDefaultsKeys.notificationsEnabled)
    private var notificationsEnabled: Bool = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ThemePreviewCard()
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)

                    ThemeSelector(selection: $appearanceTheme)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 12, leading: 0, bottom: 4, trailing: 0))
                } header: {
                    Text("Appearance")
                } footer: {
                    Text(appearanceTheme.footer)
                        .contentTransition(.opacity)
                        .animation(.smooth, value: appearanceTheme)
                }

                Section("Account") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                Section("Preferences") {
                    Stepper(value: $itemsPerPage, in: 10...100, step: 5) {
                        HStack {
                            Text("Items per page")
                            Spacer()
                            // The number rolls up or down like an odometer instead of snapping.
                            Text("\(itemsPerPage)")
                                .monospacedDigit()
                                .fontWeight(.semibold)
                                .foregroundStyle(theme.accent)
                                .contentTransition(.numericText(value: Double(itemsPerPage)))
                                .animation(.snappy, value: itemsPerPage)
                        }
                    }
                    Toggle("Enable notifications", isOn: $notificationsEnabled)
                }

                Section {
                    Button(role: .destructive) {
                        withAnimation(.smooth) { resetDefaults() }
                    } label: {
                        Text("Reset to Defaults")
                    }
                }
            }
            // Hide the Form's default grey background so the animated one shows through.
            .scrollContentBackground(.hidden)
            .background { AnimatedBackground() }
            .navigationTitle("Settings")
        }
    }

    private func resetDefaults() {
        appearanceTheme = .system
        username = ""
        itemsPerPage = 20
        notificationsEnabled = true
    }
}

// MARK: - Theme selector

/// A segmented control with a gradient pill that slides between options.
private struct ThemeSelector: View {

    @Environment(\.theme) private var theme
    @Binding var selection: AppearanceTheme

    // Flutter: the shared space for a `Hero` tag, but within one screen.
    @Namespace private var pillNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppearanceTheme.allCases) { option in
                let isSelected = option == selection
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        selection = option
                    }
                } label: {
                    Label(option.title, systemImage: option.icon)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(isSelected ? .white : theme.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                // Only the selected option draws the pill, but because every
                                // candidate shares one geometry ID, SwiftUI slides the pill from
                                // the old position to the new one instead of fading it.
                                Capsule()
                                    .fill(theme.accentGradient)
                                    .matchedGeometryEffect(id: "pill", in: pillNamespace)
                            }
                        }
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                .symbolEffect(.bounce, value: isSelected)
                .sensoryFeedback(.selection, trigger: isSelected)
            }
        }
        .padding(4)
        .glassEffect(.regular, in: .capsule)
    }
}

/// A banner that shows the live background for the current theme.
private struct ThemePreviewCard: View {

    @Environment(\.theme) private var theme

    var body: some View {
        AnimatedBackground()
            .frame(height: 140)
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.isDark ? "Cinematic night" : "Pastel skies")
                        .font(.system(.title2, design: .rounded, weight: .heavy))
                        .foregroundStyle(theme.textPrimary)
                        .contentTransition(.interpolate)
                    Text(theme.isDark ? "Stars, glow and lantern gold" : "Drifting clouds and meadow green")
                        .font(.caption)
                        .foregroundStyle(theme.textSecondary)
                }
                .padding()
            }
    }
}

//MARK: - data model for appearance

enum AppearanceTheme: String, Identifiable, CaseIterable {
    case system
    case light
    case dark
    var id: Self { return self }

    var title: String { rawValue.capitalized }

    var icon: String {
        switch self {
            case .system: "circle.lefthalf.filled"
            case .light: "sun.max.fill"
            case .dark: "moon.stars.fill"
        }
    }

    var footer: String {
        switch self {
            case .system: "Follows your device: pastel by day, cinematic by night."
            case .light: "Always uses the pastel light theme."
            case .dark: "Always uses the cinematic dark theme."
        }
    }
}

//MARK: - helper to save user defaults keys and keep them unique

enum UserDefaultsKeys {
    static let appearanceTheme = "appearanceTheme"
    static let username = "username"
    static let itemsPerPage = "itemsPerPage"
    static let notificationsEnabled = "notificationsEnabled"
}

//MARK: - helper to set saved theme

extension View {
    func setAppearanceTheme() -> some View {
        modifier(AppearanceThemeViewModifier())
    }
}


struct AppearanceThemeViewModifier: ViewModifier {

    @AppStorage(UserDefaultsKeys.appearanceTheme) private var appearanceTheme: AppearanceTheme = .system

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(scheme())
    }

    func scheme() -> ColorScheme? {
        switch appearanceTheme {
            case .dark: return .dark
            case .light: return .light
            case .system: return nil
        }
    }
}

//MARK: - Preview

#Preview {
    SettingsScreen()
        .ghibliTheme()
}
