import UIKit
import FirebaseFirestore

final class NGOFinderViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    private let db = Firestore.firestore()

    private var allNGOs: [CollectorNGO] = []
    private var shownNGOs: [CollectorNGO] = []

    private var selectedArea: String? = nil

    private enum StatusFilter: Int {
        case all = 0, approved, pending, rejected
        var key: String? {
            switch self {
            case .all: return nil
            case .approved: return "approved"
            case .pending: return "pending"
            case .rejected: return "rejected"
            }
        }
    }
    private var statusFilter: StatusFilter = .all

    private enum SortOption: Int { case none = 0, nameAZ, areaAZ }
    private var sortOption: SortOption = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "NGO Discovery"

        setupCollection()
        setupSearchBar()
        fetchCollectorsAllStatuses()
    }

    private func setupCollection() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 16
        }
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
    }

    @IBAction func filterTapped(_ sender: UITapGestureRecognizer) {
        presentFilterSheet()
    }

    private func presentFilterSheet() {
        let vc = AreaSortStatusSheetViewController()

        vc.areas = Array(Set(allNGOs.map { $0.serviceArea }.filter { !$0.isEmpty }))
            .sorted { $0.lowercased() < $1.lowercased() }

        vc.currentArea = selectedArea
        vc.currentSortIndex = sortOption.rawValue
        vc.currentStatusIndex = statusFilter.rawValue

        vc.onApply = { [weak self] area, sortIdx, statusIdx in
            guard let self else { return }
            self.selectedArea = area
            self.sortOption = SortOption(rawValue: sortIdx) ?? .none
            self.statusFilter = StatusFilter(rawValue: statusIdx) ?? .all
            self.applyFilters()
        }

        vc.onReset = { [weak self] in
            guard let self else { return }
            self.selectedArea = nil
            self.sortOption = .none
            self.statusFilter = .all
            self.searchBar.text = ""
            self.applyFilters()
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(vc, animated: true)
    }

    private func fetchCollectorsAllStatuses() {
        db.collection("users")
            .whereField("role", isEqualTo: "collector")
            .getDocuments { [weak self] snap, err in
                guard let self else { return }
                if let err {
                    print("❌ Firestore error:", err.localizedDescription)
                    return
                }

                self.allNGOs = snap?.documents.map { doc in
                    let d = doc.data()
                    return CollectorNGO(
                        id: doc.documentID,
                        name: d["name"] as? String ?? "Unknown",
                        serviceArea: d["serviceArea"] as? String ?? "",
                        profileImageUrl: d["profileImageUrl"] as? String ?? "",
                        logoUrl: d["logoUrl"] as? String ?? "",
                        applicationStatus: d["applicationStatus"] as? String ?? "",
                        email: d["email"] as? String ?? "",
                        phone: d["phone"] as? String ?? ""
                    )
                } ?? []

                DispatchQueue.main.async { self.applyFilters() }
            }
    }

    private func applyFilters() {
        var result = allNGOs

        if let needed = statusFilter.key {
            result = result.filter { $0.applicationStatus.lowercased() == needed }
        }

        if let area = selectedArea, !area.isEmpty {
            result = result.filter { $0.serviceArea.lowercased() == area.lowercased() }
        }

        let q = (searchBar.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(q) ||
                $0.serviceArea.lowercased().contains(q)
            }
        }

        switch sortOption {
        case .none: break
        case .nameAZ:
            result.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .areaAZ:
            result.sort { $0.serviceArea.lowercased() < $1.serviceArea.lowercased() }
        }

        shownNGOs = result
        collectionView.reloadData()
    }
}

// MARK: - Search
extension NGOFinderViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { applyFilters() }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { searchBar.resignFirstResponder() }
}

// MARK: - Collection
extension NGOFinderViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shownNGOs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NGOCardCell", for: indexPath) as! NGOCardCell
        cell.configure(with: shownNGOs[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 44) / 2
        return CGSize(width: width, height: 210)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selected = shownNGOs[indexPath.item]
        let status = selected.applicationStatus.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // ❌ rejected ما يفتح
        if status == "rejected" {
            return
        }

        let sb = UIStoryboard(name: "DonorNGODiscovery", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "CollectorDetailsViewController") as! CollectorDetailsViewController
        vc.ngo = selected
        navigationController?.pushViewController(vc, animated: true)
    }
}
