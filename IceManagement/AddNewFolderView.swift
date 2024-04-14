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

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Folder Name")) { // Section for user to input folder name
                    TextField("Enter folder name", text: $folderName)
                }
            }
            .navigationBarTitle("New Folder", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Save") {
                addFolder()
            })
        }
    }

    // Function for creating and saving new folder to the navigation menu
    private func addFolder() {
        let newFolder = Folder(context: viewContext)
        newFolder.id = UUID()
        newFolder.name = folderName
        newFolder.creationDate = Date()

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving folder: \(error)")
        }
    }
}

struct AddNewFolderView_Previews: PreviewProvider {
    static var previews: some View {
        AddNewFolderView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
