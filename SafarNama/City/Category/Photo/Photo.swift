//
//  Photo.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 06/12/2024.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class Photo: Identifiable, Codable {
    @DocumentID var id: String?
    var imageURLString = ""
    var description = ""
    
    init(id: String? = nil, imageURLString: String = "", description: String = "") {
        self.id = id
        self.imageURLString = imageURLString
        self.description = description
    }
}

extension Photo {
    static var preview: Photo {
        let newPhoto = Photo(
            id: "1",
            imageURLString: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Tandoorimumbai.jpg/480px-Tandoorimumbai.jpg",
            description: "Chicken Tikka"
        )
        return newPhoto
    }
  
}
