import UIKit
import AVKit

typealias CompletionForAnimation = ((Bool) -> Void)?

protocol NewsView {
    var internetService: UserInternetService? { get set }
    func reload()
    func animateResponseError(with error: String)
    func animateGoodConnection()
}

final class NewsViewController: UIViewController, NewsView {
    struct Layout {
        let contentInsets: UIEdgeInsets
        
        static var `default`: Layout {
            Layout(contentInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    
    private lazy var layout: Layout = .default
    private lazy var isInitialLoading = true
    
    var internetService: UserInternetService?
    
    private lazy var upButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        button.layer.cornerRadius = Constants.upButtonCornerRadius
        button.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        button.tintColor = Colors.valueForColor
        button.addTarget(self, action: #selector(upButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = .zero
        return button
    }()
    
    private lazy var newsList: UITableView = {
        let list = UITableView()
        list.delegate = self
        list.dataSource = self
        list.frame = CGRect(x: view.frame.minX + layout.contentInsets.left,
                                   y: view.frame.minY,
                                   width: view.frame.width - layout.contentInsets.right*2,
                                   height: view.frame.height)
        list.estimatedRowHeight = 44
        list.rowHeight = UITableView.automaticDimension
        list.showsVerticalScrollIndicator = false
        list.separatorStyle = .none
        list.clipsToBounds = false
        list.register(TopicCell.self, forCellReuseIdentifier: TopicCell.id)
        return list
    }()
    
    private lazy var skeletonsStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 16
        stack.isHidden = true
        return stack
    }()
    
    private lazy var skeletonsBackgroundViewsStackView: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 16
        stack.isHidden = true
        return stack
    }()
    
    var responseErrorLabel: UILabel = {
        let responseErrorView = UILabel()
        responseErrorView.backgroundColor = .systemRed
        responseErrorView.layer.cornerRadius = 16
        responseErrorView.translatesAutoresizingMaskIntoConstraints = false
        responseErrorView.textAlignment = .center
        responseErrorView.numberOfLines = 0
        responseErrorView.font = .systemFont(ofSize: 20, weight: .heavy)
        responseErrorView.layer.masksToBounds = true
        responseErrorView.adjustsFontSizeToFitWidth = true
        responseErrorView.textColor = .white
        return responseErrorView
    }()
    
    private func makeSkeleton() -> UIView {
        let name = UIView()
        name.backgroundColor = Colors.valueForGradientAnimation
        name.layer.cornerRadius = 16
        return name
    }
    
    private func makeSkeletonBackgroundview() -> UIView {
        let name = UIView()
        name.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        name.layer.cornerRadius = 16
        return name
    }
    
    func reload() {
        newsList.reloadData()
    }
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setLeftBarButtonItemGesture()
        configureRefreshControl()
        configureNavigationBar()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOnBoardingMessageIfNeeded()
        
        leftBarButtonItem.isHidden = false
        
        guard let newsArray = internetService?.newsArray else { return }
        
        if newsArray.isEmpty {
            animateLoading()
            Task {
                try await internetService?.getData(completion: { [weak self] in
                    DispatchQueue.main.async {
                        self?.stopAnimatingAndHide()
                    }
                }, with: nil)
            }
        }
    }
    
    // MARK: Show alert ( onBoarding ) with updates info
    private func showOnBoardingMessageIfNeeded() {
        guard StorageService.shared.getAppVersion(AppVersion.current) != nil else {
            let alertVC = UIAlertController(title: Updates.title.rawValue,
                                            message: Updates.whatsNew.rawValue,
                                            preferredStyle: .actionSheet)
            alertVC.prepairForIPad(withVCView: view, withVC: self)
            alertVC.addAction(UIAlertAction(title: Updates.ok.rawValue,
                                            style: .cancel, handler: { _ in
                alertVC.dismiss(animated: true, completion: nil)
            }))
            present(alertVC, animated: true, completion: { 
                StorageService.shared.saveAppVersion(AppVersion.current)
            })
            return
        }
    }
    
