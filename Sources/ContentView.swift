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

                    // Update Banner
                    if viewModel.updateAvailable {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 18))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Update Available")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("Calendar Agent v\(viewModel.availableVersion) is ready to install")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                if viewModel.isDownloadingUpdate {
                                    ProgressView(value: viewModel.downloadProgress)
                                        .frame(width: 100)
                                } else {
                                    Button(action: {
                                        viewModel.downloadAndInstallUpdate()
                                    }) {
                                        Text("Install Now")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 14)
                                            .background(Color.blue)
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(12)
                        }
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                        .padding(16)
                        .overlay(Divider(), alignment: .bottom)
                    }

                    // Content
                    Group {
                        switch viewModel.selectedTab {
                        case "logs":
                            LogsView(logs: viewModel.logs)
                        case "tasks":
                            TasksView(tasks: $viewModel.tasks, viewModel: viewModel)
                        case "workflows":
                            WorkflowsView(workflows: $viewModel.workflows, viewModel: viewModel)
                        case "settings":
                            SettingsView(settings: $viewModel.settings, viewModel: viewModel)
                        case "status":
                            StatusView(viewModel: viewModel)
                        default:
                            LogsView(logs: viewModel.logs)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
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

// MARK: - Navigation & Status Components

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
                Text("Python Backend")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Logs View

struct LogsView: View {
    let logs: [String]

    var body: some View {
        VStack(spacing: 0) {
            if logs.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No logs yet")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Application logs will appear here")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(nsColor: .windowBackgroundColor))
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(logs, id: \.self) { log in
                                Text(log)
                                    .font(.system(size: 11, design: .monospaced))
                                    .foregroundColor(.secondary)
                                    .textSelection(.enabled)
                                    .padding(8)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(4)
                            }
                        }
                        .padding(16)
                        .onAppear {
                            if let lastLog = logs.last {
                                proxy.scrollTo(lastLog)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

// MARK: - Tasks View

struct TasksView: View {
    @Binding var tasks: [TaskItem]
    @ObservedObject var viewModel: CalendarAgentViewModel
    @State private var showNewTaskDialog = false
    @State private var selectedTask: TaskItem?
    @State private var newTaskName = ""
    @State private var newTaskDescription = ""
    @State private var newTaskPriority = "medium"
    @State private var searchText = ""
    @State private var priorityFilter: [String] = []
    @State private var statusFilter: [String] = []

    var filteredTasks: [TaskItem] {
        var filter = TaskFilter()
        filter.searchText = searchText
        filter.priorityFilter = priorityFilter
        filter.statusFilter = statusFilter
        return viewModel.getFilteredTasks(filter: filter)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                HStack {
                    Button(action: { showNewTaskDialog = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Task")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal: 12)
                        .background(Color.blue)
                        .cornerRadius(6)
                    }
                    Spacer()
                }

                // Search Bar
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search tasks...", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                }

                // Filter Options
                HStack(spacing: 12) {
                    Menu {
                        Toggle("All", isOn: Binding(
                            get: { statusFilter.isEmpty },
                            set: { if $0 { statusFilter = [] } }
                        ))
                        Divider()
                        Toggle("Pending", isOn: Binding(
                            get: { statusFilter.contains("pending") },
                            set: { if $0 { statusFilter.append("pending") } else { statusFilter.removeAll { $0 == "pending" } } }
                        ))
                        Toggle("In Progress", isOn: Binding(
                            get: { statusFilter.contains("in_progress") },
                            set: { if $0 { statusFilter.append("in_progress") } else { statusFilter.removeAll { $0 == "in_progress" } } }
                        ))
                        Toggle("Blocked", isOn: Binding(
                            get: { statusFilter.contains("blocked") },
                            set: { if $0 { statusFilter.append("blocked") } else { statusFilter.removeAll { $0 == "blocked" } } }
                        ))
                        Toggle("Completed", isOn: Binding(
                            get: { statusFilter.contains("completed") },
                            set: { if $0 { statusFilter.append("completed") } else { statusFilter.removeAll { $0 == "completed" } } }
                        ))
                    } label: {
                        Label("Status", systemImage: "line.3.horizontal.decrease.circle")
                            .font(.system(size: 11))
                    }

                    Menu {
                        Toggle("All", isOn: Binding(
                            get: { priorityFilter.isEmpty },
                            set: { if $0 { priorityFilter = [] } }
                        ))
                        Divider()
                        Toggle("High", isOn: Binding(
                            get: { priorityFilter.contains("high") },
                            set: { if $0 { priorityFilter.append("high") } else { priorityFilter.removeAll { $0 == "high" } } }
                        ))
                        Toggle("Medium", isOn: Binding(
                            get: { priorityFilter.contains("medium") },
                            set: { if $0 { priorityFilter.append("medium") } else { priorityFilter.removeAll { $0 == "medium" } } }
                        ))
                        Toggle("Low", isOn: Binding(
                            get: { priorityFilter.contains("low") },
                            set: { if $0 { priorityFilter.append("low") } else { priorityFilter.removeAll { $0 == "low" } } }
                        ))
                    } label: {
                        Label("Priority", systemImage: "flag.circle")
                            .font(.system(size: 11))
                    }

                    Spacer()
                }
            }
            .padding(16)
            .background(Color(nsColor: .windowBackgroundColor))
            .overlay(Divider(), alignment: .bottom)

            ScrollView {
                VStack(spacing: 8) {
                    if filteredTasks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text(tasks.isEmpty ? "No tasks" : "No matching tasks")
                                .font(.system(size: 14, weight: .semibold))
                            Text(tasks.isEmpty ? "Create your first task to get started" : "Try adjusting your filters")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ForEach(Array(zip(filteredTasks.indices, filteredTasks)), id: \.0) { index, task in
                            TaskRowView(task: Binding(
                                get: { filteredTasks[index] },
                                set: {
                                    if let taskIndex = tasks.firstIndex(where: { $0.id == filteredTasks[index].id }) {
                                        tasks[taskIndex] = $0
                                    }
                                }
                            ), viewModel: viewModel)
                        }
                    }
                }
                .padding(16)
            }
        }
        .sheet(isPresented: $showNewTaskDialog) {
            NewTaskDialog(
                isPresented: $showNewTaskDialog,
                onCreate: { name, description, priority in
                    viewModel.addTask(name: name, description: description, priority: priority)
                }
            )
        }
    }
}

struct TaskRowView: View {
    @Binding var task: TaskItem
    @ObservedObject var viewModel: CalendarAgentViewModel
    @State private var showEditor = false

    var canComplete: Bool {
        viewModel.canCompleteTask(task)
    }

    var isBlocked: Bool {
        task.status == "blocked" || !canComplete && task.status != "completed"
    }

    var blockedCount: Int {
        viewModel.getTaskDependents(task).count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                // Priority Color Indicator
                RoundedRectangle(cornerRadius: 4)
                    .fill(priorityColor(task.priority))
                    .frame(width: 4)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(task.name)
                            .font(.system(size: 13, weight: .semibold))
                            .strikethrough(task.status == "completed")
                            .foregroundColor(task.status == "completed" ? .secondary : .primary)

                        Spacer()

                        // Status Badge
                        Text(task.status.replacingOccurrences(of: "_", with: " ").capitalized)
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 6)
                            .background(statusColor(task.status))
                            .cornerRadius(3)

                        // Blocked Indicator
                        if isBlocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.orange)
                        }
                    }

                    if !task.description.isEmpty {
                        Text(task.description)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }

                    HStack(spacing: 12) {
                        Label(task.priority, systemImage: "flag.fill")
                            .font(.system(size: 10))
                            .foregroundColor(priorityColor(task.priority))

                        if let dueDate = task.dueDate {
                            Label(dueDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }

                        if !task.tags.isEmpty {
                            Label(task.tags.count == 1 ? task.tags[0] : "\(task.tags.count) tags", systemImage: "tag.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }

                        if !task.dependencies.isEmpty {
                            Label("\(task.dependencies.count)", systemImage: "link")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }

                        if blockedCount > 0 {
                            Label("\(blockedCount)", systemImage: "arrow.up.square.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.blue)
                        }

                        Spacer()
                    }
                }

                HStack(spacing: 8) {
                    Button(action: {
                        if !isBlocked || task.status == "completed" {
                            var updated = task
                            updated.status = task.status == "completed" ? "pending" : "completed"
                            viewModel.updateTask(task, name: task.name, description: task.description, status: updated.status, priority: task.priority, dueDate: task.dueDate, tags: task.tags, workflowId: task.workflowId)
                            task = updated
                        }
                    }) {
                        Image(systemName: task.status == "completed" ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.status == "completed" ? .green : isBlocked ? .gray : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(isBlocked && task.status != "completed" ? 0.5 : 1)

                    Button(action: { showEditor = true }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { viewModel.deleteTask(task) }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
        .opacity(task.status == "completed" ? 0.7 : 1.0)
        .sheet(isPresented: $showEditor) {
            TaskDetailEditor(task: $task, viewModel: viewModel, isPresented: $showEditor)
        }
    }

    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "high": return .red
        case "medium": return .orange
        default: return .blue
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "completed": return .green
        case "in_progress": return .blue
        case "blocked": return .orange
        default: return .gray
        }
    }
}

struct NewTaskDialog: View {
    @Binding var isPresented: Bool
    let onCreate: (String, String, String) -> Void
    @State private var name = ""
    @State private var description = ""
    @State private var priority = "medium"

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Task Title")
                    .font(.system(size: 12, weight: .semibold))
                TextField("Enter task title", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 12, weight: .semibold))
                TextEditor(text: $description)
                    .frame(height: 80)
                    .border(Color.gray.opacity(0.3))
                    .cornerRadius(4)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Priority")
                    .font(.system(size: 12, weight: .semibold))
                Picker("Priority", selection: $priority) {
                    Text("Low").tag("low")
                    Text("Medium").tag("medium")
                    Text("High").tag("high")
                }
                .pickerStyle(.segmented)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)

                Button("Create") {
                    onCreate(name, description, priority)
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 400)
    }
}

