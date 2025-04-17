import Foundation

// Represents the data structure in the 'profiles' table
struct UserProfile: Codable, Identifiable {
    let id: UUID // Matches the primary key, linked to auth.users.id
    var fal_lora_model_id: String? // Matches the column name exactly, optional
    // Add other columns like created_at if you need them in the app
    // let created_at: Date?
} 