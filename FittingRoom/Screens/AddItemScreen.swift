import SwiftUI
import PhotosUI
import UIKit

struct AddItemScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var itemName = ""
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showActionSheet = false
    @State private var selectedCategory: WardrobeCategory = .top
    var onItemAdded: (WardrobeItem) -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // Image selection area
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 250)
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        
                        Text("Tap to select an image")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                }
            }
            .onTapGesture {
                showActionSheet = true
            }
            
            // Item name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Item Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("e.g. Blue T-Shirt", text: $itemName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
            
            // Category picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(WardrobeCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Spacer()
            
            // Save button
            Button(action: {
                let newItem = WardrobeItem(
                    name: itemName,
                    imageName: "photo.fill",
                    image: selectedImage,
                    category: selectedCategory
                )
                onItemAdded(newItem)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save Item")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .disabled(itemName.isEmpty || selectedImage == nil)
            .opacity((itemName.isEmpty || selectedImage == nil) ? 0.6 : 1.0)
        }
        .padding()
        .navigationTitle("Add New Item")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .confirmationDialog("Add Photo", isPresented: $showActionSheet) {
            Button("Take Photo") {
                imageSourceType = .camera
                showImagePicker = true
            }
            Button("Choose from Camera Roll") {
                imageSourceType = .photoLibrary
                showImagePicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: imageSourceType)
        }
    }
}

#Preview {
    NavigationView {
        AddItemScreen(onItemAdded: { _ in })
    }
} 