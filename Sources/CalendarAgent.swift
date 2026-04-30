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

    // CRUD UI State
    @Published var showNewTaskDialog = false
    @Published var showNewWorkflowDialog = false
    @Published var editingTaskId: UUID?
    @Published var newTaskName: String = ""
    @Published var newWorkflowName: String = ""
    @Published var newWorkflowDescription: String = ""

    // Update State
    @Published var updateAvailable = false
    @Published var availableVersion = ""
    @Published var isCheckingForUpdates = false
    @Published var downloadProgress: Double = 0.0
    @Published var isDownloadingUpdate = false

    // Ollama Models
    @Published var ollamaModels: [String] = []
    @Published var isLoadingModels = false

    // Filtering and searching
    @Published var taskFilter: TaskFilter = TaskFilter()
    @Published var searchText: String = "" {
        didSet {
            taskFilter.searchText = searchText
        }
    }

    // Workflow execution logs
    @Published var executionLogs: [WorkflowExecutionLog] = []

    // Custom functions
    @Published var customFunctions: [CustomFunctionDefinition] = []

    private var process: Process?
    private var pythonOutputPipe: Pipe?

    private let tasksKey = "CalendarAgent_Tasks"
    private let workflowsKey = "CalendarAgent_Workflows"
    private let updateCheckURL = "https://api.github.com/repos/moldovan/calendar-agent/releases/latest"

    override init() {
        super.init()
        loadTasks()
        loadWorkflows()
        loadExecutionLogs()
        loadCustomFunctions()
        startPythonBackend()
        checkForUpdates()
        schedulePeriodicUpdateCheck()
        detectOllamaModels()
        initializeDefaultCustomFunctions()
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

    // MARK: - Ollama Integration

    func detectOllamaModels() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoadingModels = true
            }

            let urlString = "\(self.settings.ollamaUrl)/api/tags"
            guard let url = URL(string: urlString) else {
                DispatchQueue.main.async {
                    self.isLoadingModels = false
                    self.addLog("Invalid Ollama URL: \(urlString)")
                }
                return
            }

            var request = URLRequest(url: url)
            request.timeoutInterval = 5

            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                defer {
                    DispatchQueue.main.async {
                        self.isLoadingModels = false
                    }
                }

                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.addLog("Ollama not found: \(error?.localizedDescription ?? "Connection failed")")
                    }
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let models = json["models"] as? [[String: Any]] {
                        let modelNames = models.compactMap { $0["name"] as? String }
                        DispatchQueue.main.async {
                            self.ollamaModels = modelNames.sorted()
                            self.addLog("Found \(modelNames.count) Ollama models")
                            if !modelNames.isEmpty && !modelNames.contains(self.settings.llmModel) {
                                self.settings.llmModel = modelNames[0]
                            }
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.addLog("Failed to parse Ollama models: \(error.localizedDescription)")
                    }
                }
            }

            task.resume()
        }
    }

    // MARK: - Tasks CRUD

    func addTask(name: String, description: String = "", priority: String = "medium") {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newTask = TaskItem(name: name, description: description, status: "pending", priority: priority, createdAt: Date())
        tasks.append(newTask)
        saveTasks()
        addLog("Task created: \(name)")
    }

    func updateTask(_ task: TaskItem, name: String, description: String = "", status: String, priority: String = "medium", dueDate: Date? = nil, tags: [String] = [], workflowId: UUID? = nil) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].name = name
            tasks[index].description = description
            tasks[index].status = status
            tasks[index].priority = priority
            tasks[index].dueDate = dueDate
            tasks[index].tags = tags
            tasks[index].workflowId = workflowId
            if status == "completed" {
                tasks[index].completedAt = Date()
            }
            saveTasks()
            addLog("Task updated: \(name) (\(status))")
        }
    }

    func completeTask(_ task: TaskItem) {
        updateTask(task, name: task.name, status: "completed")
    }

    func deleteTask(_ task: TaskItem) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
        addLog("Task deleted: \(task.name)")
    }

    private func saveTasks() {
        let encoded = try? JSONEncoder().encode(tasks)
        UserDefaults.standard.set(encoded, forKey: tasksKey)
    }

    private func loadTasks() {
        guard let data = UserDefaults.standard.data(forKey: tasksKey) else { return }
        if let decoded = try? JSONDecoder().decode([TaskItem].self, from: data) {
            tasks = decoded
        }
    }

    // MARK: - Workflows CRUD

    func addWorkflow(name: String, description: String = "", triggerType: String = "manual") {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        var newWorkflow = WorkflowItem(name: name, description: description, enabled: true)
        newWorkflow.triggerType = triggerType
        workflows.append(newWorkflow)
        saveWorkflows()
        addLog("Workflow created: \(name)")
    }

    func updateWorkflow(_ workflow: WorkflowItem, name: String, description: String, enabled: Bool, triggerType: String = "manual", triggerSchedule: String? = nil) {
        if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
            workflows[index].name = name
            workflows[index].description = description
            workflows[index].enabled = enabled
            workflows[index].triggerType = triggerType
            workflows[index].triggerSchedule = triggerSchedule
            saveWorkflows()
            addLog("Workflow updated: \(name)")
        }
    }

    func addWorkflowAction(_ workflow: WorkflowItem, actionType: WorkflowActionType, actionName: String) {
        if let index = workflows.firstIndex(where: { $0.id == workflow.id }) {
            let order = workflows[index].actions.count
            let newAction = WorkflowAction(type: actionType, name: actionName, order: order)
            workflows[index].actions.append(newAction)
            saveWorkflows()
            addLog("Action added to workflow: \(actionName)")
        }
    }

    func updateWorkflowAction(_ workflow: WorkflowItem, action: WorkflowAction, updates: WorkflowAction) {
        if let wfIndex = workflows.firstIndex(where: { $0.id == workflow.id }),
           let actionIndex = workflows[wfIndex].actions.firstIndex(where: { $0.id == action.id }) {
            workflows[wfIndex].actions[actionIndex] = updates
            saveWorkflows()
            addLog("Workflow action updated: \(updates.name)")
        }
    }

    func deleteWorkflowAction(_ workflow: WorkflowItem, action: WorkflowAction) {
        if let wfIndex = workflows.firstIndex(where: { $0.id == workflow.id }) {
            workflows[wfIndex].actions.removeAll { $0.id == action.id }
            saveWorkflows()
            addLog("Workflow action deleted")
        }
    }

    func toggleWorkflow(_ workflow: WorkflowItem) {
        updateWorkflow(workflow, name: workflow.name, description: workflow.description, enabled: !workflow.enabled)
    }

    func deleteWorkflow(_ workflow: WorkflowItem) {
        workflows.removeAll { $0.id == workflow.id }
        saveWorkflows()
        addLog("Workflow deleted: \(workflow.name)")
    }

    private func saveWorkflows() {
        let encoded = try? JSONEncoder().encode(workflows)
        UserDefaults.standard.set(encoded, forKey: workflowsKey)
    }

    private func loadWorkflows() {
        guard let data = UserDefaults.standard.data(forKey: workflowsKey) else { return }
        if let decoded = try? JSONDecoder().decode([WorkflowItem].self, from: data) {
            workflows = decoded
        }
    }

    // MARK: - Auto-Update

    func checkForUpdates() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isCheckingForUpdates = true
            }

            guard let url = URL(string: self.updateCheckURL) else { return }

            var request = URLRequest(url: url)
            request.timeoutInterval = 10
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                defer {
                    DispatchQueue.main.async {
                        self.isCheckingForUpdates = false
                    }
                }

                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.addLog("Update check failed: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    return
                }

                do {
                    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                    let currentVersion = self.getCurrentVersion()
                    let latestVersion = release.tag_name.replacingOccurrences(of: "v", with: "")

                    DispatchQueue.main.async {
                        if self.compareVersions(currentVersion, latestVersion) < 0 {
                            self.updateAvailable = true
                            self.availableVersion = latestVersion
                            self.addLog("Update available: v\(latestVersion)")
                        } else {
                            self.updateAvailable = false
                            self.addLog("App is up to date")
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.addLog("Failed to parse update info: \(error.localizedDescription)")
                    }
                }
            }

            task.resume()
        }
    }

    private func getCurrentVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0"
    }

    private func compareVersions(_ current: String, _ latest: String) -> Int {
        let currentParts = current.split(separator: ".").compactMap { Int($0) }
        let latestParts = latest.split(separator: ".").compactMap { Int($0) }

        let maxLength = max(currentParts.count, latestParts.count)

        for i in 0..<maxLength {
            let curr = i < currentParts.count ? currentParts[i] : 0
            let lat = i < latestParts.count ? latestParts[i] : 0

            if curr < lat { return -1 }
            if curr > lat { return 1 }
        }

        return 0
    }

    private func schedulePeriodicUpdateCheck() {
        DispatchQueue.global().asyncAfter(deadline: .now() + 3600) { [weak self] in
            self?.checkForUpdates()
            self?.schedulePeriodicUpdateCheck()
        }
    }

    func downloadAndInstallUpdate() {
        guard updateAvailable else { return }

        DispatchQueue.main.async {
            self.isDownloadingUpdate = true
            self.downloadProgress = 0
        }

        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }

            guard let url = URL(string: self.updateCheckURL) else { return }

            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }

                guard let data = data, error == nil else {
                    DispatchQueue.main.async {
                        self.isDownloadingUpdate = false
                        self.addLog("Update download failed: \(error?.localizedDescription ?? "Unknown error")")
                    }
                    return
                }

                do {
                    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)

                    guard let assets = release.assets, !assets.isEmpty else {
                        DispatchQueue.main.async {
                            self.addLog("No release assets found")
                            self.isDownloadingUpdate = false
                        }
                        return
                    }

                    guard let downloadAsset = assets.first(where: { $0.name.hasSuffix(".zip") || $0.name.hasSuffix(".app") }) else {
                        DispatchQueue.main.async {
                            self.addLog("No app bundle found in release")
                            self.isDownloadingUpdate = false
                        }
                        return
                    }

                    self.downloadAppBundle(from: downloadAsset.browser_download_url)
                } catch {
                    DispatchQueue.main.async {
                        self.addLog("Failed to parse release info: \(error.localizedDescription)")
                        self.isDownloadingUpdate = false
                    }
                }
            }

            task.resume()
        }
    }

    private func downloadAppBundle(from urlString: String) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.addLog("Invalid download URL")
                self.isDownloadingUpdate = false
            }
            return
        }

        let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] localURL, response, error in
            guard let self = self else { return }

            guard let localURL = localURL, error == nil else {
                DispatchQueue.main.async {
                    self.addLog("Download failed: \(error?.localizedDescription ?? "Unknown error")")
                    self.isDownloadingUpdate = false
                }
                return
            }

            do {
                let fileManager = FileManager.default
                let tempDir = NSTemporaryDirectory()
                let downloadedFile = URL(fileURLWithPath: tempDir).appendingPathComponent("calendar-agent-update")

                try? fileManager.removeItem(at: downloadedFile)
                try fileManager.copyItem(at: localURL, to: downloadedFile)

                var isDir: ObjCBool = false
                let isDirectory = fileManager.fileExists(atPath: downloadedFile.path, isDirectory: &isDir) && isDir.boolValue

                let appPath = "/Applications/Calendar Agent.app"

                if isDirectory && downloadedFile.pathExtension != "app" {
                    // Extract zip if needed
                    try? extractZip(at: downloadedFile, to: NSTemporaryDirectory())
                    let extractedApp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("Calendar Agent.app")
                    if fileManager.fileExists(atPath: extractedApp.path) {
                        try? fileManager.removeItem(atPath: appPath)
                        try fileManager.moveItem(at: extractedApp, to: URL(fileURLWithPath: appPath))
                    }
                } else if downloadedFile.pathExtension == "app" {
                    // Direct app bundle
                    try? fileManager.removeItem(atPath: appPath)
                    try fileManager.moveItem(at: downloadedFile, to: URL(fileURLWithPath: appPath))
                }

                DispatchQueue.main.async {
                    self.addLog("Update installed successfully. Restarting app...")
                    self.isDownloadingUpdate = false
                    self.updateAvailable = false

                    // Restart the app
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        let task = Process()
                        task.launchPath = "/bin/bash"
                        task.arguments = ["-c", "sleep 1 && open /Applications/Calendar\\ Agent.app"]
                        try? task.run()

                        NSApplication.shared.terminate(self)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.addLog("Installation failed: \(error.localizedDescription)")
                    self.isDownloadingUpdate = false
                }
            }
        }

        downloadTask.resume()
    }

    private func extractZip(at source: URL, to destination: String) throws {
        let task = Process()
        task.launchPath = "/usr/bin/unzip"
        task.arguments = ["-o", source.path, "-d", destination]
        try task.run()
        task.waitUntilExit()
    }

    // MARK: - Task Filtering
    func getFilteredTasks(filter: TaskFilter) -> [TaskItem] {
        return tasks.filter { filter.matches($0) }
    }

    // MARK: - Task Dependencies
    func getTaskDependents(_ task: TaskItem) -> [TaskItem] {
        return tasks.filter { $0.dependencies.contains(task.id) }
    }

    func canCompleteTask(_ task: TaskItem) -> Bool {
        // Check if all dependencies are completed
        for depId in task.dependencies {
            if let depTask = tasks.first(where: { $0.id == depId }) {
                if depTask.status != "completed" {
                    return false
                }
            }
        }
        return true
    }

    func getBlockedTasks() -> [TaskItem] {
        return tasks.filter { task in
            if task.status == "blocked" { return true }
            return !canCompleteTask(task) && task.status != "completed"
        }
    }

    func addTaskDependency(task: TaskItem, dependsOn: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            if !tasks[index].dependencies.contains(dependsOn.id) {
                tasks[index].dependencies.append(dependsOn.id)
                saveTasks()
                addLog("Task dependency added: \(task.name) depends on \(dependsOn.name)")
            }
        }
    }

    func removeTaskDependency(task: TaskItem, from: TaskItem) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].dependencies.removeAll { $0 == from.id }
            saveTasks()
            addLog("Task dependency removed: \(task.name) no longer depends on \(from.name)")
        }
    }

    // MARK: - Workflow Execution Logging
    private let executionLogsKey = "CalendarAgent_ExecutionLogs"

    func startWorkflowExecution(workflow: WorkflowItem) -> WorkflowExecutionLog {
        let log = WorkflowExecutionLog(workflowId: workflow.id, workflowName: workflow.name)
        executionLogs.append(log)
        saveExecutionLogs()
        addLog("Workflow execution started: \(workflow.name)")
        return log
    }

    func completeWorkflowExecution(logId: UUID, status: String, errorMessage: String? = nil) {
        if let index = executionLogs.firstIndex(where: { $0.id == logId }) {
            executionLogs[index].endTime = Date()
            executionLogs[index].status = status
            executionLogs[index].errorMessage = errorMessage
            saveExecutionLogs()
            let workflowName = executionLogs[index].workflowName
            addLog("Workflow execution \(status): \(workflowName)")
        }
    }

    func addActionLog(executionLogId: UUID, actionId: UUID, actionName: String, actionType: String) -> ActionExecutionLog {
        if let index = executionLogs.firstIndex(where: { $0.id == executionLogId }) {
            let actionLog = ActionExecutionLog(actionId: actionId, actionName: actionName, actionType: actionType)
            executionLogs[index].actions.append(actionLog)
            saveExecutionLogs()
            return actionLog
        }
        return ActionExecutionLog(actionId: actionId, actionName: actionName, actionType: actionType)
    }

    func completeActionLog(executionLogId: UUID, actionLogId: UUID, status: String, output: String? = nil, errorMessage: String? = nil) {
        if let execIndex = executionLogs.firstIndex(where: { $0.id == executionLogId }),
           let actionIndex = executionLogs[execIndex].actions.firstIndex(where: { $0.id == actionLogId }) {
            executionLogs[execIndex].actions[actionIndex].endTime = Date()
            executionLogs[execIndex].actions[actionIndex].status = status
            executionLogs[execIndex].actions[actionIndex].output = output
            executionLogs[execIndex].actions[actionIndex].errorMessage = errorMessage
            saveExecutionLogs()
        }
    }

    func getWorkflowExecutionHistory(workflowId: UUID, limit: Int = 50) -> [WorkflowExecutionLog] {
        return executionLogs
            .filter { $0.workflowId == workflowId }
            .sorted { $0.startTime > $1.startTime }
            .prefix(limit)
            .map { $0 }
    }

    private func saveExecutionLogs() {
        let encoded = try? JSONEncoder().encode(executionLogs)
        UserDefaults.standard.set(encoded, forKey: executionLogsKey)
    }

    private func loadExecutionLogs() {
        guard let data = UserDefaults.standard.data(forKey: executionLogsKey) else { return }
        if let decoded = try? JSONDecoder().decode([WorkflowExecutionLog].self, from: data) {
            executionLogs = decoded
        }
    }

    // MARK: - Custom Functions Management
    private let customFunctionsKey = "CalendarAgent_CustomFunctions"

    func registerCustomFunction(_ function: CustomFunctionDefinition) {
        customFunctions.append(function)
        saveCustomFunctions()
        addLog("Custom function registered: \(function.name)")
    }

    func unregisterCustomFunction(name: String) {
        customFunctions.removeAll { $0.name == name }
        saveCustomFunctions()
        addLog("Custom function unregistered: \(name)")
    }

    func getCustomFunction(name: String) -> CustomFunctionDefinition? {
        return customFunctions.first { $0.name == name }
    }

    private func saveCustomFunctions() {
        let encoded = try? JSONEncoder().encode(customFunctions)
        UserDefaults.standard.set(encoded, forKey: customFunctionsKey)
    }

    private func loadCustomFunctions() {
        guard let data = UserDefaults.standard.data(forKey: customFunctionsKey) else { return }
        if let decoded = try? JSONDecoder().decode([CustomFunctionDefinition].self, from: data) {
            customFunctions = decoded
        }
    }

    // MARK: - Initialize Default Custom Functions
    func initializeDefaultCustomFunctions() {
        // Email notification function
        let emailFunction = CustomFunctionDefinition(
            name: "send_email",
            description: "Send an email notification",
            parameters: ["to": "String", "subject": "String", "body": "String"],
            returnType: "Bool",
            pythonHandler: """
def send_email(to: str, subject: str, body: str) -> bool:
    import smtplib
    from email.mime.text import MIMEText
    try:
        msg = MIMEText(body)
        msg['Subject'] = subject
        msg['From'] = 'calendar-agent@localhost'
        msg['To'] = to
        # Note: Requires mail server setup
        return True
    except Exception as e:
        print(f"Email failed: {e}")
        return False
"""
        )

        // Slack notification function
        let slackFunction = CustomFunctionDefinition(
            name: "send_slack_message",
            description: "Send a message to Slack",
            parameters: ["webhook_url": "String", "message": "String"],
            returnType: "Bool",
            pythonHandler: """
def send_slack_message(webhook_url: str, message: str) -> bool:
    import requests
    try:
        payload = {"text": message}
        response = requests.post(webhook_url, json=payload)
        return response.status_code == 200
    except Exception as e:
        print(f"Slack message failed: {e}")
        return False
"""
        )

        // Database query function
        let dbFunction = CustomFunctionDefinition(
            name: "query_database",
            description: "Execute a database query and return results",
            parameters: ["connection_string": "String", "query": "String"],
            returnType: "List",
            pythonHandler: """
def query_database(connection_string: str, query: str) -> list:
    import sqlite3
    try:
        conn = sqlite3.connect(connection_string)
        cursor = conn.cursor()
        cursor.execute(query)
        results = cursor.fetchall()
        conn.close()
        return results
    except Exception as e:
        print(f"Database query failed: {e}")
        return []
"""
        )

        // Data transformation function
        let transformFunction = CustomFunctionDefinition(
            name: "transform_data",
            description: "Transform and process data",
            parameters: ["data": "String", "transformation_type": "String"],
            returnType: "String",
            pythonHandler: """
def transform_data(data: str, transformation_type: str) -> str:
    import json
    try:
        if transformation_type == "json_to_csv":
            json_data = json.loads(data)
            # Convert to CSV
            return str(json_data)
        elif transformation_type == "uppercase":
            return data.upper()
        elif transformation_type == "lowercase":
            return data.lower()
        else:
            return data
    except Exception as e:
        print(f"Data transform failed: {e}")
        return ""
"""
        )

        // Calendar manipulation function
        let calendarFunction = CustomFunctionDefinition(
            name: "create_calendar_event",
            description: "Create a calendar event",
            parameters: ["title": "String", "description": "String", "date": "String"],
            returnType: "Bool",
            pythonHandler: """
def create_calendar_event(title: str, description: str, date: str) -> bool:
    try:
        # This would integrate with calendar system
        print(f"Creating event: {title} on {date}")
        return True
    except Exception as e:
        print(f"Calendar event creation failed: {e}")
        return False
"""
        )

        // Only add if not already registered
        if getCustomFunction(name: "send_email") == nil {
            registerCustomFunction(emailFunction)
        }
        if getCustomFunction(name: "send_slack_message") == nil {
            registerCustomFunction(slackFunction)
        }
        if getCustomFunction(name: "query_database") == nil {
            registerCustomFunction(dbFunction)
        }
        if getCustomFunction(name: "transform_data") == nil {
            registerCustomFunction(transformFunction)
        }
        if getCustomFunction(name: "create_calendar_event") == nil {
            registerCustomFunction(calendarFunction)
        }

        addLog("Initialized 5 default custom functions")
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
    var llmModel: String = "llama2" // Ollama model selection
    var llmTemperature: Double = 0.7
    var ollamaUrl: String = "http://localhost:11434" // Ollama server URL
    var agentCheckInterval: Int = 60
    var taskTimeoutSeconds: Int = 300
}

