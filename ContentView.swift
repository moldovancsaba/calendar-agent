import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: CalendarAgentViewModel

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // Sidebar
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Calendar Agent")
                                    .font(.system(size: 14, weight: .semibold))
                                Text("v1.0.0")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(12)
                        Divider()
                    }
                    .padding(.top, 16)

                    // Navigation Items
                    VStack(spacing: 6) {
                        NavigationButton(
                            icon: "doc.text",
                            label: "Logs",
                            isSelected: viewModel.selectedTab == "logs"
                        ) {
                            viewModel.selectedTab = "logs"
                        }

                        NavigationButton(
                            icon: "checkmark.circle",
                            label: "Tasks",
                            isSelected: viewModel.selectedTab == "tasks"
                        ) {
                            viewModel.selectedTab = "tasks"
                        }

                        NavigationButton(
                            icon: "workflow",
                            label: "Workflows",
                            isSelected: viewModel.selectedTab == "workflows"
                        ) {
                            viewModel.selectedTab = "workflows"
                        }

                        NavigationButton(
                            icon: "gearshape",
                            label: "Settings",
                            isSelected: viewModel.selectedTab == "settings"
                        ) {
                            viewModel.selectedTab = "settings"
                        }

                        NavigationButton(
                            icon: "heart.circle",
                            label: "Status",
                            isSelected: viewModel.selectedTab == "status"
                        ) {
                            viewModel.selectedTab = "status"
                        }

                        Spacer()

                        StatusIndicator(isRunning: viewModel.isRunning)
                            .padding(.bottom, 12)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                }
                .frame(width: 160)
                .background(Color(nsColor: .controlBackgroundColor))
                .overlay(Divider(), alignment: .trailing)

                // Content Area
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(tabTitle(viewModel.selectedTab))
                                .font(.system(size: 24, weight: .bold))
                            Spacer()
                            if viewModel.isRunning {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 10, height: 10)
                                    Text("Running")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Text(tabSubtitle(viewModel.selectedTab))
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(20)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .overlay(Divider(), alignment: .bottom)

                    // Content
                    Group {
                        switch viewModel.selectedTab {
                        case "logs":
                            LogsView(logs: viewModel.logs)
                        case "tasks":
                            TasksView(tasks: viewModel.tasks)
                        case "workflows":
                            WorkflowsView(workflows: viewModel.workflows)
                        case "settings":
                            SettingsView(settings: $viewModel.settings)
                        case "status":
                            StatusView(viewModel: viewModel)
                        default:
                            LogsView(logs: viewModel.logs)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            // About Sheet (disabled for macOS 13.0 compatibility)
            // Uncomment when targeting macOS 14.0+
            // if viewModel.showAbout {
            //     AboutView()
            //         .transition(.opacity)
            // }
        }
        .preferredColorScheme(nil)
    }

    private func tabTitle(_ tab: String) -> String {
        switch tab {
        case "logs": return "Activity Logs"
        case "tasks": return "Task Management"
        case "workflows": return "Workflows"
        case "settings": return "Settings"
        case "status": return "Application Status"
        default: return "Calendar Agent"
        }
    }

    private func tabSubtitle(_ tab: String) -> String {
        switch tab {
        case "logs": return "Real-time application logs and events"
        case "tasks": return "Monitor and manage agent tasks"
        case "workflows": return "Define and execute automated workflows"
        case "settings": return "Configure application behavior and preferences"
        case "status": return "System status and performance metrics"
        default: return "Professional calendar automation agent"
        }
    }
}

// MARK: - Navigation Components
struct NavigationButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 18)
                Text(label)
                    .font(.system(size: 13))
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isSelected ? Color.blue.opacity(0.15) : Color.clear)
            .foregroundColor(isSelected ? .blue : .primary)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatusIndicator: View {
    let isRunning: Bool

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isRunning ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(isRunning ? "Active" : "Starting")
                    .font(.system(size: 12, weight: .semibold))
                Text(isRunning ? "Backend running" : "Initializing")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(10)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
    }
}

