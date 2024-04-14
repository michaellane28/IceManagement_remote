//
//  FolderView.swift
//  IceManagement
//
//  View for when user clicks on existing folder

import SwiftUI
import CoreData

struct FolderView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var folder: Folder
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        List {
            ForEach(folder.drawingsArray, id: \.id) { drawing in // Displays the drawings in list format inside of folder
                NavigationLink(destination: DrawingView(id: drawing.id, data: drawing.canvasData, title: drawing.title, backgroundImageName: drawing.backgroundImageName ?? "hockey_rink")) {
                    Text(drawing.title ?? "Untitled")
                }
            }
            .onDelete(perform: deleteDrawing)
        }
        .navigationBarTitle(Text(folder.name ?? ""), displayMode: .inline)
    }

    // Function for deleting drawing inside of folder
    private func deleteDrawing(at offsets: IndexSet) {
        for index in offsets {
            let drawingToDelete = folder.drawingsArray[index]
            viewContext.delete(drawingToDelete)
        }

        do {
            try viewContext.save()
        } catch {
            print("Error deleting drawing: \(error)")
        }
    }

}

extension Folder {
    var drawingsArray: [Drawing] {
        let set = drawings as? Set<Drawing> ?? []
        return Array(set)
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let newFolder = Folder(context: context)
        newFolder.name = "Test Folder"
        return FolderView(folder: newFolder).environment(\.managedObjectContext, context)
    }
}
