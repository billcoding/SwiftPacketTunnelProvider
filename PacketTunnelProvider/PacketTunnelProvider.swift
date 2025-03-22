import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {
    override func startTunnel(options: [String: NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        NSLog("PacketTunnelProvider>>>>>>>>PacketTunnelProvider")
        let config = options?["Config"] as? String ?? "No Config"
        print("Starting tunnel with config: \(config)")
        
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        settings.mtu = 1500
        
        let ipv4Settings = NEIPv4Settings(addresses: ["192.168.1.2"], subnetMasks: ["255.255.255.0"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        settings.ipv4Settings = ipv4Settings
        
        let dnsSettings = NEDNSSettings(servers: ["8.8.8.8", "8.8.4.4"])
        settings.dnsSettings = dnsSettings
        
        setTunnelNetworkSettings(settings) { error in
            if let error {
                print("Failed to set tunnel settings: \(error)")
                completionHandler(error)
                return
            }
            print("Tunnel settings applied successfully")
            self.startHandlingPackets()
            completionHandler(nil)
        }
    }
    
    private func startHandlingPackets() {
        print("Starting packet handling")
        packetFlow.readPackets { packets, protocols in
            for (index, packet) in packets.enumerated() {
                print("Received packet: \(packet.count) bytes, protocol: \(protocols[index])")
                self.packetFlow.writePackets([packet], withProtocols: [protocols[index]])
            }
            self.startHandlingPackets()
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        print("Stopping tunnel with reason: \(reason)")
        completionHandler()
    }
}
