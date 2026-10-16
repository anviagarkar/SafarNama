import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    // TEMPORARY — testing SyncStatus. Safe to delete once confirmed working.
    @ObservedObject private var syncStatus = SyncStatus.shared
    // Referencing .shared here is what starts the monitor at launch —
    // it needs to live somewhere that stays alive for the whole app.
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                if authViewModel.justSignedUp {
                    OnboardingView(hasSeenOnboarding: Binding(
                        get: { !authViewModel.justSignedUp },
                        set: { seen in authViewModel.justSignedUp = !seen }
                    ))
                } else {
                    HomeView(authViewModel: authViewModel)
                }
            } else {
                LoginView(authViewModel: authViewModel)
            }
        }
        // TEMPORARY — testing SyncStatus. Safe to delete once confirmed working.
        .overlay(alignment: .top) {
            if syncStatus.isSyncing {
                Text("Syncing…")
                    .font(.caption)
                    .padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
            } else if syncStatus.lastError != nil {
                // Your edit is already saved locally regardless of this —
                // this just means it hasn't reached the backend yet. Worded
                // (and colored) to say that, rather than implying data loss.
                Text("Saved locally — will sync when online")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(Color.orange, in: Capsule())
            }
        }
    }
}

#Preview {
    ContentView()
}
