import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    private var documentBrowserViewController: DocumentBrowserViewController? {
        window?.rootViewController as? DocumentBrowserViewController
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

    }
    
    func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
        guard let urlContext = contexts.first else { return }
        
        debugPrint("[SceneDelegate] open url context: \(urlContext)")
        documentBrowserViewController?.openExternalDocument(at: urlContext.url)
    }
}