struct TaskDetailEditor: View {
    @Binding var task: TaskItem
    @ObservedObject var viewModel: CalendarAgentViewModel
    @Binding var isPresented: Bool
    @State private var showDependencyList = false

    var dependencyTasks: [TaskItem] {
        task.dependencies.compactMap { depId in
            viewModel.tasks.first(where: { $0.id == depId })
        }
    }

    var availableDependencies: [TaskItem] {
        viewModel.tasks.filter { t in
            t.id != task.id && !task.dependencies.contains(t.id)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Form {
                Section("Basic") {
                    TextField("Title", text: $task.name)
                    TextEditor(text: $task.description)
                        .frame(height: 60)
                }

                Section("Details") {
                    Picker("Priority", selection: $task.priority) {
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }

                    Picker("Status", selection: $task.status) {
                        Text("Pending").tag("pending")
                        Text("In Progress").tag("in_progress")
                        Text("Blocked").tag("blocked")
                        Text("Completed").tag("completed")
                    }

                    DatePicker("Due Date", selection: Binding(
                        get: { task.dueDate ?? Date() },
                        set: { task.dueDate = $0 }
                    ), displayedComponents: .date)
                }

                Section("Tags") {
                    TextField("Enter tags (comma separated)", text: Binding(
                        get: { task.tags.joined(separator: ", ") },
                        set: { task.tags = $0.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) } }
                    ))
                }

                Section("Dependencies") {
                    if dependencyTasks.isEmpty {
                        Text("No dependencies")
                            .foregroundColor(.secondary)
                            .font(.system(size: 12))
                    } else {
                        VStack(spacing: 8) {
                            ForEach(dependencyTasks, id: \.id) { depTask in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(depTask.name)
                                            .font(.system(size: 12, weight: .semibold))
                                        Text(depTask.status)
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Button(action: {
                                        viewModel.removeTaskDependency(task: task, from: depTask)
                                        if let index = task.dependencies.firstIndex(of: depTask.id) {
                                            task.dependencies.remove(at: index)
                                        }
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundColor(.red)
                                            .font(.system(size: 10))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                .padding(8)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .cornerRadius(4)
                            }
                        }
                    }

                    if !availableDependencies.isEmpty {
                        Menu {
                            ForEach(availableDependencies, id: \.id) { availTask in
                                Button(action: {
                                    viewModel.addTaskDependency(task: task, dependsOn: availTask)
                                    task.dependencies.append(availTask.id)
                                }) {
                                    Label(availTask.name, systemImage: "link")
                                }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Dependency")
                            }
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.blue)
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Button("Close") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)

                Button("Save") {
                    viewModel.updateTask(task, name: task.name, description: task.description, status: task.status, priority: task.priority, dueDate: task.dueDate, tags: task.tags, workflowId: task.workflowId)
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(width: 500, height: 700)
    }
}

// MARK: - Workflows View

struct WorkflowsView: View {
    @Binding var workflows: [WorkflowItem]
    @ObservedObject var viewModel: CalendarAgentViewModel
    @State private var showNewWorkflowDialog = false
    @State private var selectedWorkflow: WorkflowItem?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: { showNewWorkflowDialog = true }) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus.circle.fill")
                        Text("New Workflow")
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .cornerRadius(6)
                }
                Spacer()
            }
            .padding(16)
            .background(Color(nsColor: .windowBackgroundColor))
            .overlay(Divider(), alignment: .bottom)

            ScrollView {
                VStack(spacing: 8) {
                    if workflows.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "workflow")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            Text("No workflows")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Create your first workflow to get started")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ForEach($workflows) { $workflow in
                            WorkflowRowView(workflow: $workflow, viewModel: viewModel)
                        }
                    }
                }
                .padding(16)
            }
        }
        .sheet(isPresented: $showNewWorkflowDialog) {
            NewWorkflowDialog(
                isPresented: $showNewWorkflowDialog,
                onCreate: { name, description, triggerType in
                    viewModel.addWorkflow(name: name, description: description, triggerType: triggerType)
                }
            )
        }
    }
}

