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

    let blue = Color(red: 0.18, green: 0.267, blue: 0.459) // #2e4475 // #4183c4
    
    
    
    // State variables
    @State private var showingAddFolderView = false
    @State private var showSheet = false
    @State private var selectedFolderForDeletion: Folder?
    @State private var showingDeletionAlert = false

    var body: some View {
        /*
        Image("rink_icon")
            .resizable()
            .scaledToFit()
            .frame(width: 600, height: 300)
            .listRowBackground(Color.clear)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, -110)
            //.padding(.top, -100)
         */
        
            // Navigation Stack that allows for clean look of home screen
            NavigationStack {
                List {
                    
                    Image("small_hockey_rink")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 600, height: 300)
                        .listRowBackground(Color.clear)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, -110)
                        .padding(.top, -100)
                     
                    // List of folders (Includes button for new folder and gesture for deleting folder)
                    Section(header: Image("folders_text").resizable().scaledToFit().frame(width: 150, height: 50)) {
                        ForEach(folders, id: \.id) { folder in
                            NavigationLink(destination: FolderView(folder: folder)) {
                                HStack{
                                    //Puts folder image icon next to each folder
                                    Image(systemName: "folder.fill")
                                                       .resizable()
                                                       .scaledToFit()
                                                       .frame(width: 20, height: 20)
                                                       .padding(.trailing, 0)
                                                       .foregroundColor(.gray)
                                    Text(folder.name ?? "Unnamed Folder")
                                }
                            }.listRowBackground(Color.white)
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
                    Section(header: Image("drawing_text").resizable().scaledToFit().frame(width: 150, height: 50)) {
                        ForEach(drawings) { drawing in
                            NavigationLink(destination: DrawingView(id: drawing.id, data: drawing.canvasData, title: drawing.title, backgroundImageName: drawing.backgroundImageName ?? "hockey_rink")) {
                                HStack{
                                    Text(drawing.title ?? "Untitled")
                                    
                                    // Puts preview of respective background image next to each drawing
                                    if drawing.backgroundImageName == "hockey_rink" {
                                        Image("rink_icon") // Use system folder icon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 80, height: 40) // Adjust size as needed
                                            .padding(.trailing, 0) // Add spacing between image and text
                                            .foregroundColor(.gray)
                                    } else{
                                        
                                        Image("half_rink_icon") // Use system folder icon
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40) // Adjust size as needed
                                            .padding(.trailing, 0) // Add spacing between image and text
                                            .foregroundColor(.gray)
                                    }
                                    
                                }
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
                .scrollContentBackground(.hidden)
                .background(Image("home_background").resizable().scaledToFill().edgesIgnoringSafeArea(.all)) // Background Image for homescreen
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
