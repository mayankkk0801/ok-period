import UIKit
import FirebaseAuth
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootViewController()
        window.makeKeyAndVisible()
        self.window = window

        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, _ in
            self?.window?.rootViewController = self?.makeRootViewController()
        }

        for context in connectionOptions.urlContexts {
            GIDSignIn.sharedInstance.handle(context.url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        GIDSignIn.sharedInstance.handle(url)
    }

    deinit {
        if let authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(authStateListenerHandle)
        }
    }

    private func makeRootViewController() -> UIViewController {
        if AuthService.shared.isSignedIn {
            return UINavigationController(rootViewController: HomeViewController())
        }
        return UINavigationController(rootViewController: LoginViewController())
    }
}
