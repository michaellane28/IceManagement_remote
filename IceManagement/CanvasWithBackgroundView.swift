//
//  CanvasWithBackgroundView.swift
//  IceManagement
//


import SwiftUI

struct CanvasWithBackgroundView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var data: Data
    var id: UUID
    var backgroundImageName: String

    var body: some View {
        ZStack {
            // Background image
            Image(backgroundImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .edgesIgnoringSafeArea(.all)

            // Drawing canvas
            DrawingCanvasView(data: data, id: id)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}

