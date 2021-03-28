import SwiftUI

extension Font {
    
    public enum Theme: String, CaseIterable, Identifiable {
        
        case headline
        case title1
        case title2
        case title3
        case subhead
        case body
        case small
        case smallExtra
        case caption1
        case caption2
        case link1
        case link2
        
        public var id: String {
            return rawValue
        }
    }
    
    public init(_ themeFont: Theme) {
        switch themeFont {
        case .headline:
            self = Font.system(size: 34, weight: .bold, design: .default)
        case .title1:
            self = Font.system(size: 28, weight: .bold, design: .default)
        case .title2:
            self = Font.system(size: 22, weight: .bold, design: .default)
        case .title3:
            self = Font.system(size: 20, weight: .bold, design: .default)
        case .subhead:
            self = Font.system(size: 17, weight: .bold, design: .default)
        case .body:
            self = Font.system(size: 17, weight: .regular, design: .default)
        case .small:
            self = Font.system(size: 15, weight: .regular, design: .default)
        case .smallExtra:
            self = Font.system(size: 12, weight: .regular, design: .default)
        case .caption1:
            self = Font.system(size: 11, weight: .semibold, design: .default)
        case .caption2:
            self = Font.system(size: 10, weight: .regular, design: .default)
        case .link1:
            self = Font.system(size: 17, weight: .semibold, design: .default)
        case .link2:
            self = Font.system(size: 15, weight: .semibold, design: .default)
        }
    }
}

struct Fonts_Previews: PreviewProvider {
    static var previews: some View {
        List(Font.Theme.allCases) { theme in
            Text(theme.rawValue.capitalized).font(Font(theme))
        }
    }
}