// MARK: - Data Models

// Task with full properties
struct TaskItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var status: String // pending, in_progress, blocked, completed
    var priority: String // low, medium, high
    var dueDate: Date?
    var tags: [String]
    var timeEstimate: Int? // hours
    var assignee: String?
    var workflowId: UUID? // linked workflow
    var dependencies: [UUID] // other task IDs
    var createdAt: Date
    var completedAt: Date?

    init(name: String, description: String = "", status: String = "pending", priority: String = "medium", createdAt: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.status = status
        self.priority = priority
        self.dueDate = nil
        self.tags = []
        self.timeEstimate = nil
        self.assignee = nil
        self.workflowId = nil
        self.dependencies = []
        self.createdAt = createdAt
        self.completedAt = nil
    }
}

// Workflow action types
enum WorkflowActionType: String, Codable {
    case apiCall = "api_call"
    case pythonScript = "python_script"
    case calendarEvent = "calendar_event"
    case notification = "notification"
    case llmCall = "llm_call"
    case customFunction = "custom_function"
}

// Workflow action/step
struct WorkflowAction: Identifiable, Codable {
    let id: UUID
    var type: WorkflowActionType
    var name: String
    var description: String
    var enabled: Bool
    var order: Int

    // API Call
    var apiUrl: String?
    var apiMethod: String? // GET, POST, PUT, DELETE
    var apiHeaders: [String: String]?
    var apiBody: String?

