import Foundation

// Single source of truth for the backend URL. Previously AuthService.swift
// and SyncService.swift each hardcoded their own copy of this and had
// drifted apart (one pointed at safarnama-backend.onrender.com, the other
// at safarnama-backend-71sf.onrender.com) — confirmed against the Render
// dashboard that -71sf is the actual live service, so that's the one kept
// here. If the backend ever moves again, this is the only place to change.
enum APIConfig {
    static let baseURL = "https://safarnama-backend-71sf.onrender.com"
}
