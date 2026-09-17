import Foundation
import SwiftUI
import Combine

class ScrcpyManager: ObservableObject {
    @Published var isRunning = false
    @Published var statusMessage = "Idle"
    @Published var showErrorAlert = false
    @Published var errorMessage = ""
    
    private var process: Process?
    
    func startMirroring(ipAddress: String? = nil) {
        guard !isRunning else { return }
        
        let task = Process()
        
        // Find scrcpy binary path
        let fm = FileManager.default
        let armPath = "/opt/homebrew/bin/scrcpy"
        let intelPath = "/usr/local/bin/scrcpy"
        
        guard let binaryPath = [armPath, intelPath].first(where: { fm.fileExists(atPath: $0) }) else {
            self.errorMessage = "scrcpy binary not found. Please install via 'brew install scrcpy'."
            self.showErrorAlert = true
            return
        }
        
        task.executableURL = URL(fileURLWithPath: binaryPath)
        
        // Pass system environment PATH so scrcpy can find adb
        var environment = ProcessInfo.processInfo.environment
        let currentPath = environment["PATH"] ?? ""
        environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:\(currentPath)"
        task.environment = environment
        
        var args: [String] = []
        if let ip = ipAddress, !ip.trimmingCharacters(in: .whitespaces).isEmpty {
            args.append(contentsOf: ["--tcpip=\(ip)"])
        }
        task.arguments = args
        
        // Capture error output to diagnose failures
        let errorPipe = Pipe()
        task.standardError = errorPipe
        
        task.terminationHandler = { [weak self] process in
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorString = String(data: errorData, encoding: .utf8) ?? ""
            
            DispatchQueue.main.async {
                self?.isRunning = false
                
                if process.terminationStatus != 0 {
                    print("scrcpy error log: \(errorString)") // Check Xcode Console
                    self?.statusMessage = "Connection Failed"
                    self?.errorMessage = "Connection Failed. Ensure ADB is authorized or pair via USB first.\n\nDetails: \(errorString.prefix(150))"
                    self?.showErrorAlert = true
                } else {
                    self?.statusMessage = "Mirroring Stopped"
                }
            }
        }
        
        do {
            try task.run()
            self.process = task
            self.isRunning = true
            self.statusMessage = "Mirroring Active"
        } catch {
            self.isRunning = false
            self.statusMessage = "Execution Failed"
            self.errorMessage = "Failed to launch process: \(error.localizedDescription)"
            self.showErrorAlert = true
        }
    }
    
    func stopMirroring() {
        process?.terminate()
        process = nil
        isRunning = false
        statusMessage = "Stopped"
    }
}
