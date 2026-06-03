import UIKit

final class HomeViewController: UIViewController {

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = AppTheme.primaryDark
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var signOutButton: UIButton = {
        let button = UIButton.secondary(title: "Sign Out")
        button.addTarget(self, action: #selector(signOutTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        view.backgroundColor = AppTheme.background
        updateWelcomeMessage()
        setupLayout()
    }

    private func updateWelcomeMessage() {
        if let email = AuthService.shared.currentUser?.email {
            welcomeLabel.text = "Welcome,\n\(email)"
        } else if let name = AuthService.shared.currentUser?.displayName {
            welcomeLabel.text = "Welcome,\n\(name)"
        } else {
            welcomeLabel.text = "You're signed in."
        }
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [welcomeLabel, signOutButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 24

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func signOutTapped() {
        do {
            try AuthService.shared.signOut()
        } catch {
            showAlert(title: "Sign Out Failed", message: error.localizedDescription)
        }
    }
}
