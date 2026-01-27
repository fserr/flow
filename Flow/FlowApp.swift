import SwiftUI

@main
struct FlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        SwiftUI.Settings {
            EmptyView()
        }
    }
}

class BorderlessWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var mainWindow: NSWindow?
    private var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        createAndShowMainWindow()
        setupKeyMonitor()
    }

    private func setupKeyMonitor() {
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard self?.mainWindow?.isKeyWindow == true else { return event }

            // Spacebar - toggle timer
            if event.keyCode == 49 {
                TimerManager.shared.toggle()
                return nil
            }

            // CMD+R - reset timer
            if event.keyCode == 15 && event.modifierFlags.contains(.command) {
                TimerManager.shared.reset()
                return nil
            }

            // CMD+Right Arrow - skip to next phase
            if event.keyCode == 124 && event.modifierFlags.contains(.command) {
                TimerManager.shared.skip()
                return nil
            }

            // Escape - close window
            if event.keyCode == 53 {
                self?.mainWindow?.orderOut(nil)
                return nil
            }

            return event
        }
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            let hostingView = NSHostingView(rootView: MenuBarView(timerManager: TimerManager.shared))
            hostingView.frame = NSRect(x: 0, y: 0, width: 56, height: 22)

            button.addSubview(hostingView)
            button.frame = hostingView.frame

            button.action = #selector(handleClick)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func createAndShowMainWindow() {
        let contentView = MainWindowView(timerManager: TimerManager.shared, settings: Settings.shared)

        let window = BorderlessWindow(
            contentRect: NSRect(x: 0, y: 0, width: 320, height: 280),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .floating
        window.center()
        window.contentView = NSHostingView(rootView: contentView)
        window.isReleasedWhenClosed = false
        window.makeKeyAndOrderFront(nil)

        self.mainWindow = window
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func handleClick() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            TimerManager.shared.toggle()
        } else {
            toggleMainWindow()
        }
    }

    private func toggleMainWindow() {
        guard let window = mainWindow else {
            createAndShowMainWindow()
            return
        }

        if window.isVisible {
            window.orderOut(nil)
        } else {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}
