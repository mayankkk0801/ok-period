import UIKit

final class LoginViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ok Period"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = AppTheme.primaryDark
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Sign in to continue"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = AppTheme.secondaryText
        label.textAlignment = .center
        return label
    }()

    private lazy var googleButton: UIButton = {
        let button = UIButton.secondary(title: "Sign in with Google")
        button.addTarget(self, action: #selector(googleSignInTapped), for: .touchUpInside)
        return button
    }()

    private lazy var emailButton: UIButton = {
        let button = UIButton.primary(title: "Sign in with Email")
        button.addTarget(self, action: #selector(emailSignInTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayout()
    }

    private func setupLayout() {
        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, googleButton, emailButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(8, after: titleLabel)
        stack.setCustomSpacing(32, after: subtitleLabel)

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func googleSignInTapped() {
        setLoading(true, on: googleButton, title: "Sign in with Google")

        Task { @MainActor in
            do {
                try await AuthService.shared.signInWithGoogle(presenting: self)
            } catch {
                showAlert(title: "Sign-In Failed", message: error.localizedDescription)
                setLoading(false, on: googleButton, title: "Sign in with Google")
            }
        }
    }

    @objc private func emailSignInTapped() {
        navigationController?.pushViewController(EmailEntryViewController(), animated: true)
    }
}
