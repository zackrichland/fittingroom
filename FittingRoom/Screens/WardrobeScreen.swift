import SwiftUI

struct WardrobeScreen: View {
    @EnvironmentObject private var wardrobeManager: WardrobeManager
    @State private var showAddItem = false
    @State private var selectedCategory: WardrobeCategory = .top
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a1a1a").edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // Category Picker
                    Menu {
                        ForEach(WardrobeCategory.allCases, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                HStack {
                                    Text(category.rawValue)
                                    if selectedCategory == category {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6).opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    // Items Grid
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            let categoryItems = wardrobeManager.wardrobeItems.filter { $0.category == selectedCategory }
                            
                            ForEach(categoryItems) { item in
                                WardrobeItemCard(item: item)
                            }
                            
                            Button(action: {
                                showAddItem = true
                            }) {
                                AddItemCard()
                            }
                        }
                        .padding()
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Wardrobe")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showAddItem) {
                AddItemScreen(onItemAdded: { newItem in
                    wardrobeManager.addItem(newItem)
                })
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

struct WardrobeItemCard: View {
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
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(item.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
    }
}

struct AddItemCard: View {
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .aspectRatio(1, contentMode: .fit)
                
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Add Item")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("New")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.top, 4)
        }
    }
}

#Preview {
    WardrobeScreen()
        .environmentObject(WardrobeManager())
} 