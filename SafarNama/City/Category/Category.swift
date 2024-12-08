//
//  Category.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 02/12/2024.
//

import Foundation
import FirebaseFirestore

struct Category: Codable, Identifiable {
    @DocumentID var id: String?
    var categoryName: String = ""
    var cityID: String = ""
    
    init(categoryName: String, cityID: String) {
        self.categoryName = categoryName
        self.cityID = cityID
    }
}
