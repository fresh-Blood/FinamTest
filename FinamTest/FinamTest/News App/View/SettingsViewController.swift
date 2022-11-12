import UIKit

final class SettingsViewController: UIViewController {
    
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
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: Sound
    private lazy var soundsSettingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .natural
        label.text = SettingsKeys.soundWord.rawValue
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
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
    
    // MARK: Sound Switcher
    private lazy var soundSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(switcherValueDidChange), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    @objc private func switcherValueDidChange(sender: UISwitch) {
        soundSwitcher.setOn(sender.isOn, animated: true)
        StorageService.shared.saveData(with: sender.isOn, for: SettingsKeys.soundSettings.rawValue)
    }
    
    // MARK: Developer Switcher
    private lazy var developerInfoSwitcher: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(showDeveloperInfo), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    // MARK: Developer info
    @objc private func showDeveloperInfo(sender: UISwitch) {
        if sender.isOn {
            let alertVC = UIAlertController(title: DeveloperInfo.title.rawValue, message: DeveloperInfo.message.rawValue, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
                alertVC.dismiss(animated: true, completion: nil)
                sender.setOn(!sender.isOn, animated: true)
            }))
            alertVC.prepairForIPad(withVCView: view, withVC: self)
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    private lazy var developerInfoLabel: UILabel = {
        let label = UILabel()
        label.text = SettingsKeys.info.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .natural
        label.numberOfLines = .zero
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private func getHorizontalStack() -> UIStackView {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalCentering
        stack.isUserInteractionEnabled = true
        return stack
    }

    // MARK: Life - cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupUserSoundSettings()
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
        let soundStack = getHorizontalStack()
        let infoStack = getHorizontalStack()
        soundStack.addArrangedSubview(soundsSettingsLabel)
        soundStack.addArrangedSubview(soundSwitcher)
        infoStack.addArrangedSubview(developerInfoLabel)
        infoStack.addArrangedSubview(developerInfoSwitcher)
        bgView.addSubview(soundStack)
        bgView.addSubview(infoStack)
        view.addSubview(bgView)
        view.addSubview(appVersionLabel)
        showKittenIfDarkDeviceTheme()
        let width: CGFloat = view.frame.width / 3
        
        NSLayoutConstraint.activate([
            appVersionLabel.widthAnchor.constraint(equalToConstant: width),
            appVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appVersionLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40),
            
            bgView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                        constant: 10),
            bgView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: layout.contentInsets.left),
            bgView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: layout.contentInsets.right),

            soundStack.topAnchor.constraint(equalTo: bgView.topAnchor, constant: layout.contentInsets.top),
            soundStack.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: layout.contentInsets.left),
            soundStack.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: layout.contentInsets.bottom),
            
            infoStack.topAnchor.constraint(equalTo: soundStack.bottomAnchor, constant: layout.contentInsets.top),
            infoStack.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: layout.contentInsets.left),
            infoStack.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: layout.contentInsets.right),
            infoStack.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: layout.contentInsets.bottom)
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
            #colorLiteral(red: 0.0862628296, green: 0.08628197759, blue: 0.08625862747, alpha: 1).cgColor,
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
    
    // MARK: SetupUser sound settings
    private func setupUserSoundSettings() {
        guard let soundOn = StorageService.shared.getData(for: SettingsKeys.soundSettings.rawValue) else { return }
        // SetUp initial state
        soundSwitcher.setOn(soundOn, animated: true)
    }
}

private enum Constants {
    static let kittenAnimationDuration: Double = 4.5
    static let kittenHidingDuration: Double = 0.3
    static let kittenSize: CGSize = CGSize(width: 190, height: 140)
    static let kittenLeftInsetValue: CGFloat = -70
    static let navBarHeight: CGFloat = 96
}
