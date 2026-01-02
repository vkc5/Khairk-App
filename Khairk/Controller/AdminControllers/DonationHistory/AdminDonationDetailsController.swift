//
//  AdminDonationDetailsController.swift
//  Khairk
//
//  Created by BP-19-130-16 on 28/12/2025.
//

import UIKit
import FirebaseFirestore
import MapKit

class AdminDonationDetailsController: UIViewController, MKMapViewDelegate{
    var donationID: String?

    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var foodNameLabel: UILabel!
    @IBOutlet weak var foodNameHeaderLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var expiresSoonContainer: UIView!
    @IBOutlet weak var expiresSoonAlert: UIView!
    @IBOutlet weak var expiresSoonIcon: UIImageView!
    @IBOutlet weak var expireSoonText: UITextView!
    
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var donationTypeLabel: UILabel!
    @IBOutlet weak var Quantity: UILabel!
    @IBOutlet weak var expireDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var donerContainer: UIView!
    @IBOutlet weak var donarImage: UIImageView!
    @IBOutlet weak var donerName: UILabel!
    @IBOutlet weak var donerEmail: UILabel!
    @IBOutlet weak var donerPhoneNumber: UILabel!
    
    @IBOutlet weak var ngoImage: UIImageView!
    @IBOutlet weak var ngoName: UILabel!
    @IBOutlet weak var ngoEmail: UILabel!
    @IBOutlet weak var ngoPhoneNumber: UILabel!
    @IBOutlet weak var ngoContainer: UIView!
    
    @IBOutlet weak var ngoCaseImage: UIImageView!
    @IBOutlet weak var ngoCaseTitle: UILabel!
    @IBOutlet weak var ngoCaseBody: UILabel!
    @IBOutlet weak var ngoCaseContainer: UIView!
    
