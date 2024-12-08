//
//  FoodDetailView.swift
//  SafarNama
//
//  Created by Anvi Agarkar on 02/12/2024.
//


import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Firebase

struct FoodDetailView: View {
    
    @State var food: Food
    @State private var selectedCuisine: String
    var cityID: String
    var categoryName: String
    @State private var photoSheetIsPresented = false
    @State private var showingAlert = false
    @State private var alertMessage = "Cannot add a photo unless you change a spot "
    let cuisineOptions = ["Italian", "Chinese", "Mexican", "Indian", "Japanese", "American"]
    @Environment(\.dismiss) private var dismiss
    
    init(food: Food, cityID: String, categoryName: String) {
        _food = State(initialValue: food)
        _selectedCuisine = State(initialValue: food.cuisineType.isEmpty ? "Italian" : food.cuisineType)
        self.cityID = cityID
        self.categoryName = categoryName
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Group {
                Text("Restaurant")
                    .bold()
                TextField("Enter restaurant name", text: $food.restaurant)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                
                Text("Cuisine Type")
                    .bold()
                
                Picker("Select Cuisine", selection: $selectedCuisine) {
                    ForEach(cuisineOptions, id: \.self) { cuisine in
                        Text(cuisine).tag(cuisine)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCuisine) { newValue in
                    food.cuisineType = newValue
                }
            }
            .padding(.top)
            
                
            Spacer()
            
                Button{
                    if food.id == nil {
                        showingAlert.toggle()
                    } else {
                        photoSheetIsPresented.toggle()
                    }
                } label: {
                    Image(systemName: "camera.fill")
                    Text("Add Photo")
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .frame(maxWidth: .infinity)
            
            
        }
        .padding()
        .font(.title2)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    Task {
                                guard let id = await FoodViewModel.saveFood(cityID: cityID, categoryName: categoryName, food: food) else {
                                    print("Error saving spot")
                                    return
                                }
                                food.id = id 
                                dismiss()
                            }
                    dismiss()
                }
            }
        }
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                Task {
                    guard let  id = await FoodViewModel.saveFood(cityID: cityID, categoryName: categoryName, food: food)
                    else {
                        print("ERROR")
                        return
                    }
                    food.id = id
                    photoSheetIsPresented.toggle()
                }
                
                
            }
        }
        .fullScreenCover(isPresented: $photoSheetIsPresented) {
            PhotoView(food: food, cityID: cityID, categoryName: categoryName)
        }
    }
}
#Preview {
    NavigationStack {
        FoodDetailView(food: Food(), cityID: "SampleCity", categoryName: "Food")
    }
}
