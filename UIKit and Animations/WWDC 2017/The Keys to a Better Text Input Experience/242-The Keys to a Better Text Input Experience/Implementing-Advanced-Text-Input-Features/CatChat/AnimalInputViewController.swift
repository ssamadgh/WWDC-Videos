/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The primary class for the keyboard extension. You can also instantiate this and set it as the
        inputView for the main UIResponder to get it to work in-process.
*/

import UIKit

struct AnimalLexiconEntry {
    var glyph: UIImage
    var textRepresentation: String
}

class KeyView: UIButton {
    var representedEntity: AnimalLexiconEntry?
    private static let keyRadius = CGFloat(5.0)

    let keyBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = KeyView.keyRadius
        view.isUserInteractionEnabled = false

        return view
    }()

    let keyShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.6, alpha: 1.0)
        view.layer.cornerRadius = KeyView.keyRadius
        view.isUserInteractionEnabled = false

        return view
    }()

    let keyGlyphView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    let keyCapView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        textView.textAlignment = NSTextAlignment.center
        textView.font = UIFont.boldSystemFont(ofSize: 16.0)
        textView.backgroundColor = UIColor.clear

        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(keyShadowView)
        addSubview(keyBackgroundView)
        addSubview(keyCapView)
        addSubview(keyGlyphView)

        keyBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        keyBackgroundView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        keyBackgroundView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        keyBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        keyBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        keyShadowView.translatesAutoresizingMaskIntoConstraints = false
        keyShadowView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        keyShadowView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        keyShadowView.topAnchor.constraint(equalTo: topAnchor, constant: 1.0).isActive = true
        keyShadowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 1.0).isActive = true

        let horizontalPadding = CGFloat(18.0)
        keyGlyphView.translatesAutoresizingMaskIntoConstraints = false
        keyGlyphView.leftAnchor.constraint(equalTo: leftAnchor, constant: horizontalPadding).isActive = true
        keyGlyphView.rightAnchor.constraint(equalTo: rightAnchor, constant: -horizontalPadding).isActive = true
        keyGlyphView.topAnchor.constraint(equalTo: topAnchor, constant: 8.0).isActive = true
        keyGlyphView.bottomAnchor.constraint(lessThanOrEqualTo: keyCapView.topAnchor).isActive = true
        keyGlyphView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        keyCapView.translatesAutoresizingMaskIntoConstraints = false
        keyCapView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        keyCapView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return super.point(inside: point, with: event)
    }

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                keyBackgroundView.backgroundColor = UIColor.gray
            } else {
                keyBackgroundView.backgroundColor = UIColor.white
            }
        }
    }
}

class AnimalInputViewController: UIInputViewController {
    let keyStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10.0

        return stackView
    }()

    let inputSwitcherButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "paw"), for: .normal)
        button.addTarget(self, action: #selector(handleInputModeList(from:with:)), for: .allEvents)

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenBounds = UIScreen.main.bounds
        inputView?.frame = CGRect(x: 0.0, y: 0.0, width: screenBounds.width, height: 240.0)
        inputView?.addSubview(keyStackView)

        for key in fullLexicon() {
            let keyView = KeyView(type: .system)
            keyView.representedEntity = key
            keyView.keyCapView.text = key.textRepresentation
            keyView.keyGlyphView.image = key.glyph
            keyView.addTarget(self, action: #selector(didTapButton(sender:)), for: .touchUpInside)

            keyStackView.addArrangedSubview(keyView)
        }

        let guide = inputView!.layoutMarginsGuide
        keyStackView.translatesAutoresizingMaskIntoConstraints = false
        keyStackView.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        keyStackView.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        keyStackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 30.0).isActive = true
        keyStackView.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -60.0).isActive = true
        keyStackView.heightAnchor.constraint(equalToConstant: 160.0).isActive = true

        if needsInputModeSwitchKey {
            inputView?.addSubview(inputSwitcherButton)
            inputSwitcherButton.translatesAutoresizingMaskIntoConstraints = false
            inputSwitcherButton.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
            inputSwitcherButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -8.0).isActive = true
            inputSwitcherButton.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
            inputSwitcherButton.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        }
    }

    @objc
    private func didTapButton(sender: KeyView) {
        if let entity = sender.representedEntity {
            textDocumentProxy.insertText(entity.textRepresentation + " ")
        }
    }

    func fullLexicon() -> [AnimalLexiconEntry] {
        return [
            AnimalLexiconEntry(glyph: #imageLiteral(resourceName: "food"), textRepresentation: NSLocalizedString("FOOD", comment: "")),
            AnimalLexiconEntry(glyph: #imageLiteral(resourceName: "outside"), textRepresentation: NSLocalizedString("OUTSIDE", comment: "")),
            AnimalLexiconEntry(glyph: #imageLiteral(resourceName: "stop"), textRepresentation: NSLocalizedString("STOP", comment: ""))
        ]
    }

    private func numberOfKeys() -> Int {
        return fullLexicon().count
    }
}
