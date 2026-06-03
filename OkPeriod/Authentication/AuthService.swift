import FirebaseAuth
import FirebaseCore
import FirebaseFunctions
import GoogleSignIn

enum AuthError: LocalizedError {
    case missingGoogleClientID
    case missingGoogleIDToken
    case missingCustomToken
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .missingGoogleClientID:
            return "Google Sign-In is not configured for this app."
        case .missingGoogleIDToken:
            return "Unable to retrieve a Google ID token."
        case .missingCustomToken:
            return "Unable to complete email sign-in."
        case .invalidResponse:
            return "Unexpected response from the server."
        }
    }
}

final class AuthService {

    static let shared = AuthService()

    private let functions = Functions.functions()

    private init() {}

    var currentUser: User? { Auth.auth().currentUser }
    var isSignedIn: Bool { currentUser != nil }

    @MainActor
    func signInWithGoogle(presenting viewController: UIViewController) async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingGoogleClientID
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingGoogleIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        _ = try await Auth.auth().signIn(with: credential)
    }

    func requestEmailOTP(email: String) async throws {
        let callable = functions.httpsCallable("requestEmailOTP")
        _ = try await callable.call(["email": email])
    }

    func verifyEmailOTP(email: String, otp: String) async throws {
        let callable = functions.httpsCallable("verifyEmailOTP")
        let result = try await callable.call(["email": email, "otp": otp])

        guard
            let data = result.data as? [String: Any],
            let customToken = data["customToken"] as? String
        else {
            throw AuthError.missingCustomToken
        }

        _ = try await Auth.auth().signIn(withCustomToken: customToken)
    }

    @MainActor
    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
    }
}
