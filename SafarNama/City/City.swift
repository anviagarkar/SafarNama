//
//  City.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 29/11/2024.
//

import Foundation
import FirebaseFirestore

struct City: Codable, Identifiable{
    @DocumentID var id: String?
    var cityName = ""
    var country = ""
    var flag = ""
}
