//
//  FoodViewModel.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 04/12/2024.
//

import Foundation
import FirebaseFirestore

@MainActor
@Observable
class FoodViewModel {
    
    static func saveFood(cityID: String, categoryName: String, food: Food) async -> String? {
        let db = Firestore.firestore()
        let categoryPath = categoryName.lowercased()

        if let id = food.id {
            // Update the existing food item
            do {
                try db.collection("cities").document(cityID)
                    .collection("categories").document(categoryPath)
                    .collection("food")
                    .document(id)
                    .setData(from: food)
                print("🍴 Food updated successfully!")
                return id
            } catch {
                print("❌ ERROR: Could not update food \(error.localizedDescription)")
                return nil
            }
        } else {
            // Add a new food item
            do {
                let docRef = try db.collection("cities").document(cityID)
                    .collection("categories").document(categoryPath)
                                    .collection("food") 
                                    .addDocument(from: food)
                print("🍴 New food item added successfully!")
                return docRef.documentID
            } catch {
                print("❌ ERROR: Could not add food \(error.localizedDescription)")
                return nil
            }
        }
    }

    
    static func deleteFood(food: Food) async {
            guard let id = food.id, !food.categoryName.isEmpty, !food.cityID.isEmpty else {
                print("😡 ERROR: Missing categoryName or cityID.")
                return
            }
            
            let db = Firestore.firestore()
            let cityRef = db.collection("cities").document(food.cityID)
            let categoriesRef = cityRef.collection("categories").document(food.categoryName.lowercased())
            let foodsRef = categoriesRef.collection("food")
            
            Task {
                do {
                    try await foodsRef.document(id).delete()
                    print("🍴 Food deleted successfully!")
                } catch {
                    print("😡 ERROR: Could not delete document \(id). \(error.localizedDescription)")
                }
            }
        }
}

