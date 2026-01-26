import SwiftUI

struct MenuBarView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: 13, weight: .regular, design: .default))
            .padding(.horizontal, 0)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(timerManager.currentPhase.backgroundColor)
            )
    }
}
