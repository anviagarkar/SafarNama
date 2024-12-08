//
//  CityDetailView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 29/11/2024.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CityDetailView: View {
    @State var city: City
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("City")
                .bold()
                .foregroundStyle(Color("navy"))
            TextField("city", text: $city.cityName)
                .textFieldStyle(.roundedBorder)
            
            Text("Country")
                .bold()
                .foregroundStyle(Color("navy"))
            TextField("country", text: $city.country)
                .textFieldStyle(.roundedBorder)
            
            Spacer()
            
        }
        .padding(.horizontal)
        .font(.title)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Save") {
                    Task {
                        if let cityID = await  CityViewModel.saveCity(city: city) {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    CityDetailView(city: City())
}
