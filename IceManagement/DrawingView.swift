//
//  DrawingView.swift
//  IceManagement
//
// View for creating the new CanvasWithBackgroundView view


import SwiftUI
import Photos

struct DrawingView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State var id: UUID?
    @State var data: Data?
    @State var title: String?
    @State var backgroundImageName: String
    
    @State private var showSavedMessage = false
    @State private var showPermissionMessage = false

        
    var body: some View {
        VStack {
            CanvasWithBackgroundView(data: data ?? Data(), id: id ?? UUID(), backgroundImageName: backgroundImageName)
                .environment(\.managedObjectContext, viewContext)
                .navigationBarBackButtonHidden(true) // Hides the default back button
                .navigationBarItems(leading: backButton, trailing: saveButton)
                .toolbar {
                            ToolbarItem(placement: .principal) {
                                customTitleView
                            }
                        }
        }
        .overlay(
            ZStack {
                savedMessageView
                    .opacity(showSavedMessage ? 1 : 0)
                
                permissionMessageView
                    .opacity(showPermissionMessage ? 1 : 0)
            }
        )
    }
    
    var savedMessageView: some View {
        VStack {
            Image("image_saved")
                .resizable()
                .frame(width: 381, height: 113)
                .scaledToFit()
                .padding(.top, -360)
        }
    }
    
    var permissionMessageView: some View {
        VStack {
            Image("permission_denied")
                .resizable()
                .frame(width: 381, height: 113)
                .scaledToFit()
                .padding(.top, -360)
        }
    }
    
    // Customizes the drawing title at the top of the screen
    var customTitleView: some View {
        Text(title ?? "Untitled")
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .foregroundColor(.black)
                .font(.headline)
        }
    
    // Saves the drawing to the users camera roll
    func saveToCameraRoll() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            let controller = UIHostingController(rootView: self)
            
            let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
            let image = renderer.image { context in
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            }
            
            // Trims the image to remove buttons and labels at the top of the screen
            let imageSize = image.size
            let scale = image.scale
            let width = imageSize.width * scale
            let height = imageSize.height * scale
            let rect = CGRect(x: 0, y: 139, width: width, height: height - 115)
            if let croppedImage = image.cgImage?.cropping(to: rect) {
                let trimmedImage = UIImage(cgImage: croppedImage, scale: scale, orientation: image.imageOrientation)
                
                // Prints width and height of the trimmed image
                let trimmedWidth = Int(trimmedImage.size.width)
                let trimmedHeight = Int(trimmedImage.size.height)
                print("Trimmed image size: \(trimmedWidth) x \(trimmedHeight)")
                
                let status = PHPhotoLibrary.authorizationStatus()
                
                switch status {
                case .authorized:
                    UIImageWriteToSavedPhotosAlbum(trimmedImage, nil, nil, nil)
                    
                    withAnimation(.easeInOut(duration: 0.4)){
                        showSavedMessage = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                                withAnimation {
                                    showSavedMessage = false
                                }
                            }
                case .denied, .restricted, .notDetermined:
                    withAnimation(.easeInOut(duration: 0.4)){
                        showPermissionMessage = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
                                withAnimation {
                                    showPermissionMessage = false
                                }
                            }
                case .limited:
                    print("Limited")
                @unknown default:
                    print("Default")
                }
                
            }
            
            controller.view.removeFromSuperview()
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
    
       
    var saveButton: some View {
            Button(action: {
                showAlert = true
            }) {
                RoundedRectangle(cornerRadius: 10) // Rounded Rectangle as button background
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .overlay(
                            Image(systemName: "square.and.arrow.down") // Saving arrow icone
                                .foregroundColor(.black) // Icon color
                        )
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Save to Camera Roll"),
                    message: Text("Are you sure you want to save this drawing to your Camera Roll?"),
                    primaryButton: .default(Text("Save"), action: {
                        saveToCameraRoll()
                    }),
                    secondaryButton: .cancel(Text("Cancel"))
                )
            }
        }

        @State private var showAlert = false
}