struct WorkflowRowView: View {
    @Binding var workflow: WorkflowItem
    @ObservedObject var viewModel: CalendarAgentViewModel
    @State private var showEditor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workflow.name)
                        .font(.system(size: 13, weight: .semibold))
                    if !workflow.description.isEmpty {
                        Text(workflow.description)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    HStack(spacing: 12) {
                        Label(workflow.triggerType, systemImage: "timerswitch.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Label("\(workflow.actions.count) actions", systemImage: "gearshape")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                HStack(spacing: 8) {
                    Button(action: {
                        var updated = workflow
                        updated.enabled = !workflow.enabled
                        viewModel.updateWorkflow(workflow, name: workflow.name, description: workflow.description, enabled: updated.enabled, triggerType: workflow.triggerType, triggerSchedule: workflow.triggerSchedule)
                        workflow = updated
                    }) {
                        Image(systemName: workflow.enabled ? "power.circle.fill" : "power.circle")
                            .foregroundColor(workflow.enabled ? .green : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { showEditor = true }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { viewModel.deleteWorkflow(workflow) }) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(12)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(6)
        .sheet(isPresented: $showEditor) {
            WorkflowDetailEditor(workflow: $workflow, viewModel: viewModel, isPresented: $showEditor)
        }
    }
}

struct NewWorkflowDialog: View {
    @Binding var isPresented: Bool
    let onCreate: (String, String, String) -> Void
    @State private var name = ""
    @State private var description = ""
    @State private var triggerType = "manual"

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Workflow Title")
                    .font(.system(size: 12, weight: .semibold))
                TextField("Enter workflow title", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.system(size: 12, weight: .semibold))
                TextEditor(text: $description)
                    .frame(height: 80)
                    .border(Color.gray.opacity(0.3))
                    .cornerRadius(4)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Trigger Type")
                    .font(.system(size: 12, weight: .semibold))
                Picker("Trigger", selection: $triggerType) {
                    Text("Manual").tag("manual")
                    Text("Scheduled").tag("scheduled")
                    Text("Event-based").tag("event")
                }
                .pickerStyle(.segmented)
            }

            HStack(spacing: 12) {
                Button("Cancel") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)

                Button("Create") {
                    onCreate(name, description, triggerType)
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 400)
    }
}

