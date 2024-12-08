//
//  CityViewModel.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 29/11/2024.
//

//
//  PlaceViewModel.swift
//  PIB-Firebase
//
//  Created by Anvi Agarkar on 25/11/2024.
//

import Foundation
import FirebaseFirestore

@Observable
class CityViewModel {
    
    static func saveCity(city: City) async -> String? {
        let db = Firestore.firestore()
        
        if let id = city.id {
            // If the city already exists, update it
            do {
                try db.collection("cities").document(id).setData(from: city)
                print("😎 Data updated successfully!")
                
                // List of subcollections (food, shops, things-to-do)
                let categories = ["food", "shops", "things-to-do"]
                
                // Create empty documents for each category (just to initialize subcollections)
                for category in categories {
                    let categoryRef = db.collection("cities").document(id).collection(category).document()
                    
                    // You can optionally set some initial data for each category document if needed
                    try await categoryRef.setData([
                        "categoryName": category,
                        "cityID": id
                    ])
                }
                
                return id
            } catch {
                print("😡 ERROR: Could not update data \(error.localizedDescription)")
                return id
            }
        } else {
            // If the city doesn't exist, create a new city document
            do {
                let docRef = try db.collection("cities").addDocument(from: city)
                print("😎🐣 Data added successfully!")
                
                let cityID = docRef.documentID
                
                // List of subcollections (food, shops, things-to-do)
                let categories = ["food", "shops", "things-to-do"]
                
                // Create empty documents for each category (just to initialize subcollections)
                for category in categories {
                    let categoryRef = db.collection("cities").document(cityID).collection(category).document()
                    
                    // You can optionally set some initial data for each category document if needed
                    try await categoryRef.setData([
                        "categoryName": category,
                        "cityID": cityID
                    ])
                }
                
                return cityID
            } catch {
                print("😡 ERROR: Could not add city \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    static func deleteData(city: City) {
        let db = Firestore.firestore()
        guard let id = city.id else {
            print("😡 ERROR:  No city id")
            return
        }
        
        Task {
            do {
                try await db.collection("cities").document(id).delete()
            } catch {
                print("😡 ERROR: Could not delete document \(id). \(error.localizedDescription)")
            }
        }
    }
}