    // Python Script
    var scriptPath: String?
    var scriptArgs: [String]?

    // Calendar Event
    var calendarTitle: String?
    var calendarDescription: String?

    // Notification
    var notificationMessage: String?
    var notificationRecipient: String?

    // LLM Call
    var llmPrompt: String?
    var llmContext: String?

    // Custom Function
    var functionName: String?
    var functionParams: [String: String]?

    // Condition (optional)
    var conditionScript: String?

    init(type: WorkflowActionType, name: String, order: Int) {
        self.id = UUID()
        self.type = type
        self.name = name
        self.description = ""
        self.enabled = true
        self.order = order
    }
}

// Workflow with steps/actions
struct WorkflowItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var description: String
    var enabled: Bool
    var triggerType: String // manual, scheduled, event
    var triggerSchedule: String? // cron expression if scheduled
    var actions: [WorkflowAction]
    var notifyOnComplete: Bool
    var createdAt: Date

    init(name: String, description: String = "", enabled: Bool = true) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.enabled = enabled
        self.triggerType = "manual"
        self.triggerSchedule = nil
        self.actions = []
        self.notifyOnComplete = true
        self.createdAt = Date()
    }
}

// MARK: - GitHub API Models
struct GitHubRelease: Codable {
    let tag_name: String
    let name: String?
    let body: String?
    let assets: [GitHubAsset]?

