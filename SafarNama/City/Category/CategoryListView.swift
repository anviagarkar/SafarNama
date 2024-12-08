import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CategoryListView: View {
    @State var cityID: String
    @Environment(\.dismiss) private var dismiss
    @State private var categories: [String] = []
    
    func loadCategories() {
        let db = Firestore.firestore()
        db.collection("cities").document(cityID).getDocument { document, error in
            if let error = error {
                print("Error fetching city document: \(error)")
            } else {
                categories = ["food", "shops", "things-to-do"]
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color("categories"))
                    .ignoresSafeArea()
                VStack {
                    Text("take your pick")
                        .font(.custom("Playfair Display", size: 30))
                        .fontWeight(.bold)
                        .padding()
                    
                    List {
                        ForEach(categories, id: \.self) { category in
                            NavigationLink {
                                if category == "food" {
                                    FoodListView(cityID: cityID, categoryName: category)
                                } else if category == "shops" {
                                    ShopListView(cityID: cityID, categoryName: category)
                                } else if category == "things-to-do" {
                                    ThingsToDoListView(cityID: cityID, categoryName: category)
                                }
                                else {
                                    Text("Other category: \(category)")
                                }
                            } label: {
                                Text(category)
                                    .font(.headline)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
                .onAppear {
                    loadCategories()
                }
            }
        }
    }
}

#Preview {
    CategoryListView(cityID: "sampleCityID")
}

