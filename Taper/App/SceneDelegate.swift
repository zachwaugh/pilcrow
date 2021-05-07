import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let blocks: [Blockable] = [
            TextBlock(content: "This is a heading", style: .heading),
            TextBlock(content: "This is a paragraph"),
            ListItemBlock(content: "Bullet list item"),
            ListItemBlock(content: "Ordered list item", style: .number(1)),
            
            TextBlock(content: "This is another paragraph that is much longer so it will wrap to multiple lines"),
            TodoBlock(completed: false, content: "This is a new todo"),
            TextBlock(content: "More text"),
            TodoBlock(completed: true, content: "This is a completed todo that is also much longer so we can test how it wraps"),
            TextBlock(content: "And a final paragraph"),
        ]
        
        let document = Document(
            title: "Test Document",
            blocks: blocks.map { $0.asBlock() }
        )
        
        let documentController = DocumentViewController(document: document)
        let navController = UINavigationController()
        
        let emptyViewController = UIViewController()
        emptyViewController.navigationItem.backButtonDisplayMode = .minimal

        navController.viewControllers = [emptyViewController, documentController]
        window?.rootViewController = navController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