    struct GitHubAsset: Codable {
        let name: String
        let browser_download_url: String
    }
}

// MARK: - Custom Functions
struct CustomFunctionDefinition: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let parameters: [String: String] // paramName: paramType
    let returnType: String
    let pythonHandler: String // Python function code

    init(name: String, description: String, parameters: [String: String], returnType: String = "Any", pythonHandler: String) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.parameters = parameters
        self.returnType = returnType
        self.pythonHandler = pythonHandler
    }
}

// MARK: - Workflow Execution Log
struct WorkflowExecutionLog: Identifiable, Codable {
    let id: UUID
    let workflowId: UUID
    let workflowName: String
    let startTime: Date
    var endTime: Date?
    var status: String // running, success, failed
    var actions: [ActionExecutionLog]
    var errorMessage: String?

    init(workflowId: UUID, workflowName: String) {
        self.id = UUID()
        self.workflowId = workflowId
        self.workflowName = workflowName
        self.startTime = Date()
        self.endTime = nil
        self.status = "running"
        self.actions = []
        self.errorMessage = nil
    }
}

struct ActionExecutionLog: Identifiable, Codable {
    let id: UUID
    let actionId: UUID
    let actionName: String
    let actionType: String
    let startTime: Date
    var endTime: Date?
    var status: String // running, success, failed
    var output: String?
    var errorMessage: String?

