//
//  FoodDonationViewController.swift
//  Khairk
//
//  Created by Yousif Qassim on 20/12/2025.
//
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseSharedSwift

// MARK: - 1. Model
struct DonationCase: Codable, Identifiable {
    @DocumentID var id: String?
    let title: String
    let ngoName: String
    let description: String
    let targetAmount: Double
    let raisedAmount: Double
    let daysLeft: Int
    let imageUrl: String
}

// MARK: - 2. ViewController Class
class FoodDonationViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var donationCases: [DonationCase] = []
    private var filteredCases: [DonationCase] = []
    private let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        setupCollectionView()
        fetchDonations()
    }

        private func setupCollectionView() {
            collectionView.dataSource = self
            collectionView.delegate = self
            if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.estimatedItemSize = .zero
            }
        }

        private func fetchDonations() {
            db.collection("donationCases").addSnapshotListener { [weak self] snapshot, _ in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                // Map Firestore data to the Model
                self.donationCases = documents.compactMap { try? $0.data(as: DonationCase.self) }
                self.filteredCases = self.donationCases
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }

    // MARK: - Search Logic
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchText.isEmpty {
                filteredCases = donationCases
            } else {
                filteredCases = donationCases.filter { data in
                    let titleMatch = data.title.lowercased().contains(searchText.lowercased())
                    let ngoMatch = data.ngoName.lowercased().contains(searchText.lowercased())
                    return titleMatch || ngoMatch
                }
            }
            collectionView.reloadData()
        }

        @objc func viewDetailsPressed(_ sender: UIButton) {
            // Validate index to prevent app crash
            guard sender.tag < filteredCases.count else { return }
            let selectedCase = filteredCases[sender.tag]
            performSegue(withIdentifier: "toDetails", sender: selectedCase)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toDetails" {
                if let destinationVC = segue.destination as? FoodCaseViewController,
                   let caseData = sender as? DonationCase {
                    destinationVC.selectedCase = caseData
                }
            }
        }
    }

// MARK: - 3. Collection View Configuration
    extension FoodDonationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return filteredCases.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodDonationCell", for: indexPath) as! FoodDonationCell
            
            let data = filteredCases[indexPath.item]
            
            cell.caseNameLabel.text = data.title
            cell.ngoNameLabel.text = data.ngoName
            cell.shortDescriptionLabel.text = data.description
            cell.daysLeftLabel.text = "\(data.daysLeft) Days left"
            
            let progress = data.targetAmount > 0 ? Float(data.raisedAmount / data.targetAmount) : 0
            cell.progressView.progress = progress
            cell.percentageLabel.text = "\(Int(progress * 100))%"
            cell.statsLabel?.text = "\(Int(data.raisedAmount)) / \(Int(data.targetAmount))"
            
            // Load Image
            if let url = URL(string: data.imageUrl) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let imageData = data {
                        DispatchQueue.main.async { cell.caseImageView.image = UIImage(data: imageData) }
                    }
                }.resume()
            }

            cell.detailsButton.tag = indexPath.item
            cell.detailsButton.addTarget(self, action: #selector(viewDetailsPressed(_:)), for: .touchUpInside)
            
            return cell
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.width - 30, height: 350)
        }
    }


// MARK: - Cell Class (Outlets)
class FoodDonationCell: UICollectionViewCell {
    @IBOutlet weak var caseImageView: UIImageView!
    @IBOutlet weak var caseNameLabel: UILabel!
    @IBOutlet weak var ngoNameLabel: UILabel!
    @IBOutlet weak var shortDescriptionLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var daysLeftLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var statsLabel: UILabel!
    
    @IBOutlet weak var donateButton: UIButton!
    
    @IBOutlet weak var detailsButton: UIButton!
    
}
