//
//  Food.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 03/12/2024.
//

import Foundation
import FirebaseFirestore

struct Food: Codable, Identifiable {
    @DocumentID var id: String?
    var restaurant: String = ""
    var cuisineType: String = ""
    var cityID: String = ""
    var categoryName: String = ""
}

