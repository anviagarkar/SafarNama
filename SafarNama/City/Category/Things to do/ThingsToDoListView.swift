////
////  ThingsToDoListView.swift
////  SafarNama
////
////  Created by Anvi Agarkar on 05/12/2024.
////
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ThingsToDoListView: View {
    @State var cityID: String
    @State var categoryName: String
    @State private var sheetIsPresented = false
    @Environment(\.dismiss) private var dismiss
    @State private var thingsToDo: [ThingToDo] = []
    
    func loadThingsToDo() {
        let db = Firestore.firestore()
        let path = "cities/\(cityID)/categories/\(categoryName.lowercased())/things-to-do"
        
        db.collection(path).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching food data: \(error.localizedDescription)")
            } else {
                thingsToDo = snapshot?.documents.compactMap { document in
                    try? document.data(as: ThingToDo.self)
                } ?? []
                print("Loaded \(thingsToDo.count) food items.")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(Color("ttd"))
                    .ignoresSafeArea()
                VStack {
                    Text("City Highlights")
                        .font(.custom("Playfair Display", size: 30))
                        .fontWeight(.bold)
                        .padding()
                    
                    List {
                        ForEach(thingsToDo) { ttd in
                            NavigationLink {
                                TTDDetailView(thingToDo: ttd, cityID: cityID, categoryName: categoryName)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(ttd.activityName)
                                        .font(.headline)
                                    
                                    Text(ttd.description)
                                        .font(.title3)
                                }
                            }
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    Task {
                                        await
                                        deleteThingToDO(ttd: ttd)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onAppear {
                        loadThingsToDo()
                    }
                    .navigationTitle("highlights")
                    
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                sheetIsPresented.toggle()
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $sheetIsPresented) {
                        NavigationStack {
                            TTDDetailView(thingToDo: ThingToDo(), cityID: cityID, categoryName: categoryName)
                                .onDisappear {
                                    loadThingsToDo()
                                }
                        }
                    }
                }
            }
        }
       
    }
    func deleteThingToDO(ttd: ThingToDo) async {
        guard let ttdID = ttd.id else { return }
        let db = Firestore.firestore()
        let path = "cities/\(cityID)/categories/\(categoryName.lowercased())/things to do/\(ttdID)"
        
        do {
            try await db.document(path).delete()
            thingsToDo.removeAll { $0.id == ttdID }
            print("Deleted food with ID: \(ttdID)")
        } catch {
            print("Error deleting food: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ThingsToDoListView(cityID: "Sample", categoryName: "Sample")
}
