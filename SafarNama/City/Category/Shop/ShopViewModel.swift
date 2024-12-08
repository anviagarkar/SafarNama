////
////  ShopViewModel.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 05/12/2024.
////
//
import Foundation
import FirebaseFirestore

@MainActor
@Observable
class ShopViewModel {
    
    static func saveShop(cityID: String, categoryName: String, shop: Shop) async -> String?  {
        let db = Firestore.firestore()
        let categoryPath = categoryName.lowercased()
        
        if let id = shop.id {
            do {
                try db.collection("cities").document(cityID)
                    .collection("categories").document(categoryPath)
                    .collection("shop").document(id)
                    .setData(from: shop)
                print("🍴 Food updated successfully!")
                return id
            } catch {
                print("❌ ERROR: Could not update food \(error.localizedDescription)")
                return nil
            }
        } else {
            do {
                let docRef = try db.collection("cities").document(cityID)
                                    .collection("categories").document(categoryPath)
                                    .collection("shop") 
                                    .addDocument(from: shop)
                return docRef.documentID
            } catch {
                print("❌ ERROR: Could not add food \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteShop(shop: Shop) async {
        guard let id = shop.id, !shop.categoryName.isEmpty, !shop.cityID.isEmpty else {
            print("😡 ERROR: Missing category ID or cityID.")
            return
        }
        
        let db = Firestore.firestore()
        let cityRef = db.collection("cities").document(shop.cityID)
        let categoriesRef = cityRef.collection("categories").document(shop.categoryName.lowercased())
        let shopsRef = categoriesRef.collection("shop")
        
        Task {
            do {
                try await shopsRef.document(id).delete()
                print("🍴 Food deleted successfully!")
            } catch {
                print("😡 ERROR: Could not delete document \(id). \(error.localizedDescription)")
            }
        }
    }
}

