import AppKit

class SettingsMenuBuilder {
    static func buildMenu() -> NSMenu {
        let menu = NSMenu()
        let settings = Settings.shared

        // Work Duration submenu
        let workMenu = NSMenu()
        let workPresets = [25, 50, 80, 90]
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
        let shortPresets = [5, 10, 15, 20]
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
        let longPresets = [10, 15, 20, 30, 60]
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
        let sessionsPresets = [2, 3, 4, 5, 6]
        let sessionsIsCustom = !sessionsPresets.contains(settings.sessionsBeforeLongBreak)
        for count in sessionsPresets {
            let item = NSMenuItem(title: "\(count) sessions", action: #selector(SettingsMenuHandler.shared.setSessions(_:)), keyEquivalent: "")
            item.target = SettingsMenuHandler.shared
            item.tag = count
            if settings.sessionsBeforeLongBreak == count {
                item.state = .on
            }
            sessionsMenu.addItem(item)
        }
        sessionsMenu.addItem(NSMenuItem.separator())
        let customSessionsItem = NSMenuItem(title: sessionsIsCustom ? "Custom (\(settings.sessionsBeforeLongBreak))..." : "Custom...", action: #selector(SettingsMenuHandler.shared.customSessions), keyEquivalent: "")
        customSessionsItem.target = SettingsMenuHandler.shared
        if sessionsIsCustom { customSessionsItem.state = .on }
        sessionsMenu.addItem(customSessionsItem)
        let sessionsItem = NSMenuItem(title: "Sessions", action: nil, keyEquivalent: "")
        sessionsItem.submenu = sessionsMenu
        menu.addItem(sessionsItem)

        menu.addItem(NSMenuItem.separator())

        // Saved Setups submenu
        let setupsMenu = NSMenu()
        let currentSetupName = settings.currentSetup.displayName
        for setup in settings.savedSetups {
            let item = NSMenuItem(title: setup.displayName, action: #selector(SettingsMenuHandler.shared.applySetup(_:)), keyEquivalent: "")
            item.target = SettingsMenuHandler.shared
            item.representedObject = setup
            if setup.displayName == currentSetupName {
                item.state = .on
            }
            setupsMenu.addItem(item)
        }
        if !settings.savedSetups.isEmpty {
            setupsMenu.addItem(NSMenuItem.separator())
        }
        let saveCurrentItem = NSMenuItem(title: "Save Current (\(currentSetupName))", action: #selector(SettingsMenuHandler.shared.saveCurrentSetup), keyEquivalent: "")
        saveCurrentItem.target = SettingsMenuHandler.shared
        if settings.savedSetups.contains(where: { $0.displayName == currentSetupName }) {
            saveCurrentItem.isEnabled = false
        }
        setupsMenu.addItem(saveCurrentItem)
        if !settings.savedSetups.isEmpty {
            setupsMenu.addItem(NSMenuItem.separator())
            let deleteMenu = NSMenu()
            for setup in settings.savedSetups {
                let deleteItem = NSMenuItem(title: setup.displayName, action: #selector(SettingsMenuHandler.shared.deleteSetup(_:)), keyEquivalent: "")
                deleteItem.target = SettingsMenuHandler.shared
                deleteItem.representedObject = setup
                deleteMenu.addItem(deleteItem)
            }
            let deleteSubmenu = NSMenuItem(title: "Delete...", action: nil, keyEquivalent: "")
            deleteSubmenu.submenu = deleteMenu
            setupsMenu.addItem(deleteSubmenu)
        }
        let setupsItem = NSMenuItem(title: "Saved Setups", action: nil, keyEquivalent: "")
        setupsItem.submenu = setupsMenu
        menu.addItem(setupsItem)

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

        return menu
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

    private func showCustomDurationDialog(title: String, current: Int, unit: String = "minutes") -> Int? {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = "Enter value in \(unit):"
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

    @objc func customSessions() {
        if let value = showCustomDurationDialog(title: "Sessions", current: Settings.shared.sessionsBeforeLongBreak, unit: "sessions") {
            Settings.shared.sessionsBeforeLongBreak = value
        }
    }

    @objc func toggleAutoStart() {
        Settings.shared.autoStartBreak.toggle()
    }

    @objc func toggleSound() {
        Settings.shared.playSoundOnComplete.toggle()
    }

    @objc func applySetup(_ sender: NSMenuItem) {
        if let setup = sender.representedObject as? TimerSetup {
            Settings.shared.applySetup(setup)
        }
    }

    @objc func saveCurrentSetup() {
        Settings.shared.saveCurrentSetup()
    }

    @objc func deleteSetup(_ sender: NSMenuItem) {
        if let setup = sender.representedObject as? TimerSetup {
            Settings.shared.deleteSetup(setup)
        }
    }

    @objc func quit() {
        NSApp.terminate(nil)
    }
}
