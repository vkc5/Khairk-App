//
//  AdminNGOVerificationDetailsController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 31/12/2025.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import SafariServices

class AdminNGOVerificationDetailsController: UIViewController {
    var ngoID: String?
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var ngoLogo: UIImageView!
    @IBOutlet weak var ngoNameHeader: UILabel!
    @IBOutlet weak var ngoStatusicon: UIImageView!
    @IBOutlet weak var ngoStatus: UILabel!
    @IBOutlet weak var joinDate: UILabel!
    @IBOutlet weak var ngoName: UILabel!
    @IBOutlet weak var ngoArea: UILabel!
    @IBOutlet weak var ngoEmail: UILabel!
    @IBOutlet weak var ngoPhone: UILabel!
    @IBOutlet weak var ngoMemberName: UILabel!
    @IBOutlet weak var ngoMemberEmail: UILabel!
    @IBOutlet weak var ngoMemberPhone: UILabel!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var rejectBtn: UIButton!
    var licenseURLString: String?
    private var documentController: UIDocumentInteractionController?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        if let id = ngoID {
            print("Received NGO ID: \(id)")
            fetchNGODetails()
        }
        // Do any additional setup after loading the view.
    }
    
    private func uiSetup() {
        self.approveBtn.isHidden = true
        self.rejectBtn.isHidden = true
        bannerImage.contentMode = .scaleAspectFill
        bannerImage.clipsToBounds = true
        ngoLogo.layer.cornerRadius = 10
        ngoLogo.clipsToBounds = true
        ngoLogo.layer.borderWidth = 0.5
        ngoLogo.contentMode = .scaleAspectFill
    }
    
    private func fetchNGODetails() {
        guard let ngoID = ngoID else {
            print("ID is nil")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("users").document(ngoID).getDocument { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
  
            guard let snapshot = querySnapshot,
                  let data = snapshot.data(),
                  let ngo = User(id: snapshot.documentID, dictionary: data)
            else {
                print("Ngo not found or parsing failed")
                return
            }
            

            // Reload table view on main thread
            DispatchQueue.main.async {
                if let url = ngo.profileImageUrl, !url.isEmpty {
                    self.bannerImage.loadImage(from: url)
                }
                if let url = ngo.logoUrl, !url.isEmpty {
                    self.ngoLogo.loadImage(from: url)
                }
                
                if let status = ngo.applicationStatus {
                    switch ngo.applicationStatus?.lowercased() {
                    case "pending":
                        self.ngoStatusicon.image = UIImage(systemName: "hourglass")
                        self.ngoStatus.text = "Pending"
                        self.ngoStatus.textColor = .gray
                        self.ngoStatusicon.tintColor = .gray
                        self.approveBtn.isHidden = false
                        self.rejectBtn.isHidden = false
                    case "approved":
                        self.ngoStatusicon.image = UIImage(systemName: "checkmark.circle.fill")
                        self.ngoStatus.text = "Approved"
                        self.ngoStatus.textColor = UIColor.mainBrand500
                        self.ngoStatusicon.tintColor = UIColor.mainBrand500
                        self.rejectBtn.isHidden = false
                    case "rejected":
                        self.ngoStatusicon.image = UIImage(systemName: "xmark.circle.fill")
                        self.ngoStatus.text = "Rejected"
                        self.ngoStatus.textColor = .red
                        self.ngoStatusicon.tintColor = .red
                        self.approveBtn.isHidden = false
                    default:
                        self.ngoStatusicon.image = UIImage(systemName: "questionmark.circle")
                        self.ngoStatus.text = status.capitalized
                        self.ngoStatus.textColor = .black
                        self.ngoStatusicon.tintColor = .black
                    }
                }
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_BH")
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                self.joinDate.text = "Joind on \(dateFormatter.string(from: ngo.createdAt))"
                self.ngoName.text = ngo.name
                self.ngoNameHeader.text = ngo.name
                self.ngoEmail.text = ngo.email
                self.ngoPhone.text = ngo.phone
                self.ngoArea.text = ngo.serviceArea ?? "—"
                self.ngoMemberName.text = ngo.memberName ?? "—"
                self.ngoMemberEmail.text = ngo.memberEmail ?? "—"
                self.ngoMemberPhone.text = ngo.memberPhone ?? "—"
                self.licenseURLString = ngo.licenseUrl
            }
            
        }
    }
    @IBAction func viewLicenseBtn(_ sender: Any) {
        guard let urlString = licenseURLString,
              let url = URL(string: urlString) else {
            return
        }

        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    @IBAction func downloadLicenseBtn(_ sender: Any) {
        guard let licenseUrlString = licenseURLString,
                  let url = URL(string: licenseUrlString) else {
                print("Invalid license URL")
                return
            }

            let task = URLSession.shared.downloadTask(with: url) { localURL, response, error in
                if let error = error {
                    print("Download error:", error)
                    return
                }

                guard let localURL = localURL else { return }

                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let destinationURL = documentsURL.appendingPathComponent(url.lastPathComponent)

                try? fileManager.removeItem(at: destinationURL)

                do {
                    try fileManager.copyItem(at: localURL, to: destinationURL)

                    DispatchQueue.main.async {
                        self.documentController = UIDocumentInteractionController(url: destinationURL)
                        self.documentController?.presentOptionsMenu(
                            from: self.view.bounds,
                            in: self.view,
                            animated: true
                        )

                    }
                } catch {
                    print("File save error:", error)
                }
            }

            task.resume()
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
