////
////  ThingsToDo.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 05/12/2024.
////
import Foundation
import FirebaseFirestore

struct ThingToDo: Codable, Identifiable{
    @DocumentID var id: String?
    var activityName: String = ""
    var description: String = ""
    var cityID: String = ""
    var categoryName: String = ""
}
