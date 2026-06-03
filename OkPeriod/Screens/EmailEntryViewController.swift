import UIKit

final class EmailEntryViewController: UIViewController {

    private let emailField = UITextField.styled(
        placeholder: "Email address",
        keyboardType: .emailAddress
    )

    private lazy var continueButton: UIButton = {
        let button = UIButton.primary(title: "Send Verification Code")
        button.addTarget(self, action: #selector(sendOTPTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Email Sign-In"
        view.backgroundColor = AppTheme.background
        setupLayout()
    }

    private func setupLayout() {
        let instructionLabel = UILabel()
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.text = "Enter your email and we'll send a one-time verification code."
        instructionLabel.font = .systemFont(ofSize: 16)
        instructionLabel.textColor = AppTheme.secondaryText
        instructionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [instructionLabel, emailField, continueButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 20

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
    }

    @objc private func sendOTPTapped() {
        guard let email = emailField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty else {
            showAlert(title: "Email Required", message: "Please enter your email address.")
            return
        }

        setLoading(true, on: continueButton, title: "Send Verification Code")
        emailField.resignFirstResponder()

        Task {
            do {
                try await AuthService.shared.requestEmailOTP(email: email)
                await MainActor.run {
                    setLoading(false, on: continueButton, title: "Send Verification Code")
                    navigationController?.pushViewController(
                        OTPVerificationViewController(email: email),
                        animated: true
                    )
                }
            } catch {
                await MainActor.run {
                    setLoading(false, on: continueButton, title: "Send Verification Code")
                    showAlert(title: "Unable to Send Code", message: error.localizedDescription)
                }
            }
        }
    }
}
