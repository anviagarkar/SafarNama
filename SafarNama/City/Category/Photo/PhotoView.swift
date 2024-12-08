//
//  PhotoView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 06/12/2024.
//

import SwiftUI
import PhotosUI

struct PhotoView: View {
    @State var food: Food
    var cityID: String
    var categoryName: String
    @State private var photo = Photo()
    @State private var data = Data()
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var pickerIsPresented = false
    @State private var selectedImage = Image(systemName: "photo")
    @Environment(\.dismiss) private var dismiss
    
    
    var body: some View {
        NavigationStack {
            
            selectedImage
                .resizable()
                .scaledToFit()
            
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Save") {
                            Task {
                                await PhotoViewModel.saveImage(
                                    cityID: cityID,
                                    categoryName: categoryName,
                                    food: food,
                                    photo: photo,
                                    data: data
                                )
                                dismiss()

                            }
                        }
                    }
                }
                .photosPicker(isPresented: $pickerIsPresented, selection: $selectedPhoto)
                .onChange(of: selectedPhoto) {
                    Task {
                        do {
                            if let image = try await selectedPhoto?.loadTransferable(type: Image.self) {
                                selectedImage = image
                            }
                            
                            guard let transferData = try await selectedPhoto?.loadTransferable(type: Data.self) else {
                                print("Could not convert data")
                                return
                            }
                            data = transferData
                        } catch {
                            print("Error: Could not create image")
                        }
                    }
                    
                }
        }
        .padding()
    }
}

#Preview {
    PhotoView(food: Food(), cityID: "sample", categoryName: "sample")
}
