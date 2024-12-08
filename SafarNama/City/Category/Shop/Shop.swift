////
////  Shop.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 04/12/2024.
////

import Foundation
import FirebaseFirestore

struct Shop: Codable, Identifiable {
    @DocumentID var id: String?
    var shopName: String = ""
    var description: String = ""
    var cityID: String = ""
    var categoryName: String = ""
}


