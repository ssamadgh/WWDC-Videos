import UIKit

fileprivate enum Theme {
    enum Color {
        static let border = UIColor(red: CGFloat(184/255.0), green: 201/255.0, blue: 238/255.0, alpha: 1)
        static let shade = UIColor(red: CGFloat(227/255.0), green: 234/255.0, blue: 249/255.0, alpha: 1)
        static let highlight = UIColor(red: CGFloat(14/255.0), green: 114/255.0, blue: 199/255.0, alpha: 1)
    }
    enum Font {
        static let codeVoice = UIFont(name: "Menlo-Regular", size: 14)!
    }
}

fileprivate struct StyledString {
    let string: String
    let shaded: Bool
    let highlighted: Bool
    let bordered: Bool
}

fileprivate extension UILabel {
    convenience init(styledString: StyledString) {
        self.init()
        text = styledString.string
        textAlignment = .center
        font = Theme.Font.codeVoice
        textColor = styledString.highlighted ? Theme.Color.highlight : UIColor.black
        backgroundColor = styledString.shaded ? Theme.Color.shade : UIColor.white
        if (styledString.bordered) {
            layer.borderColor = Theme.Color.border.cgColor
            layer.borderWidth = 1.0
        }
    }
}

public func visualize(_ str: String) -> UIView {
    return _visualize(str, range: nil)
}

public func visualize(_ str: String, index: String.Index) -> UIView {
   let range = index..<str.index(after:index)
   return _visualize(str, range: range)
}

public func visualize(_ str: String, range: Range<String.Index>) -> UIView {
    return _visualize(str, range: range)
}

fileprivate func _visualize(_ str: String, range: Range<String.Index>?) -> UIView {
    let stringIndices = str.indices
    
    let styledCharacters = zip(stringIndices, [str]).map { (characterIndex, char) -> StyledString in
        let shaded: Bool
        if let range = range, range.contains(characterIndex) {
            shaded = true
        } else {
            shaded = false
        }
        return StyledString(string: String(char), shaded: shaded, highlighted: false, bordered: true)
    }
    
    let characterLabels = styledCharacters.map { UILabel(styledString: $0) }
    
    let styledIndices = stringIndices.enumerated().map { (index, characterIndex) -> StyledString in
        let highlighted: Bool
        let nextCharacterIndex = str.index(after: characterIndex)
        if range?.lowerBound == characterIndex || range?.upperBound == nextCharacterIndex {
            highlighted = true
        } else {
            highlighted = false
        }
        
        return StyledString(string: String(index), shaded: false, highlighted: highlighted, bordered: false)
    }
    
    let indexLabels = styledIndices.map { UILabel(styledString: $0) }
    
    let charStacks: [UIStackView] = zip(characterLabels, indexLabels).map { (charLabel, indexLabel) in
        let stack = UIStackView()
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.addArrangedSubview(indexLabel)
        stack.addArrangedSubview(charLabel)
        return stack
    }
    
    let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 25 * charStacks.count, height: 50))
    stackView.distribution = .fillEqually
    charStacks.forEach(stackView.addArrangedSubview)
    
    return stackView
}

public let messageDates = [
    Date().addingTimeInterval(-2000),
    Date().addingTimeInterval(-1500),
    Date().addingTimeInterval(-500),
    Date()
]
