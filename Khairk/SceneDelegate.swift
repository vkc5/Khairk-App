//
//  SceneDelegate.swift
//  Khairk
//
//  Created by vkc5 on 22/11/2025.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Create window and attach it to the current scene
        let window = UIWindow(windowScene: windowScene)

        // Load your DonationGroup storyboard
        let storyboard = UIStoryboard(name: "DonationCreate", bundle: nil)

        // Instantiate the Navigation Controller for Donation Groups
        let nav = storyboard.instantiateViewController(withIdentifier: "DonationNav")

        // Set as root and show
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}
