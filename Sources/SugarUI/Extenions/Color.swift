import SwiftUI

extension Color {
    
    public enum Theme: String, CaseIterable, Identifiable {
        case primary
        case secondary
        case disabled
        case background
        case success
        case error
        case warning
        
        public var id: String {
            rawValue
        }
    }
    
    public init(_ value: Theme) {
        self = Color(value.rawValue)
    }
    
    public enum Dim: Double {
        case d60 = 0.6
        case d40 = 0.4
        case d20 = 0.2
    }
    
    public func dim(_ value: Dim) -> Color {
        self.opacity(value.rawValue)
    }
}

struct Color_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ForEach(Color.Theme.allCases) { theme in
                ZStack(alignment: .center) {
                    Color(theme)
                    Text(theme.rawValue.capitalized)
                    .font(Font(.title1))
                    .foregroundColor(Color.white)
                }
            }
            
        }
    }
}
