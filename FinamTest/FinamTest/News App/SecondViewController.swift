import UIKit


final class SecondViewController: UIViewController {
    
    var moreInfo = ""
    
    var counter = 0 {
        didSet {
            stopAnimatingGhostLoadingViewAndHide()
        }
    }
    
    let newsImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private let ghostNewsView: UIView = {
        let loadingGhostView = UIView()
        loadingGhostView.backgroundColor = Colors.valueForLoading
        loadingGhostView.alpha = 0
        loadingGhostView.layer.cornerRadius = 8
        return loadingGhostView
    }()
    
    let topicLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .natural
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 17, weight: .regular)
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    private let moreInfoButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Подробнее ಠ_ಠ", for: .normal)
        btn.addTarget(self,
                      action: #selector(showMoreInfo),
                      for: .touchUpInside)
        return btn
    }()
    
    @objc private func showMoreInfo() {
        moreInfoButton.pulsate()
        guard let url = URL(string: moreInfo) else { return }
        UIApplication.shared.open(url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateGhostLoadingView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if topicLabel.text == Errors.topicLabelNoInfo.rawValue {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 0.1,
                           options: .curveLinear,
                           animations: { [self] in
                moreInfoButton.layer.borderColor = Colors.valueForButtonColor.cgColor
                moreInfoButton.layer.borderWidth = 3
                moreInfoButton.layer.cornerRadius = 8
                moreInfoButton.layer.shadowOffset = CGSize(width: 2, height: 3)
                moreInfoButton.layer.shadowOpacity = 10
                moreInfoButton.layer.shadowColor = Colors.valueForButtonColor.cgColor
                moreInfoButton.layer.shadowRadius = 7
                view.layoutIfNeeded()
            })
            stopAnimatingGhostLoadingViewAndHide()
            showPowerOffImage()
        }
    }
    
    private func animateGhostLoadingView() {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: [.autoreverse,.repeat,.curveEaseIn],
                       animations: { [self] in
            ghostNewsView.alpha = 1
        }, completion: { finished in
            self.ghostNewsView.alpha = 0
        })
    }
    
    private func showPowerOffImage() {
        let powerOffImage = UIImageView(image: UIImage(systemName: "power.dotted"))
        powerOffImage.tintColor = Colors.valueForButtonColor
        powerOffImage.frame.size = CGSize(width: 50, height: 50)
        powerOffImage.center = self.newsImage.center
        powerOffImage.alpha = 0
        self.newsImage.addSubview(powerOffImage)
        
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 0.1,
                       options: .curveLinear,
                       animations: {
            powerOffImage.alpha = 1
            powerOffImage.layer.shadowOffset = CGSize(width: 2, height: 3)
            powerOffImage.layer.shadowOpacity = 10
            powerOffImage.layer.shadowColor = Colors.valueForButtonColor.cgColor
            powerOffImage.layer.shadowRadius = powerOffImage.frame.size.height/2
            self.view.layoutIfNeeded()
        })
    }
    
    private func stopAnimatingGhostLoadingViewAndHide() {
        ghostNewsView.layer.removeAllAnimations()
        ghostNewsView.isHidden = true
    }
    
    private func setupUI() {
        view.addSubview(topicLabel)
        newsImage.addSubview(ghostNewsView)
        view.addSubview(newsImage)
        view.addSubview(moreInfoButton)
        view.backgroundColor = .systemBackground
        newsImage.backgroundColor = Colors.reversedValueForColor
        moreInfoButton.setTitleColor(Colors.valueForColor, for: .normal)
        
        let inset: CGFloat = 8
        let insetForLoadingView: CGFloat = 50
        newsImage.frame = CGRect(x: view.bounds.minX,
                                 y: view.bounds.minY,
                                 width: view.bounds.width,
                                 height: view.bounds.height/2)
        ghostNewsView.frame = CGRect(x: newsImage.bounds.minX + insetForLoadingView/2,
                                     y: newsImage.bounds.minY + insetForLoadingView*2,
                                     width: newsImage.bounds.width - insetForLoadingView,
                                     height: newsImage.bounds.height - insetForLoadingView*2.5)
        topicLabel.frame = CGRect(x: view.bounds.minX + inset + view.safeAreaInsets.left,
                                  y: newsImage.bounds.maxY + inset,
                                  width: view.bounds.width - inset*2 - view.safeAreaInsets.right,
                                  height: view.bounds.height/8*3)
        moreInfoButton.frame = CGRect(x: view.bounds.midX - 100,
                                      y: newsImage.bounds.maxY + topicLabel.bounds.maxY + inset - view.safeAreaInsets.bottom,
                                      width: 200,
                                      height: 50)
        topicLabel.sizeToFit()
    }
}

extension UIButton {
    func pulsate() {
        let animation = CASpringAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.98
        animation.toValue = 1
        animation.damping = 1.0
        animation.duration = 0.1
        layer.add(animation, forKey: nil)
    }
}

// MARK: images are loading when we see them not on main queue, if the image is huge and loading takes much time - UI doesn't freeze: we can go back and choose another topic

extension UIImageView {
    func downLoadImage(from:String, completion: @escaping () -> Void) {
        if let cachedImage = Cashe.imageCache.object(forKey: from as AnyObject) {
            DispatchQueue.main.async {
                completion()
            }
            self.image = cachedImage
            return
        }
        if let url = URL(string: from) {
            URLSession.shared.dataTask(with: url, completionHandler: { data,response,error in
                if let data = data {
                    DispatchQueue.main.async {
                        guard
                            let unwrappedImage = UIImage(data: data) else { return }
                        Cashe.imageCache.setObject(unwrappedImage, forKey: from as AnyObject)
                        self.image = unwrappedImage
                        completion()
                    }
                }
            }).resume()
        }
    }
}

struct Colors {
    static var valueForColor: UIColor {
        UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
    }
    
    static var reversedValueForColor: UIColor {
        UITraitCollection.current.userInterfaceStyle == .dark ? .black : .white
    }
    
    static var valueForButtonColor: UIColor {
        UITraitCollection.current.userInterfaceStyle == .dark ? .systemGreen : .systemBlue
    }
    
    static var valueForLoading: UIColor {
        UITraitCollection.current.userInterfaceStyle == .dark ? .darkGray : .systemGray4
    }
}


