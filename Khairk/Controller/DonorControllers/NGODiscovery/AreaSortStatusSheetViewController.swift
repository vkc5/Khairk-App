import UIKit

final class AreaSortStatusSheetViewController: UIViewController {

    var areas: [String] = []
    var currentArea: String? = nil
    var currentSortIndex: Int = 0
    var currentStatusIndex: Int = 0

    var onApply: ((String?, Int, Int) -> Void)?
    var onReset: (() -> Void)?

    private let areaPicker = UIPickerView()
    private let sortSegment = UISegmentedControl(items: ["None", "Name A–Z", "Area A–Z"])
    private let statusSegment = UISegmentedControl(items: ["All", "Approved", "Pending", "Rejected"])
    private let selectedAreaLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Filter"

        areaPicker.dataSource = self
        areaPicker.delegate = self

        sortSegment.selectedSegmentIndex = currentSortIndex
        statusSegment.selectedSegmentIndex = currentStatusIndex

        setupUI()
        preselectArea()
        updateSelectedAreaText()
    }

    private func setupUI() {
        let areaTitle = makeTitle("Area")
        selectedAreaLabel.font = .systemFont(ofSize: 14)
        selectedAreaLabel.textColor = .secondaryLabel

        let statusTitle = makeTitle("Status")
        let sortTitle = makeTitle("Sort")

        let applyBtn = UIButton(type: .system)
        applyBtn.setTitle("Apply", for: .normal)
        applyBtn.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        applyBtn.addTarget(self, action: #selector(applyTapped), for: .touchUpInside)

        let resetBtn = UIButton(type: .system)
        resetBtn.setTitle("Reset", for: .normal)
        resetBtn.titleLabel?.font = .systemFont(ofSize: 17)
        resetBtn.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)

        let btnRow = UIStackView(arrangedSubviews: [resetBtn, UIView(), applyBtn])
        btnRow.axis = .horizontal
        btnRow.alignment = .center

        let stack = UIStackView(arrangedSubviews: [
            areaTitle,
            selectedAreaLabel,
            areaPicker,
            makeDivider(),
            statusTitle,
            statusSegment,
            makeDivider(),
            sortTitle,
            sortSegment,
            makeDivider(),
            btnRow
        ])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            areaPicker.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    private func makeTitle(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 16, weight: .semibold)
        return lbl
    }

    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([v.heightAnchor.constraint(equalToConstant: 1)])
        return v
    }

    private func preselectArea() {
        if let area = currentArea,
           let idx = areas.firstIndex(where: { $0.lowercased() == area.lowercased() }) {
            areaPicker.selectRow(idx + 1, inComponent: 0, animated: false)
        } else {
            areaPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }

    private func updateSelectedAreaText() {
        let row = areaPicker.selectedRow(inComponent: 0)
        selectedAreaLabel.text = (row == 0) ? "Selected: All Areas" : "Selected: \(areas[row - 1])"
    }

    @objc private func applyTapped() {
        let row = areaPicker.selectedRow(inComponent: 0)
        let area: String? = (row == 0) ? nil : areas[row - 1]

        onApply?(area, sortSegment.selectedSegmentIndex, statusSegment.selectedSegmentIndex)
        dismiss(animated: true)
    }

    @objc private func resetTapped() {
        onReset?()
        dismiss(animated: true)
    }
}

extension AreaSortStatusSheetViewController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        1 + areas.count // All + areas
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        row == 0 ? "All Areas" : areas[row - 1]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        updateSelectedAreaText()
    }
}
