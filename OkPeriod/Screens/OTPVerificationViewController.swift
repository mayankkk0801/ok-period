import UIKit

final class OTPVerificationViewController: UIViewController {

    private let email: String

    private let otpField = UITextField.styled(
        placeholder: "6-digit code",
        keyboardType: .numberPad
    )

    private lazy var verifyButton: UIButton = {
        let button = UIButton.primary(title: "Verify & Sign In")
        button.addTarget(self, action: #selector(verifyTapped), for: .touchUpInside)
        return button
    }()

    private lazy var resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Resend code", for: .normal)
        button.setTitleColor(AppTheme.primaryDark, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.addTarget(self, action: #selector(resendTapped), for: .touchUpInside)
        return button
    }()

    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Verify Code"
        view.backgroundColor = AppTheme.background
        otpField.textContentType = .oneTimeCode
        setupLayout()
    }

    private func setupLayout() {
        let instructionLabel = UILabel()
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.text = "Enter the 6-digit code sent to \(email)."
        instructionLabel.font = .systemFont(ofSize: 16)
        instructionLabel.textColor = AppTheme.secondaryText
        instructionLabel.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [instructionLabel, otpField, verifyButton, resendButton])
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

    @objc private func verifyTapped() {
        guard let otp = otpField.text?.trimmingCharacters(in: .whitespacesAndNewlines), otp.count == 6 else {
            showAlert(title: "Invalid Code", message: "Please enter the 6-digit verification code.")
            return
        }

        setLoading(true, on: verifyButton, title: "Verify & Sign In")
        otpField.resignFirstResponder()

        Task {
            do {
                try await AuthService.shared.verifyEmailOTP(email: email, otp: otp)
            } catch {
                await MainActor.run {
                    setLoading(false, on: verifyButton, title: "Verify & Sign In")
                    showAlert(title: "Verification Failed", message: error.localizedDescription)
                }
            }
        }
    }

    @objc private func resendTapped() {
        Task {
            do {
                try await AuthService.shared.requestEmailOTP(email: email)
                await MainActor.run {
                    showAlert(title: "Code Sent", message: "A new verification code was sent to your email.")
                }
            } catch {
                await MainActor.run {
                    showAlert(title: "Unable to Resend", message: error.localizedDescription)
                }
            }
        }
    }
}
