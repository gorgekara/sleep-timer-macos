import SwiftUI

@main
struct SleepTimerApp: App {
    @StateObject private var viewModel = SleepTimerViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView(viewModel: viewModel)
                .frame(width: 268)
        } label: {
            HStack(spacing: 6) {
                Image(systemName: viewModel.menuBarSymbol)
                Text(viewModel.menuBarTitle)
                    .monospacedDigit()
            }
            .contextMenu {
                Button("About") {
                    viewModel.showAboutAlert()
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}
