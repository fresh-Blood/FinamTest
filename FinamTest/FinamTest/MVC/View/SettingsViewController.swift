import UIKit

final class SettingsViewController: UIViewController {
    
    private let settingsService = SettingsService()
    
    struct Layout {
        let contentInsets: UIEdgeInsets
        
        static var `default`: Layout {
            Layout(contentInsets: UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16))
        }
    }
    
    var closeCompletion: (() -> Void)?
    
    private var currentUserInterfaceStyle: UIUserInterfaceStyle {
        UIScreen.main.traitCollection.userInterfaceStyle
    }
    
    private lazy var layout = Layout.default
    
    private lazy var settingsList: UITableView = {
        let settingsList = UITableView()
        settingsList.backgroundColor = .clear
        settingsList.translatesAutoresizingMaskIntoConstraints = false
        settingsList.showsVerticalScrollIndicator = false
        settingsList.separatorStyle = .none
        settingsList.isScrollEnabled = false 
        settingsList.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.id)
        return settingsList
    }()
    
    // MARK: AppVersion label
    private lazy var appVersionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = SettingsKeys.appVerstion.rawValue + " " + AppVersion.current
        label.textColor = Colors.valueForColor
        label.numberOfLines = .zero
        label.font = .preferredFont(forTextStyle: .caption1)
        label.adjustsFontSizeToFitWidth = true
        label.backgroundColor = .clear
        return label
    }()
    
    // MARK: Life - cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsList.delegate = self
        settingsList.dataSource = self 
        setupUI()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeGradientIfNeeded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.subviews.forEach {
            $0.isHidden = $0.tag == 0
            $0.isHidden = $0.tag == 1
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        closeCompletion?()
    }
    
    // MARK: SetupUI
    private func setupUI() {
        title = SettingsKeys.settings.rawValue
        view.backgroundColor = .systemBackground
        setGradient()
        view.addSubview(settingsList)
        view.addSubview(appVersionLabel)
        showKittenIfDarkDeviceTheme()
        let width: CGFloat = view.frame.width / 3
        
        NSLayoutConstraint.activate([
            appVersionLabel.widthAnchor.constraint(equalToConstant: width),
            appVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appVersionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            settingsList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                        constant: 10),
            settingsList.leftAnchor.constraint(equalTo: view.leftAnchor, constant: layout.contentInsets.left),
            settingsList.rightAnchor.constraint(equalTo: view.rightAnchor, constant: layout.contentInsets.right),
            settingsList.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func showKittenIfDarkDeviceTheme() {
        guard currentUserInterfaceStyle == .dark else { return }
        setGradient()
        let kitten = UIImageView()
        kitten.image = UIImage.gifImageWithName(GifName.kitten.rawValue)
        kitten.translatesAutoresizingMaskIntoConstraints = false
        kitten.backgroundColor = .clear
        view.insertSubview(kitten, belowSubview: appVersionLabel)
        NSLayoutConstraint.activate([
            kitten.leftAnchor.constraint(equalTo: appVersionLabel.rightAnchor, constant: Constants.kittenLeftInsetValue),
            kitten.centerYAnchor.constraint(equalTo: appVersionLabel.centerYAnchor),
            kitten.widthAnchor.constraint(equalToConstant: Constants.kittenSize.width),
            kitten.heightAnchor.constraint(equalToConstant: Constants.kittenSize.height)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.kittenAnimationDuration,
                                      execute: {
            UIView.animate(withDuration: Constants.kittenHidingDuration,
                           delay: .zero,
                           options: .curveEaseOut,
                           animations: {
                kitten.alpha = .zero
            }, completion: {_ in
                kitten.removeFromSuperview()
            })
        })
    }
    
    private func setGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.name = "gradientLayer"
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor.systemBackground.cgColor,
            #colorLiteral(red: 0.0689323023, green: 0.01944343746, blue: 0.03194189072, alpha: 1).cgColor,
            #colorLiteral(red: 0.0862628296, green: 0.08628197759, blue: 0.08625862747, alpha: 1).cgColor
        ]
        view.layer.insertSublayer(gradientLayer, at: .zero)
    }
    
    private func removeGradientIfNeeded() {
        if currentUserInterfaceStyle != .dark {
            let gradientLayer = view.layer.sublayers?.first(where: { $0.name == "gradientLayer" })
            gradientLayer?.removeFromSuperlayer()
        }
    }
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        settingsService.settingsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = settingsList.dequeueReusableCell(withIdentifier: SettingsCell.id, for: indexPath) as? SettingsCell else {
            return UITableViewCell(frame: .zero)
        }
        let model = settingsService.settingsList[indexPath.row]
        cell.update(model: model)
        return cell
    }
}

private enum Constants {
    static let kittenAnimationDuration: Double = 4.5
    static let kittenHidingDuration: Double = 0.3
    static let kittenSize: CGSize = CGSize(width: 190, height: 140)
    static let kittenLeftInsetValue: CGFloat = -70
    static let navBarHeight: CGFloat = 96
}
