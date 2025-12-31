//
//  AddGroupStep2ViewController.swift
//  Khairk
//
//  Created by FM on 16/12/2025.
//

import UIKit

private var draft: DonationGroupDraft {
    get { DonationGroupDraftStore.shared.draft }
    set { DonationGroupDraftStore.shared.draft = newValue }
}


final class AddGroupStep2ViewController: UIViewController {

    @IBOutlet private weak var frequencySegmentedControl: UISegmentedControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var startDateTextField: UITextField!
    @IBOutlet private weak var endDateTextField: UITextField!
    @IBOutlet private weak var nextButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!

    private enum FrequencyMode: Int { case weekly = 0, monthly = 1 }

    private var mode: FrequencyMode = .weekly {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
            updateCollectionHeight()
            updateNextButtonState()
        }
    }

    private let weeklyItems = ["SUN","MON","TUE","WED","THU","FRI","SAT"]
    private let monthlyItems = Array(1...31).map(String.init)

    private var selectedWeeklyIndex: IndexPath?
    private var selectedMonthlyIndex: IndexPath?

    private var selectedIndex: IndexPath? {
        get { mode == .weekly ? selectedWeeklyIndex : selectedMonthlyIndex }
        set {
            if mode == .weekly { selectedWeeklyIndex = newValue }
            else { selectedMonthlyIndex = newValue }
        }
    }

    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()

    private var collectionHeightConstraint: NSLayoutConstraint?

    // ✅ IMPORTANT: do NOT create a new draft here
    private var draft: DonationGroupDraft {
        get { DonationGroupDraftStore.shared.draft }
        set { DonationGroupDraftStore.shared.draft = newValue }
    }


    private lazy var dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private let spacing: CGFloat = 12
    private let insets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    private let weeklyCellHeight: CGFloat = 60
    private let monthlyCellHeight: CGFloat = 54

    override func viewDidLoad() {
        super.viewDidLoad()

       

        setupSegmentedControl()
        setupCollectionView()
        setupDatePickers()
        setupCollectionHeightConstraint()
        updateNextButtonState()
        navigationItem.hidesBackButton = true
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateCollectionHeight()
    }

    private func setupSegmentedControl() {
        frequencySegmentedControl.removeAllSegments()
        frequencySegmentedControl.insertSegment(withTitle: "Weekly", at: 0, animated: false)
        frequencySegmentedControl.insertSegment(withTitle: "Monthly", at: 1, animated: false)
        frequencySegmentedControl.selectedSegmentIndex = FrequencyMode.weekly.rawValue
        mode = .weekly
        frequencySegmentedControl.addTarget(self, action: #selector(onFrequencyChanged), for: .valueChanged)
    }

    @objc private func onFrequencyChanged() {
        mode = FrequencyMode(rawValue: frequencySegmentedControl.selectedSegmentIndex) ?? .weekly
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(DayCell.self, forCellWithReuseIdentifier: "DayCell")

        let flow = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout) ?? UICollectionViewFlowLayout()
        flow.scrollDirection = .vertical
        flow.minimumInteritemSpacing = spacing
        flow.minimumLineSpacing = spacing
        flow.sectionInset = insets
        collectionView.collectionViewLayout = flow

        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .clear
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
    }

    private func setupDatePickers() {
        if #available(iOS 13.4, *) {
            startDatePicker.preferredDatePickerStyle = .wheels
            endDatePicker.preferredDatePickerStyle = .wheels
        }

        startDatePicker.datePickerMode = .date
        endDatePicker.datePickerMode = .date

        startDatePicker.addTarget(self, action: #selector(onStartDateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(onEndDateChanged), for: .valueChanged)

        startDateTextField.inputView = startDatePicker
        endDateTextField.inputView = endDatePicker

        startDateTextField.inputAccessoryView = makeToolbar()
        endDateTextField.inputAccessoryView = makeToolbar()
    }

    private func makeToolbar() -> UIToolbar {
        let tb = UIToolbar()
        tb.sizeToFit()
        tb.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicking))
        ]
        return tb
    }

    @objc private func donePicking() {
        view.endEditing(true)
        updateNextButtonState()
    }

    private func setupCollectionHeightConstraint() {
        if collectionHeightConstraint == nil {
            let c = collectionView.heightAnchor.constraint(equalToConstant: 160)
            c.priority = .required
            c.isActive = true
            collectionHeightConstraint = c
        }
    }

    private func updateCollectionHeight() {
        guard let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let columns: CGFloat = (mode == .weekly) ? 4 : 6
        let itemCount = CGFloat(itemsForCurrentMode().count)
        let rows = ceil(itemCount / columns)

        let cellH: CGFloat = (mode == .weekly) ? weeklyCellHeight : monthlyCellHeight
        let totalLineSpacing = flow.minimumLineSpacing * max(0, rows - 1)
        let totalInsets = flow.sectionInset.top + flow.sectionInset.bottom

        collectionHeightConstraint?.constant = rows * cellH + totalLineSpacing + totalInsets
    }

    @objc private func onStartDateChanged() {
        startDateTextField.text = dateFormatter.string(from: startDatePicker.date)

        if endDatePicker.date < startDatePicker.date {
            endDatePicker.date = startDatePicker.date
            endDateTextField.text = dateFormatter.string(from: endDatePicker.date)
        }
        updateNextButtonState()
    }

    @objc private func onEndDateChanged() {
        if endDatePicker.date < startDatePicker.date {
            endDatePicker.date = startDatePicker.date
        }
        endDateTextField.text = dateFormatter.string(from: endDatePicker.date)
        updateNextButtonState()
    }

    private func itemsForCurrentMode() -> [String] {
        (mode == .weekly) ? weeklyItems : monthlyItems
    }

    private func updateNextButtonState() {
        let hasSelection = (selectedIndex != nil)
        let hasStart = !(startDateTextField.text ?? "").isEmpty
        let hasEnd = !(endDateTextField.text ?? "").isEmpty
        nextButton.isEnabled = hasSelection && hasStart && hasEnd
    }

    // MARK: - Actions

    @IBAction private func onNextTapped(_ sender: UIButton) {
        guard let selectedIndex else { return }

        let selectedValue = itemsForCurrentMode()[selectedIndex.item]

        // Save Step2 values into the same draft from Step1
        draft.frequencyType = (mode == .weekly) ? "Weekly" : "Monthly"
        draft.frequencySelection = selectedValue
        draft.startDate = startDatePicker.date
        draft.endDate = endDatePicker.date


        // Open Step3 WITHOUT segues (Storyboard ID required)
      
        
        
    }

    @IBAction private func onBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

extension AddGroupStep2ViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemsForCurrentMode().count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DayCell", for: indexPath) as! DayCell

        cell.shape = (mode == .weekly) ? .rounded(12) : .circle
        cell.configure(text: itemsForCurrentMode()[indexPath.item],
                       selected: indexPath == selectedIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let old = selectedIndex
        selectedIndex = indexPath

        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])

        var reload = [indexPath]
        if let old, old != indexPath { reload.append(old) }

        collectionView.reloadItems(at: reload)
        updateNextButtonState()
    }
}

extension AddGroupStep2ViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        guard let flow = collectionViewLayout as? UICollectionViewFlowLayout else {
            return CGSize(width: 44, height: 44)
        }

        let columns: CGFloat = (mode == .weekly) ? 4 : 6
        let availableWidth = collectionView.bounds.width
            - flow.sectionInset.left
            - flow.sectionInset.right
            - flow.minimumInteritemSpacing * (columns - 1)

        let w = floor(availableWidth / columns)
        let h: CGFloat = (mode == .weekly) ? weeklyCellHeight : monthlyCellHeight
        return CGSize(width: w, height: h)
    }
}
