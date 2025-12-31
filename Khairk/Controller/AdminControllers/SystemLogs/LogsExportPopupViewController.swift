import UIKit

final class LogsExportPopupViewController: UIViewController {

    enum State {
        case confirm
        case success
        case failure
    }

    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()
    private let primaryButton = UIButton(type: .system)
    private let secondaryButton = UIButton(type: .system)

    private let state: State
    private let primaryTitle: String
    private let secondaryTitle: String
    private let onPrimary: () -> Void
    private let onSecondary: () -> Void

    init(
        title: String,
        message: String,
        state: State,
        primaryTitle: String,
        secondaryTitle: String,
        onPrimary: @escaping () -> Void,
        onSecondary: @escaping () -> Void
    ) {
        self.state = state
        self.primaryTitle = primaryTitle
        self.secondaryTitle = secondaryTitle
        self.onPrimary = onPrimary
        self.onSecondary = onSecondary
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        messageLabel.text = message
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        applyState()
    }

    private func setupLayout() {
        view.backgroundColor = .clear

        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        view.addSubview(cardView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.font = UIFont.systemFont(ofSize: 13)
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        primaryButton.translatesAutoresizingMaskIntoConstraints = false
        primaryButton.setTitle(primaryTitle, for: .normal)
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        primaryButton.layer.cornerRadius = 16
        primaryButton.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        primaryButton.addTarget(self, action: #selector(primaryTapped), for: .touchUpInside)

        secondaryButton.translatesAutoresizingMaskIntoConstraints = false
        secondaryButton.setTitle(secondaryTitle, for: .normal)
        secondaryButton.setTitleColor(UIColor(named: "MainBrand-500") ?? UIColor.systemGreen, for: .normal)
        secondaryButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        secondaryButton.layer.cornerRadius = 16
        secondaryButton.layer.borderWidth = 1
        secondaryButton.layer.borderColor = (UIColor(named: "MainBrand-500") ?? UIColor.systemGreen).cgColor
        secondaryButton.addTarget(self, action: #selector(secondaryTapped), for: .touchUpInside)

        cardView.addSubview(titleLabel)
        cardView.addSubview(messageLabel)
        cardView.addSubview(primaryButton)
        cardView.addSubview(secondaryButton)

        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 280),

            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            primaryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            primaryButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            primaryButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            primaryButton.heightAnchor.constraint(equalToConstant: 40),

            secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: 10),
            secondaryButton.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            secondaryButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            secondaryButton.heightAnchor.constraint(equalToConstant: 40),
            secondaryButton.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16),
        ])
    }

    private func applyState() {
        switch state {
        case .confirm:
            break
        case .success:
            break
        case .failure:
            primaryButton.backgroundColor = UIColor(named: "MainBrand-500") ?? UIColor.systemGreen
        }
    }

    @objc private func primaryTapped() {
        dismiss(animated: true) { [onPrimary] in
            onPrimary()
        }
    }

    @objc private func secondaryTapped() {
        dismiss(animated: true) { [onSecondary] in
            onSecondary()
        }
    }
}
