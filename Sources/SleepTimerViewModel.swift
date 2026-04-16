import Foundation
import SwiftUI
import AppKit

enum ScheduleMode: String, CaseIterable, Identifiable {
    case countdown
    case timeOfDay

    var id: String { rawValue }

    var label: String {
        switch self {
        case .countdown:
            return "After Time"
        case .timeOfDay:
            return "At Clock Time"
        }
    }
}

enum TimeUnit: String, CaseIterable, Identifiable {
    case seconds
    case minutes
    case hours

    var id: String { rawValue }

    var label: String {
        switch self {
        case .seconds: return "Seconds"
        case .minutes: return "Minutes"
        case .hours: return "Hours"
        }
    }

    var shortLabel: String {
        switch self {
        case .seconds: return "Sec"
        case .minutes: return "Min"
        case .hours: return "Hour"
        }
    }

    func toSeconds(_ value: Int) -> Int {
        switch self {
        case .seconds:
            return value
        case .minutes:
            return value * 60
        case .hours:
            return value * 3600
        }
    }
}

@MainActor
final class SleepTimerViewModel: ObservableObject {
    @Published var scheduleMode: ScheduleMode = .countdown {
        didSet {
            refreshPreviewIfNeeded()
        }
    }
    @Published var durationValue: Int = 10 {
        didSet {
            refreshPreviewIfNeeded()
        }
    }
    @Published var selectedUnit: TimeUnit = .minutes {
        didSet {
            refreshPreviewIfNeeded()
        }
    }
    @Published var scheduledTime: Date = Calendar.current.date(
        bySettingHour: 23,
        minute: 0,
        second: 0,
        of: Date()
    ) ?? Date() {
        didSet {
            refreshPreviewIfNeeded()
        }
    }
    @Published private(set) var isRunning = false
    @Published private(set) var statusText = ""
    @Published private(set) var remainingTimeText = "00:10:00"
    @Published private(set) var statusColor: Color = Color(red: 0.94, green: 0.97, blue: 0.95)

    private var remainingSeconds = 0
    private var timer: Timer?
    private var targetDate: Date?

    deinit {
        timer?.invalidate()
    }

    func startTimer() {
        let totalSeconds: Int

        switch scheduleMode {
        case .countdown:
            let countdownSeconds = selectedUnit.toSeconds(durationValue)

            guard durationValue > 0 else {
                setStatus("Enter a duration greater than zero.", color: Color(red: 0.98, green: 0.76, blue: 0.62))
                return
            }

            totalSeconds = countdownSeconds
        case .timeOfDay:
            guard let nextDate = nextScheduledDate() else {
                setStatus("Choose a valid time of day.", color: Color(red: 0.98, green: 0.76, blue: 0.62))
                return
            }

            totalSeconds = max(Int(nextDate.timeIntervalSinceNow.rounded(.down)), 0)
        }

        guard totalSeconds > 0 else {
            setStatus("Pick a time that is still ahead.", color: Color(red: 0.98, green: 0.76, blue: 0.62))
            return
        }

        cancelTimer(clearStatus: false)

        remainingSeconds = totalSeconds
        targetDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        remainingTimeText = format(seconds: totalSeconds)
        isRunning = true
        setStatus("", color: Color(red: 0.94, green: 0.97, blue: 0.95))

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func cancelTimer(clearStatus: Bool = true) {
        timer?.invalidate()
        timer = nil
        targetDate = nil
        remainingSeconds = 0
        isRunning = false
        remainingTimeText = previewTimeText

        if clearStatus {
            setStatus("Timer cancelled.", color: Color(red: 0.84, green: 0.89, blue: 0.87))
        }
    }

    private func tick() {
        guard let targetDate else {
            cancelTimer()
            return
        }

        let secondsLeft = max(Int(targetDate.timeIntervalSinceNow.rounded(.down)), 0)
        remainingSeconds = secondsLeft
        remainingTimeText = format(seconds: secondsLeft)

        guard secondsLeft == 0 else { return }

        timer?.invalidate()
        timer = nil
        isRunning = false
        setStatus("Timer finished. Putting your Mac to sleep...", color: Color(red: 0.94, green: 0.97, blue: 0.95))
        sendSystemToSleep()
    }

    private func sendSystemToSleep() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["sleepnow"]

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus != 0 {
                setStatus("macOS rejected the sleep command.", color: Color(red: 0.98, green: 0.76, blue: 0.62))
            }
        } catch {
            setStatus("Unable to request sleep: \(error.localizedDescription)", color: Color(red: 0.98, green: 0.76, blue: 0.62))
        }
    }

    func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func quitAppAfterCancellingSleep() {
        cancelTimer(clearStatus: false)
        quitApp()
    }

    func showAboutAlert() {
        let alert = NSAlert()
        alert.messageText = "About"
        alert.informativeText = "Gjorge Karakabakov\n\ngorgekara@gmail.com"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        NSApp.activate(ignoringOtherApps: true)
        alert.runModal()
    }

    var menuBarTitle: String {
        isRunning ? remainingTimeText : ""
    }

    var menuBarSymbol: String {
        isRunning ? "moon.zzz.fill" : "moon.stars"
    }

    var scheduledTimeText: String {
        scheduledTime.formatted(date: .omitted, time: .shortened)
    }

    var previewTimeText: String {
        switch scheduleMode {
        case .countdown:
            return format(seconds: selectedUnit.toSeconds(max(durationValue, 0)))
        case .timeOfDay:
            guard let nextDate = nextScheduledDate() else { return "00:00:00" }
            return format(seconds: max(Int(nextDate.timeIntervalSinceNow.rounded(.down)), 0))
        }
    }

    private func setStatus(_ text: String, color: Color) {
        statusText = text
        statusColor = color
    }

    private func refreshPreviewIfNeeded() {
        guard !isRunning else { return }
        remainingTimeText = previewTimeText
    }

    private func nextScheduledDate(from now: Date = Date()) -> Date? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: scheduledTime)

        guard let hour = components.hour, let minute = components.minute else {
            return nil
        }

        var scheduledComponents = calendar.dateComponents([.year, .month, .day], from: now)
        scheduledComponents.hour = hour
        scheduledComponents.minute = minute
        scheduledComponents.second = 0

        guard let todayCandidate = calendar.date(from: scheduledComponents) else {
            return nil
        }

        if todayCandidate > now {
            return todayCandidate
        }

        return calendar.date(byAdding: .day, value: 1, to: todayCandidate)
    }

    private func format(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
