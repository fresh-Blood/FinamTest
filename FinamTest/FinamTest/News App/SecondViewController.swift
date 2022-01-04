import UIKit






let loading = UIActivityIndicatorView(style: .large)

final class SecondViewController: UIViewController {
    
    var moreInfo = "" 
    
    let newsImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .black
        return img
    }()
    
    let topicLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .natural
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 18, weight: .medium)
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    let moreInfoButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Подробнее ಠ_ಠ", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.addTarget(self,
                      action: #selector(showMoreInfo),
                      for: .touchUpInside)
        return btn
    }()
    
    @objc private func showMoreInfo() {
        moreInfoButton.pulsate()
        guard
            let url = URL(string: moreInfo) else { return }
        UIApplication.shared.open(url)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(topicLabel)
        view.addSubview(newsImage)
        view.addSubview(moreInfoButton)
        view.addSubview(loading)
        loading.hidesWhenStopped = true
        loading.color = .white
        loading.startAnimating()
        view.backgroundColor = .systemGroupedBackground
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let inset: CGFloat = 8
        let inset1: CGFloat = 15
        newsImage.frame = CGRect(x: view.bounds.minX,
                                 y: view.bounds.minY,
                                 width: view.bounds.width,
                                 height: view.bounds.height/2)
        loading.frame = CGRect(x: view.bounds.width/2 - inset1,
                                 y: view.bounds.height/4 - inset1,
                                 width: 30,
                                 height: 30)
        topicLabel.frame = CGRect(x: view.bounds.minX + inset + view.safeAreaInsets.left,
                                  y: newsImage.bounds.maxY + inset,
                                  width: view.bounds.width - inset*2 - view.safeAreaInsets.right,
                                  height: view.bounds.height/8*3)
        moreInfoButton.frame = CGRect(x: view.bounds.minX + inset,
                                      y: newsImage.bounds.maxY + topicLabel.bounds.maxY + inset - view.safeAreaInsets.bottom,
                                      width: view.bounds.width - inset*2,
                                      height: view.bounds.height/8)
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


// MARK: no freezing: images are loading when we see them not on main queue, if the image is huge and loading takes much time - we will see default image immideately 

extension UIImageView {
    func downLoadImage(from:String) {
        if let cachedImage = Cashe.imageCache.object(forKey: from as AnyObject) {
            print("image loaded from cashe")
            DispatchQueue.main.async {
                loading.stopAnimating()
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
                        print("image loaded from internet")
                        self.image = unwrappedImage
                        loading.stopAnimating()
                    }
                }
            }).resume()
        }
    }
}


