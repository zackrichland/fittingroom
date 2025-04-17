import SwiftUI
import PhotosUI
import UIKit

// Placeholder for the Digital Twin view
struct DigitalTwinView: View {
    // TODO: Replace with actual image loading logic based on user's model
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Digital Twin")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black) // Changed for white background

            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.1)) // Placeholder background
                .frame(height: 350) // Adjust height as needed
                .overlay(
                    VStack {
                        Image(systemName: "person.fill") // Placeholder icon
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        Text("Loading your digital twin...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                )
        }
    }
}

struct HomeScreen: View {
    @State private var showGeneratedResult = false
    @State private var selectedItems: [WardrobeCategory: WardrobeItem] = [:]
    @State private var showImagePicker = false
    @State private var showWardrobeActionSheet = false
    @State private var showWardrobePicker = false
    @State private var showAddItemScreen = false
    @State private var showClothesActionSheet = false
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isAnimating = false
    @State private var currentGreeting: String
    @EnvironmentObject private var wardrobeManager: WardrobeManager
    @EnvironmentObject private var authManager: AuthManager // Assuming AuthManager provides user info/model ID later
    @EnvironmentObject private var lookManager: LookManager // Add lookManager
    
    private let greetings = [
        "What's the vibe today?",
        "What's your slay of the day?",
        "Pick your fit, make it fierce.",
        "Which look are we serving?",
        "Dress to impress... yourself.",
        "Manifesting today's outfit...",
        "Time to slay. What's the fit?",
        "OOTD loading...",
        "Let's get dressed, bestie.",
        "Choose your slay weapon.",
        "Styling session starts now.",
        "Mirror, mirror — what's the fit?",
        "Today's aesthetic?"
    ]
    
