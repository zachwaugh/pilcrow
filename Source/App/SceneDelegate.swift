import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        let listViewController = DocumentsViewController(store: DocumentStore.shared)
        let navController = UINavigationController(rootViewController: listViewController)
        window?.rootViewController = navController
    }
}
