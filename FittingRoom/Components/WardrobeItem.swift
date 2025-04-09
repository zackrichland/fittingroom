import Foundation
import SwiftUI
import UIKit

enum WardrobeCategory: String, CaseIterable {
    case top = "Top"
    case bottom = "Bottom"
    case shoes = "Shoes"
    case hat = "Hat"
}

struct WardrobeItem: Identifiable, Equatable {
    let id: String
    let name: String
    let imageName: String
    var image: UIImage?
    let category: WardrobeCategory
    
    // Additional properties that would be used in full implementation
    var color: Color = .blue
    
    static func == (lhs: WardrobeItem, rhs: WardrobeItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    init(id: String = UUID().uuidString, name: String, imageName: String, image: UIImage? = nil, category: WardrobeCategory) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.image = image
        self.category = category
    }
} 