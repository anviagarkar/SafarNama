////
////  TTDViewModel.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 05/12/2024.
////
//
////
////  ThingsToDoViewModel.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 05/12/2024.
////
//
import Foundation
import FirebaseFirestore

@MainActor
@Observable
class TTDViewModel {
    
    static func saveThingToDo(cityID: String, categoryName: String, thingToDo: ThingToDo) async -> String? {
        let db = Firestore.firestore()
        let categoryPath = categoryName.lowercased() // 

        if let id = thingToDo.id {
            do {
                try db.collection("cities").document(cityID)
                    .collection("categories").document(categoryPath)
                    .collection("things-to-do").document(id)
                    .setData(from: thingToDo)
                print("✅ Thing to do updated successfully!")
                return id
            } catch {
                print("❌ ERROR: Could not update thing to do \(error.localizedDescription)")
                return nil
            }
        } else {
            do {
                let docRef = try db.collection("cities").document(cityID)
                                    .collection("categories").document(categoryPath)
                                    .collection("things-to-do").addDocument(from: thingToDo)
                print("✅ New thing to do added successfully!")
                return docRef.documentID
            } catch {
                print("❌ ERROR: Could not add thing to do \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteThingToDo(thingToDo: ThingToDo) async {
        guard let id = thingToDo.id, !thingToDo.categoryName.isEmpty, !thingToDo.cityID.isEmpty else {
            print("😡 ERROR: Missing categoryName or cityID.")
            return
        }
        
        let db = Firestore.firestore()
        let cityRef = db.collection("cities").document(thingToDo.cityID)
        let categoriesRef = cityRef.collection("categories").document(thingToDo.categoryName.lowercased())
        let thingsToDoRef = categoriesRef.collection("things-to-do")
        
        Task {
            do {
                try await thingsToDoRef.document(id).delete()
                print("✅ Thing to do deleted successfully!")
            } catch {
                print("😡 ERROR: Could not delete document \(id). \(error.localizedDescription)")
            }
        }
    }
}


