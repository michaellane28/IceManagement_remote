//
//  AddNewFolderView.swift
//  IceManagement
//
// View for when user clicks on "Add Folder" button on the navigation menu

import SwiftUI

struct AddNewFolderView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @State private var folderName = ""
    @State private var showAlert = false
    
    var folderCreationHandler: () -> Void

    
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Name").foregroundColor(Color.black)) { // Section for user to input folder name
                    TextField("Enter folder name", text: $folderName)
                    Text("Max 30 Characters")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                GeometryReader { geometry in
                        Image("new_canvas_background")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width)
                    }
                    .edgesIgnoringSafeArea(.all)
            )
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark").foregroundColor(Color.white)
            }), trailing: Button(action: addFolder, label: {
                Text("Save").foregroundColor(Color.white)
            }))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Folder name invalid"),
                    message: Text("Folder name cannot be empty and should be MAX 30 characters"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // Function for creating and saving new folder to the navigation menu
    private func addFolder() {
        
        // Checks if folder name is valid
        if folderName.count > 30 || folderName == "" {
            showAlert = true
        } else {
            let newFolder = Folder(context: viewContext)
            newFolder.id = UUID()
            newFolder.name = folderName
            newFolder.creationDate = Date()

            do {
                try viewContext.save()
                folderCreationHandler()
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Error saving folder: \(error)")
            }
        }
    }
    
}

struct AddNewFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewFolderView(folderCreationHandler: {}).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