    @IBOutlet weak var locationContainer: UIView!
    @IBOutlet weak var locationMapView: MKMapView!
    @IBOutlet weak var locationTitle: UILabel!
    @IBOutlet weak var locationAddress: UILabel!
    @IBOutlet weak var pickupTimeStampContainer: UIStackView!
    @IBOutlet weak var pickupTime: UILabel!
    @IBOutlet weak var pickupDate: UILabel!
    private var donationCoords: CLLocationCoordinate2D?
    private var ngoCoords: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uiSetup()
        locationMapView.delegate = self
        if let id = donationID {
            print("Received Donation ID: \(id)")
            fetchDonationDetails()
            
        }
        // Do any additional setup after loading the view.
    }
    
    private func uiSetup() {
        pickupTimeStampContainer.isHidden = true
        foodImage.contentMode = .scaleAspectFill
        foodImage.clipsToBounds = true
        foodImage.layer.cornerRadius = 5
        expiresSoonAlert.layer.cornerRadius = 5
        expiresSoonIcon.layer.cornerRadius = 2
        
        donerContainer.layer.cornerRadius = 5
        donarImage.layer.cornerRadius = donarImage.frame.width / 2
        donarImage.clipsToBounds = true
        donarImage.contentMode = .scaleAspectFill
        
        ngoCaseContainer.layer.cornerRadius = 5
        ngoCaseImage.contentMode = .scaleAspectFill
        ngoCaseImage.clipsToBounds = true
        ngoCaseImage.layer.cornerRadius = 5
        
        ngoContainer.layer.cornerRadius = 5
        ngoImage.layer.cornerRadius = 5
        ngoImage.clipsToBounds = true
        ngoImage.contentMode = .scaleAspectFill
        ngoImage.layer.borderWidth = 1
        ngoImage.layer.borderColor = UIColor.lightGray.cgColor
        
        locationContainer.layer.cornerRadius = 5
        locationMapView.layer.cornerRadius = 5
        locationMapView.isUserInteractionEnabled = true
        locationMapView.isZoomEnabled = true
        locationMapView.isScrollEnabled = true
        pickupTimeStampContainer.distribution = .fillEqually
        
    }
    
    private func setupMap(with coordinate: CLLocationCoordinate2D, title: String) {
        locationMapView.removeAnnotations(locationMapView.annotations)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        pin.title = title
        locationMapView.addAnnotation(pin)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        locationMapView.setRegion(region, animated: true)
    }
    
    private func fetchDonationDetails() {
        guard let donationID = donationID else {
            print("Donation ID is nil")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("donations").document(donationID).getDocument { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
  
            guard let snapshot = querySnapshot,
                  let data = snapshot.data(),
                  let donation = Donation(id: snapshot.documentID, dictionary: data)
            else {
                print("Donation not found or parsing failed")
                return
            }
            
            if let lat = donation.latitude, let lon = donation.longitude {
                self.donationCoords = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            

            // Reload table view on main thread
            DispatchQueue.main.async {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_BH")
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                
                let timeFormatter = DateFormatter()
                timeFormatter.locale = Locale(identifier: "en_BH")
                timeFormatter.dateStyle = .none
                timeFormatter.timeStyle = .short
                
                self.foodImage.loadImage(from: donation.imageURL)
                self.idLabel.text = "ID: \(donation.id)"
                self.foodNameLabel.text = donation.foodName
                self.foodNameHeaderLabel.text = donation.foodName
                self.statusLabel.text = donation.status
                self.createdAtLabel.text = dateFormatter.string(from: donation.createdAt)
                self.donationTypeLabel.text = donation.donationType
                self.Quantity.text = "\(donation.quantity)"
                self.expireDateLabel.text = "At \(dateFormatter.string(from: donation.expiryDate)) on \(timeFormatter.string(from: donation.expiryDate))"
                self.descriptionLabel.text = donation.description
                
                let calendar = Calendar.current
                if let daysUntilExpiration = calendar.dateComponents([.day], from: Date(), to: donation.expiryDate).day {
                    self.expiresSoonContainer.isHidden = daysUntilExpiration > 2
                } else {
                    self.expiresSoonContainer.isHidden = true
                }
                
                if donation.donationType.lowercased() == "delivery" {
                    if let coords = self.donationCoords {
                        self.setupMap(with: coords, title: "Donor's Delivery Location")
                    }
                    self.locationTitle.text = "Delivery Location"
                    self.locationAddress.text = donation.serviceArea ?? "Specified delivery zone"
                } else {
                    
                    if let pTime = donation.pickupTime {
                        self.pickupDate.text = dateFormatter.string(from: pTime)
                        self.pickupTime.text = timeFormatter.string(from: pTime)
                    }
                }

            }
            
            fetchDoner(donation.donorId)
            fetchNgoCase(donation.caseId)
        }
    }
    
    private func fetchDoner(_ id: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(id).getDocument { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
  
            guard let snapshot = querySnapshot,
                  let data = snapshot.data(),
                  let name = data["name"] as? String,
                  let phoneNumber = data["phone"] as? String,
                  let email = data["email"] as? String,
                  let imageURL = data["profileImageUrl"] as? String
            else {
                print("Doner not found or parsing failed")
                return
            }
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.donarImage.loadImage(from: imageURL)
                self.donerName.text = name
                self.donerEmail.text = email
                self.donerPhoneNumber.text = phoneNumber
               
            }
        }
    }
    
    private func fetchNgoCase(_ id: String) {
        let db = Firestore.firestore()
        
        db.collection("ngoCases").document(id).getDocument { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
  
            guard let snapshot = querySnapshot,
                  let data = snapshot.data(),
                  let title = data["title"] as? String,
                  let body = data["description"] as? String,
                  let imageURL = data["imageURL"] as? String,
                  let ngoId = data["ngoID"] as? String
            else {
                print("Case not found or parsing failed")
                return
            }

            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.ngoCaseImage.loadImage(from: imageURL)
                self.ngoCaseTitle.text = title
                self.ngoCaseBody.text = body
            }
            
            fetchNgo(ngoId)
        }
    }
    
    private func fetchNgo(_ id: String) {
        let db = Firestore.firestore()
        
        db.collection("users").document(id).getDocument { [weak self] querySnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
  
            guard let snapshot = querySnapshot,
                  let data = snapshot.data(),
                  let name = data["name"] as? String,
                  let phoneNumber = data["phone"] as? String,
                  let email = data["email"] as? String,
                  let imageURL = data["logoUrl"] as? String,
                  let area = data["serviceArea"] as? String
            else {
                print("Donation not found or parsing failed")
                return
            }
            
            if let geoPoint = data["ngoLocation"] as? GeoPoint {
                self.ngoCoords = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
            }
            
            // Reload table view on main thread
            DispatchQueue.main.async {
                self.ngoImage.loadImage(from: imageURL)
                self.ngoName.text = name
                self.ngoEmail.text = email
                self.ngoPhoneNumber.text = phoneNumber
                if self.donationTypeLabel.text?.lowercased() == "pickup" {
                    if let coords = self.ngoCoords {
                        self.setupMap(with: coords, title: "\(name) Location")
                    }
                    self.locationTitle.text = "\(name) Location"
                    self.locationAddress.text = area
                    self.pickupTimeStampContainer.isHidden = false
                }
               
            }
        }
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
