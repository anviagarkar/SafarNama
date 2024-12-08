////
////  ShopListView.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 05/12/2024.
////
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ShopListView: View {
    @State var cityID: String
    @State var categoryName: String
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    @State private var shops: [Shop] = []
    
    func loadShops() {
        let db = Firestore.firestore()
        let path = "cities/\(cityID)/categories/\(categoryName.lowercased())/shop"
        
        db.collection(path).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching food data: \(error.localizedDescription)")
            } else {
                shops = snapshot?.documents.compactMap { document in
                    try? document.data(as: Shop.self)
                } ?? []
                print("Loaded \(shops.count) food items.")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color("shop"))
                    .ignoresSafeArea()
                VStack {
                    Text("diary of a shopaholic")
                        .font(.custom("Playfair Display", size: 30))
                        .fontWeight(.bold)
                        .padding()
                    
                    List {
                        ForEach(shops) { shop in
                            NavigationLink {
                                ShopDetailView(shop: shop, cityID: cityID, categoryName: categoryName)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(shop.shopName)
                                        .font(.headline)
                                    
                                    Text(shop.description)
                                        .font(.title3)
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    Task {
                                        await deleteShop(shop: shop)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onAppear {
                        loadShops()
                    }
                    .navigationTitle("Shops")
                    
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                sheetIsPresented.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $sheetIsPresented) {
                        NavigationStack {
                            ShopDetailView(shop: Shop(), cityID: cityID, categoryName: categoryName)
                                .onDisappear {
                                    loadShops()
                                }
                        }
                    }
                }
            }
            
        }
    }
    func deleteShop(shop: Shop) async {
        guard let shopID = shop.id else { return }
        let db = Firestore.firestore()
        let path = "cities/\(cityID)/categories/\(categoryName.lowercased())/shops/\(shopID)"
        
        do {
            try await db.document(path).delete()
            shops.removeAll { $0.id == shopID } // Update local list
            print("Deleted food with ID: \(shopID)")
        } catch {
            print("Error deleting food: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ShopListView(cityID: "sample", categoryName: "shops")
}


