import SwiftUI

struct ContentView: View {
    @StateObject private var vpnManager = VPNManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("VPN Status: \(statusString)")
                .font(.headline)
            Button(action: {
                vpnManager.connect()
            }) {
                Text("Connect VPN")
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            Button(action: {
                vpnManager.disconnect()
            }) {
                Text("Disconnect VPN")
                    .frame(width: 200, height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private var statusString: String {
        switch vpnManager.status {
            case .invalid: return "Invalid"
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting"
            case .connected: return "Connected"
            case .reasserting: return "Reasserting"
            case .disconnecting: return "Disconnecting"
            @unknown default: return "Unknown"
        }
    }
}

#Preview {
    ContentView()
}
