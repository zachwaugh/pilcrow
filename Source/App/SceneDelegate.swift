import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        let documentController = DocumentViewController(document: .test)
        let listViewController = DocumentsViewController(store: DocumentStore.shared)
        let navController = UINavigationController()
        navController.viewControllers = [listViewController, documentController]
        window?.rootViewController = navController
    }
}
