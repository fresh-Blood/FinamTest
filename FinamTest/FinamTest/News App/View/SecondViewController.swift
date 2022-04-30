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
    
    private let ghostNewsViewBG: UIView = {
        let loadingGhostView = UIView()
        loadingGhostView.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        loadingGhostView.layer.cornerRadius = 8
        loadingGhostView.isHidden = true
        return loadingGhostView
    }()
    
    private let ghostNewsView: UIView = {
        let loadingGhostView = UIView()
        loadingGhostView.backgroundColor = Colors.valueForGradientAnimation
        loadingGhostView.layer.cornerRadius = 8
        loadingGhostView.isHidden = true
        return loadingGhostView
    }()
    
    let topicLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .natural
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
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
        
        navigationController?.navigationBar.subviews.forEach {
            $0.isHidden = $0.tag == 0
            $0.isHidden = $0.tag == 1
        }
        
        if topicLabel.text == Errors.topicLabelNoInfo.rawValue {
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 0.1,
                           options: .curveLinear,
                           animations: { [self] in
                moreInfoButton.setShadow(configureBorder: true)
                view.layoutIfNeeded()
            })
            stopAnimatingGhostLoadingViewAndHide()
            showPowerOffImage()
        }
    }
    
    private func animateGhostLoadingView() {
        ghostNewsView.isHidden.toggle()
        ghostNewsViewBG.isHidden.toggle()
        ghostNewsView.animateGradient()
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
                       animations: { [self] in
            powerOffImage.alpha = 1
            powerOffImage.setShadow(configureBorder: false)
            self.view.layoutIfNeeded()
        })
    }
    
    private func stopAnimatingGhostLoadingViewAndHide() {
        ghostNewsView.isHidden = true
        ghostNewsViewBG.isHidden = true
    }
    
    private func setupUI() {
        view.addSubview(topicLabel)
        newsImage.addSubview(ghostNewsViewBG)
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
        ghostNewsViewBG.frame = CGRect(x: newsImage.bounds.minX + insetForLoadingView/2,
                                     y: newsImage.bounds.minY + insetForLoadingView*2,
                                     width: newsImage.bounds.width - insetForLoadingView,
                                     height: newsImage.bounds.height - insetForLoadingView*2.5)
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


