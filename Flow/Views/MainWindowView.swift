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
            .font(.system(size: 72, weight: .medium, design: .default))
            .foregroundColor(textColor)
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
        let dotColor = isBreak
            ? (filled ? Color.white.opacity(0.9) : Color.white.opacity(0.4))
            : (filled ? Color.gray.opacity(0.6) : Color.gray.opacity(0.3))
        return Capsule()
            .fill(dotColor)
            .frame(width: isCurrentlyActive && isFirst && timerManager.currentPhase == .work ? 20 : 8, height: 8)
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
        let menu = NSMenu()

        // Work Duration submenu
        let workMenu = NSMenu()
        let workPresets = [15, 20, 25, 30, 45, 60, 90]
        let workIsCustom = !workPresets.contains(settings.workDuration)
        for mins in workPresets {
            let item = NSMenuItem(title: "\(mins) min", action: #selector(SettingsMenuHandler.shared.setWorkDuration(_:)), keyEquivalent: "")
            item.target = SettingsMenuHandler.shared
            item.tag = mins
            if settings.workDuration == mins {
                item.state = .on
            }
            workMenu.addItem(item)
        }
        workMenu.addItem(NSMenuItem.separator())
        let customWorkItem = NSMenuItem(title: workIsCustom ? "Custom (\(settings.workDuration) min)..." : "Custom...", action: #selector(SettingsMenuHandler.shared.customWorkDuration), keyEquivalent: "")
        customWorkItem.target = SettingsMenuHandler.shared
        if workIsCustom { customWorkItem.state = .on }
        workMenu.addItem(customWorkItem)
        let workItem = NSMenuItem(title: "Work Duration", action: nil, keyEquivalent: "")
        workItem.submenu = workMenu
        menu.addItem(workItem)

        // Short Break Duration submenu
        let shortBreakMenu = NSMenu()
        let shortPresets = [3, 5, 10, 15]
        let shortIsCustom = !shortPresets.contains(settings.shortBreakDuration)
        for mins in shortPresets {
            let item = NSMenuItem(title: "\(mins) min", action: #selector(SettingsMenuHandler.shared.setShortBreakDuration(_:)), keyEquivalent: "")
            item.target = SettingsMenuHandler.shared
            item.tag = mins
            if settings.shortBreakDuration == mins {
                item.state = .on
            }
            shortBreakMenu.addItem(item)
        }
        shortBreakMenu.addItem(NSMenuItem.separator())
        let customShortItem = NSMenuItem(title: shortIsCustom ? "Custom (\(settings.shortBreakDuration) min)..." : "Custom...", action: #selector(SettingsMenuHandler.shared.customShortBreakDuration), keyEquivalent: "")
        customShortItem.target = SettingsMenuHandler.shared
        if shortIsCustom { customShortItem.state = .on }
        shortBreakMenu.addItem(customShortItem)
        let shortBreakItem = NSMenuItem(title: "Short Break", action: nil, keyEquivalent: "")
        shortBreakItem.submenu = shortBreakMenu
        menu.addItem(shortBreakItem)

        // Long Break Duration submenu
        let longBreakMenu = NSMenu()
        let longPresets = [10, 15, 20, 30]
        let longIsCustom = !longPresets.contains(settings.longBreakDuration)
        for mins in longPresets {
            let item = NSMenuItem(title: "\(mins) min", action: #selector(SettingsMenuHandler.shared.setLongBreakDuration(_:)), keyEquivalent: "")
            item.target = SettingsMenuHandler.shared
            item.tag = mins
            if settings.longBreakDuration == mins {
                item.state = .on
            }
            longBreakMenu.addItem(item)
        }
        longBreakMenu.addItem(NSMenuItem.separator())
        let customLongItem = NSMenuItem(title: longIsCustom ? "Custom (\(settings.longBreakDuration) min)..." : "Custom...", action: #selector(SettingsMenuHandler.shared.customLongBreakDuration), keyEquivalent: "")
        customLongItem.target = SettingsMenuHandler.shared
        if longIsCustom { customLongItem.state = .on }
        longBreakMenu.addItem(customLongItem)
        let longBreakItem = NSMenuItem(title: "Long Break", action: nil, keyEquivalent: "")
        longBreakItem.submenu = longBreakMenu
        menu.addItem(longBreakItem)

        // Sessions submenu
        let sessionsMenu = NSMenu()
        for count in [2, 3, 4, 5, 6] {
            let item = NSMenuItem(title: "\(count) sessions", action: #selector(SettingsMenuHandler.shared.setSessions(_:)), keyEquivalent: "")
            item.target = SettingsMenuHandler.shared
            item.tag = count
            if settings.sessionsBeforeLongBreak == count {
                item.state = .on
            }
            sessionsMenu.addItem(item)
        }
        let sessionsItem = NSMenuItem(title: "Sessions", action: nil, keyEquivalent: "")
        sessionsItem.submenu = sessionsMenu
        menu.addItem(sessionsItem)

        menu.addItem(NSMenuItem.separator())

        // Auto-start toggle
        let autoStartItem = NSMenuItem(title: "Auto-Start Breaks", action: #selector(SettingsMenuHandler.shared.toggleAutoStart), keyEquivalent: "")
        autoStartItem.target = SettingsMenuHandler.shared
        autoStartItem.state = settings.autoStartBreak ? .on : .off
        menu.addItem(autoStartItem)

        // Sound toggle
        let soundItem = NSMenuItem(title: "Sound on Completion", action: #selector(SettingsMenuHandler.shared.toggleSound), keyEquivalent: "")
        soundItem.target = SettingsMenuHandler.shared
        soundItem.state = settings.playSoundOnComplete ? .on : .off
        menu.addItem(soundItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(title: "Quit Flow2", action: #selector(SettingsMenuHandler.shared.quit), keyEquivalent: "q")
        quitItem.target = SettingsMenuHandler.shared
        menu.addItem(quitItem)

        // Show menu
        if let event = NSApp.currentEvent {
            NSMenu.popUpContextMenu(menu, with: event, for: NSApp.keyWindow?.contentView ?? NSView())
        }
    }
}

class SettingsMenuHandler: NSObject {
    static let shared = SettingsMenuHandler()

    @objc func setWorkDuration(_ sender: NSMenuItem) {
        Settings.shared.workDuration = sender.tag
        TimerManager.shared.updateFromSettings()
    }

    @objc func setShortBreakDuration(_ sender: NSMenuItem) {
        Settings.shared.shortBreakDuration = sender.tag
        TimerManager.shared.updateFromSettings()
    }

    @objc func setLongBreakDuration(_ sender: NSMenuItem) {
        Settings.shared.longBreakDuration = sender.tag
        TimerManager.shared.updateFromSettings()
    }

    @objc func customWorkDuration() {
        if let value = showCustomDurationDialog(title: "Work Duration", current: Settings.shared.workDuration) {
            Settings.shared.workDuration = value
            TimerManager.shared.updateFromSettings()
        }
    }

    @objc func customShortBreakDuration() {
        if let value = showCustomDurationDialog(title: "Short Break Duration", current: Settings.shared.shortBreakDuration) {
            Settings.shared.shortBreakDuration = value
            TimerManager.shared.updateFromSettings()
        }
    }

    @objc func customLongBreakDuration() {
        if let value = showCustomDurationDialog(title: "Long Break Duration", current: Settings.shared.longBreakDuration) {
            Settings.shared.longBreakDuration = value
            TimerManager.shared.updateFromSettings()
        }
    }

    private func showCustomDurationDialog(title: String, current: Int) -> Int? {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = "Enter duration in minutes:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 100, height: 24))
        input.stringValue = "\(current)"
        alert.accessoryView = input

        alert.window.initialFirstResponder = input

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let value = Int(input.stringValue), value > 0 {
                return value
            }
        }
        return nil
    }

    @objc func setSessions(_ sender: NSMenuItem) {
        Settings.shared.sessionsBeforeLongBreak = sender.tag
    }

    @objc func toggleAutoStart() {
        Settings.shared.autoStartBreak.toggle()
    }

    @objc func toggleSound() {
        Settings.shared.playSoundOnComplete.toggle()
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
