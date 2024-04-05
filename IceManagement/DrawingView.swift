//
//  DrawingView.swift
//  IceManagement
//


import SwiftUI

struct DrawingView: View {
    @Environment(\.managedObjectContext) var viewContext

    @State var id: UUID?
    @State var data: Data?
    @State var title: String?
    @State var backgroundImageName: String

    var body: some View {
        VStack {
            CanvasWithBackgroundView(data: data ?? Data(), id: id ?? UUID(), backgroundImageName: backgroundImageName)
                .environment(\.managedObjectContext, viewContext)
                .navigationBarTitle(title ?? "Untitled", displayMode: .inline)
        }
    }
}
