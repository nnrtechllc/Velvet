//
//  ContentView.swift
//  Velvet
//
//  Created by Nikhil Vaddey on 2/4/24.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct ClassData: Identifiable {
    var id: UUID
    var classroomNumber: String
    var information: String
    var status: String // Use String for status
}


struct EmployeeCheckinView: View {
    @State private var classData: [ClassData] = []
    @State private var newClassroomNumber = ""
    @State private var newInformation = ""
    @State private var isAddingClass = false
    @State private var listener: ListenerRegistration?
    @State private var password = ""
    @State private var isAnimating = false
    @State private var showConfirmation = false
    @State private var isPasswordVisible: Bool = false
    @State private var actualPassword: String = ""
    @State private var searchText = ""
    @State private var sortAscending = true // Toggle this to change sorting order
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                // Filter and sort the classData array
                let filteredAndSortedData = classData
                    .filter { searchText.isEmpty || $0.classroomNumber.localizedCaseInsensitiveContains(searchText) }
                    .sorted { sortAscending ? $0.classroomNumber < $1.classroomNumber : $0.classroomNumber > $1.classroomNumber }
                
                ForEach(filteredAndSortedData) { data in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(data.classroomNumber)
                                .font(.headline)
                            
                            Text(data.information)
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            toggleClassStatus(for: data)
                        }) {
                            Text(data.status)
                                .font(.callout)
                                .padding()
                                .foregroundColor(.white)
                                .background(data.status == "CheckedIn" ? Color.green : data.status == "CheckedOut" ? Color.red : Color.blue) // Customize colors for different status values
                                .cornerRadius(10)
                                .scaleEffect(isAnimating ? 1.3 : 1.0)
                                .animation(.spring())
                        }
                        
                        Button(action: {
                            deleteClass(data: data)
                        }) {
                            Image(systemName: "trash")
                                .padding()
                                .foregroundColor(.red)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                
                if isAddingClass {
                    VStack {
                        TextField("Member Name", text: $newClassroomNumber)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical)
                        
                        TextField("Event", text: $newInformation)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.vertical)
                        
                        Button(action: {
                            addClass()
                            isAddingClass = false
                        }) {
                            Text("Add Member")
                                .font(.headline)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    }
                    .padding()
                } else {
                    Button(action: {
                        isAddingClass = true
                    }) {
                        Text("Add")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.vertical)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Members")
            .navigationBarItems(leading: backButton, trailing: searchSortBar)
            .overlay(
                VStack {
                    Spacer()
              //      NavigationLink(destination: EventView()) {
            //            Text("View Events")
            //                .font(.headline)
           //                 .padding()
           //                 .foregroundColor(.white)
           //                 .background(Color.blue)
          //                  .cornerRadius(10)
         //           }
                    .padding()
                }
            )
        }
        .onAppear {
            fetchClassData()
        }
        .onDisappear {
            listener?.remove()
        }
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "")
                .font(.title)
                .foregroundColor(.orange)
        }
    }
    
    private var searchSortBar: some View {
        HStack {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical)
            
            Button(action: {
                sortAscending.toggle()
            }) {
                Image(systemName: sortAscending ? "arrow.down.circle" : "arrow.up.circle")
            }
            .padding(.vertical)
        }
    }
    
    private func toggleClassStatus(for data: ClassData) {
        guard password == "mrhs" else {
            print("Incorrect password")
            return
        }
        
        let newStatus: String = {
            switch data.status {
            case "CheckedIn": return "CheckedOut"
            case "CheckedOut": return "On Break"
            case "On Break": return "CheckedIn"
            default: return "CheckedIn" // Set a default value or handle other cases as needed
            }
        }()
        
        Firestore.firestore().collection("Classrooms").document(data.id.uuidString)
            .setData(["status": newStatus], merge: true) { error in
                if let error = error {
                    print("Error updating class status: \(error)")
                } else {
                    updateClassDataStatus(for: data, newStatus: newStatus)
                }
            }
    }
    
    private func updateClassDataStatus(for data: ClassData, newStatus: String) {
        if let index = classData.firstIndex(where: { $0.id == data.id }) {
            classData[index].status = newStatus
        }
    }
    
    private func deleteClass(data: ClassData) {
        guard password == "mrhs" else {
            print("Incorrect password")
            return
        }
        
        Firestore.firestore().collection("Classrooms").document(data.id.uuidString).delete { error in
            if let error = error {
                print("Error deleting class: \(error)")
            } else {
                classData.removeAll(where: { $0.id == data.id })
            }
        }
    }
    
    private func fetchClassData() {
        listener = Firestore.firestore().collection("Classrooms").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching class data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            classData = documents.compactMap { document in
                guard let classroomNumber = document.data()["classroomNumber"] as? String,
                      let information = document.data()["information"] as? String,
                      let status = document.data()["status"] as? String else {
                    return nil
                }
                
                let id = UUID(uuidString: document.documentID) ?? UUID()
                return ClassData(id: id, classroomNumber: classroomNumber, information: information, status: status)
            }
        }
    }
    
    private func addClass() {
        guard password == "mrhs" else {
            print("Incorrect password")
            return
        }

        let newId = UUID()
        let newClassData = ClassData(id: newId, classroomNumber: newClassroomNumber, information: newInformation, status: "CheckedIn")

        Firestore.firestore().collection("Classrooms").document(newId.uuidString)
            .setData(["classroomNumber": newClassroomNumber,
                      "information": newInformation,
                      "status": newClassData.status]) { error in
                if let error = error {
                    print("Error adding class: \(error)")
                } else {
                    newClassroomNumber = ""
                    newInformation = ""
                }
            }
    }
    
    struct EmployeeCheckinView_Previews: PreviewProvider {
        static var previews: some View {
            EmployeeCheckinView()
        }
    }
    
    
    
    
}
