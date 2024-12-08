//
//  ContentView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 26/11/2024.
//

//
//  ContentView.swift
//  PIB-Firebase
//
//  Created by Anvi Agarkar on 25/11/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CityListView: View {
    @FirestoreQuery(collectionPath: "cities") var cities: [City]
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ZStack {
                Color("main-bg").opacity(0.6)
                    .ignoresSafeArea()
                VStack {
                    Text("Which city do you want to explore today?")
                        .font(.title3)
                        .padding(.trailing)
                        .foregroundStyle(Color("navy"))
                    
                    List {
                        ForEach(cities) { city in
                            NavigationLink {
                                CategoryListView(cityID: city.id ?? "")
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(city.cityName)
                                        .font(.title)
                                    
                                    Text(city.country)
                                        .font(.title3)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    CityViewModel.deleteData(city: city)
                                }
                            }
                            
                        }
                    }
                    .listStyle(.plain)
                    .navigationTitle("Hi Traveller!")
                    
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Sign Out") {
                                do {
                                    try Auth.auth().signOut()
                                    print("🪵➡️ successful!")
                                    dismiss()
                                } catch {
                                    print("😡 ERROR: Could not sign out!")
                                }
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                sheetIsPresented.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                            
                            
                        }
                    }
                    .padding(.bottom)
                    .tint(Color("navy"))
                    .sheet(isPresented: $sheetIsPresented) {
                        NavigationStack {
                            CityDetailView(city: City())
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    CityListView()
}
