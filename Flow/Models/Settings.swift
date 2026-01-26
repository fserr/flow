import SwiftUI

final class Settings: ObservableObject {
    static let shared = Settings()

    @AppStorage("workDuration") var workDuration: Int = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration") var longBreakDuration: Int = 15
    @AppStorage("sessionsBeforeLongBreak") var sessionsBeforeLongBreak: Int = 4
    @AppStorage("autoStartBreak") var autoStartBreak: Bool = false
    @AppStorage("playSoundOnComplete") var playSoundOnComplete: Bool = true

    private init() {}
}
