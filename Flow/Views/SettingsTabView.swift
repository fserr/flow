import SwiftUI

struct SettingsTabView: View {
    @ObservedObject var settings: Settings
    @Binding var showSettings: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                Text("Settings")
                    .font(.system(size: 16, weight: .medium))

                HStack {
                    Button(action: { showSettings = false }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)

            // Scrollable content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Launch section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Launch")
                            .font(.system(size: 14, weight: .semibold))
                            .padding(.horizontal, 20)

                        VStack(spacing: 0) {
                            SettingsToggleRow(
                                title: "Launch at Login",
                                isOn: Binding(
                                    get: { settings.launchAtLogin },
                                    set: { settings.launchAtLogin = $0 }
                                )
                            )

                            Divider()
                                .padding(.leading, 20)

                            SettingsToggleRow(
                                title: "Show Window at Launch",
                                isOn: $settings.showWindowAtLaunch
                            )
                        }
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .frame(width: 320, height: 280)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.96, green: 0.96, blue: 0.96))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 14))

            Spacer()

            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
