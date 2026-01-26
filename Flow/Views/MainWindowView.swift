import SwiftUI

struct MainWindowView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var settings: Settings
    @State private var showingSettings = false
    @State private var isHovering = false
    @State private var isHoveringCloseButton = false

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                titleLabel
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
                .fill(Color(red: 0.96, green: 0.96, blue: 0.96))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onHover { hovering in
            isHovering = hovering
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(settings: settings, timerManager: timerManager)
        }
    }

    private var titleLabel: some View {
        Text("Flow2")
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.primary)
    }

    private var timerDisplay: some View {
        Text(timerManager.formattedTime)
            .font(.system(size: 72, weight: .medium, design: .default))
            .foregroundColor(.primary)
            .monospacedDigit()
    }

    private var sessionDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<settings.sessionsBeforeLongBreak, id: \.self) { index in
                sessionDot(filled: index < timerManager.completedSessions, isFirst: index == 0)
            }
        }
    }

    private func sessionDot(filled: Bool, isFirst: Bool) -> some View {
        let isCurrentlyActive = timerManager.isRunning && timerManager.completedSessions == (isFirst ? 0 : timerManager.completedSessions)
        return Capsule()
            .fill(filled ? Color.gray.opacity(0.6) : Color.gray.opacity(0.3))
            .frame(width: isCurrentlyActive && isFirst && timerManager.currentPhase == .work ? 20 : 8, height: 8)
            .animation(.easeInOut(duration: 0.2), value: timerManager.isRunning)
    }

    private var controlButtons: some View {
        HStack(spacing: 16) {
            // Reset button - only visible on hover
            Button(action: { timerManager.reset() }) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .opacity(isHovering ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: isHovering)

            Button(action: { timerManager.toggle() }) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.82, green: 0.88, blue: 0.85))
                        .frame(width: 48, height: 48)
                    Image(systemName: timerManager.isRunning ? "pause" : "play")
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(Color(red: 0.35, green: 0.45, blue: 0.4))
                        .offset(x: timerManager.isRunning ? 0 : 1.5)
                }
            }
            .buttonStyle(.plain)

            // Skip button - only visible on hover
            Button(action: { timerManager.skip() }) {
                Image(systemName: "forward.end.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
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
                    .fill(Color.gray.opacity(isHoveringCloseButton ? 0.3 : 0.15))
                    .frame(width: 18, height: 18)
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(Color.gray.opacity(isHoveringCloseButton ? 0.9 : 0.6))
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHoveringCloseButton = hovering
        }
    }

    private var settingsButton: some View {
        Button(action: { showingSettings = true }) {
            Image(systemName: "ellipsis")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .keyboardShortcut(",", modifiers: .command)
    }
}
