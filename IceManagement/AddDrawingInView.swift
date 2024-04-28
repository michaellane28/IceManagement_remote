//
//  AddDrawingInView.swift
//  IceManagement
//
// AddDrawingInView.swift


import SwiftUI
import CoreData

struct AddDrawingInView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    var folder: Folder // Receive the folder object from FolderView
    @State private var showAlert = false

    @State private var canvasTitle = ""
    @State private var selectedBackgroundImage = "hockey_rink"
    
    var drawingCreationHandler: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Enter Canvas Title").foregroundColor(Color.white)) {
                    TextField("Canvas Title", text: $canvasTitle)
                    Text("Max 30 Characters")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Section(header: Text("Select Background").foregroundColor(Color.white)) {
                    HStack {
                        Button(action: {
                            selectedBackgroundImage = "hockey_rink"
                        }) {
                            Image("hockey_rink")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedBackgroundImage == "hockey_rink" ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()

                        Button(action: {
                            selectedBackgroundImage = "half_rink"
                        }) {
                            Image("half_rink")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 300)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(selectedBackgroundImage == "half_rink" ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding()
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Image("new_canvas_background").resizable().scaledToFill().edgesIgnoringSafeArea(.all))
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark").foregroundColor(Color.white)
            }), trailing: Button(action: saveDrawing, label: {
                Text("Save").foregroundColor(Color.white)
            }))
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Drawing name invalid"),
                    message: Text("Drawing name cannot be empty and should be MAX 30 characters."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func saveDrawing() {
        
        // Checks if canvas title is valid
        if canvasTitle.count > 30 || canvasTitle == "" {
            showAlert = true
        } else {
            if !canvasTitle.isEmpty {
                let newDrawing = Drawing(context: viewContext)
                newDrawing.title = canvasTitle
                newDrawing.id = UUID()
                newDrawing.backgroundImageName = selectedBackgroundImage

                folder.addToDrawings(newDrawing) // Associates the new drawing with the current folder

                do {
                    try viewContext.save()
                    drawingCreationHandler()
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print("Error saving new drawing: \(error)")
                }
            }
        }
    }
}

struct AddDrawingInView_Previews: PreviewProvider {
    static var previews: some View {
        AddDrawingInView(folder: Folder(), drawingCreationHandler: {})
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
