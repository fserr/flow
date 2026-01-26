import SwiftUI

enum TimerPhase: String {
    case work
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .work:
            return "Work"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        }
    }

    var isBreak: Bool {
        self != .work
    }

    var backgroundColor: Color {
        switch self {
        case .work:
            return .clear
        case .shortBreak, .longBreak:
            return Color(red: 0.28, green: 0.55, blue: 0.47) // #488d77
        }
    }
}
