import SwiftUI
import Foundation

@main
struct CalendarAgentApp: App {
    @StateObject private var viewModel = CalendarAgentViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .frame(minWidth: 1000, minHeight: 700)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Calendar Agent") {
                    viewModel.showAbout = true
                }
            }
        }
    }
}

// MARK: - View Models
class CalendarAgentViewModel: NSObject, ObservableObject {
    @Published var selectedTab: String = "logs"
    @Published var isRunning = false
    @Published var logs: [String] = []
    @Published var tasks: [TaskItem] = []
    @Published var workflows: [WorkflowItem] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var showAbout = false

    private var process: Process?
    private var pythonOutputPipe: Pipe?

    override init() {
        super.init()
        startPythonBackend()
    }

    func startPythonBackend() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")

        let projectPath = "/Users/Shared/Projects/claude/calendar-agent"
        process.arguments = ["\(projectPath)/run_calendar_agent.py"]
        process.currentDirectoryURL = URL(fileURLWithPath: projectPath)

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            self.process = process
            self.pythonOutputPipe = pipe
            self.isRunning = true

            readPythonOutput()
        } catch {
            addLog("Error starting Python backend: \(error.localizedDescription)")
            self.isRunning = false
        }
    }

    private func readPythonOutput() {
        DispatchQueue.global().async { [weak self] in
            guard let pipe = self?.pythonOutputPipe else { return }
            let fileHandle = pipe.fileHandleForReading

            while self?.process?.isRunning ?? false {
                let data = fileHandle.availableData
                if data.count > 0 {
                    if let output = String(data: data, encoding: .utf8) {
                        DispatchQueue.main.async {
                            self?.addLog(output.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                }
                usleep(100000)
            }
        }
    }

    func addLog(_ message: String) {
        DispatchQueue.main.async {
            let timestamp = ISO8601DateFormatter().string(from: Date())
            self.logs.append("[\(timestamp)] \(message)")
            if self.logs.count > 1000 {
                self.logs.removeFirst(self.logs.count - 500)
            }
        }
    }

    deinit {
        process?.terminate()
    }
}

// MARK: - Settings
struct AppSettings: Codable {
    var applicationName: String = "Calendar Agent"
    var autoStartEnabled: Bool = true
    var logLevel: String = "INFO"
    var llmModel: String = "claude-3-5-sonnet"
    var llmTemperature: Double = 0.7
    var agentCheckInterval: Int = 60
    var taskTimeoutSeconds: Int = 300
}

// MARK: - Data Models
struct TaskItem: Identifiable {
    let id = UUID()
    var name: String
    var status: String
    var createdAt: Date
    var completedAt: Date?
}

struct WorkflowItem: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var enabled: Bool
}
