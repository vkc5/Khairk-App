import Foundation
import FirebaseFirestore

struct NgoCase {
    let id: String
    let title: String
    let measurements: String
    let goal: Int
    let collected: Int
    let startDate: Date
    let endDate: Date
    let details: String
    let imageURL: String?
    let status: String
    let ngoId: String
    let ngoName: String

    init(
        id: String,
        title: String,
        measurements: String,
        goal: Int,
        collected: Int,
        startDate: Date,
        endDate: Date,
        details: String,
        imageURL: String?,
        status: String,
        ngoId: String,
        ngoName: String
    ) {
        self.id = id
        self.title = title
        self.measurements = measurements
        self.goal = goal
        self.collected = collected
        self.startDate = startDate
        self.endDate = endDate
        self.details = details
        self.imageURL = imageURL
        self.status = status
        self.ngoId = ngoId
        self.ngoName = ngoName
    }

    init?(doc: DocumentSnapshot) {
        guard let data = doc.data() else { return nil }

        let title = data["title"] as? String ?? ""
        let measurements = data["measurements"] as? String ?? ""

        let goal =
            (data["Goal"] as? Int)
            ?? (data["goal"] as? Int)
            ?? (data["Goal"] as? NSNumber)?.intValue
            ?? (data["goal"] as? NSNumber)?.intValue
            ?? 0

        let collected =
            (data["Collected"] as? Int)
            ?? (data["collected"] as? Int)
            ?? (data["Collected"] as? NSNumber)?.intValue
            ?? (data["collected"] as? NSNumber)?.intValue
            ?? 0

        let startTS = data["startDate"] as? Timestamp
        let endTS = data["endDate"] as? Timestamp
        let startDate = startTS?.dateValue() ?? Date()
        let endDate = endTS?.dateValue() ?? Date()

        let details = data["description"] as? String ?? ""
        let imageURL = data["imageURL"] as? String
        let status = data["status"] as? String ?? "active"
        let ngoId = data["ngoID"] as? String ?? ""
        let ngoName = data["name"] as? String ?? ""

        self.init(
            id: doc.documentID,
            title: title,
            measurements: measurements,
            goal: goal,
            collected: collected,
            startDate: startDate,
            endDate: endDate,
            details: details,
            imageURL: imageURL,
            status: status,
            ngoId: ngoId,
            ngoName: ngoName
        )
    }


    var asFirestoreData: [String: Any] {
        var data: [String: Any] = [
            "title": title,
            "measurements": measurements,
            "Goal": goal,
            "Collected": collected,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "description": details,
            "imageURL": imageURL as Any,
            "status": status,
            "ngoID": ngoId,
        ]

        if !ngoName.isEmpty {
            data["name"] = ngoName
        }

        return data
    }
}
