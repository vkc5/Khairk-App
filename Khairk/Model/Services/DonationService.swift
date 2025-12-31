//
//  DonationService.swift
//  Khairk
//
//  Created by FM on 18/12/2025.
//

import Foundation
import FirebaseFirestore

final class DonationService {

    static let shared = DonationService()
    private let db = Firestore.firestore()
    private init() {}

    func createDonation(
        foodName: String,
        quantity: Int,
        expiryDate: Date,
        description: String,
        donationType: String,
        imageURL: String,
        pickupTime: Date? = nil,
        serviceArea: String? = nil,
        buildingNumber: String? = nil,
        block: String? = nil,
        street: String? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        completion: @escaping (Result<String, Error>) -> Void
    ) {

        var donationData: [String: Any] = [
            "foodName": foodName,
            "quantity": quantity,
            "expiryDate": Timestamp(date: expiryDate),
            "description": description,
            "donationType": donationType,          // "pickup" or "delivery"
            "imageURL": imageURL,
            "donorId": "",
            "status": "accepted",
            "createdAt": Timestamp()
        ]

        if let pickupTime = pickupTime {
            donationData["pickupTime"] = Timestamp(date: pickupTime)
        }

        if let serviceArea = serviceArea { donationData["serviceArea"] = serviceArea }
        if let buildingNumber = buildingNumber { donationData["buildingNumber"] = buildingNumber }
        if let block = block { donationData["block"] = block }
        if let street = street { donationData["street"] = street }
        if let latitude = latitude { donationData["latitude"] = latitude }
        if let longitude = longitude { donationData["longitude"] = longitude }

        let ref = db.collection("donations").document()
        ref.setData(donationData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(ref.documentID))
            }
        }
    }
}
