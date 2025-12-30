//
//  AddGroupStep1ViewController 2.swift
//  Khairk
//
//  Created by FM on 16/12/2025.
//


import UIKit

final class AddGroupStep1ViewController: UIViewController {

    // MARK: - Outlets (connect from storyboard)
    @IBOutlet private weak var groupNameTextField: UITextField!
    @IBOutlet private weak var descriptionTextField: UITextField!   // or UITextView if you used it
    @IBOutlet private weak var nextButton: UIButton!

    // MARK: - State
    /// Draft shared across steps.
    var draft = DonationGroupDraft()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        refreshNextButtonState()
    }

    // MARK: - UI Setup
    private func setupUI() {
        // Basic button styling (match your app)
        nextButton.layer.cornerRadius = 14
        nextButton.clipsToBounds = true

        // If you want Next disabled at first:
        nextButton.isEnabled = false
        nextButton.alpha = 0.6
    }

    private func setupTextFields() {
        groupNameTextField.delegate = self
        descriptionTextField.delegate = self

        groupNameTextField.placeholder = "Enter your group name"
        descriptionTextField.placeholder = "Enter your description (optional)"

        // Update draft while typing
        groupNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        descriptionTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    // MARK: - Actions
    @IBAction private func nextTapped(_ sender: UIButton) {
        // 1) Save latest values into draft
        saveDraftFromUI()

        // 2) Validate required fields
        let name = draft.groupName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else {
            showAlert(title: "Missing Group Name",
                      message: "Please enter a group name before continuing.")
            return
        }

        // 3) Navigate to Step 2
        performSegue(withIdentifier: "ShowStep2", sender: self)
    }

    @IBAction private func dismissKeyboardTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    // MARK: - Helpers
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

    // MARK: - Navigation (pass draft to Step 2)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowStep2" {
            // Replace with your Step2 controller name
            let vc = segue.destination as? AddGroupStep2ViewController
            vc?.draft = draft
        }
    }
}

// MARK: - UITextFieldDelegate
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
