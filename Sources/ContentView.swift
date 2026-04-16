import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SleepTimerViewModel
    @State private var showingAbout = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isRunning {
                    HStack {
                        Spacer()

                        Label(viewModel.remainingTimeText, systemImage: "timer")
                            .font(.system(.subheadline, design: .rounded, weight: .semibold))
                            .monospacedDigit()
                            .labelStyle(.titleAndIcon)
                            .foregroundStyle(.secondary)
                    }
                } else if !viewModel.statusText.isEmpty {
                    Text(viewModel.statusText)
                        .font(.callout)
                        .foregroundStyle(viewModel.statusColor)
                        .animation(.default, value: viewModel.statusText)
                }

                HStack(spacing: 8) {
                    modeButton(
                        title: "Timer",
                        icon: "timer",
                        mode: .countdown
                    )

                    modeButton(
                        title: "Clock",
                        icon: "clock",
                        mode: .timeOfDay
                    )
                }
                .padding(6)
                .frame(maxWidth: .infinity)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 14) {
                    if viewModel.scheduleMode == .countdown {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Label("Amount", systemImage: "number")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                TextField("10", value: $viewModel.durationValue, format: .number)
                                    .textFieldStyle(.roundedBorder)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Label("Unit", systemImage: "dial.low")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Picker("Unit", selection: $viewModel.selectedUnit) {
                                    ForEach(TimeUnit.allCases) { unit in
                                        Text(unit.shortLabel).tag(unit)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Sleep At", systemImage: "calendar.badge.clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            DatePicker(
                                "Hour Of Day",
                                selection: $viewModel.scheduledTime,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .datePickerStyle(.field)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            Label("Next \(viewModel.scheduledTimeText)", systemImage: "arrow.clockwise")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 0.5)
                )

                HStack(spacing: 10) {
                    Button {
                        viewModel.startTimer()
                    }
                    label: {
                        Label(viewModel.isRunning ? "Restart" : "Start", systemImage: viewModel.isRunning ? "arrow.clockwise" : "play.fill")
                    }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button {
                        viewModel.cancelTimer()
                    }
                    label: {
                        Label("Cancel", systemImage: "xmark")
                    }
                    .buttonStyle(.bordered)
                    .disabled(!viewModel.isRunning)
                    .controlSize(.small)

                    Spacer()

                    Button {
                        showingAbout = true
                    }
                    label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(.link)

                    Button {
                        viewModel.quitAppAfterCancellingSleep()
                    }
                    label: {
                        Image(systemName: "power")
                    }
                    .buttonStyle(.link)
                }
            }
            .blur(radius: showingAbout ? 3 : 0)
            .disabled(showingAbout)

            if showingAbout {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingAbout = false
                    }

                VStack(spacing: 14) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 28))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 4) {
                        Text("Gjorge Karakabakov")
                            .font(.title3.weight(.semibold))

                        Text("gorgekara@gmail.com")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .textSelection(.enabled)
                    }

                    Button("Close") {
                        showingAbout = false
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
                }
                .frame(width: 220)
                .padding(18)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(.white.opacity(0.35), lineWidth: 0.5)
                )
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .frame(width: 268)
    }

    @ViewBuilder
    private func modeButton(title: String, icon: String, mode: ScheduleMode) -> some View {
        Button {
            viewModel.scheduleMode = mode
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.caption.weight(.medium))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 46)
            .foregroundStyle(viewModel.scheduleMode == mode ? .primary : .secondary)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(viewModel.scheduleMode == mode ? Color.primary.opacity(0.10) : Color.clear)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView(viewModel: SleepTimerViewModel())
}
