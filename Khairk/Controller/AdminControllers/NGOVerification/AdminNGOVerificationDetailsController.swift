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
    @IBOutlet weak var ngoMemberContainer: UIView!
    @IBOutlet weak var approveBtn: UIButton!
    @IBOutlet weak var licenseContainer: UIView!
    @IBOutlet weak var rejectBtn: UIButton!
    var licenseURLString: String?
    private var documentController: UIDocumentInteractionController?
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        if let id = ngoID {
            print("Received NGO ID: \(id)")
        }
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNGODetails()
        tabBarController?.tabBar.isHidden = true
    }
    
    private func uiSetup() {
        ngoNameHeader.numberOfLines = 0
        ngoNameHeader.lineBreakMode = .byWordWrapping
        ngoNameHeader.setContentCompressionResistancePriority(.required, for: .vertical)
        ngoNameHeader.setContentHuggingPriority(.required, for: .vertical)
        self.approveBtn.isHidden = true
        self.rejectBtn.isHidden = true
        bannerImage.contentMode = .scaleAspectFill
        bannerImage.clipsToBounds = true
        ngoLogo.contentMode = .scaleAspectFill
        ngoLogo.clipsToBounds = true
        ngoLogo.layer.cornerRadius = 10
        ngoLogo.layer.borderWidth = 0.5
        ngoLogo.layer.borderColor = UIColor.lightGray.cgColor
        licenseContainer.layer.cornerRadius = 5
        ngoMemberContainer.layer.cornerRadius = 5
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
                } else {
                    self.bannerImage.image = UIImage(named: "NGOBanner")
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
    
    @IBAction func rejectBtnClick(_ sender: Any) {
        guard let ngoID = ngoID else {
            print("NGO ID is nil at reject click")
            return
        }

        guard let vc = storyboard?.instantiateViewController( withIdentifier: "AdminNGOVerificationRejectController") as? AdminNGOVerificationRejectController else {
            fatalError("Storyboard ID not set for AdminNGOVerificationRejectController")
        }

        vc.ngoID = ngoID
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
        }
        
        present(vc, animated: true)
    }
    @IBAction func approveBtnClick(_ sender: Any) {
        guard let ngoID = ngoID else {
            print("ngo ID is nil")
            return
        }
        let db = Firestore.firestore()
        let name = self.ngoName.text ?? "NGO"
        let alert = UIAlertController(
            title: "Approve NGO",message: "Are you sure you want to approve \(name)? This will give them full access to the Khairk.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                if let id = self.ngoID {
                    db.collection("users").document(ngoID).updateData([
                        "applicationStatus": "approved",
                    ]) { error in
                        if let error = error {
                            print("Failed: \(error)")
                        } else {
                            let notification = Notification()
                            notification.save(title: "Application Approved!", body: "Congratulations \(name), your Khairk NGO account has been approved. You can now start with case.", userId: id)
                        }
                    }
                   
                } else {
                    print("Error")
                }

                
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 1. Check the segue identifier to ensure it's the correct transition
        if segue.identifier == "ShowNGOReject" {
            // 2. Check the destination view controller type
            if let userVC = segue.destination as? AdminNGOVerificationRejectController {
                // 3. Check if the sender is the expected data type (the donation ID)
                if let ngoID = sender as? String { // Use the correct type for your ID (e.g., String, UUID, Int)
                    // 4. Pass the data to a property in the destination view controller
                    userVC.ngoID = ngoID
                    segue.destination.navigationItem.title = "NGO Details"
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
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
