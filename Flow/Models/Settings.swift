import SwiftUI
import ServiceManagement

struct TimerSetup: Codable, Identifiable, Equatable {
    var id = UUID()
    var workDuration: Int
    var shortBreakDuration: Int
    var longBreakDuration: Int
    var sessionsBeforeLongBreak: Int

    var displayName: String {
        "\(workDuration)m/\(shortBreakDuration)m/\(longBreakDuration)m/\(sessionsBeforeLongBreak)"
    }
}

final class Settings: ObservableObject {
    static let shared = Settings()

    @AppStorage("workDuration") var workDuration: Int = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") var longBreakDuration: Int = 15
    @AppStorage("sessionsBeforeLongBreak") var sessionsBeforeLongBreak: Int = 4
    @AppStorage("autoStartBreak") var autoStartBreak: Bool = false
    @AppStorage("autoStartWork") var autoStartWork: Bool = false
    @AppStorage("playSoundOnComplete") var playSoundOnComplete: Bool = true
    @AppStorage("showWindowAtLaunch") var showWindowAtLaunch: Bool = true

    @Published var savedSetups: [TimerSetup] = []

    private let savedSetupsKey = "savedTimerSetups"

    var launchAtLogin: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
        set {
            objectWillChange.send()
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to \(newValue ? "enable" : "disable") launch at login: \(error)")
            }
        }
    }

    private init() {
        loadSavedSetups()
    }

    var currentSetup: TimerSetup {
        TimerSetup(
            workDuration: workDuration,
            shortBreakDuration: shortBreakDuration,
            longBreakDuration: longBreakDuration,
            sessionsBeforeLongBreak: sessionsBeforeLongBreak
        )
    }

    func saveCurrentSetup() {
        let setup = currentSetup
        if !savedSetups.contains(where: { $0.displayName == setup.displayName }) {
            savedSetups.append(setup)
            persistSavedSetups()
        }
    }

    func applySetup(_ setup: TimerSetup) {
        workDuration = setup.workDuration
        shortBreakDuration = setup.shortBreakDuration
        longBreakDuration = setup.longBreakDuration
        sessionsBeforeLongBreak = setup.sessionsBeforeLongBreak
        TimerManager.shared.updateFromSettings()
    }

    func deleteSetup(_ setup: TimerSetup) {
        savedSetups.removeAll { $0.id == setup.id }
        persistSavedSetups()
    }

    private func loadSavedSetups() {
        if let data = UserDefaults.standard.data(forKey: savedSetupsKey),
           let setups = try? JSONDecoder().decode([TimerSetup].self, from: data) {
            savedSetups = setups
        }
    }

    private func persistSavedSetups() {
        if let data = try? JSONEncoder().encode(savedSetups) {
            UserDefaults.standard.set(data, forKey: savedSetupsKey)
        }
    }
}
