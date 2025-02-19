import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        
        // Check if the user has completed onboarding and set the initial view controller
        let isOnboarded = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        let hasSetPreferences = UserDefaults.standard.bool(forKey: "hasSetAuthorPreferences")
        
        // If onboarding is complete and preferences are set, show the home screen
        if isOnboarded && hasSetPreferences {
            window?.rootViewController = TabBarController()
        } else {
            // Otherwise, show the splash screen which will navigate accordingly
            window?.rootViewController = SplashViewController()
        }

        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}

