import NetworkExtension
import SwiftUI

class VPNManager: ObservableObject {
    @Published var status: NEVPNStatus = .invalid
    private var manager: NETunnelProviderManager
    
    init() {
        manager = NETunnelProviderManager()
        setupStatusObserver()
        loadVPNManager()
    }
    
    private func setupStatusObserver() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.NEVPNStatusDidChange,
            object: manager.connection,
            queue: .main
        ) { _ in
            self.updateStatus()
        }
    }
    
    func loadVPNManager() {
        NETunnelProviderManager.loadAllFromPreferences { managers, error in
            if let error {
                print("Failed to load configurations: \(error)")
                self.setupNewManager()
                return
            }
            if let existingManager = managers?.first {
                self.manager = existingManager
                print("Loaded existing manager, enabled: \(existingManager.isEnabled)")
            } else {
                self.setupNewManager()
            }
            self.updateStatus()
        }
    }
    
    private func setupNewManager() {
        let protocolConfig = NETunnelProviderProtocol()
        protocolConfig.providerBundleIdentifier = "me.app.myapp01.PacketTunnelProvider"
        protocolConfig.serverAddress = "127.0.0.1"
        manager.protocolConfiguration = protocolConfig
        manager.localizedDescription = "My VPN"
        manager.isEnabled = true
        
        Task {
            do {
                try await manager.saveToPreferences()
                try await manager.loadFromPreferences()
                self.updateStatus()
            } catch {
                print("Setup error: \(error)")
            }
        }
    }
    
    func connect() {
        Task {
            do {
                try await manager.loadFromPreferences()
                print("Starting VPN tunnel")
                try manager.connection.startVPNTunnel(options: ["Config": "SampleConfig" as NSString])
                self.updateStatus()
            } catch {
                print("Connect error: \(error)")
            }
        }
    }
    
    func disconnect() {
        manager.connection.stopVPNTunnel()
        updateStatus()
    }
    
    private func updateStatus() {
        DispatchQueue.main.async {
            self.status = self.manager.connection.status
            print("VPN Status updated: \(self.status.rawValue)")
        }
    }
}
