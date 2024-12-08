import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct TTDDetailView: View {
    @State var thingToDo: ThingToDo
    var cityID: String
    var categoryName: String
    @State private var description = ""
    @Environment(\.dismiss) private var dismiss
    
    init(thingToDo: ThingToDo, cityID: String, categoryName: String) {
        _thingToDo = State(initialValue: thingToDo)
        self.cityID = cityID
        self.categoryName = categoryName
        _description = State(initialValue: description)
        
        }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Activity")
                .font(.headline)
                .padding(.top)
            TextField("Enter activity name", text: $thingToDo.activityName)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
            
            Text("Description")
                .font(.headline)
                .padding(.top)
            TextField("Enter activity description", text: $thingToDo.description)
                .textFieldStyle(.roundedBorder)
                .padding(.bottom)
                .onChange(of: description) { newValue in
                    thingToDo.description = newValue
                }
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    Task {
                        let _ = await
                        TTDViewModel.saveThingToDo(cityID: cityID, categoryName: categoryName, thingToDo: thingToDo)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        TTDDetailView(thingToDo: ThingToDo(), cityID: "Sample", categoryName: "Sample")
    }
}