    init(actionId: UUID, actionName: String, actionType: String) {
        self.id = UUID()
        self.actionId = actionId
        self.actionName = actionName
        self.actionType = actionType
        self.startTime = Date()
        self.endTime = nil
        self.status = "running"
        self.output = nil
        self.errorMessage = nil
    }
}

// MARK: - Task Filtering
struct TaskFilter {
    var searchText: String = ""
    var statusFilter: [String] = [] // empty = all
    var priorityFilter: [String] = [] // empty = all
    var dueDateRange: (start: Date?, end: Date?) = (nil, nil)
    var tagsFilter: [String] = [] // empty = all (OR logic)
    var assigneeFilter: String? = nil

    func matches(_ task: TaskItem) -> Bool {
        // Search text in name or description
        if !searchText.isEmpty {
            let lowerSearch = searchText.lowercased()
            if !task.name.lowercased().contains(lowerSearch) &&
               !task.description.lowercased().contains(lowerSearch) {
                return false
            }
        }

        // Status filter
        if !statusFilter.isEmpty && !statusFilter.contains(task.status) {
            return false
        }

        // Priority filter
        if !priorityFilter.isEmpty && !priorityFilter.contains(task.priority) {
            return false
        }

        // Due date range
        if let start = dueDateRange.start, let dueDate = task.dueDate {
            if dueDate < start { return false }
        }
        if let end = dueDateRange.end, let dueDate = task.dueDate {
            if dueDate > end { return false }
        }

        // Tags filter (OR logic - has any of the tags)
        if !tagsFilter.isEmpty {
            let hasAnyTag = tagsFilter.contains { tag in task.tags.contains(tag) }
            if !hasAnyTag { return false }
        }

        // Assignee filter
        if let assignee = assigneeFilter {
            if task.assignee != assignee { return false }
        }

        return true
    }
}

