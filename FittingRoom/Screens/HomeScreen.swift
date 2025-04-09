import SwiftUI
import PhotosUI
import UIKit

struct HomeScreen: View {
    @State private var showGeneratedResult = false
    @State private var selectedItems: [WardrobeCategory: WardrobeItem] = [:]
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var showWardrobeActionSheet = false
    @State private var showWardrobePicker = false
    @State private var showAddItemScreen = false
    @State private var showClothesActionSheet = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isAnimating = false
    @EnvironmentObject private var wardrobeManager: WardrobeManager
    
    private let gradient = LinearGradient(
        colors: [Color(hex: "1a1a1a"), Color(hex: "2d2d2d")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    var body: some View {
        NavigationView {
            ZStack {
                gradient.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Selfie section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Your Photo")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            if selectedImage == nil {
                                Button(action: {
                                    showWardrobeActionSheet = true
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 24)
                                            .fill(Color(.systemGray6).opacity(0.1))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 24)
                                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                            )
                                            .frame(height: 250)
                                        
                                        VStack(spacing: 16) {
                                            Image(systemName: "camera.fill")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 40, height: 40)
                                                .foregroundColor(.white)
                                                .padding()
                                                .background(Color.blue)
                                                .clipShape(Circle())
                                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                                .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                                            
                                            Text("Upload Photo")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text("Take a photo or choose from your library")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                        }
                                    }
                                }
                            } else {
                                // Show selected selfie
                                Image(uiImage: selectedImage!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .overlay(
                                        Button(action: {
                                            selectedImage = nil
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                                .padding(8)
                                                .background(Color.black.opacity(0.5))
                                                .clipShape(Circle())
                                        }
                                        .padding(8),
                                        alignment: .topTrailing
                                    )
                            }
                        }
                        
                        // Your clothes section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Your clothes")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    showClothesActionSheet = true
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.title2)
                                }
                            }
                            
                            if !selectedItems.isEmpty {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    ForEach(WardrobeCategory.allCases, id: \.self) { category in
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(category.rawValue)
                                                .font(.headline)
                                                .foregroundColor(.gray)
                                            
                                            if let item = selectedItems[category] {
                                                ZStack(alignment: .topTrailing) {
                                                    WardrobeItemView(item: item, isSelected: true)
                                                        .frame(height: 150)
                                                    
                                                    Button(action: {
                                                        selectedItems.removeValue(forKey: category)
                                                    }) {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundColor(.white)
                                                            .font(.title3)
                                                            .padding(4)
                                                            .background(Color.black.opacity(0.3))
                                                            .clipShape(Circle())
                                                    }
                                                    .padding(8)
                                                }
                                            } else {
                                                Button(action: {
                                                    showWardrobePicker = true
                                                }) {
                                                    ZStack {
                                                        RoundedRectangle(cornerRadius: 12)
                                                            .fill(Color(.systemGray6).opacity(0.1))
                                                            .frame(height: 150)
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 12)
                                                                    .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                                            )
                                                        
                                                        VStack(spacing: 8) {
                                                            Image(systemName: "plus.circle")
                                                                .font(.title2)
                                                                .foregroundColor(.blue)
                                                            Text("Add \(category.rawValue)")
                                                                .font(.subheadline)
                                                                .foregroundColor(.blue)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                VStack(spacing: 16) {
                                    Image(systemName: "tshirt.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.blue)
                                        .padding()
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    Text("No clothes selected")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Add clothes to see how they look on you")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(.systemGray6).opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                        
                        // Generate outfit button
                        Button(action: {
                            showGeneratedResult = true
                        }) {
                            Text("Generate")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .opacity(selectedImage != nil && !selectedItems.isEmpty ? 1 : 0.5)
                                )
                                .cornerRadius(16)
                                .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(selectedImage == nil || selectedItems.isEmpty)
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationTitle("DressMe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark)
            .confirmationDialog("Add Photo", isPresented: $showWardrobeActionSheet) {
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
            .confirmationDialog("Add Clothes", isPresented: $showClothesActionSheet) {
                Button("Add New Item") {
                    showAddItemScreen = true
                }
                Button("Choose from Wardrobe") {
                    showWardrobePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: imageSourceType)
            }
            .sheet(isPresented: $showWardrobePicker) {
                WardrobePickerView(selectedItems: $selectedItems)
            }
            .sheet(isPresented: $showAddItemScreen) {
                NavigationView {
                    AddItemScreen(onItemAdded: { newItem in
                        wardrobeManager.addItem(newItem)
                        selectedItems[newItem.category] = newItem
                    })
                }
            }
            .onAppear {
                isAnimating = true
            }
        }
        .preferredColorScheme(.dark)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct WardrobeItemView: View {
    let item: WardrobeItem
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
            
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Image(systemName: item.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct WardrobePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedItems: [WardrobeCategory: WardrobeItem]
    @EnvironmentObject private var wardrobeManager: WardrobeManager
    @State private var selectedCategory: WardrobeCategory?
    @State private var showAddItemScreen = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(WardrobeCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category.rawValue)
                                    .font(.headline)
                                    .foregroundColor(selectedCategory == category ? .white : .gray)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(selectedCategory == category ? Color.blue : Color(.systemGray6).opacity(0.1))
                                    )
                            }
                        }
                    }
                    .padding()
                }
                
                // Items grid
                if let category = selectedCategory {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("\(category.rawValue)s")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    showAddItemScreen = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle")
                                        Text("Add New")
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            let categoryItems = wardrobeManager.wardrobeItems.filter { $0.category == category }
                            
                            if categoryItems.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "tshirt.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.gray)
                                    
                                    Text("No \(category.rawValue)s in your wardrobe")
                                        .font(.headline)
                                        .foregroundColor(.gray)
                                    
                                    Button(action: {
                                        showAddItemScreen = true
                                    }) {
                                        Text("Add \(category.rawValue)")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding()
                                            .background(Color.blue)
                                            .cornerRadius(8)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(Color(.systemGray6).opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 16) {
                                    ForEach(categoryItems) { item in
                                        WardrobeItemView(item: item, isSelected: selectedItems[category]?.id == item.id)
                                            .frame(height: 150)
                                            .onTapGesture {
                                                selectedItems[category] = item
                                                dismiss()
                                            }
                                            .overlay(
                                                selectedItems[category]?.id == item.id ?
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.blue, lineWidth: 3) : nil
                                            )
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "tshirt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .foregroundColor(.gray)
                        
                        Text("Select a category")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationTitle("Your Wardrobe")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddItemScreen) {
                NavigationView {
                    AddItemScreen(onItemAdded: { newItem in
                        wardrobeManager.addItem(newItem)
                        selectedItems[newItem.category] = newItem
                        dismiss()
                    })
                }
            }
        }
    }
}

#Preview {
    HomeScreen()
} 