struct WorkflowDetailEditor: View {
    @Binding var workflow: WorkflowItem
    @ObservedObject var viewModel: CalendarAgentViewModel
    @Binding var isPresented: Bool
    @State private var showActionEditor = false
    @State private var selectedActionType: WorkflowActionType = .apiCall

    var executionHistory: [WorkflowExecutionLog] {
        viewModel.getWorkflowExecutionHistory(workflowId: workflow.id, limit: 10)
    }

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Form {
                    Section("Basic") {
                        TextField("Title", text: $workflow.name)
                        TextEditor(text: $workflow.description)
                            .frame(height: 60)
                    }

                    Section("Configuration") {
                        Picker("Trigger Type", selection: $workflow.triggerType) {
                            Text("Manual").tag("manual")
                            Text("Scheduled").tag("scheduled")
                            Text("Event-based").tag("event")
                        }

                        if workflow.triggerType == "scheduled" {
                            TextField("Cron Expression (min hour day month dow)", text: Binding(
                                get: { workflow.triggerSchedule ?? "" },
                                set: { workflow.triggerSchedule = $0 }
                            ))
                            Text("Example: 0 9 * * 1-5 (9am Mon-Fri)")
                                .font(.system(size: 10))
                                .foregroundColor(.secondary)
                        }

                        Toggle("Enable", isOn: $workflow.enabled)
                        Toggle("Notify on Complete", isOn: $workflow.notifyOnComplete)
                    }

                    Section("Actions (\(workflow.actions.count))") {
                        if workflow.actions.isEmpty {
                            Text("No actions configured")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        } else {
                            ForEach(workflow.actions.sorted { $0.order < $1.order }) { action in
                                HStack {
                                    Image(systemName: actionIcon(action.type))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(action.name)
                                            .font(.system(size: 12, weight: .semibold))
                                        Text(action.type.rawValue)
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if !action.enabled {
                                        Image(systemName: "eye.slash.fill")
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }

                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Action")
                                .foregroundColor(.blue)
                            Spacer()
                        }
                        .onTapGesture {
                            showActionEditor = true
                        }
                    }

                    if !executionHistory.isEmpty {
                        Section("Recent Executions") {
                            VStack(spacing: 8) {
                                ForEach(executionHistory.prefix(5), id: \.id) { log in
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Circle()
                                                .fill(statusColor(log.status))
                                                .frame(width: 8, height: 8)
                                            Text(log.status.capitalized)
                                                .font(.system(size: 11, weight: .semibold))
                                            Spacer()
                                            Text(log.startTime.formatted(date: .abbreviated, time: .shortened))
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                        if let errorMsg = log.errorMessage {
                                            Text(errorMsg)
                                                .font(.system(size: 10))
                                                .foregroundColor(.red)
                                                .lineLimit(1)
                                        }
                                    }
                                    .padding(8)
                                    .background(Color(nsColor: .controlBackgroundColor))
                                    .cornerRadius(4)
                                }
                            }
                        }
                    }
                }
            }

