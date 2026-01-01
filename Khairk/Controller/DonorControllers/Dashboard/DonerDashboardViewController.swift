
import UIKit

class DonerDashboardViewController: UIViewController {

    // MARK: - Outlets

    // Top boxes (Map, Hub, MyDonation, Goodness, Stats)
    @IBOutlet weak var ngoMapView: UIView!
    @IBOutlet weak var donorHubView: UIView!
    @IBOutlet weak var myDonationView: UIView!
    @IBOutlet weak var goodnessView: UIView!
    @IBOutlet weak var statsView: UIView!

    // Goal cards
    @IBOutlet weak var goalCard1: UIView!
    @IBOutlet weak var goalCard2: UIView!

    // Spotlight cards (two)
    @IBOutlet weak var spotlightView1: UIView!
    @IBOutlet weak var spotlightView2: UIView!


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // TOP BOXES
        styleTopBox(ngoMapView)
        styleTopBox(donorHubView)
        styleTopBox(myDonationView)
        styleTopBox(goodnessView)
        styleTopBox(statsView)

        // GOAL CARDS
        styleGoalCard(goalCard1)
        styleGoalCard(goalCard2)

        // SPOTLIGHT (gradient added after layout)
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }


    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // gradient must be re-applied after the view gets its final size
        styleSpotlight(spotlightView1)
        styleSpotlight(spotlightView2)
    }


    // MARK: - Style Functions

    // Top small boxes
    func styleTopBox(_ view: UIView) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.clipsToBounds = true
    }

    // Goal cards (bigger radius)
    func styleGoalCard(_ view: UIView) {
        // Rounded card
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.masksToBounds = true

        // INNER PADDING (this fixes the issue you want)
        view.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        view.preservesSuperviewLayoutMargins = false
    }


    // Spotlight gradient style
    func styleSpotlight(_ view: UIView) {

        // Remove old gradient layers to avoid stacking
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradient = CAGradientLayer()
        gradient.frame = view.bounds

        // Green gradient left → right
        gradient.colors = [
            UIColor(red: 0/255, green: 140/255, blue: 80/255, alpha: 1).cgColor,
            UIColor(red: 0/255, green: 180/255, blue: 100/255, alpha: 1).cgColor
        ]

        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)

        gradient.cornerRadius = 16

        // Insert gradient at background
        view.layer.insertSublayer(gradient, at: 0)

        view.layer.cornerRadius = 16
        view.clipsToBounds = true
    }

}
