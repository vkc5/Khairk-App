//
//  DonorProfileViewController.swift
//  Khairk
//
//  Created by vkc5 on 02/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AdminProfileViewController: UIViewController {
    
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        makeAvatarRound()
        loadProfile()
        styleContentContainer()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 22, weight: .semibold), 
            .foregroundColor: UIColor.white
        ]
        
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        loadProfile()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: UIColor.label
        ]
    }

    private func styleContentContainer() {
        contentContainerView.layer.cornerRadius = 24
        contentContainerView.layer.masksToBounds = false

        // Round ONLY the top corners
        contentContainerView.layer.maskedCorners = [
            .layerMinXMinYCorner,  // top-left
            .layerMaxXMinYCorner   // top-right
        ]
    }
    
    private func makeAvatarRound() {
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        // Make it circular after layout
        DispatchQueue.main.async {
            self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
        }
    }

    private func loadProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            nameLabel.text = "Guest"
            emailLabel.text = ""
            profileImageView.image = UIImage(systemName: "person.circle.fill")
            return
        }

        db.collection("users").document(uid).getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Failed to load profile:", error.localizedDescription)
                    return
                }

                let data = snapshot?.data() ?? [:]
                let name = data["name"] as? String ?? "User"
                let email = data["email"] as? String ?? (Auth.auth().currentUser?.email ?? "")
                let imageUrl = data["profileImageUrl"] as? String

                self?.nameLabel.text = name
                self?.emailLabel.text = email

                if let imageUrl = imageUrl {
                    self?.loadImage(from: imageUrl)
                } else {
                    self?.profileImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }

    private func loadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.profileImageView.image = image
            }
        }.resume()
    }
    
    @IBAction func logoutTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Logout",
            message: "Are you sure you want to logout?",
            preferredStyle: .alert
        )

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { _ in
            self.performLogout()
        }

        alert.addAction(cancelAction)
        alert.addAction(logoutAction)

        present(alert, animated: true)
    }
    
    private func performLogout() {
        do {
            try Auth.auth().signOut()
            goToLogin()
        } catch {
            showAlert(title: "Logout Failed", message: error.localizedDescription)
        }
    }
    
    private func goToLogin() {
        let storyboard = UIStoryboard(name: "Auth", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginVC")

        let nav = UINavigationController(rootViewController: loginVC)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