// MARK: - Cron Scheduler
struct CronSchedule {
    let minute: String // 0-59 or *
    let hour: String // 0-23 or *
    let dayOfMonth: String // 1-31 or *
    let month: String // 1-12 or *
    let dayOfWeek: String // 0-6 or *

    init?(cronExpression: String) {
        let parts = cronExpression.split(separator: " ").map(String.init)
        guard parts.count == 5 else { return nil }

        self.minute = parts[0]
        self.hour = parts[1]
        self.dayOfMonth = parts[2]
        self.month = parts[3]
        self.dayOfWeek = parts[4]
    }

    func shouldRunNow() -> Bool {
        let now = Calendar.current.dateComponents([.minute, .hour, .day, .month, .weekday], from: Date())

        return matchesComponent(now.minute ?? 0, pattern: minute) &&
               matchesComponent(now.hour ?? 0, pattern: hour) &&
               matchesComponent(now.day ?? 0, pattern: dayOfMonth) &&
               matchesComponent(now.month ?? 0, pattern: month) &&
               matchesComponent((now.weekday ?? 1) - 1, pattern: dayOfWeek) // Convert to 0-6
    }

    private func matchesComponent(_ value: Int, pattern: String) -> Bool {
        if pattern == "*" { return true }

        // Handle ranges: 1-5
        if pattern.contains("-") {
            let parts = pattern.split(separator: "-").compactMap { Int($0) }
            if parts.count == 2 {
                return value >= parts[0] && value <= parts[1]
            }
        }

        // Handle steps: */15, 0-30/5
        if pattern.contains("/") {
            let parts = pattern.split(separator: "/").map(String.init)
            if parts.count == 2, let step = Int(parts[1]) {
                if parts[0] == "*" {
                    return value % step == 0
                }
            }
        }

        // Single value
        if let intValue = Int(pattern) {
            return value == intValue
        }

        return false
    }
}
