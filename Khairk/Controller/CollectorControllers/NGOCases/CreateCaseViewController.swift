import UIKit
import FirebaseAuth

final class CreateCaseViewController: UIViewController {

    private let service = CaseService()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let uploadButton = UIButton(type: .system)
    private let foodTypeField = UITextField()
    private let goalField = UITextField()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let measurementField = UITextField()
    private let descriptionTextView = UITextView()
    private let confirmButton = UIButton(type: .system)

    private var ngoId: String {
        Auth.auth().currentUser?.uid ?? "MISSING_NGO_ID"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Case"
        view.backgroundColor = .systemBackground

        setupLayout()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 16

        configureUploadButton()

        configureTextField(foodTypeField, placeholder: "Enter Food Type")
        configureTextField(goalField, placeholder: "Enter Goal")
        goalField.keyboardType = .numberPad

        configureTextField(measurementField, placeholder: "Measurement")
        let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
        chevron.tintColor = .secondaryLabel
        measurementField.rightView = chevron
        measurementField.rightViewMode = .always

        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact

        let startLabel = makeSectionLabel(text: "Start Date")
        let endLabel = makeSectionLabel(text: "End Date")

        descriptionTextView.font = UIFont.systemFont(ofSize: 14)
        descriptionTextView.layer.cornerRadius = 10
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.heightAnchor.constraint(equalToConstant: 90).isActive = true

        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        confirmButton.layer.cornerRadius = 18
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        confirmButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(uploadButton)
        stackView.addArrangedSubview(makeSectionLabel(text: "Food Type"))
        stackView.addArrangedSubview(foodTypeField)
        stackView.addArrangedSubview(makeSectionLabel(text: "Goal"))
        stackView.addArrangedSubview(goalField)
        stackView.addArrangedSubview(makeSectionLabel(text: "Start date & End date"))
        stackView.addArrangedSubview(startLabel)
        stackView.addArrangedSubview(startDatePicker)
        stackView.addArrangedSubview(endLabel)
        stackView.addArrangedSubview(endDatePicker)
        stackView.addArrangedSubview(makeSectionLabel(text: "Measurements"))
        stackView.addArrangedSubview(measurementField)
        stackView.addArrangedSubview(makeSectionLabel(text: "Description"))
        stackView.addArrangedSubview(descriptionTextView)
        stackView.addArrangedSubview(confirmButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    private func configureUploadButton() {
        uploadButton.setTitle("Upload Image", for: .normal)
        uploadButton.setTitleColor(UIColor(named: "MainBrand-500") ?? UIColor.systemGreen, for: .normal)
        uploadButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        uploadButton.backgroundColor = UIColor.systemGray6
        uploadButton.layer.cornerRadius = 14
        uploadButton.heightAnchor.constraint(equalToConstant: 90).isActive = true
        uploadButton.addTarget(self, action: #selector(uploadTapped), for: .touchUpInside)
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor.systemGray6
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
    }

    private func makeSectionLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    @objc private func uploadTapped() {
        showAlert(title: "Upload Image", message: "Image upload is not wired yet.")
    }

    @objc private func saveTapped() {
        guard ngoId != "MISSING_NGO_ID" else {
            showAlert(title: "Not Logged In", message: "Please log in as an NGO first.")
            return
        }

        let foodType = (foodTypeField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let goal = Int(goalField.text ?? "") ?? 0
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let measurementText = (measurementField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionText = (descriptionTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !foodType.isEmpty, goal > 0 else {
            showAlert(title: "Missing Info", message: "Enter Food Type and a valid Goal.")
            return
        }

        if endDate < startDate {
            showAlert(title: "Invalid Dates", message: "End date must be after start date.")
            return
        }

        let combinedDetails: String
        if measurementText.isEmpty {
            combinedDetails = descriptionText
        } else if descriptionText.isEmpty {
            combinedDetails = "Measurements: \(measurementText)"
        } else {
            combinedDetails = "Measurements: \(measurementText)\n\(descriptionText)"
        }

        let newCase = NgoCase(
            id: "temp",
            title: foodType,
            foodType: foodType,
            goal: goal,
            collected: 0,
            startDate: startDate,
            endDate: endDate,
            details: combinedDetails,
            imageURL: nil,
            status: "active"
        )

        service.createCase(ngoId: ngoId, newCase: newCase) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success:
                    let alert = UIAlertController(
                        title: "Case Added",
                        message: "Your new case has been created and added to the list.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK, Got It", style: .default) { _ in
                        self.navigationController?.popViewController(animated: true)
                    })
                    self.present(alert, animated: true)
                case .failure(let error):
                    self.showAlert(title: "Save Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
