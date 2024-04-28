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
    @State private var showingAddDrawingView = false
    
    @State private var showDrawingCreatedMessage = false

    var body: some View {
        List {
            Section(header: Image("drawing_text").resizable().scaledToFit().frame(width: 150, height: 50)){
                ForEach(folder.drawingsArray, id: \.id) { drawing in // Displays the drawings in list format inside of folder
                    NavigationLink(destination: DrawingView(id: drawing.id, data: drawing.canvasData, title: drawing.title, backgroundImageName: drawing.backgroundImageName ?? "hockey_rink")) {
                        HStack{
                            Text(drawing.title ?? "Untitled")
                            
                            if drawing.backgroundImageName == "hockey_rink" {
                                Image("rink_icon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 40)
                                    .padding(.trailing, 0)
                                    .foregroundColor(.gray)
                            } else{
                                
                                Image("half_rink_icon") // Uses system folder icon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .padding(.trailing, 0) // Adds spacing between image and text
                                    .foregroundColor(.gray)
                            }
                            
                        }
                    }
                }
                .onDelete(perform: deleteDrawing)
                
                Button(action: {
                    self.showingAddDrawingView.toggle()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Canvas")
                    }
                }
                .sheet(isPresented: $showingAddDrawingView) {
                    AddDrawingInView(
                        folder: folder,
                        drawingCreationHandler: {
                            
                            withAnimation {
                                               showDrawingCreatedMessage = true
                                           }

                            // Optionally, hide the message after a certain duration
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                               withAnimation {
                                                   showDrawingCreatedMessage = false
                                               }
                                           }
                        }
                    
                    ).environment(\.managedObjectContext, viewContext)
                }
                
            }
        }
        .overlay(
            ZStack {
                drawingCreatedMessageView
                    .opacity(showDrawingCreatedMessage ? 1 : 0)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // Position at the top
                }
            )
        .scrollContentBackground(.hidden)
        .background(
            GeometryReader { geometry in
                    Image("home_background")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width)
                }
                .edgesIgnoringSafeArea(.all)
        )
        .navigationBarBackButtonHidden(true) // Hide the default back button
        .navigationBarItems(leading: backButton)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarTitleTextColor(.white)
        .toolbar {
                    ToolbarItem(placement: .principal) {
                        customTitleView
                    }
                }
    }
    
    var drawingCreatedMessageView: some View {
        VStack {
            Image("drawing_created")
                .resizable()
                .frame(width: 381, height: 113)
                .scaledToFit()
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }
    
    // Custome folder title for top of screen
    var customTitleView: some View {
        Text(folder.name ?? "Untitled")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .foregroundColor(.black)
                .font(.headline)
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
    
    var backButton: some View {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                RoundedRectangle(cornerRadius: 30) // Rounded Rectangle as button background
                            .frame(width: 60, height: 40)
                            .foregroundColor(.white)
                            .overlay(
                                HStack {
                                    Image(systemName: "arrow.left") // Back arrow icon
                                        .foregroundColor(.black) // Icon color
                                }
                            )
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

extension View {
    @available(iOS 14, *)
    func navigationBarTitleTextColor(_ color: Color) -> some View {
        let uiColor = UIColor(color)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: uiColor ]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: uiColor ]
        return self
    }
}
