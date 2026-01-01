import UIKit
import FirebaseFirestore

final class NGOFinderViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!

    // MARK: - Filter Tap (Gesture)
    @IBAction func filterTapped(_ sender: UITapGestureRecognizer) {
        showFilterSheet()
    }

    // MARK: - Firestore
    private let db = Firestore.firestore()

    // MARK: - Data
    private var allNGOs: [CollectorNGO] = []
    private var shownNGOs: [CollectorNGO] = []

    // MARK: - Area Filter
    private var selectedArea: String? = nil   // nil = All

    // MARK: - Sort
    private enum SortOption { case none, nameAZ, areaAZ }
    private var sortOption: SortOption = .none

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("collectionView:", collectionView as Any)
        print("searchBar:", searchBar as Any)
    }


    // MARK: - Layout
    private func setupLayout() {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
            layout.minimumInteritemSpacing = 12
            layout.minimumLineSpacing = 16
        }
    }

    // MARK: - SearchBar (Fix mirror line)
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage() // يشيل الخط / الميرور
    }

    // MARK: - Filter Sheet (Area + Sort)
    private func showFilterSheet() {

        let areas = Array(
            Set(allNGOs.map { $0.serviceArea }.filter { !$0.isEmpty })
        ).sorted { $0.lowercased() < $1.lowercased() }

        let sheet = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)

        // All Areas
        sheet.addAction(UIAlertAction(title: "All Areas", style: .default) { _ in
            self.selectedArea = nil
            self.applySearchFilterSort()
        })

        // Area options
        for area in areas {
            sheet.addAction(UIAlertAction(title: area, style: .default) { _ in
                self.selectedArea = area
                self.applySearchFilterSort()
            })
        }

        // Sort options
        sheet.addAction(UIAlertAction(title: "Sort: Name A → Z", style: .default) { _ in
            self.sortOption = .nameAZ
            self.applySearchFilterSort()
        })

        sheet.addAction(UIAlertAction(title: "Sort: Area A → Z", style: .default) { _ in
            self.sortOption = .areaAZ
            self.applySearchFilterSort()
        })

        sheet.addAction(UIAlertAction(title: "Clear Sort", style: .default) { _ in
            self.sortOption = .none
            self.applySearchFilterSort()
        })

        // Reset everything
        sheet.addAction(UIAlertAction(title: "Reset Filter", style: .destructive) { _ in
            self.selectedArea = nil
            self.sortOption = .none
            self.searchBar.text = ""
            self.applySearchFilterSort()
        })

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    // MARK: - Fetch Approved Collectors
    private func fetchApprovedCollectors() {
        db.collection("users")
            .whereField("role", isEqualTo: "collector")
            .whereField("applicationStatus", isEqualTo: "approved")
            .getDocuments { [weak self] snap, err in
                guard let self else { return }

                if let err {
                    print("❌ Firestore error:", err.localizedDescription)
                    return
                }

                let docs = snap?.documents ?? []

                self.allNGOs = docs.map { doc in
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
                }

                DispatchQueue.main.async {
                    self.applySearchFilterSort()
                }
            }
    }

    // MARK: - Apply Search + Filter + Sort
    private func applySearchFilterSort() {

        var result = allNGOs

        // Area filter
        if let area = selectedArea, !area.isEmpty {
            result = result.filter {
                $0.serviceArea.lowercased() == area.lowercased()
            }
        }

        // Search
        let query = searchBar.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased() ?? ""

        if !query.isEmpty {
            result = result.filter {
                $0.name.lowercased().contains(query) ||
                $0.serviceArea.lowercased().contains(query)
            }
        }

        // Sort
        switch sortOption {
        case .none:
            break
        case .nameAZ:
            result.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .areaAZ:
            result.sort { $0.serviceArea.lowercased() < $1.serviceArea.lowercased() }
        }

        shownNGOs = result
        collectionView.reloadData()
    }
}

// MARK: - UISearchBarDelegate
extension NGOFinderViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        applySearchFilterSort()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource
extension NGOFinderViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        shownNGOs.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "NGOCardCell",
            for: indexPath
        ) as! NGOCardCell

        cell.configure(with: shownNGOs[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NGOFinderViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let columns: CGFloat = 2
        let spacing: CGFloat = 12
        let insets: CGFloat = 32
        let total = insets + (columns - 1) * spacing
        let width = (collectionView.bounds.width - total) / columns

        return CGSize(width: width, height: 210)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let selected = shownNGOs[indexPath.item]
        let sb = UIStoryboard(name: "DonorNGODiscovery", bundle: nil)

        let vc = sb.instantiateViewController(
            withIdentifier: "CollectorDetailsViewController"
        ) as! CollectorDetailsViewController

        vc.ngo = selected
        navigationController?.pushViewController(vc, animated: true)
    }
}
