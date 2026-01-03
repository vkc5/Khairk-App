import UIKit
import PhotosUI
import FirebaseFirestore

final class CreateCaseViewController: UIViewController {

    private let service = CaseService()
    private let db = Firestore.firestore()

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let stackView = UIStackView()

    private let uploadButton = UIButton(type: .system)
    private let titleField = UITextField()
    private let goalField = UITextField()
    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let measurementField = UITextField()
    private let descriptionTextView = UITextView()
    private let confirmButton = UIButton(type: .system)

    private var selectedImage: UIImage? {
        didSet {
            updateUploadButtonAppearance()
        }
    }
    private var uploadedImageURL: String?
    private var isUploading = false {
        didSet {
            updateUploadState()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Case"
        view.backgroundColor = .systemBackground

        setupLayout()
        updateUploadState()
    }

    private func setupLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        stackView.axis = .vertical
        stackView.spacing = 16

        configureUploadButton()

        configureTextField(titleField, placeholder: "Enter Title")
        configureTextField(goalField, placeholder: "Enter Goal")
        goalField.keyboardType = .numberPad

        configureTextField(measurementField, placeholder: "Measurements")
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
        stackView.addArrangedSubview(makeSectionLabel(text: "Title"))
        stackView.addArrangedSubview(titleField)
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
        uploadButton.clipsToBounds = true
        uploadButton.contentHorizontalAlignment = .center
        uploadButton.contentVerticalAlignment = .center
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
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func updateUploadButtonAppearance() {
        if let image = selectedImage {
            uploadButton.setTitle("", for: .normal)
            uploadButton.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
            uploadButton.contentHorizontalAlignment = .fill
            uploadButton.contentVerticalAlignment = .fill
            uploadButton.imageView?.contentMode = .scaleAspectFill
        } else {
            uploadButton.setImage(nil, for: .normal)
            uploadButton.setTitle("Upload Image", for: .normal)
            uploadButton.contentHorizontalAlignment = .center
            uploadButton.contentVerticalAlignment = .center
        }
    }

    private func updateUploadState() {
        let enabled = !isUploading
        uploadButton.isEnabled = enabled
        confirmButton.isEnabled = enabled
        uploadButton.alpha = enabled ? 1.0 : 0.6
        confirmButton.alpha = enabled ? 1.0 : 0.6
    }

    private func uploadImage(_ image: UIImage) {
        isUploading = true
        CloudinaryService.shared.uploadImage(image) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isUploading = false
                switch result {
                case .success(let url):
                    self.uploadedImageURL = url
                case .failure(let error):
                    self.uploadedImageURL = nil
                    self.showAlert(title: "Upload Failed", message: error.localizedDescription)
                }
            }
        }
    }

    private func fetchNgoName(ngoId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("ngos")
            .whereField("uid", isEqualTo: ngoId)
            .limit(to: 1)
            .getDocuments { snap, err in
                if let err = err {
                    completion(.failure(err))
                    return
                }
                guard let doc = snap?.documents.first else {
                    completion(.failure(NSError(
                        domain: "CreateCaseViewController",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "NGO not found for this user."]
                    )))
                    return
                }
                let name = doc.data()["name"] as? String ?? ""
                if name.isEmpty {
                    completion(.failure(NSError(
                        domain: "CreateCaseViewController",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "NGO name is missing."]
                    )))
                    return
                }
                completion(.success(name))
            }
    }

    @objc private func saveTapped() {
        let titleText = (titleField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let goal = Int(goalField.text ?? "") ?? 0
        let startDate = startDatePicker.date
        let endDate = endDatePicker.date
        let measurementText = (measurementField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptionText = (descriptionTextView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !titleText.isEmpty, goal > 0 else {
            showAlert(title: "Missing Info", message: "Enter Title and a valid Goal.")
            return
        }

        if endDate < startDate {
            showAlert(title: "Invalid Dates", message: "End date must be after start date.")
            return
        }

        if isUploading {
            showAlert(title: "Uploading", message: "Please wait for the image upload to finish.")
            return
        }

        NGOContext.shared.getNgoId { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let err):
                self.showAlert(title: "Error", message: err.localizedDescription)
            case .success(let ngoId):
                self.fetchNgoName(ngoId: ngoId) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .failure(let err):
                        self.showAlert(title: "Error", message: err.localizedDescription)
                    case .success(let ngoName):
                        let newCase = NgoCase(
                            id: "temp",
                            title: titleText,
                            measurements: measurementText,
                            goal: goal,
                            collected: 0,
                            startDate: startDate,
                            endDate: endDate,
                            details: descriptionText,
                            imageURL: uploadedImageURL,
                            status: "active",
                            ngoId: ngoId,
                            ngoName: ngoName
                        )

                        self.service.createCase(newCase: newCase) { [weak self] result in
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

extension CreateCaseViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {
            return
        }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self = self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.selectedImage = image
                self.uploadedImageURL = nil
                self.uploadImage(image)
            }
        }
    }
}
