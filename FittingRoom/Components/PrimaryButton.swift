import SwiftUI

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isPrimary: Bool = true
    var icon: String? = nil
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                
                Text(title)
                    .font(.headline)
            }
            .foregroundColor(isPrimary ? .white : .blue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                isPrimary 
                    ? (isDisabled ? Color.gray : Color.blue)
                    : Color.white
            )
            .cornerRadius(8)
            .overlay(
                !isPrimary 
                    ? RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                    : nil
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryButton(title: "Primary Button", action: {})
        PrimaryButton(title: "Secondary Button", action: {}, isPrimary: false)
        PrimaryButton(title: "With Icon", action: {}, icon: "star.fill")
        PrimaryButton(title: "Disabled Button", action: {}, isDisabled: true)
    }
    .padding()
} 