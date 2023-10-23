import UIKit

class SettingsViewController: UIViewController {
    private lazy var settings = [
        SettingsModel(name: SettingsKeys.soundSettings.rawValue),
        SettingsModel(name: SettingsKeys.newsTheme.rawValue, rightTitle: StorageService.shared.selectedCategory)
    ]
    
    struct Layout {
        let contentInsets: UIEdgeInsets
        
        static var `default`: Layout {
            Layout(contentInsets: UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16))
        }
    }
    
    private var currentUserInterfaceStyle: UIUserInterfaceStyle {
        UIScreen.main.traitCollection.userInterfaceStyle
    }
    
    lazy var layout = Layout.default
    
    lazy var settingsList: UITableView = {
        let settingsList = UITableView()
        settingsList.backgroundColor = .clear
        settingsList.translatesAutoresizingMaskIntoConstraints = false
        settingsList.showsVerticalScrollIndicator = false
        settingsList.separatorStyle = .none
        settingsList.isScrollEnabled = false 
        settingsList.delegate = self
        settingsList.dataSource = self
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
        setupUI()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeGradientIfNeeded()
    }
    
    // MARK: SetupUI
    func setupUI() {
        title = SettingsKeys.settings.rawValue
        view.backgroundColor = .systemBackground
        
        setGradient()
        
        view.addSubview(settingsList)
        view.addSubview(appVersionLabel)
        
        showKittenIfDarkDeviceTheme()
        
        let width: CGFloat = view.frame.width / 3
        
        NSLayoutConstraint.activate([
            settingsList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            settingsList.leftAnchor.constraint(equalTo: view.leftAnchor, constant: layout.contentInsets.left),
            settingsList.rightAnchor.constraint(equalTo: view.rightAnchor, constant: layout.contentInsets.right),
            
            appVersionLabel.topAnchor.constraint(equalTo: settingsList.bottomAnchor, constant: 16),
            appVersionLabel.widthAnchor.constraint(equalToConstant: width),
            appVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appVersionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
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
            #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).cgColor,
            #colorLiteral(red: 0.08748871833, green: 0.08748871833, blue: 0.08748871833, alpha: 1).cgColor,
            #colorLiteral(red: 0.08748871833, green: 0.08748871833, blue: 0.08748871833, alpha: 1).cgColor
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = settingsList.dequeueReusableCell(withIdentifier: SettingsCell.id, for: indexPath) as? SettingsCell else {
            return UITableViewCell(frame: .zero)
        }
        let model = settings[indexPath.section]
        cell.update(model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section != 0 else { return .zero }
        return .zero
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        settings.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 1:
                let chooseThemeVc = UIAlertController(title: Categories.title,
                                                      message: Categories.title,
                                                      preferredStyle: .actionSheet)
                
                chooseThemeVc.prepairForIPad(withVCView: view, withVC: self)
                
                Categories.allCases.forEach { category in
                    chooseThemeVc.addAction(UIAlertAction(title: category.rawValue,
                                                          style: .default,
                                                          handler: { [weak self] action in
                        guard let self else { return }
                        StorageService.shared.save(category.rawValue, forKey: Categories.key)
                        navigationController?.popToRootViewController(animated: true)
                    }))
                }
                
                present(chooseThemeVc, animated: true)
                
            default:
                break 
        }
    }
}

private enum Constants {
    static let kittenAnimationDuration: Double = 4.5
    static let kittenHidingDuration: Double = 0.3
    static let kittenSize: CGSize = CGSize(width: 190, height: 140)
    static let kittenLeftInsetValue: CGFloat = -70
    static let navBarHeight: CGFloat = 96
}
