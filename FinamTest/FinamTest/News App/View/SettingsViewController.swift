import UIKit

final class SettingsViewController: UIViewController {
    
    var closeCompletion: (() -> Void)?
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.configureShadow(configureBorder: false)
        return view
    }()
    
    // MARK: Close VC settings
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        btn.addTarget(self, action: #selector(closeSettingsVC), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.tintColor = Colors.valueForColor
        return btn
    }()
    
    @objc private func closeSettingsVC() {
        closeCompletion?()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Sound
    private lazy var soundsSettingsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .natural
        label.text = SettingsKeys.soundWord.rawValue
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
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
            present(alertVC, animated: true, completion: nil)
        }
    }
    
    private lazy var developerInfoLabel: UILabel = {
        let label = UILabel()
        label.text = SettingsKeys.info.rawValue
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .natural
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    // MARK: Life - cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupUserSoundSettings()
        animateBGViewShadow()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bgView.layer.removeAllAnimations()
    }
    
    private func animateBGViewShadow() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: { [weak self] in
            let animation = CABasicAnimation(keyPath: "shadowOpacity")
            animation.fromValue = self?.bgView.layer.shadowOpacity
            animation.toValue = 0.0
            animation.duration = 3.0
            animation.repeatCount = .infinity
            animation.autoreverses = true
            self?.bgView.layer.add(animation, forKey: animation.keyPath)
            self?.bgView.layer.shadowOpacity = 0.0
        })
    }
    
    
    
    // MARK: SetupUI
    private func setupUI() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        bgView.addSubview(closeButton)
        bgView.addSubview(soundsSettingsLabel)
        bgView.addSubview(soundSwitcher)
        bgView.addSubview(developerInfoLabel)
        bgView.addSubview(developerInfoSwitcher)
        view.addSubview(bgView)
        
        NSLayoutConstraint.activate([
            bgView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bgView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            bgView.widthAnchor.constraint(equalToConstant: 190),
            bgView.heightAnchor.constraint(equalToConstant: 175),

            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30),
            closeButton.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 2),
            closeButton.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -2),

            soundsSettingsLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 53),
            soundsSettingsLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),

            soundSwitcher.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 50),
            soundSwitcher.leftAnchor.constraint(equalTo: soundsSettingsLabel.rightAnchor, constant: 16),
            soundSwitcher.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16),
            
            developerInfoLabel.topAnchor.constraint(equalTo: soundsSettingsLabel.bottomAnchor, constant: 26),
            developerInfoLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 16),

            developerInfoSwitcher.topAnchor.constraint(equalTo: soundSwitcher.bottomAnchor, constant: 16),
            developerInfoSwitcher.leftAnchor.constraint(equalTo: developerInfoLabel.rightAnchor, constant: 16),
            developerInfoSwitcher.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -16)
        ])
    }
    
    private func setupUserSoundSettings() {
        guard let soundOn = StorageService.shared.getData(for: SettingsKeys.soundSettings.rawValue) else { return }
        // SetUp initial state
        soundSwitcher.setOn(soundOn, animated: true)
    }
}

