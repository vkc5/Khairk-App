//
//  AddGroupStep1ViewController.swift
//  Khairk
//
//  Created by FM on 16/12/2025.
//

import UIKit

private var draft: DonationGroupDraft {
    get { DonationGroupDraftStore.shared.draft }
    set { DonationGroupDraftStore.shared.draft = newValue }
}


final class AddGroupStep1ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var groupNameTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextField!
    @IBOutlet private weak var nextButton: UIButton!

    // MARK: - State (shared draft)
    private var draft: DonationGroupDraft {
        get { DonationGroupDraftStore.shared.draft }
        set { DonationGroupDraftStore.shared.draft = newValue }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        refreshNextButtonState()
    }

    private func setupUI() {

        nextButton.clipsToBounds = true
        nextButton.isEnabled = false
        nextButton.alpha = 0.6
    }

    private func setupTextFields() {
        groupNameTextField.delegate = self
        descriptionTextField.delegate = self

        groupNameTextField.placeholder = "Enter your group name"
        descriptionTextField.placeholder = "Enter your description (optional)"

        groupNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    @IBAction private func nextTapped(_ sender: UIButton) {
        // Save latest values into the draft
        saveDraftFromUI()

        let name = draft.groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            showAlert(title: "Missing Group Name",
                      message: "Please enter a group name before continuing.")
            return
        }

        // Go to Step 2 (Storyboard segue identifier must be: ShowStep2)
        performSegue(withIdentifier: "ShowStep2", sender: self)
    }

    @IBAction private func dismissKeyboardTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc private func textDidChange() {
        saveDraftFromUI()
        refreshNextButtonState()
    }

    private func saveDraftFromUI() {
        draft.groupName = groupNameTextField.text ?? ""
        draft.groupDescription = descriptionTextField.text ?? ""
    }

    private func refreshNextButtonState() {
        let name = (groupNameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let enabled = !name.isEmpty
        nextButton.isEnabled = enabled
        nextButton.alpha = enabled ? 1.0 : 0.6
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension AddGroupStep1ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === groupNameTextField {
            descriptionTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
