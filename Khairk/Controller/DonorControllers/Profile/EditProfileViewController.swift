//
//  EditProfileViewController.swift
//  Khairk
//
//  Created by vkc5 on 04/12/2025.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIImageView!

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!

    @IBOutlet weak var saveButton: UIButton!

    enum Mode {
        case view
        case edit
    }

    private var mode: Mode = .view

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateUI(for: .view)       // start in view mode
        cameraButton.layer.cornerRadius = 24
        cameraButton.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editTapped)
        )
    }
    
    @objc func editTapped() {
        updateUI(for: .edit)
    }

    @objc func cancelTapped() {
        updateUI(for: .view)
    }

    func updateUI(for newMode: Mode) {
        mode = newMode

        let isEditing = (newMode == .edit)

        // Text fields editable or not
        [nameTextField, emailTextField, phoneTextField].forEach {
            $0?.isUserInteractionEnabled = isEditing
        }

        // Show/hide Save button
        saveButton.isHidden = !isEditing

        // Show/hide camera icon
        cameraButton.isHidden = !isEditing

        // Nav bar buttons
        if isEditing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Cancel",
                style: .plain,
                target: self,
                action: #selector(cancelTapped)
            )
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Edit",
                style: .plain,
                target: self,
                action: #selector(editTapped)
            )
        }
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