    init() {
        _currentGreeting = State(initialValue: greetings.randomElement() ?? "DressMe")
        // Customize navigation bar appearance for white background
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Changed background to white
                Color.white.edgesIgnoringSafeArea(.all)

                VStack(spacing: 0) { // Use VStack for top-to-bottom layout
                    ScrollView {
                        VStack(spacing: 30) {
                            // --- Digital Twin Section ---
                            DigitalTwinView()
                                .padding(.top) // Add some padding if needed

                            // Removed the original // Selfie section ... // End of Selfie section VStack

                            // Spacer to push content up if needed, adjust padding/spacing instead if preferred
                            // Spacer()
                        }
                        .padding(.horizontal) // Add horizontal padding to scroll content
                    } // End ScrollView

                    // Use the computed property here
                    tryOnSection
                    
                } // End Main VStack
            } // End ZStack
            .navigationTitle(currentGreeting)
            .navigationBarTitleDisplayMode(.inline)
            // Removed toolbarColorScheme(.dark)
            // Confirmation dialogs remain the same
            .confirmationDialog("Add Photo", isPresented: $showWardrobeActionSheet) { // Keep for adding clothes? Or rename?
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
            // Sheets remain the same, but check GeneratedResultScreen input
            .sheet(isPresented: $showImagePicker) {
                 // This ImagePicker now likely relates to adding clothes, not the main selfie
                 // Remove the onImagePicked closure, assume it uses a binding
                 // Also, need a real binding target if we want the image back here.
                 // For now, just pass .constant(nil) if we don't need the image in HomeScreen directly.
                 ImagePicker(image: .constant(nil), sourceType: imageSourceType)
             }
            .sheet(isPresented: $showWardrobePicker) {
                 WardrobePickerView(selectedItems: $selectedItems)
                     .environmentObject(wardrobeManager) // Ensure env object is passed
             }
            .sheet(isPresented: $showAddItemScreen) {
                 NavigationView {
                     AddItemScreen(onItemAdded: { newItem in
                         wardrobeManager.addItem(newItem)
                         // Optionally select the newly added item
                         selectedItems[newItem.category] = newItem
                     })
                     .environmentObject(wardrobeManager) // Ensure env object is passed
                 }
             }
            .sheet(isPresented: $showGeneratedResult) {
                 NavigationView {
                     // Update GeneratedResultScreen initializer if needed
                     // Remove the selfie parameter from the call
                     GeneratedResultScreen(
                         items: Array(selectedItems.values)
                         // TODO: Pass digital twin identifier or image here later
                     )
                      .environmentObject(lookManager) // Pass lookManager if needed
                 }
             }
            .onAppear {
                isAnimating = true
                // Refresh greeting or other setup
                 currentGreeting = greetings.randomElement() ?? "DressMe"
            }
        }
        // Removed preferredColorScheme(.dark)
    }
    
    // --- Computed Property for Try On Section ---
    private var tryOnSection: some View {
        VStack {
             // --- Try On Anything Section ---
             VStack(alignment: .leading, spacing: 15) {
                 HStack {
                     // Renamed title
                     Text("Try On Anything")
                         .font(.title2)
                         .fontWeight(.bold)
                         .foregroundColor(.black) // Changed for white background

                     Spacer()

                     Button(action: {
                         showClothesActionSheet = true
                     }) {
                         Image(systemName: "plus.circle.fill")
                             .foregroundColor(.blue)
                             .font(.title2)
                     }
                 }

                 // Logic for displaying clothes selection (empty or grid) remains similar
                 if selectedItems.isEmpty {
                      Button(action: {
                         showClothesActionSheet = true
                     }) {
                         VStack(spacing: 16) {
                              Image(systemName: "tshirt.fill")
                                  .resizable()
                                  .aspectRatio(contentMode: .fit)
                                  .frame(width: 40, height: 40)
                                  .foregroundColor(.white) // Keep accent color
                                  .padding()
                                  .background(Color(hex: "fc1657")) // Use new hex code
                                  .clipShape(Circle())

                              Text("No clothes selected")
                                  .font(.headline)
                                  .foregroundColor(.black) // Changed

                              Text("Add clothes to see how they look on you")
                                  .font(.subheadline)
                                  .foregroundColor(.gray) // Keep gray
                                  .multilineTextAlignment(.center)
                          }
                          .frame(maxWidth: .infinity)
                          .padding(.vertical, 20) // Reduced padding a bit
                          .background(
                              RoundedRectangle(cornerRadius: 24)
                                  .fill(Color.gray.opacity(0.05)) // Lighter background for white theme
                                  .overlay(
                                      RoundedRectangle(cornerRadius: 24)
                                          .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1) // Lighter border
                                  )
                          )
                      }
                 } else {
                     // Grid view for selected items - adjust styling for white theme if needed
                      LazyVGrid(columns: [
                          GridItem(.flexible()),
                          GridItem(.flexible())
                      ], spacing: 16) {
                          ForEach(WardrobeCategory.allCases, id: \.self) { category in
                              VStack(alignment: .leading, spacing: 8) {
                                  Text(category.rawValue)
                                      .font(.headline)
                                      .foregroundColor(.gray) // Keep gray

                                  if let item = selectedItems[category] {
                                      ZStack(alignment: .topTrailing) {
                                          // Assuming WardrobeItemView looks okay on white
                                          WardrobeItemView(item: item, isSelected: true)
                                              .frame(height: 150)

                                          Button(action: {
                                              selectedItems.removeValue(forKey: category)
                                          }) {
                                              Image(systemName: "xmark.circle.fill")
                                                  .foregroundColor(.white) // Keep white on dark background
                                                  .font(.title3)
                                                  .padding(4)
                                                  .background(Color.black.opacity(0.4)) // Keep dark background for contrast
                                                  .clipShape(Circle())
                                          }
                                          .padding(8)
                                      }
                                  } else {
                                      Button(action: {
                                          // TODO: Need logic to pick item for *this* category
                                          // This might require passing the category to the picker
                                          showWardrobePicker = true
                                      }) {
                                          ZStack {
                                              RoundedRectangle(cornerRadius: 16)
                                                  .fill(Color.gray.opacity(0.1)) // Lighter background
                                                  .frame(height: 150)
                                                  .overlay(
                                                      RoundedRectangle(cornerRadius: 16)
                                                          .strokeBorder(Color.gray.opacity(0.2), lineWidth: 1) // Lighter border
                                                  )
                                                 // .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2) // Lighter shadow

                                              VStack(spacing: 12) {
                                                  Image(systemName: "plus.circle")
                                                      .font(.title)
                                                      .foregroundColor(.blue) // Keep blue
                                                  Text("Add \(category.rawValue)")
                                                      .font(.headline)
                                                      .foregroundColor(.blue) // Keep blue
                                              }
                                          }
                                      }
                                  }
                              }
                          }
                      } // End LazyVGrid
                 } // End else
             }
             .padding() // Add padding around the clothes section
             .background(Color.white) // Ensure it has a white background if needed for separation

             // --- Generate outfit button ---
             Button(action: {
                 // TODO: Update action - needs digital twin + selected items, not selfie image
                 // For now, just triggers the sheet display
                 if !selectedItems.isEmpty { // Only enable if clothes are selected
                     showGeneratedResult = true
                 }
             }) {
                 HStack(spacing: 16) {
                     Image(systemName: "wand.and.stars") // Changed icon
                         .font(.system(size: 20, weight: .semibold))
                         .foregroundColor(.white)

                     Text("Generate Outfit") // Updated text
                         .font(.system(size: 20, weight: .semibold))
                         .foregroundColor(.white)
                 }
                 .frame(maxWidth: .infinity)
                 .padding(.vertical, 16)
                 .background(
                     LinearGradient(
                         colors: [Color(hex: "fc1657"), Color(hex: "f3c7e1")], // Use new hex code
                         startPoint: .leading,
                         endPoint: .trailing
                     )
                     // Enable/disable based only on selectedItems now
                     .opacity(!selectedItems.isEmpty ? 1 : 0.5)
                 )
                 .cornerRadius(30)
                 .shadow(color: Color(hex: "fc1657").opacity(0.5), radius: 10, x: 0, y: 0) // Use new hex code
                  .overlay(
                      RoundedRectangle(cornerRadius: 30)
                          .stroke(Color(hex: "fc1657").opacity(0.5), lineWidth: 1) // Use new hex code
                          .blur(radius: 4)
                          .opacity(!selectedItems.isEmpty ? 1 : 0) // Enable/disable based only on selectedItems
                  )
                  .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isAnimating) // Keep animation? Maybe remove.
             }
              // Disable based only on selectedItems
             .disabled(selectedItems.isEmpty)
             .padding(.horizontal) // Padding for the button
             .padding(.bottom) // Padding at the very bottom
        } // End outer VStack for the section
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
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color(hex: "fc1657")) // Use new hex code
                                        .clipShape(Circle())
                                    
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
        .environmentObject(WardrobeManager()) // Add required env objects for preview
        .environmentObject(AuthManager())
        .environmentObject(LookManager())
} 