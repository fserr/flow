import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.colorScheme) var colorScheme

    private var borderColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    private var textColor: Color {
        if timerManager.currentPhase.isBreak {
            return .white
        } else {
            return colorScheme == .dark ? .white : .black
        }
    }

    var body: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: 11, weight: .regular, design: .default).monospacedDigit())
            .foregroundColor(textColor)
            .padding(.horizontal, 6)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(timerManager.currentPhase.backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(borderColor, lineWidth: timerManager.currentPhase == .work ? 1 : 0)
                    )
            )
    }
}
