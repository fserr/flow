import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: Settings
    @ObservedObject var timerManager: TimerManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            settingsForm
        }
        .frame(width: 300, height: 360)
    }

    private var header: some View {
        HStack {
            Text("Settings")
                .font(.headline)
            Spacer()
            Button("Done") {
                timerManager.updateFromSettings()
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding()
    }

    private var settingsForm: some View {
        Form {
            Section("Durations") {
                durationField("Work", value: $settings.workDuration, unit: "min")
                durationField("Short Break", value: $settings.shortBreakDuration, unit: "min")
                durationField("Long Break", value: $settings.longBreakDuration, unit: "min")
            }

            Section("Sessions") {
                durationField("Sessions before long break", value: $settings.sessionsBeforeLongBreak, unit: "")
            }

            Section("Behavior") {
                Toggle("Auto-start breaks", isOn: $settings.autoStartBreak)
                Toggle("Play sound on completion", isOn: $settings.playSoundOnComplete)
            }
        }
        .formStyle(.grouped)
    }

    private func durationField(_ label: String, value: Binding<Int>, unit: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            TextField("", value: value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 50)
                .multilineTextAlignment(.center)
            if !unit.isEmpty {
                Text(unit)
                    .foregroundColor(.secondary)
            }
        }
    }
}