            HStack(spacing: 12) {
                Button("Close") {
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(6)

                Button("Save") {
                    viewModel.updateWorkflow(workflow, name: workflow.name, description: workflow.description, enabled: workflow.enabled, triggerType: workflow.triggerType, triggerSchedule: workflow.triggerSchedule)
                    isPresented = false
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(6)
            }
            .padding(.horizontal)

            Spacer()
        }
        .frame(width: 500, height: 600)
        .sheet(isPresented: $showActionEditor) {
            ActionTypeSelector(
                isPresented: $showActionEditor,
                onSelect: { actionType in
                    var newAction = WorkflowAction(type: actionType, name: actionType.rawValue, order: workflow.actions.count)
                    newAction.enabled = true
                    viewModel.addWorkflowAction(workflow, actionType: actionType, actionName: actionType.rawValue)
                }
            )
        }
    }

    private func actionIcon(_ type: WorkflowActionType) -> String {
        switch type {
        case .apiCall: return "network"
        case .pythonScript: return "terminal.fill"
        case .calendarEvent: return "calendar"
        case .notification: return "bell.fill"
        case .llmCall: return "sparkles"
        case .customFunction: return "function"
        }
    }
}

struct ActionTypeSelector: View {
    @Binding var isPresented: Bool
    let onSelect: (WorkflowActionType) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text("Select Action Type")
                .font(.system(size: 16, weight: .bold))

