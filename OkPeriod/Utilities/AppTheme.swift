import UIKit

enum AppTheme {
    static let primary = UIColor(red: 0.91, green: 0.45, blue: 0.55, alpha: 1.0)
    static let primaryDark = UIColor(red: 0.78, green: 0.30, blue: 0.42, alpha: 1.0)
    static let background = UIColor(red: 0.99, green: 0.96, blue: 0.97, alpha: 1.0)
    static let cardBackground = UIColor.white
    static let primaryText = UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1.0)
    static let bodyText = UIColor(red: 0.28, green: 0.28, blue: 0.32, alpha: 1.0)
    static let placeholderText = UIColor(red: 0.55, green: 0.55, blue: 0.58, alpha: 1.0)
    static let secondaryText = UIColor(red: 0.28, green: 0.28, blue: 0.32, alpha: 1.0)
}

extension UIViewController {

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func setLoading(_ isLoading: Bool, on button: UIButton, title: String) {
        button.isEnabled = !isLoading
        if isLoading {
            button.setTitle("Please wait…", for: .normal)
        } else {
            button.setTitle(title, for: .normal)
        }
    }
}

extension UIButton {

    static func primary(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = AppTheme.primary
        button.layer.cornerRadius = 14
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return button
    }

    static func secondary(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.setTitleColor(AppTheme.primaryDark, for: .normal)
        button.backgroundColor = AppTheme.cardBackground
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1.5
        button.layer.borderColor = AppTheme.primary.cgColor
        button.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return button
    }
}

extension UITextField {

    static func styled(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = placeholder
        field.keyboardType = keyboardType
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.borderStyle = .none
        field.backgroundColor = AppTheme.cardBackground
        field.textColor = AppTheme.primaryText
        field.tintColor = AppTheme.primaryDark
        field.font = .systemFont(ofSize: 17)
        field.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: AppTheme.placeholderText]
        )
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.separator.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        field.leftViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 52).isActive = true
        return field
    }
}
