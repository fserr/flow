import SwiftUI

struct MainWindowView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var settings: Settings
    @State private var isHovering = false
    @State private var isHoveringCloseButton = false

    private var isBreak: Bool {
        timerManager.currentPhase.isBreak
    }

    private var backgroundColor: Color {
        isBreak ? Color(red: 0.28, green: 0.55, blue: 0.47) : Color(red: 0.96, green: 0.96, blue: 0.96)
    }

    private var textColor: Color {
        isBreak ? .white : .primary
    }

    private var secondaryTextColor: Color {
        isBreak ? .white.opacity(0.7) : .secondary
    }

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                // titleLabel
                timerDisplay
                sessionDots
                controlButtons
            }
            .padding(32)
            .frame(width: 320, height: 280)

            // Top bar with close and settings buttons (only on hover)
            VStack {
                HStack {
                    closeButton
                    Spacer()
                    settingsButton
                }
                .padding(16)
                Spacer()
            }
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: isHovering)
        }
        .frame(width: 320, height: 280)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(backgroundColor)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var titleLabel: some View {
        Text("Flow2")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.primary)
    }

    private var timerDisplay: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: 78, weight: .regular, design: .default))
            .foregroundColor(textColor)
            .monospacedDigit()
    }

    @ViewBuilder
    private var sessionDots: some View {
        if timerManager.currentPhase == .longBreak {
            Text("TAKE A BREAK!")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        } else {
            HStack(spacing: 6) {
                ForEach(0..<settings.sessionsBeforeLongBreak, id: \.self) { index in
                    sessionDot(filled: index < timerManager.completedSessions, index: index)
                }
            }
        }
    }

    private func sessionDot(filled: Bool, index: Int) -> some View {
        let isCurrentSession = index == timerManager.completedSessions
        let isCurrentlyActive = timerManager.isRunning && isCurrentSession && timerManager.currentPhase == .work
        let dotColor = isBreak
            ? (filled ? Color.white.opacity(0.9) : Color.white.opacity(0.4))
            : (filled ? Color(red: 0.3, green: 0.5, blue: 0.42) : Color.gray.opacity(0.3))
        return Capsule()
            .fill(dotColor)
            .frame(width: isCurrentlyActive ? 20 : 8, height: 8)
            .animation(.easeInOut(duration: 0.2), value: timerManager.isRunning)
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            Button(action: { timerManager.reset() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(secondaryTextColor)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: isHovering)

            Button(action: { timerManager.toggle() }) {
                ZStack {
                    Circle()
                        .fill(isBreak ? Color.white.opacity(0.2) : Color(red: 0.82, green: 0.88, blue: 0.85))
                        .frame(width: 48, height: 48)
                    Image(systemName: timerManager.isRunning ? "pause" : "play")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(isBreak ? .white : Color(red: 0.35, green: 0.45, blue: 0.4))
                        .offset(x: timerManager.isRunning ? 0 : 1.5)
                }
            }
            .buttonStyle(.plain)

            Button(action: { timerManager.skip() }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(secondaryTextColor)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: isHovering)
        }
    }

    private var closeButton: some View {
        Button(action: {
            NSApp.keyWindow?.orderOut(nil)
        }) {
            ZStack {
                Circle()
                    .fill(isBreak
                          ? Color.white.opacity(isHoveringCloseButton ? 0.3 : 0.15)
                          : Color.gray.opacity(isHoveringCloseButton ? 0.3 : 0.15))
                    .frame(width: 18, height: 18)
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(isBreak
                                     ? Color.white.opacity(isHoveringCloseButton ? 0.9 : 0.6)
                                     : Color.gray.opacity(isHoveringCloseButton ? 0.9 : 0.6))
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHoveringCloseButton = hovering
        }
    }

    private var settingsButton: some View {
        Button(action: { showSettingsMenu() }) {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(secondaryTextColor)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func showSettingsMenu() {
        let menu = SettingsMenuBuilder.buildMenu()
        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: NSApp.keyWindow?.contentView ?? NSView())
        }
    }
}
