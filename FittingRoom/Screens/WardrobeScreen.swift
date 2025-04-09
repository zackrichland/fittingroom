import SwiftUI

struct WardrobeScreen: View {
    @State private var showAddItem = false
    @EnvironmentObject private var wardrobeManager: WardrobeManager
    
    var body: some View {
        NavigationView {
            VStack {
                if wardrobeManager.wardrobeItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "tshirt.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                        
                        Text("Your wardrobe is empty")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Add clothing items to start creating outfits")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showAddItem = true
                        }) {
                            Text("Add First Item")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(wardrobeManager.wardrobeItems) { item in
                                WardrobeGridItem(item: item)
                            }
                        }
                        .padding()
                    }
                }
                
                NavigationLink(
                    destination: AddItemScreen(onItemAdded: { newItem in
                        wardrobeManager.addItem(newItem)
                    }),
                    isActive: $showAddItem,
                    label: { EmptyView() }
                )
            }
            .navigationTitle("My Wardrobe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddItem = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct WardrobeGridItem: View {
    let item: WardrobeItem
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .aspectRatio(1, contentMode: .fit)
                
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(item.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    WardrobeScreen()
} 