    // MARK: Configure navigation bar
    private lazy var leftBarButtonItem: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.tag = 1
        btn.isHidden = true
        return btn
    }()
    
    private func setLeftBarButtonItemGesture() {
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(showSettings))
        gesture.minimumPressDuration = 0
        leftBarButtonItem.addGestureRecognizer(gesture)
    }
    
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = DeveloperInfo.appTitle.rawValue
        navigationItem.backButtonTitle = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.vertical.3"), style: .plain, target: self, action: nil)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = Colors.valueForColor
        
        let searchVC = UISearchController()
        navigationItem.searchController = searchVC
        searchVC.searchBar.keyboardType = .asciiCapable
        searchVC.searchBar.delegate = self
        searchVC.searchBar.placeholder = "Please type the keyword"
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    @objc private func showSettings(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            VibrateManager.shared.impactOccured(.rigid)
        } else if gesture.state == .ended {
            navigationController?.pushViewController(SettingsViewController(), animated: true)
        }
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        for _ in 1...6 {
            skeletonsStackView.addArrangedSubview(makeSkeleton())
            skeletonsBackgroundViewsStackView.addArrangedSubview(makeSkeletonBackgroundview())
        }
        
        newsList.addSubview(skeletonsBackgroundViewsStackView)
        newsList.addSubview(skeletonsStackView)
        view.addSubview(newsList)
        view.addSubview(responseErrorLabel)
        navigationController?.navigationBar.addSubview(leftBarButtonItem)
        leftBarButtonItem.frame = CGRect(x: 0,
                                         y: 0,
                                         width: 60,
                                         height: 50)
        
        skeletonsStackView.frame = newsList.bounds
        skeletonsBackgroundViewsStackView.frame = newsList.bounds
        
        NSLayoutConstraint.activate([
            responseErrorLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            responseErrorLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            responseErrorLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            responseErrorLabel.heightAnchor.constraint(equalToConstant: 0)
        ])
        
        view.addSubview(upButton)
        
        NSLayoutConstraint.activate([
            upButton.heightAnchor.constraint(equalToConstant: 40),
            upButton.widthAnchor.constraint(equalToConstant: 40),
            upButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35),
            upButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
        ])
    }
    
    // MARK: Good connection animations 
    func animateGoodConnection() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if isInitialLoading {
                SoundManager.shared.playSound(soundFileName: SoundName.loaded.rawValue)
                isInitialLoading.toggle()
            }
            
            removePowerOffImage(fromView: view)
        }
    }
    
    // MARK: Skeletons animations
    private func animateLoading() {
        skeletonsStackView.isHidden = false
        skeletonsBackgroundViewsStackView.isHidden = false
        skeletonsStackView.arrangedSubviews.forEach {
            $0.animateGradient()
        }
    }
    
    private func stopAnimatingAndHide() {
        newsList.refreshControl?.endRefreshing()
        skeletonsStackView.isHidden = true
        skeletonsBackgroundViewsStackView.isHidden = true
    }
}

