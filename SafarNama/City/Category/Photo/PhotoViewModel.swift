//
//  PhotoViewModel.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 06/12/2024.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage
import SwiftUI

class PhotoViewModel {
    
    static func saveImage(cityID: String, categoryName: String, food: Food, photo: Photo, data: Data) async {
        guard let foodID = food.id else {
            print("Error: Food ID is nil")
            return
        }
        
        let storage = Storage.storage().reference()
        let metadata = StorageMetadata()
        
        if photo.id == nil {
            photo.id = UUID().uuidString
        }
        metadata.contentType = "image/jpeg"
        let path = "cities/\(cityID)/categories/\(categoryName)/food/\(foodID)/photos/\(photo.id ?? "n/a")"
        
        do {
            let storageRef = storage.child(path)
            _ = try await storageRef.putDataAsync(data, metadata: metadata)
            print("Image uploaded to storage.")
            
            guard let url = try? await storageRef.downloadURL() else {
                print("Could not get download URL.")
                return
            }
            
            photo.imageURLString = url.absoluteString
            
            let db = Firestore.firestore()
            do {
                try db.collection("cities")
                    .document(cityID)
                    .collection("categories")
                    .document(categoryName)
                    .collection("food")
                    .document(foodID)
                    .collection("photos")
                    .document(photo.id ?? "n/a")
                    .setData(from: photo)
                print("Photo metadata saved to Firestore.")
            } catch {
                print("Error saving photo metadata to Firestore: \(error)")
            }
        } catch {
            print("Error uploading image to storage: \(error)")
        }
    }


}
