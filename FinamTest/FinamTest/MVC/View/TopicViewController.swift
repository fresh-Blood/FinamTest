import UIKit
import WebKit

protocol PowerOffShowable {
    var powerOffImageId: String { get }
    func showPowerOffImage(insideView: UIView)
    func removePowerOffImage(fromView: UIView)
}

extension PowerOffShowable {
    var powerOffImageId: String { "powerOffImage" }
    
    func showPowerOffImage(insideView: UIView) {
        let imageView = UIImageView(image: UIImage(systemName: "power.dotted"))
        imageView.tintColor = Colors.valueForButtonColor
        imageView.frame.size = CGSize(width: 50, height: 50)
        imageView.center = insideView.center
        imageView.alpha = 0
        imageView.accessibilityIdentifier = powerOffImageId
        insideView.addSubview(imageView)
        
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 0.1,
                       options: .curveLinear,
                       animations: {
            imageView.alpha = 1
        })
    }
    
    func removePowerOffImage(fromView: UIView) {
        let powerOffImage = fromView.subviews.first(where: { $0.accessibilityIdentifier == powerOffImageId })
        powerOffImage?.removeFromSuperview()
    }
}

final class TopicViewController: UIViewController, PowerOffShowable, WKNavigationDelegate {
    var moreInfo = ""
    
    lazy var newsImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var imageSkeleton: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        view.layer.cornerRadius = 16
        view.clipsToBounds = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var topicLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .natural
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var moreInfoButton: UILabel = {
        let label = UILabel()
        label.text = Other.moreInfo.rawValue
        label.textColor = Colors.valueForColor
        label.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.layer.cornerRadius = 16
        label.translatesAutoresizingMaskIntoConstraints = false
        label.clipsToBounds = true
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(moreInfoTapped))
        gesture.minimumPressDuration = .zero
        label.addGestureRecognizer(gesture)
        return label
    }()
    
    @objc private func moreInfoTapped(gesture: UILongPressGestureRecognizer) {
        moreInfoButton.animatePressing(gesture: gesture, completion: { [weak self] in
            guard let self, let url = URL(string: moreInfo) else { return }

            let webView = WKWebView()
            webView.navigationDelegate = self
            webView.load(URLRequest(url: url))
            webView.allowsBackForwardNavigationGestures = true
            webView.frame = CGRect(x: view.frame.minX,
                                   y: view.safeAreaInsets.top,
                                   width: view.frame.width,
                                   height: view.frame.height)
            view.addSubview(webView)
        })
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        animateSkeleton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.subviews.forEach { $0.isHidden = $0.tag == 1 }
        
        if topicLabel.text == Errors.topicLabelNoInfo.rawValue {
            VibrateManager.shared.vibrate(.warning)
            self.imageSkeleton.alpha = .zero
            showPowerOffImage(insideView: newsImage)
        }
        
        view.layoutIfNeeded()
    }
    
    private func animateSkeleton() {
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.curveEaseInOut, .autoreverse, .repeat],
                       animations: {
            self.imageSkeleton.alpha = 0
        })
    }
    
    // MARK: SetupUI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(imageSkeleton)
        view.addSubview(newsImage)
        view.addSubview(topicLabel)
        view.addSubview(moreInfoButton)
        
        NSLayoutConstraint.activate([
            imageSkeleton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            imageSkeleton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            imageSkeleton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            imageSkeleton.heightAnchor.constraint(equalToConstant: 400),
            
            newsImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            newsImage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            newsImage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            newsImage.heightAnchor.constraint(equalToConstant: 400),
            
            topicLabel.topAnchor.constraint(equalTo: newsImage.bottomAnchor, constant: 16),
            topicLabel.leftAnchor.constraint(equalTo: newsImage.leftAnchor),
            topicLabel.rightAnchor.constraint(equalTo: newsImage.rightAnchor),
            
            moreInfoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            moreInfoButton.widthAnchor.constraint(equalToConstant: 70),
            moreInfoButton.heightAnchor.constraint(equalToConstant: 50),
            moreInfoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40)
        ])
    }
}

// MARK: ScrollView Delegate
extension TopicViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { newsImage }
}
