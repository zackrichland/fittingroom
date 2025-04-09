import SwiftUI

@main
struct FittingRoomApp: App {
    @StateObject private var wardrobeManager = WardrobeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(wardrobeManager)
        }
    }
}

class WardrobeManager: ObservableObject {
    @Published var wardrobeItems: [WardrobeItem] = [
        WardrobeItem(id: "1", name: "T-Shirt", imageName: "tshirt.fill", category: .top),
        WardrobeItem(id: "2", name: "Jeans", imageName: "staroflife", category: .bottom),
        WardrobeItem(id: "3", name: "Jacket", imageName: "person.fill", category: .top),
        WardrobeItem(id: "4", name: "Shoes", imageName: "bag.fill", category: .shoes)
    ]
    
    func addItem(_ item: WardrobeItem) {
        wardrobeItems.append(item)
    }
}

struct ContentView: View {
    @State private var isAuthenticated = false
    @EnvironmentObject private var wardrobeManager: WardrobeManager
    
    var body: some View {
        if isAuthenticated {
            TabView {
                HomeScreen()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                WardrobeScreen()
                    .tabItem {
                        Label("Wardrobe", systemImage: "tshirt.fill")
                    }
            }
        } else {
            AuthScreen(isAuthenticated: $isAuthenticated)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(WardrobeManager())
} 