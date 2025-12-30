//
//  HelpSupportViewController.swift
//  Khairk
//
//  Created by vkc5 on 05/12/2025.
//

import UIKit

struct CollectorFAQItem {
    let question: String
    let answer: String
}

class CollectorHelpSupportViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var faqContactSegment: UISegmentedControl!      // FAQ / Contact us
    @IBOutlet weak var categorySegment: UISegmentedControl!        // Popular / General / Services
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var faqPopularFiltered: [CollectorFAQItem] = []
    private var faqGeneralFiltered: [CollectorFAQItem] = []
    private var faqServicesFiltered: [CollectorFAQItem] = []
    private var contactFiltered: [ContactItem] = []

    private var isSearching: Bool {
        let text = searchBar.text ?? ""
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // Data
    enum FAQCategory: Int {
        case popular = 0
        case general = 1
        case services = 2
    }

    enum Mode {
        case faq
        case contact
    }

    private var mode: Mode = .faq
    private var selectedCategory: FAQCategory = .popular
    

    private var faqPopular: [CollectorFAQItem] = [
        CollectorFAQItem(
            question: "How can I create a food donation?",
            answer: "You can go to “Donate Food” from your home screen, fill in the food details (name, quantity, expiry date), upload a photo, and select the pickup or delivery option before submitting."
        ),
        CollectorFAQItem(
            question: "How do I track the status of my donation?",
            answer: "Open “Track & Monitor” from your dashboard to view your active and completed donations. Each donation card shows its current status (Pending, Accepted, Collected)."
        ),
        CollectorFAQItem(
            question: "Can I cancel my donation?",
            answer: "Yes, if your donation is still Pending, you can open it from the Track & Monitor list and click Cancel before it’s accepted by a collector."
        ),
        CollectorFAQItem(
            question: "How do I contact the NGO?",
            answer: "In the Track & Monitor page, select your donation and tap Contact NGO to reach out directly to the collector handling your food item."
        ),
        CollectorFAQItem(
            question: "What happens after my donation is collected?",
            answer: "Once the collector marks your donation as Collected, it will move to the History section where you can see your completed donations and their details."
        ),
        CollectorFAQItem(
            question: "Can I edit my profile or change my password?",
            answer: "Go to Profile → Edit Profile to update your information, or select Change Password under Settings to reset your password securely."
        ),
        CollectorFAQItem(
            question: "How do notifications work in the app?",
            answer: "You’ll automatically receive alerts for important updates — such as when your donation is accepted, collected, or if your NGO verification is approved. You can mute them from Notifications."
        ),
        CollectorFAQItem(
            question: "Can I view nearby NGOs I can donate to?",
            answer: "Yes, tap Map to view approved NGOs near your area or open NGO Discovery to browse their missions and activities."
        ),
        CollectorFAQItem(
            question: "What is the Community Impact section for?",
            answer: "The Community Impact page shows collective statistics, such as total meals provided and donations made, helping users see how their contributions make a difference in the community."
        )
    ]

    private var faqGeneral: [CollectorFAQItem] = [
        CollectorFAQItem(
            question: "What is the Khairk app?",
            answer: "Khairk is a community-based food donation platform that connects donors and NGOs to reduce food waste and help people in need across Bahrain."
        ),
        CollectorFAQItem(
            question: "Who can use Khairk?",
            answer: "Anyone can register as a Donor or an NGO (Collector) through the app’s signup page."
        ),
        CollectorFAQItem(
            question: "Can I switch my account type later?",
            answer: "No, once you register as a Donor or NGO, that role stays linked to your account. You can create another account if needed."
        ),
        CollectorFAQItem(
            question: "Is Khairk free to use?",
            answer: "Yes, the app is completely free for both donors and NGOs."
        ),
        CollectorFAQItem(
            question: "What happens after my donation is collected?",
            answer: "Once the collector marks your donation as Collected, it will move to the History section where you can see your completed donations and their details."
        ),
        CollectorFAQItem(
            question: "Can I share my donation on social media?",
            answer: "Yes, you can share your impact or donation summaries using the Social Sharing feature."
        ),
        CollectorFAQItem(
            question: "What is the Plant of Goodness feature?",
            answer: "It’s a reward system that grows your virtual plant as you donate more food — each level represents your impact in reducing food waste."
        ),
        CollectorFAQItem(
            question: "How do I level up my plant?",
            answer: "You earn experience (EXP) every time you complete a donation. Once you reach a set amount of EXP, your plant levels up automatically."
        ),
        CollectorFAQItem(
            question: "What happens when I level up?",
            answer: "When you reach a new level, you’ll see a “Congratulations” screen and may earn a free spin for a small reward or recognition inside the app."
        )
    ]

    private var faqServices: [CollectorFAQItem] = [
        CollectorFAQItem(
            question: "How do I sign up for the project?",
            answer: "Tap the Donate Now button on any NGO campaign to make a secure donation in seconds."
        ),
        CollectorFAQItem(
            question: "Can I donate multiple items at once?",
            answer: "Yes, the app allows bulk donations, so you can list several food items in one submission."
        ),
        CollectorFAQItem(
            question: "How do I know if my donation is accepted?",
            answer: "You’ll receive a notification once an NGO accepts your donation, and the status will change to “Accepted” in Track & Monitor."
        ),
        CollectorFAQItem(
            question: "How can I check my donation progress?",
            answer: "Open My Donations, where you’ll see your active and completed donations with real-time updates."
        ),
        CollectorFAQItem(
            question: "How do I know if the collector is on the way?",
            answer: "You’ll receive a pickup reminder notification when your donation has been assigned and scheduled."
        ),
        CollectorFAQItem(
            question: "Can I set a preferred pickup location?",
            answer: "Yes, you can select a pickup address or point from your Donation Form when submitting."
        ),
        CollectorFAQItem(
            question: "What types of food can I donate?",
            answer: "You can donate fresh, cooked, or packaged food, as long as it’s safe and within the expiry period."
        ),
        CollectorFAQItem(
            question: "How does the NGO rating system work?",
            answer: "After a donation is collected, you can rate the NGO based on pickup speed and service quality."
        ),
        CollectorFAQItem(
            question: "Can I see my total donations made so far?",
            answer: "Yes, the History section and Community Impact page show your donation count and achievements."
        )
    ]


    // Contact us
    private struct ContactItem {
        let title: String
        let detail: String
    }

    private var contactOptions: [ContactItem] = [
        ContactItem(title: "WhatsApp",  detail: "+973 39997777"),
        ContactItem(title: "Instagram", detail: "@khairk.bh"),
        ContactItem(title: "Email",     detail: "support@khairk.bh"),
        ContactItem(title: "Twitter",   detail: "@khairkApp")
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        setupSegments()
        setupTableView()

        searchBar.delegate = self
        searchBar.placeholder = "Search"

        resetFilteredData()
        reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 22, weight: .semibold),
            .foregroundColor: UIColor.white
        ]
    }
    
    func setupSegments() {
        // FAQ / Contact us
        faqContactSegment.removeAllSegments()
        faqContactSegment.insertSegment(withTitle: "FAQ", at: 0, animated: false)
        faqContactSegment.insertSegment(withTitle: "Contact us", at: 1, animated: false)
        faqContactSegment.selectedSegmentIndex = 0

        // Categories
        categorySegment.removeAllSegments()
        categorySegment.insertSegment(withTitle: "Popular Topic", at: 0, animated: false)
        categorySegment.insertSegment(withTitle: "General", at: 1, animated: false)
        categorySegment.insertSegment(withTitle: "Services", at: 2, animated: false)
        categorySegment.selectedSegmentIndex = 0

        // Actions
        faqContactSegment.addTarget(self, action: #selector(modeChanged(_:)), for: .valueChanged)
        categorySegment.addTarget(self, action: #selector(categoryChanged(_:)), for: .valueChanged)
    }

    @objc func modeChanged(_ sender: UISegmentedControl) {
        mode = sender.selectedSegmentIndex == 0 ? .faq : .contact
        // hide category segment when in Contact mode
        categorySegment.isHidden = (mode == .contact)
        reloadData()
        searchBar.text = ""
        applySearchFilter("")
    }

    @objc func categoryChanged(_ sender: UISegmentedControl) {
        selectedCategory = FAQCategory(rawValue: sender.selectedSegmentIndex) ?? .popular
        reloadData()
        searchBar.text = ""
        applySearchFilter("")
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    func reloadData() {
        tableView.reloadData()
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch mode {
        case .faq:
            switch selectedCategory {
            case .popular: return (isSearching ? faqPopularFiltered.count : faqPopular.count)
            case .general: return (isSearching ? faqGeneralFiltered.count : faqGeneral.count)
            case .services: return (isSearching ? faqServicesFiltered.count : faqServices.count)
            }
        case .contact:
            return isSearching ? contactFiltered.count : contactOptions.count
        }
    }


    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FAQCell", for: indexPath)

        if mode == .contact {
            let item = isSearching ? contactFiltered[indexPath.row] : contactOptions[indexPath.row]
            cell.textLabel?.text = item.title
        } else {
            let item: CollectorFAQItem
            switch selectedCategory {
            case .popular:
                item = isSearching ? faqPopularFiltered[indexPath.row] : faqPopular[indexPath.row]
            case .general:
                item = isSearching ? faqGeneralFiltered[indexPath.row] : faqGeneral[indexPath.row]
            case .services:
                item = isSearching ? faqServicesFiltered[indexPath.row] : faqServices[indexPath.row]
            }

            cell.textLabel?.text = item.question
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            cell.textLabel?.textColor = .black
            cell.textLabel?.numberOfLines = 1
            cell.textLabel?.lineBreakMode = .byTruncatingTail

        }

        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if mode == .contact {
            let item = isSearching ? contactFiltered[indexPath.row] : contactOptions[indexPath.row]
            let alert = UIAlertController(title: item.title, message: item.detail, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }

        let item: CollectorFAQItem
        switch selectedCategory {
        case .popular:
            item = isSearching ? faqPopularFiltered[indexPath.row] : faqPopular[indexPath.row]
        case .general:
            item = isSearching ? faqGeneralFiltered[indexPath.row] : faqGeneral[indexPath.row]
        case .services:
            item = isSearching ? faqServicesFiltered[indexPath.row] : faqServices[indexPath.row]
        }

        let alert = UIAlertController(title: item.question, message: item.answer, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    
    private func resetFilteredData() {
        faqPopularFiltered = faqPopular
        faqGeneralFiltered = faqGeneral
        faqServicesFiltered = faqServices
        contactFiltered = contactOptions
    }
    
    private func applySearchFilter(_ query: String) {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if q.isEmpty {
            resetFilteredData()
            tableView.reloadData()
            return
        }

        // Filter FAQ (question OR answer)
        faqPopularFiltered = faqPopular.filter {
            $0.question.lowercased().contains(q) || $0.answer.lowercased().contains(q)
        }

        faqGeneralFiltered = faqGeneral.filter {
            $0.question.lowercased().contains(q) || $0.answer.lowercased().contains(q)
        }

        faqServicesFiltered = faqServices.filter {
            $0.question.lowercased().contains(q) || $0.answer.lowercased().contains(q)
        }

        // Filter Contact (title OR detail)
        contactFiltered = contactOptions.filter {
            $0.title.lowercased().contains(q) || $0.detail.lowercased().contains(q)
        }

        tableView.reloadData()
    }


    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            applySearchFilter(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            applySearchFilter("")
            searchBar.resignFirstResponder()
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
