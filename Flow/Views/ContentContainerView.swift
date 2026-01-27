import SwiftUI

class ViewState: ObservableObject {
    static let shared = ViewState()
    @Published var showSettings = false

    private init() {}
}

struct ContentContainerView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var settings: Settings
    @ObservedObject var viewState: ViewState

    var body: some View {
        ZStack {
            if viewState.showSettings {
                SettingsTabView(settings: settings, showSettings: $viewState.showSettings)
            } else {
                MainWindowView(timerManager: timerManager, settings: settings)
            }
        }
        .frame(width: 320, height: 280)
    }
}
