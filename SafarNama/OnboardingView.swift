//
//  OnboardingView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 23/06/2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        ZStack {
            // Background colour changes per page
            (currentPage == 0 ? AppTheme.Colour.homeBackground : AppTheme.Colour.background)
                .ignoresSafeArea()
                .animation(.easeInOut, value: currentPage)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button {
                        hasSeenOnboarding = true
                    } label: {
                        Text("skip")
                            .font(AppTheme.Font.handwritingSmall)
                            .foregroundStyle(AppTheme.Colour.inkLight)
                    }
                    .padding(.horizontal, AppTheme.Spacing.md)
                    .padding(.top, AppTheme.Spacing.md)
                }

                // Page content
                TabView(selection: $currentPage) {
                    OnboardingPage1()
                        .tag(0)
                    OnboardingPage2(hasSeenOnboarding: $hasSeenOnboarding)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<2, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage
                                ? AppTheme.Colour.stampGreen
                                : AppTheme.Colour.inkLight.opacity(0.3)
                            )
                            .frame(width: 8, height: 8)
                            .onTapGesture {
                                withAnimation {
                                    currentPage = index
                                }
                            }
                    }
                }
                .padding(.bottom, AppTheme.Spacing.xl)
            }
        }
    }
}

// MARK: - Page 1

struct OnboardingPage1: View {
    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            // App icon placeholder + name
            VStack(spacing: AppTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(AppTheme.Colour.surface)
                        .frame(width: 100, height: 100)
                        .shadow(color: AppTheme.Colour.inkDark.opacity(0.1), radius: 10)
                    Image(systemName: "book.pages")
                        .font(.system(size: 44))
                        .foregroundStyle(AppTheme.Colour.inkDark)
                }

                Text("Safarnama")
                    .font(AppTheme.Font.displayLarge)
                    .foregroundStyle(AppTheme.Colour.inkDark)

                Text("your travel diary")
                    .font(AppTheme.Font.handwritingLarge)
                    .foregroundStyle(AppTheme.Colour.inkLight)
            }

            Spacer()

            // Stamp stat hint
            VStack(spacing: AppTheme.Spacing.sm) {
                StampStatView(count: 0, label: "countries")

                Text("every place you add\ncounts towards your collection")
                    .font(AppTheme.Font.handwritingSmall)
                    .foregroundStyle(AppTheme.Colour.inkLight)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Next button
            Button {
                withAnimation {
                    // handled by swipe or dot tap
                }
            } label: {
                Text("see how it works →")
                    .font(AppTheme.Font.handwritingMedium)
                    .foregroundStyle(AppTheme.Colour.inkDark)
            }
            .padding(.bottom, AppTheme.Spacing.lg)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}

// MARK: - Page 2

struct OnboardingPage2: View {
    @Binding var hasSeenOnboarding: Bool

    // Dummy data for preview
    let dummyCountry = DummyCountry()

    var body: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Text("Simple by design")
                .font(AppTheme.Font.displayMedium)
                .foregroundStyle(AppTheme.Colour.inkDark)
                .multilineTextAlignment(.center)

            Text("add a country, then a city,\nthen start logging your favourite spots")
                .font(AppTheme.Font.handwritingMedium)
                .foregroundStyle(AppTheme.Colour.inkLight)
                .multilineTextAlignment(.center)

            // Fanned card preview
            ZStack {
                // Entry row (bottom)
                dummyEntryCard
                    .offset(x: 20, y: 20)
                    .rotationEffect(.degrees(4))

                // City card (middle)
                dummyCityCard
                    .offset(x: 10, y: 10)
                    .rotationEffect(.degrees(2))

                // Country card (top)
                dummyCountryCard
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            Spacer()

            // Feature rows
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                featureRow(icon: "fork.knife", text: "food, places, shops — all organised")
                featureRow(icon: "mappin.circle", text: "save a location to every entry")
                featureRow(icon: "map", text: "see your journey on a map")
            }
            .padding(.horizontal, AppTheme.Spacing.lg)

            Spacer()

            // Start button
            Button {
                hasSeenOnboarding = true
            } label: {
                Text("Start my diary →")
                    .font(AppTheme.Font.handwritingMedium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.Colour.stampGreen)
                    .cornerRadius(AppTheme.Radius.lg)
            }
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.bottom, AppTheme.Spacing.lg)
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.Colour.stampGreen)
                .frame(width: 24)
            Text(text)
                .font(AppTheme.Font.handwritingMedium)
                .foregroundStyle(AppTheme.Colour.inkMedium)
        }
    }

    // Dummy cards
    private var dummyCountryCard: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(Color(hex: "C8D8C0"))
                .frame(width: 4)
                .cornerRadius(2)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("🇮🇪 Ireland")
                        .font(AppTheme.Font.displaySmall)
                        .foregroundStyle(AppTheme.Colour.inkDark)
                    Text("3 cities · 12 places")
                        .font(AppTheme.Font.handwritingSmall)
                        .foregroundStyle(AppTheme.Colour.inkLight)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.4))
                    .font(.system(size: 12))
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.vertical, AppTheme.Spacing.sm)
        }
        .background(AppTheme.Colour.surface)
        .cornerRadius(AppTheme.Radius.lg)
        .shadow(color: AppTheme.Colour.inkDark.opacity(0.08), radius: 6, y: 2)
    }

    private var dummyCityCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dublin")
                    .font(AppTheme.Font.displaySmall)
                    .foregroundStyle(AppTheme.Colour.inkDark)
                Text("6 entries")
                    .font(AppTheme.Font.handwritingSmall)
                    .foregroundStyle(AppTheme.Colour.inkLight)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(AppTheme.Colour.inkLight.opacity(0.4))
                .font(.system(size: 12))
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colour.surface)
        .cornerRadius(AppTheme.Radius.lg)
        .shadow(color: AppTheme.Colour.inkDark.opacity(0.08), radius: 6, y: 2)
    }

    private var dummyEntryCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "fork.knife")
                .foregroundStyle(Color(hex: "3A6040"))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text("Paulie's Pizza")
                    .font(AppTheme.Font.displaySmall)
                    .foregroundStyle(AppTheme.Colour.inkDark)
                Text("Italian · ★★★★★")
                    .font(AppTheme.Font.handwritingSmall)
                    .foregroundStyle(AppTheme.Colour.inkLight)
            }
            Spacer()
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .background(AppTheme.Colour.surface)
        .cornerRadius(AppTheme.Radius.lg)
        .shadow(color: AppTheme.Colour.inkDark.opacity(0.08), radius: 6, y: 2)
    }
}

struct DummyCountry {}
