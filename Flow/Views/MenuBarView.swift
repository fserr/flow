import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: 11, weight: .regular, design: .default))
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(timerManager.currentPhase.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.white.opacity(0.5), lineWidth: timerManager.currentPhase == .work ? 0.5 : 0)
            )
    }
}
