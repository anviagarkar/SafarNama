import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct FoodListView: View {
    @State var cityID: String
    @State var categoryName: String
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    @State private var foods: [Food] = []
    
    func loadFoods() {
        let db = Firestore.firestore()
        let path = "cities/\(cityID)/categories/\(categoryName.lowercased())/food"
        
        db.collection(path).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching food data: \(error.localizedDescription)")
            } else {
                foods = snapshot?.documents.compactMap { document in
                    try? document.data(as: Food.self)
                } ?? []
                print("Loaded \(foods.count) food items.")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color("food"))
                    .ignoresSafeArea()
                VStack {
                    Text("always have space for second helpings")
                        .font(.custom("Playfair Display", size: 30))
                        .fontWeight(.bold)
                        .padding()
                        .multilineTextAlignment(.center)
                    
                    List {
                        ForEach(foods) { food in
                            NavigationLink {
                                FoodDetailView(food: food, cityID: cityID, categoryName: categoryName)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(food.restaurant)
                                        .font(.title2)
                                    
                                    Text(food.cuisineType)
                                        .font(.title3)
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    Task {
                                        await deleteFood(food: food)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onAppear {
                        loadFoods()
                    }
                    .navigationTitle("Food")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                sheetIsPresented.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $sheetIsPresented) {
                        NavigationStack {
                            FoodDetailView(food: Food(), cityID: cityID, categoryName: categoryName)
                                .onDisappear {
                                    loadFoods() 
                                }
                        }
                    }
                }
            }
        }
    }
    
    func deleteFood(food: Food) async {
        guard let foodID = food.id else { return }
        let db = Firestore.firestore()
        let path = "cities/\(cityID)/categories/\(categoryName.lowercased())/food/\(foodID)"
        
        do {
            try await db.document(path).delete()
            foods.removeAll { $0.id == foodID } // Update local list
            print("Deleted food with ID: \(foodID)")
        } catch {
            print("Error deleting food: \(error.localizedDescription)")
        }
    }
}

#Preview {
    FoodListView(cityID: "sampleCityID", categoryName: "food")
}