// MARK: TableView delegate & dataSource methods
extension NewsViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return internetService?.newsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TopicCell.id, for: indexPath) as! TopicCell
        let model = internetService?.newsArray[indexPath.row]
        cell.titleLabel.text = model?.title
        cell.newsDate.text = model?.publishedAt?.toReadableDate()
        cell.newsSource.text = model?.source?.name
        cell.cellDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = internetService?.newsArray[indexPath.row]
        let secondVC = TopicViewController()
        secondVC.title = topic?.title
        secondVC.topicLabel.text = topic?.description ?? Errors.topicLabelNoInfo.rawValue
        secondVC.newsImage.downLoadImage(from: topic?.urlToImage ?? Errors.error.rawValue, completion: {
            secondVC.newsImageLoaded = true
        })
        secondVC.moreInfo = topic?.url ?? Errors.error.rawValue
        navigationController?.pushViewController(secondVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Refresh control settings
extension NewsViewController {
    func configureRefreshControl () {
        let refreshContol = UIRefreshControl()
        refreshContol.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        newsList.refreshControl = refreshContol
        newsList.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        removePowerOffImage(fromView: view)
        SoundManager.shared.playSound(soundFileName: SoundManager.shared.randomRefreshJedySound)
        internetService?.newsArray.removeAll()
        reload()
        animateLoading()
        Task {
            try await internetService?.getData(completion: { [weak self] in
                DispatchQueue.main.async {
                    self?.stopAnimatingAndHide()
                }
            }, with: nil)
        }
    }
}

// MARK: Animate errors
extension NewsViewController: PowerOffShowable {
    func animateResponseError(with error: String) {
        DispatchQueue.main.async { [weak self] in
            if let currentView = self?.view {
                self?.showPowerOffImage(insideView: currentView)
            }
            SoundManager.shared.playSound(soundFileName: SoundName.error.rawValue)
            self?.responseErrorLabel.text = error
            self?.setErrorResponseLabelHeightConstraint(to: 100, from: 0)
            UIView.animate(withDuration: 2.0,
                           delay: 0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseIn,
                           animations: {
                self?.view.layoutIfNeeded()
                VibrateManager.shared.vibrate(.error)
                self?.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
            }, completion: { finished in
                self?.animateChanges()
            })
        }
    }
    
    func setErrorResponseLabelHeightConstraint(to oneValue: CGFloat, from anotherValue: CGFloat) {
        responseErrorLabel.constraints.forEach {
            if $0.constant == anotherValue {
                responseErrorLabel.removeConstraint($0)
            }
        }
        responseErrorLabel.heightAnchor.constraint(equalToConstant: oneValue).isActive = true
    }
    
    func animateChanges() {
        setErrorResponseLabelHeightConstraint(to: 0, from: 100)
        UIView.animate(withDuration: 2.0,
                       delay: 5.0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 0.1,
                       options: .curveLinear,
                       animations: {
            self.view.layoutIfNeeded()
        })
    }
}

// MARK: Search bar delegate settings
extension NewsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        internetService?.newsArray.removeAll()
        reload()
        animateLoading()
        Task {
            try await internetService?.getData(completion: { [weak self] in
                DispatchQueue.main.async {
                    self?.stopAnimatingAndHide()
                    self?.view.endEditing(true)
                }
            }, with: searchBar.text)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchBar.text?.filter{ $0.isLetter && $0 != " " }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
    }
}

extension NewsViewController: CellDelegate {
    private func injectCloseButtonTo(vc: UIViewController) {
        let closeButton = UIButton()
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(close),
                              for: .touchUpInside)
        closeButton.backgroundColor = .clear
        let closeButtonSize: CGFloat = 50
        
        vc.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: .zero),
            closeButton.rightAnchor.constraint(equalTo: vc.view.rightAnchor, constant: .zero),
            closeButton.widthAnchor.constraint(equalToConstant: closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: closeButtonSize)
        ])
    }
    
    func sendDetailsForPresenting(vc: UIActivityViewController, contentView: UIView) {
        vc.prepairForIPad(withVCView: contentView, withVC: self)
        // For some reason close button doesn't work, so i made my own
        injectCloseButtonTo(vc: vc)
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func close() {
        if let presentingVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            presentingVC.dismiss(animated: true)
        }
    }
}

extension NewsViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        if contentOffset >= Constants.upButtonContentOffset {
            UIView.animate(withDuration: Constants.animationDuration,
                           delay: .zero,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseInOut,
                           animations: {
                self.upButton.alpha = 1.0
                self.upButton.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            })
        } else {
            UIView.animate(withDuration: Constants.animationDuration,
                           delay: .zero,
                           options: .curveEaseInOut,
                           animations: {
                self.upButton.alpha = .zero
                self.upButton.transform = .identity
            })
        }
    }
    
    @objc
    private func upButtonTapped() {
        newsList.scrollToRow(at: IndexPath(row: .zero, section: .zero),
                             at: .top,
                             animated: true)
        VibrateManager.shared.impactOccured(.rigid)
    }
}

private enum Constants {
    static let animationDuration: CGFloat = 0.3
    static let upButtonContentOffset: CGFloat = 20.0
    static let upButtonCornerRadius: CGFloat = 20.0
}
