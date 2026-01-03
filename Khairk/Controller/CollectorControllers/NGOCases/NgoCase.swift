import Foundation
import FirebaseFirestore

struct NgoCase {
    let id: String
    let title: String
    let foodType: String
    let goal: Int
    let collected: Int
    let startDate: Date
    let endDate: Date
    let details: String
    let imageURL: String?
    let status: String

    init(
        id: String,
        title: String,
        foodType: String,
        goal: Int,
        collected: Int,
        startDate: Date,
        endDate: Date,
        details: String,
        imageURL: String?,
        status: String
    ) {
        self.id = id
        self.title = title
        self.foodType = foodType
        self.goal = goal
        self.collected = collected
        self.startDate = startDate
        self.endDate = endDate
        self.details = details
        self.imageURL = imageURL
        self.status = status
    }

    init?(doc: DocumentSnapshot) {
        guard let data = doc.data() else { return nil }

        let title = data["title"] as? String ?? ""
        let foodType = data["foodType"] as? String ?? ""

        // ✅ support both "goal" and "Goal"
        let goal =
            (data["goal"] as? Int)
            ?? (data["Goal"] as? Int)
            ?? (data["goal"] as? NSNumber)?.intValue
            ?? (data["Goal"] as? NSNumber)?.intValue
            ?? 0

        let collected =
            (data["collected"] as? Int)
            ?? (data["Collected"] as? Int)
            ?? (data["collected"] as? NSNumber)?.intValue
            ?? (data["Collected"] as? NSNumber)?.intValue
            ?? 0

        let startTS = data["startDate"] as? Timestamp
        let endTS = data["endDate"] as? Timestamp
        let startDate = startTS?.dateValue() ?? Date()
        let endDate = endTS?.dateValue() ?? Date()

        let details = data["description"] as? String ?? ""
        let imageURL = data["imageURL"] as? String
        let status = data["status"] as? String ?? "active"

        self.init(
            id: doc.documentID,
            title: title,
            foodType: foodType,
            goal: goal,
            collected: collected,
            startDate: startDate,
            endDate: endDate,
            details: details,
            imageURL: imageURL,
            status: status
        )
    }


    var asFirestoreData: [String: Any] {
        [
            "title": title,
            "foodType": foodType,
            "goal": goal,
            "collected": collected,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "description": details,
            "imageURL": imageURL as Any,
            "status": status,
            "createdAt": FieldValue.serverTimestamp(),
        ]
    }
}