// MARK: - Tab Views
struct LogsView: View {
    let logs: [String]

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        if logs.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.system(size: 32))
                                    .foregroundColor(.secondary)
                                Text("No logs yet")
                                    .font(.system(size: 14, weight: .medium))
                                Text("Activity logs will appear here")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding()
                        } else {
                            ForEach(logs, id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                            }
                        }
                    }
                    .padding(16)
                    .onChange(of: logs.count) { _ in
                        if let lastLog = logs.last {
                            withAnimation {
                                proxy.scrollTo(lastLog)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct TasksView: View {
    let tasks: [TaskItem]

    var body: some View {
        VStack {
            if tasks.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No tasks")
                        .font(.system(size: 14, weight: .medium))
                    Text("Tasks will appear here when created")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct TaskRowView: View {
    let task: TaskItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: statusIcon(task.status))
                .foregroundColor(statusColor(task.status))
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(task.name)
                    .font(.system(size: 13, weight: .medium))
                Text(task.createdAt.formatted())
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(task.status)
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(statusBgColor(task.status))
                .cornerRadius(4)
        }
        .padding(12)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(6)
    }

    private func statusIcon(_ status: String) -> String {
        switch status {
        case "completed": return "checkmark.circle.fill"
        case "failed": return "x.circle.fill"
        case "running": return "hourglass.circle.fill"
        default: return "circle"
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "completed": return .green
        case "failed": return .red
        case "running": return .blue
        default: return .gray
        }
    }

    private func statusBgColor(_ status: String) -> Color {
        switch status {
        case "completed": return Color.green.opacity(0.15)
        case "failed": return Color.red.opacity(0.15)
        case "running": return Color.blue.opacity(0.15)
        default: return Color.gray.opacity(0.15)
        }
    }
}

struct WorkflowsView: View {
    let workflows: [WorkflowItem]

    var body: some View {
        VStack {
            if workflows.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "workflow")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    Text("No workflows")
                        .font(.system(size: 14, weight: .medium))
                    Text("Create workflows to automate tasks")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(workflows) { workflow in
                            WorkflowRowView(workflow: workflow)
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct WorkflowRowView: View {
    let workflow: WorkflowItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "workflow")
                .foregroundColor(.blue)
                .font(.system(size: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(workflow.name)
                    .font(.system(size: 13, weight: .medium))
                Text(workflow.description)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Toggle("", isOn: .constant(workflow.enabled))
                .disabled(true)
        }
        .padding(12)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(6)
    }
}

struct SettingsView: View {
    @Binding var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Application Settings
                SettingsSectionView(title: "Application") {
                    SettingsFieldView(label: "Application Name", value: settings.applicationName) {
                        TextField("", text: $settings.applicationName)
                    }
                    Toggle("Auto-start on launch", isOn: $settings.autoStartEnabled)
                    SettingsFieldView(label: "Log Level", value: settings.logLevel) {
                        Picker("", selection: $settings.logLevel) {
                            Text("DEBUG").tag("DEBUG")
                            Text("INFO").tag("INFO")
                            Text("WARNING").tag("WARNING")
                            Text("ERROR").tag("ERROR")
                        }
                        .pickerStyle(.menu)
                    }
                }

                // LLM Configuration
                SettingsSectionView(title: "LLM Configuration") {
                    SettingsFieldView(label: "Model", value: settings.llmModel) {
                        TextField("", text: $settings.llmModel)
                    }
                    SettingsFieldView(label: "Temperature", value: String(format: "%.1f", settings.llmTemperature)) {
                        Slider(value: $settings.llmTemperature, in: 0...1)
                    }
                }

                // Agent Configuration
                SettingsSectionView(title: "Agent Configuration") {
                    SettingsFieldView(label: "Check Interval (seconds)", value: String(settings.agentCheckInterval)) {
                        Stepper("", value: $settings.agentCheckInterval, in: 10...600, step: 10)
                    }
                    SettingsFieldView(label: "Task Timeout (seconds)", value: String(settings.taskTimeoutSeconds)) {
                        Stepper("", value: $settings.taskTimeoutSeconds, in: 30...3600, step: 30)
                    }
                }
            }
            .padding(20)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct SettingsSectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor))
            .cornerRadius(6)
        }
    }
}

struct SettingsFieldView<Content: View>: View {
    let label: String
    let value: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                Text(value)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
            Spacer()
            content()
        }
    }
}

struct StatusView: View {
    @ObservedObject var viewModel: CalendarAgentViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StatusCardView(title: "Backend Status", content: {
                    HStack {
                        Circle()
                            .fill(viewModel.isRunning ? Color.green : Color.orange)
                            .frame(width: 12, height: 12)
                        Text(viewModel.isRunning ? "Running" : "Initializing")
                            .font(.system(size: 14, weight: .medium))
                        Spacer()
                    }
                })

                StatusCardView(title: "Recent Logs", content: {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.logs.suffix(5), id: \.self) { log in
                            Text(log)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                    }
                })

                StatusCardView(title: "System Information", content: {
                    VStack(alignment: .leading, spacing: 8) {
                        InfoRow(label: "Version", value: "1.0.0")
                        InfoRow(label: "Build", value: "2026.04.30")
                        InfoRow(label: "Platform", value: "macOS")
                        InfoRow(label: "Architecture", value: "Native SwiftUI")
                    }
                })
            }
            .padding(20)
        }
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct StatusCardView<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)
            content()
                .padding(12)
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(6)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 12, weight: .medium))
        }
    }
}

// MARK: - About View
struct AboutView: View {
    @Environment(\.dismissWindow) var dismissWindow

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 48))
                    .foregroundColor(.blue)
                Text("Calendar Agent")
                    .font(.system(size: 24, weight: .bold))
                Text("v1.0.0")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            VStack(spacing: 8) {
                Text("Professional macOS calendar automation")
                    .font(.system(size: 13))
                Text("Built with native SwiftUI")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)

            Button("Close") {
                dismissWindow()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
        }
        .padding(24)
        .frame(width: 340)
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarAgentViewModel())
}
