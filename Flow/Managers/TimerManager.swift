import Foundation
import AppKit
import Combine

final class TimerManager: ObservableObject {
    static let shared = TimerManager()

    @Published var currentPhase: TimerPhase = .work
    @Published var timeRemaining: Int = 25 * 60
    @Published var isRunning: Bool = false
    @Published var completedSessions: Int = 0

    private var timer: AnyCancellable?
    private let settings = Settings.shared

    var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        let total = totalTimeForCurrentPhase
        guard total > 0 else { return 0 }
        return Double(total - timeRemaining) / Double(total)
    }

    private var totalTimeForCurrentPhase: Int {
        switch currentPhase {
        case .work:
            return settings.workDuration * 60
        case .shortBreak:
            return settings.shortBreakDuration * 60
        case .longBreak:
            return settings.longBreakDuration * 60
        }
    }

    private init() {
        resetToCurrentPhase()
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    func pause() {
        isRunning = false
        timer?.cancel()
        timer = nil
    }

    func toggle() {
        if isRunning {
            pause()
        } else {
            start()
        }
    }

    func reset() {
        pause()
        resetToCurrentPhase()
    }

    func skip() {
        pause()
        transitionToNextPhase()
    }

    private func tick() {
        guard timeRemaining > 0 else { return }
        timeRemaining -= 1

        if timeRemaining == 0 {
            onPhaseComplete()
        }
    }

    private func onPhaseComplete() {
        pause()

        if settings.playSoundOnComplete {
            playCompletionSound()
        }

        transitionToNextPhase()

        if settings.autoStartBreak || !currentPhase.isBreak {
            // Auto-start if setting enabled, or if transitioning to work (auto-start work after break)
        }
    }

    private func transitionToNextPhase() {
        switch currentPhase {
        case .work:
            completedSessions += 1
            if completedSessions >= settings.sessionsBeforeLongBreak {
                currentPhase = .longBreak
                completedSessions = 0
            } else {
                currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentPhase = .work
        }
        resetToCurrentPhase()
    }

    private func resetToCurrentPhase() {
        timeRemaining = totalTimeForCurrentPhase
    }

    func updateFromSettings() {
        if !isRunning {
            resetToCurrentPhase()
        }
    }

    private func playCompletionSound() {
        NSSound.beep()
    }
}
