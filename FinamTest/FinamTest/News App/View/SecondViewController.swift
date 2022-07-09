import UIKit

protocol PowerOffShowable {
    func showPowerOffImage(insideView: UIView)
    func removePowerOffImage(fromView: UIView)
    var powerOffImageId: String { get }
}

extension PowerOffShowable {
    
    var powerOffImageId: String {
        "powerOffImage"
    }
    
    func showPowerOffImage(insideView: UIView) {
        let powerOffImage = UIImageView(image: UIImage(systemName: "power.dotted"))
        powerOffImage.tintColor = Colors.valueForButtonColor
        powerOffImage.frame.size = CGSize(width: 50, height: 50)
        powerOffImage.center = insideView.center
        powerOffImage.alpha = 0
        powerOffImage.accessibilityIdentifier = powerOffImageId
        insideView.addSubview(powerOffImage)
        
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 0.1,
                       options: .curveLinear,
                       animations: {
            powerOffImage.alpha = 1
            powerOffImage.configureShadow(configureBorder: false)
        })
    }
    func removePowerOffImage(fromView: UIView) {
        let powerOffImage = fromView.subviews.first(where: { $0.accessibilityIdentifier == powerOffImageId })
        powerOffImage?.removeFromSuperview()
    }
}

final class SecondViewController: UIViewController, PowerOffShowable {
    
    var moreInfo = ""
    
    var newsImageLoaded = false {
        didSet {
            stopAnimatingGhostLoadingViewAndHide()
        }
    }
    
    private lazy var scrollImageView = UIScrollView()
    
    let newsImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        return img
    }()
    
    private lazy var ghostNewsViewBG: UIView = {
        let loadingGhostView = UIView()
        loadingGhostView.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        loadingGhostView.layer.cornerRadius = 8
        loadingGhostView.isHidden = true
        return loadingGhostView
    }()
    
    private lazy var ghostNewsView: UIView = {
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
    
    private lazy var moreInfoButton: UIButton = {
        let btn = UIButton()
        btn.setTitle(Other.moreInfo.rawValue, for: .normal)
        btn.addTarget(self,
                      action: #selector(showMoreInfo),
                      for: .touchUpInside)
        return btn
    }()
    
    @objc private func showMoreInfo() {
        guard let url = URL(string: moreInfo) else { return }
        UIApplication.shared.open(url)
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateGhostLoadingView()
        setScrollView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.subviews.forEach {
            $0.isHidden = $0.tag == 0
            $0.isHidden = $0.tag == 1
        }
        
        if topicLabel.text == Errors.topicLabelNoInfo.rawValue {
            VibrateManager.shared.makeWarningVibration()
            UIView.animate(withDuration: 1.0,
                           delay: 0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 0.1,
                           options: .curveLinear,
                           animations: { [self] in
                moreInfoButton.configureShadow(configureBorder: true)
                view.layoutIfNeeded()
            })
            stopAnimatingGhostLoadingViewAndHide()
            showPowerOffImage(insideView: newsImage)
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Zoom Gesture and animations
    private func setScrollView() {
        scrollImageView.delegate = self
        scrollImageView.minimumZoomScale = 1.0
        scrollImageView.maximumZoomScale = 7.0
        scrollImageView.showsHorizontalScrollIndicator = false
        scrollImageView.showsVerticalScrollIndicator = false 
        scrollImageView.zoomScale = 1.0
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapTwice))
        gesture.numberOfTapsRequired = 2
        scrollImageView.addGestureRecognizer(gesture)
        scrollImageView.bouncesZoom = true
    }
    
    @objc private func tapTwice(gesture: UITapGestureRecognizer) {
        if newsImageLoaded {
            let scale = min(scrollImageView.zoomScale * 2, scrollImageView.maximumZoomScale)
            if scale != scrollImageView.zoomScale { // zoom in
                let point = gesture.location(in: newsImage)
                let scrollSize = scrollImageView.frame.size
                let size = CGSize(width: scrollSize.width / scrollImageView.maximumZoomScale,
                                  height: scrollSize.height / scrollImageView.maximumZoomScale)
                let origin = CGPoint(x: point.x - size.width / 2,
                                     y: point.y - size.height / 2)
                scrollImageView.zoom(to:CGRect(origin: origin, size: size), animated: true)
            } else { // zoom out
                scrollImageView.zoom(to: zoomRectForScale(scale: scrollImageView.maximumZoomScale, center: gesture.location(in: newsImage)), animated: true)
            }
            VibrateManager.shared.makeLoadingResultVibration()
        }
    }
    
    private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = newsImage.frame.size.height / scale
        zoomRect.size.width  = newsImage.frame.size.width  / scale
        let newCenter = scrollImageView.convert(center, from: newsImage)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    private func animateGhostLoadingView() {
        ghostNewsView.isHidden.toggle()
        ghostNewsViewBG.isHidden.toggle()
        ghostNewsView.animateGradient()
    }
    
    private func stopAnimatingGhostLoadingViewAndHide() {
        ghostNewsView.isHidden = true
        ghostNewsViewBG.isHidden = true
    }
    
    // MARK: SetupUI
    private func setupUI() {
        view.addSubview(topicLabel)
        newsImage.addSubview(ghostNewsViewBG)
        newsImage.addSubview(ghostNewsView)
        scrollImageView.addSubview(newsImage)
        view.addSubview(scrollImageView)
        view.addSubview(moreInfoButton)
        view.backgroundColor = .systemBackground
        newsImage.backgroundColor = Colors.reversedValueForColor
        moreInfoButton.setTitleColor(Colors.valueForColor, for: .normal)
        
        let inset: CGFloat = 8
        let insetForLoadingView: CGFloat = 50
        scrollImageView.frame = CGRect(x: view.bounds.minX,
                                       y: view.bounds.minY,
                                       width: view.bounds.width,
                                       height: view.bounds.height/2)
        newsImage.frame = scrollImageView.frame
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

// MARK: ScrollView Delegate
extension SecondViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        newsImage
    }
}
