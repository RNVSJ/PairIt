import SwiftUI

struct ContentView: View {
    @StateObject private var scrcpy = ScrcpyManager()
    @State private var deviceIP: String = ""

    var body: some View {
        VStack(spacing: 20) {
            HeaderView
            
            Divider()
            
            IPInputSection
            
            ControlButtons
            
            StatusFooter
        }
        .padding(30)
        .frame(width: 400, height: 260)
        .alert("Error", isPresented: $scrcpy.showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(scrcpy.errorMessage)
        }
    }
    
    private var HeaderView: some View {
        VStack(spacing: 4) {
            Text("PairIt")
                .font(.system(size: 28, weight: .bold))
            Text("An app to mirror your Android device to macOS.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var IPInputSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Wireless Debugging IP (Optional)")
                .font(.caption)
                .foregroundColor(.secondary)
            TextField("e.g. 192.168.1.50", text: $deviceIP)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(scrcpy.isRunning)
        }
    }
    
    private var ControlButtons: some View {
        HStack(spacing: 16) {
            if scrcpy.isRunning {
                Button(action: { scrcpy.stopMirroring() }) {
                    Label("Stop Mirroring", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            } else {
                Button(action: { scrcpy.startMirroring(ipAddress: deviceIP) }) {
                    Label("Start Mirroring", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
        }
    }
    
    private var StatusFooter: some View {
        HStack {
            Circle()
                .fill(scrcpy.isRunning ? Color.green : Color.gray)
                .frame(width: 8, height: 8)
            Text(scrcpy.statusMessage)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}
