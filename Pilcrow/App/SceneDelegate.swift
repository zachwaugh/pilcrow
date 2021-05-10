import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }

        let document = Document.test
        let documentController = DocumentViewController(document: document)
        let listViewController = DocumentsViewController(documents: [document])
        let navController = UINavigationController()
        navController.viewControllers = [listViewController, documentController]
        window?.rootViewController = navController
    }
}
