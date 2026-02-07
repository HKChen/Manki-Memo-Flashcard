import SwiftUI

// MARK: - Modifiers

struct MujiBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()
            content
        }
    }
}

extension View {
    func mujiBackground() -> some View {
        self.modifier(MujiBackgroundModifier())
    }
}

// MARK: - Components

struct MujiCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(AppTheme.Colors.surface)
            .cornerRadius(0) // Muji style is often sharp or very slightly rounded, let's go with 2 for a "paper" feel, or 0 for strict boxy
            .overlay(
                Rectangle()
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 2, x: 0, y: 1) // Very subtle shadow
    }
}

// MARK: - Styles

struct MujiButtonStyle: ButtonStyle {
    var isPrimary: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium, design: .default)) // Clean font
            .padding(.vertical, 12)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(
                isPrimary ? (configuration.isPressed ? AppTheme.Colors.accent.opacity(0.8) : AppTheme.Colors.accent) : Color.clear
            )
            .foregroundColor(isPrimary ? .white : AppTheme.Colors.accent)
            .overlay(
                Rectangle()
                    .stroke(isPrimary ? Color.clear : AppTheme.Colors.accent, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct MujiTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 16, design: .serif)) // Serif for input feels more "textual"/traditional
            .padding(12)
            .background(Color.white)
            .overlay(
                Rectangle()
                    .stroke(AppTheme.Colors.border, lineWidth: 1)
            )
            .foregroundColor(AppTheme.Colors.primaryText)
    }
}

// MARK: - Previews
struct MujiComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Muji Title")
                .font(.title)
                .foregroundColor(AppTheme.Colors.primaryText)
            
            MujiCard {
                VStack(alignment: .leading) {
                    Text("Card Title")
                        .font(.headline)
                        .foregroundColor(AppTheme.Colors.primaryText)
                    Text("This is a simple card description following the Muji aesthetic.")
                        .font(.body)
                        .foregroundColor(AppTheme.Colors.secondaryText)
                }
            }
            .padding()
            
            Button("Primary Action") {}
                .buttonStyle(MujiButtonStyle(isPrimary: true))
                .padding(.horizontal)
            
            Button("Secondary Action") {}
                .buttonStyle(MujiButtonStyle(isPrimary: false))
                .padding(.horizontal)
                
            TextField("Input Field", text: .constant(""))
                .textFieldStyle(MujiTextFieldStyle())
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .mujiBackground()
    }
}
