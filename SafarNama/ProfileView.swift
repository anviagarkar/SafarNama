import SwiftUI
import SwiftData

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var countries: [Country]
    @State private var showingLogoutConfirm = false
    @State private var isSyncing = false
    @State private var syncMessage: String? = nil
    @State private var showingDeleteAccountConfirm = false
    @State private var isDeletingAccount = false

    var totalCountries: Int { countries.count }
    var totalCities: Int { countries.reduce(0) { $0 + $1.cities.count } }
    var totalEntries: Int {
        countries.reduce(0) { total, country in
            total + country.cities.reduce(0) { $0 + $1.entries.count }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.Colour.stampGreen)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(authViewModel.currentName ?? "Unknown")
                                .font(AppTheme.Font.displaySmall)
                                .foregroundStyle(AppTheme.Colour.inkDark)
                            Text(authViewModel.currentEmail ?? "")
                                .font(AppTheme.Font.handwritingSmall)
                                .foregroundStyle(AppTheme.Colour.inkLight)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Your Travels") {
                    HStack {
                        VStack(spacing: 2) {
                            Text("\(totalCountries)")
                                .font(AppTheme.Font.displayMedium)
                                .foregroundStyle(AppTheme.Colour.stampGreen)
                            Text("Countries")
                                .font(AppTheme.Font.handwritingSmall)
                                .foregroundStyle(AppTheme.Colour.inkLight)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 2) {
                            Text("\(totalCities)")
                                .font(AppTheme.Font.displayMedium)
                                .foregroundStyle(AppTheme.Colour.stampGreen)
                            Text("Cities")
                                .font(AppTheme.Font.handwritingSmall)
                                .foregroundStyle(AppTheme.Colour.inkLight)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 2) {
                            Text("\(totalEntries)")
                                .font(AppTheme.Font.displayMedium)
                                .foregroundStyle(AppTheme.Colour.stampGreen)
                            Text("Entries")
                                .font(AppTheme.Font.handwritingSmall)
                                .foregroundStyle(AppTheme.Colour.inkLight)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                }

                Section("Backup") {
                    Button {
                        Task {
                            isSyncing = true
                            syncMessage = nil
                            do {
                                try await SyncService.push(modelContext: modelContext)
                                syncMessage = "Backup successful"
                            } catch {
                                syncMessage = "Backup failed: \(error)"
                            }
                            isSyncing = false
                        }
                    } label: {
                        if isSyncing {
                            ProgressView()
                        } else {
                            Text("Backup Now")
                        }
                    }
                    .disabled(isSyncing)

                    if let message = syncMessage {
                        Text(message)
                            .font(AppTheme.Font.handwritingSmall)
                            .foregroundStyle(message.contains("failed") ? .red : AppTheme.Colour.stampGreen)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingLogoutConfirm = true
                    } label: {
                        Text("Log Out")
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showingDeleteAccountConfirm = true
                    } label: {
                        if isDeletingAccount {
                            ProgressView()
                        } else {
                            Text("Delete Account")
                        }
                    }
                    .disabled(isDeletingAccount)
                } footer: {
                    Text("This permanently deletes your account and all your travel data. This cannot be undone.")
                        .font(AppTheme.Font.handwritingSmall)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Log out?", isPresented: $showingLogoutConfirm) {
                Button("Log Out", role: .destructive) {
                    Task {
                        await authViewModel.logout(modelContext: modelContext)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert("Delete your account?", isPresented: $showingDeleteAccountConfirm) {
                Button("Delete", role: .destructive) {
                    Task {
                        isDeletingAccount = true
                        _ = await authViewModel.deleteAccount(modelContext: modelContext)
                        isDeletingAccount = false
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete your account and all your data. This action cannot be undone.")
            }
        }
    }
}