            VStack(spacing: 8) {
                ForEach([
                    WorkflowActionType.apiCall,
                    .pythonScript,
                    .calendarEvent,
                    .notification,
                    .llmCall,
                    .customFunction
                ], id: \.self) { actionType in
                    Button(action: {
                        onSelect(actionType)
                        isPresented = false
                    }) {
                        HStack {
                            Image(systemName: actionIcon(actionType))
                            VStack(alignment: .leading) {
                                Text(actionLabel(actionType))
                                    .font(.system(size: 12, weight: .semibold))
                                Text(actionDescription(actionType))
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color(nsColor: .controlBackgroundColor))
                        .cornerRadius(6)
                        .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }

            Spacer()

            Button("Cancel") {
                isPresented = false
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(6)
        }
        .padding(20)
        .frame(width: 400, height: 500)
    }

    private func actionIcon(_ type: WorkflowActionType) -> String {
        switch type {
        case .apiCall: return "network"
        case .pythonScript: return "terminal.fill"
        case .calendarEvent: return "calendar"
        case .notification: return "bell.fill"
        case .llmCall: return "sparkles"
        case .customFunction: return "function"
        }
    }

    private func actionLabel(_ type: WorkflowActionType) -> String {
        switch type {
        case .apiCall: return "API Call"
        case .pythonScript: return "Python Script"
        case .calendarEvent: return "Calendar Event"
        case .notification: return "Notification"
        case .llmCall: return "LLM Call"
        case .customFunction: return "Custom Function"
        }
    }

    private func actionDescription(_ type: WorkflowActionType) -> String {
        switch type {
        case .apiCall: return "Call an external API endpoint"
        case .pythonScript: return "Execute a Python script"
        case .calendarEvent: return "Create or update calendar event"
        case .notification: return "Send a notification"
        case .llmCall: return "Use the selected LLM model"
        case .customFunction: return "Execute a pre-created function"
        }
    }
}

// MARK: - Settings View

struct SettingsView: View {
    @Binding var settings: AppSettings
    @ObservedObject var viewModel: CalendarAgentViewModel

    var body: some View {
        Form {
            Section("Application") {
                TextField("Application Name", text: $settings.applicationName)
                Toggle("Auto Start Enabled", isOn: $settings.autoStartEnabled)
                Picker("Log Level", selection: $settings.logLevel) {
                    Text("DEBUG").tag("DEBUG")
                    Text("INFO").tag("INFO")
                    Text("WARNING").tag("WARNING")
                }
            }

            Section("LLM Configuration (Ollama)") {
                if viewModel.isLoadingModels {
                    HStack {
                        ProgressView()
                        Text("Loading models...")
                            .foregroundColor(.secondary)
                    }
                } else if viewModel.ollamaModels.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("No Ollama models detected")
                            .foregroundColor(.secondary)
                        Text("Make sure Ollama is running at \(settings.ollamaUrl)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Picker("Selected Model", selection: $settings.llmModel) {
                        ForEach(viewModel.ollamaModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }

                TextField("Ollama Server URL", text: $settings.ollamaUrl)
                Slider(value: $settings.llmTemperature, in: 0...1, step: 0.1)
                HStack {
                    Text("Temperature")
                    Spacer()
                    Text(String(format: "%.1f", settings.llmTemperature))
                        .foregroundColor(.secondary)
                }
            }

            Section("Agent Configuration") {
                Stepper("Check Interval (seconds): \(settings.agentCheckInterval)", value: $settings.agentCheckInterval, in: 10...600, step: 10)
                Stepper("Task Timeout (seconds): \(settings.taskTimeoutSeconds)", value: $settings.taskTimeoutSeconds, in: 10...3600, step: 10)
            }
        }
        .onAppear {
            viewModel.detectOllamaModels()
        }
    }
}

// MARK: - Status View

struct StatusView: View {
    @ObservedObject var viewModel: CalendarAgentViewModel

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Python Backend")
                    .font(.system(size: 14, weight: .semibold))
                HStack(spacing: 12) {
                    Circle()
                        .fill(viewModel.isRunning ? Color.green : Color.orange)
                        .frame(width: 12, height: 12)
                    Text(viewModel.isRunning ? "Running" : "Starting...")
                        .font(.system(size: 12))
                }
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            VStack(alignment: .leading, spacing: 12) {
                Text("Statistics")
                    .font(.system(size: 14, weight: .semibold))
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Tasks:")
                        Spacer()
                        Text("\(viewModel.tasks.count)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Workflows:")
                        Spacer()
                        Text("\(viewModel.workflows.count)")
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Log Entries:")
                        Spacer()
                        Text("\(viewModel.logs.count)")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(8)
            }
            .padding(16)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            Spacer()
        }
        .padding(16)
    }
}
