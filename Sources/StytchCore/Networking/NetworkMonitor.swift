import Network

class NetworkMonitor {
    private var monitor: NWPathMonitor
    private let queue = DispatchQueue.global(qos: .background)

    // We want to have an optional Bool here becuase we dont want to assume any state at startup
    var isConnected: Bool?

    init() {
        monitor = NWPathMonitor()
        startMonitoring()
    }

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            if path.status == .satisfied {
                // We only want to call StartupClient.start() if we were offline and then came online
                // Therefore `isConnected` would not be nil having been previously set as false
                if let isConnected = self?.isConnected, isConnected == false {
                    Task {
                        try await StartupClient.start()
                    }
                }
                self?.isConnected = true
            } else {
                self?.isConnected = false
            }
        }
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    private func getConnectionType(_ path: NWPath) -> String {
        if path.usesInterfaceType(.wifi) {
            return "WiFi"
        } else if path.usesInterfaceType(.cellular) {
            return "Cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            return "Wired Ethernet"
        } else if path.usesInterfaceType(.loopback) {
            return "Loopback"
        } else {
            return "Unknown"
        }
    }
}
