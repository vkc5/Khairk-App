import FirebaseFirestore
import UserNotifications

final class DonationNotificationService {

    static let shared = DonationNotificationService()

    private let db = Firestore.firestore()
    private var donationListener: ListenerRegistration?

    /// Track already scheduled notifications (avoid duplicates)
    private var scheduledDonationIds = Set<String>()

    private init() {}


    func monitorExpiryForUser(userId: String, role: String) {
        print("👀 Monitoring expiry for role:", role, "user:", userId)

        let collection = db.collection("donations")
        let query: Query

        if role == "admin" {
            query = collection
                .whereField("pickupStatus", in: ["pending", "in_progress", "accepted"])
        } else if role == "collector" {
            query = collection
                .whereField("ngoId", isEqualTo: userId)
                .whereField("pickupStatus", in: ["in_progress", "accepted"])
        } else {
            return
        }

        donationListener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Donation monitor error:", error.localizedDescription)
                return
            }

            guard let documents = snapshot?.documents else { return }

            let now = Date()

            for doc in documents {

                if self.scheduledDonationIds.contains(doc.documentID) {
                    continue
                }

                guard let donation = Donation(doc: doc) else { continue }

                guard donation.expiryDate > now else { continue }

                Notification.shared.scheduleExpiryCheck(
                    donationId: donation.id,
                    foodName: donation.foodName,
                    expiryDate: donation.expiryDate
                )

                self.scheduledDonationIds.insert(donation.id)

                print("⏰ Expiry notification scheduled for:", donation.foodName)
            }
        }
    }

    // MARK: - Stop Monitoring

    func stopMonitoring() {
        donationListener?.remove()
        donationListener = nil
        scheduledDonationIds.removeAll()
        print("🛑 Stopped monitoring donations.")
    }
}
