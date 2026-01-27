import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.colorScheme) var colorScheme

    private var borderColor: Color {
        colorScheme == .dark ? Color.white : Color.black
    }

    var body: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: 11, weight: .medium, design: .default))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(timerManager.currentPhase.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(borderColor, lineWidth: timerManager.currentPhase == .work ? 0.5 : 0)
            )
    }
}
