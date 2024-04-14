//
//  ContentView.swift
//  IceManagement
//
// Main file including functions for creating, deleting and manipulation of folders and drawings


import SwiftUI
import CoreData
import Photos

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Sorts folders by order of creation date
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.creationDate, ascending: true)]
    ) var folders: FetchedResults<Folder>

    @FetchRequest(
        entity: Drawing.entity(),
        sortDescriptors: [],
        predicate: NSPredicate(format: "folder == nil")
    ) var drawings: FetchedResults<Drawing>

    
    // State variables
    @State private var showingAddFolderView = false
    @State private var showSheet = false
    @State private var selectedFolderForDeletion: Folder?
    @State private var showingDeletionAlert = false

    var body: some View {
        // Navigation Stack that allows for clean look of home screen
        NavigationStack {
            List {
                // List of folders (Includes button for new folder and gesture for deleting folder)
                Section(header: Text("Folders")) {
                    ForEach(folders, id: \.id) { folder in
                        NavigationLink(destination: FolderView(folder: folder)) {
                            Text(folder.name ?? "Unnamed Folder")
                        }
                    }
                    .onDelete(perform: deleteFolder)

                    Button(action: {
                        showingAddFolderView = true
                    }) {
                        HStack {
                            Image(systemName: "folder.badge.plus")
                            Text("Add Folder")
                        }
                    }
                }
                
                // List of drawings (includes button for new drawing and gesture for deleting folder)
                Section(header: Text("Drawings")) {
                    ForEach(drawings) { drawing in
                        NavigationLink(destination: DrawingView(id: drawing.id, data: drawing.canvasData, title: drawing.title, backgroundImageName: drawing.backgroundImageName ?? "hockey_rink")) {
                            Text(drawing.title ?? "Untitled")
                        }
                    }
                    .onDelete(perform: deleteDrawing)
                    
                    Button(action: {
                        self.showSheet.toggle()
                    }) {
                        HStack {
                            Image(systemName: "plus")
                            Text("Add Canvas")
                        }
                    }
                    .sheet(isPresented: $showSheet) {
                        AddNewCanvasView().environment(\.managedObjectContext, viewContext)
                    }
                }
            }
            .navigationBarTitle("Ice Management")
            .sheet(isPresented: $showingAddFolderView) {
                AddNewFolderView().environment(\.managedObjectContext, self.viewContext)
            }
            .alert(isPresented: $showingDeletionAlert) {
                Alert(
                    // alert for deleting folder. Asks user if they want to delete folder and drawings, or just the folder (keeps drawings in tact)
                    title: Text("Delete Folder"),
                    message: Text("Delete Folder and its Drawings?"),
                    primaryButton: .destructive(Text("Delete Folder and Drawings")) {
                        performDeletion(deleteDrawings: true)
                    },
                    secondaryButton: .default(Text("Delete Only Folder")) {
                        performDeletion(deleteDrawings: false)
                    }
                )
            }
            .onAppear{
                requestPhotoLibraryAccess()
            }
        }
    }

    private func requestPhotoLibraryAccess() {
            PHPhotoLibrary.requestAuthorization { status in
                switch status {
                case .authorized:
                    print("Photo Library Access Granted")
                case .denied, .restricted:
                    print("Photo Library Access Denied or Restricted")
                case .notDetermined:
                    print("Photo Library Access State Not Determined")
                case .limited:
                    print("Photo Library Access Limited")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    
    // Function for deleting drawing
    private func deleteDrawing(at offsets: IndexSet) {
        for index in offsets {
            let drawing = drawings[index]
            viewContext.delete(drawing)
            do {
                try viewContext.save()
            } catch {
                print("Error saving context after deleting drawing: \(error)")
            }
        }
    }
    
    // Function for deleting folder
    private func deleteFolder(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        selectedFolderForDeletion = folders[index]
        showingDeletionAlert = true
    }

    private func performDeletion(deleteDrawings: Bool) {
        guard let folder = selectedFolderForDeletion else { return }

        if deleteDrawings {
            for drawing in folder.drawingsArray {
                viewContext.delete(drawing)
            }
        }
        viewContext.delete(folder)

        do {
            try viewContext.save()
        } catch {
            print("Error saving context after deleting folder: \(error)")
        }
        selectedFolderForDeletion = nil
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
