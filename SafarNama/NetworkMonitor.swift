import Foundation
import Network
import SwiftData
import Combine

// Watches for the device coming back online and automatically retries a
// push if the last sync attempt failed — so a user who edits something
// offline doesn't have to make another edit just to trigger a retry.
//
// Reference NetworkMonitor.shared somewhere that's always alive (e.g.
// ContentView, via @ObservedObject) so init() runs once at launch and the
// monitor starts watching immediately.
@MainActor
final class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    @Published private(set) var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "SafarNama.NetworkMonitor")
    private var wasConnected: Bool = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            let connected = path.status == .satisfied
            Task { @MainActor in
                guard let self else { return }
                let justReconnected = connected && !self.wasConnected
                self.wasConnected = connected
                self.isConnected = connected

                // Only retry if we actually have a failed sync waiting and a
                // ModelContext to retry it with — otherwise this would fire
                // a push on every network blip for no reason.
                if justReconnected,
                   SyncStatus.shared.lastError != nil,
                   let context = SyncStatus.shared.pendingModelContext {
                    SyncService.autoPushIfLoggedIn(modelContext: context)
                }
            }
        }
        monitor.start(queue: queue)
    }
}
