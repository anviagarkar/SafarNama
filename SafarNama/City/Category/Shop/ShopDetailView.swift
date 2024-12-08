////
////  ShopDetailView.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 05/12/2024.
////
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ShopDetailView: View {
    @State var shop: Shop
    var cityID: String
    var categoryName: String
    @State private var description = ""
    @Environment(\.dismiss) private var dismiss
    
    init(shop: Shop, cityID: String, categoryName: String) {
        _shop = State(initialValue: shop)
        self.cityID = cityID
        self.categoryName = categoryName
        _description = State(initialValue: description)
        
        }
    
    var body: some View {
        VStack {
            Text("Shop Name")
                .bold()
            TextField("shop", text: $shop.shopName)
                .textFieldStyle(.roundedBorder)
            
            Text("Description")
                .bold()
            TextField("tell us about the shop", text: $shop.description)
                .onChange(of: description) { newValue in
                    shop.description = newValue
                }
            
            Spacer()
        }
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
                        let _ = await
                        ShopViewModel.saveShop(cityID: cityID, categoryName: categoryName, shop: shop)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShopDetailView(shop: Shop(), cityID: "sample", categoryName: "SAMPLE")
    }
    
}
