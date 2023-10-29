import UIKit
import AVKit
import SwiftUI

protocol NewsView {
    var internetService: UserInternetService? { get set }
    func handleResponseFailure(with error: String)
    func handleResponseSuccess()
}

final class NewsViewController: UIViewController {
    struct Layout {
        let contentInsets: UIEdgeInsets
        
        static var `default`: Layout {
            Layout(contentInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    
    private lazy var refreshContol = UIRefreshControl()
    private lazy var layout: Layout = .default
    private lazy var isInitialLoading = true
    private lazy var skeletonsStackView = makeStackView()
    private lazy var skeletonsBackgroundViewsStackView = makeStackView()
    
    private var hostingViewController: UIHostingController<ErrorView>?
    private var errorView: UIView?
    private var cachedCategory: String?
    
    private var needLoadNews: Bool {
        let currentCategory = StorageService.shared.selectedCategory
        return cachedCategory != currentCategory || internetService?.newsArray.isEmpty ?? false
    }
    
    var internetService: UserInternetService?
    var isSearchViewControllerFirstResponder = false
    
    private lazy var settingsButton: UIView = {
        let view = UIView()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(showSettings(gesture: )))
        gesture.minimumPressDuration = .zero
        view.addGestureRecognizer(gesture)
        return view
    }()
    
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
    
    // MARK: Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        configureNavigationBar()
        setupUI()
        cachedCategory = StorageService.shared.selectedCategory
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        settingsButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsButton.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOnBoardingMessageIfNeeded()
        
        if needLoadNews {
            loadNews()
            cachedCategory = StorageService.shared.selectedCategory
        }
        
        if isSearchViewControllerFirstResponder {
            navigationItem.searchController?.searchBar.becomeFirstResponder()
            isSearchViewControllerFirstResponder.toggle()
        }
    }
    
    // MARK: OnBoarding
    private func showOnBoardingMessageIfNeeded() {
        guard StorageService.shared.get(AppVersion.current) != nil else {
            let alertVC = UIAlertController(title: Updates.title.rawValue,
                                            message: Updates.whatsNew.rawValue,
                                            preferredStyle: .actionSheet)
            
            alertVC.view.tintColor = .systemGray
            
            alertVC.prepairForIPad(withVCView: view, withVC: self)
            
            alertVC.addAction(UIAlertAction(title: Updates.ok.rawValue,
                                            style: .cancel, handler: { _ in
                alertVC.dismiss(animated: true, completion: nil)
            }))
            
            present(alertVC, animated: true, completion: {
                StorageService.shared.save(AppVersion.current, forKey: AppVersion.current)
            })
            
            return
        }
    }
    
    // MARK: Configure navigation bar
    private func configureNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = DeveloperInfo.appTitle.rawValue
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = Colors.valueForColor
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.vertical.3"),
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
        navigationController?.navigationBar.addSubview(settingsButton)
        settingsButton.frame = CGRect(origin: .zero, size: CGSize(width: 46, height: 36))
        navigationItem.hidesSearchBarWhenScrolling = true
    }
    
    @objc func showSettings(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            VibrateManager.shared.impactOccured(.rigid)
        } else if gesture.state == .ended {
            navigationController?.pushViewController(SettingsViewController(), animated: true)
        }
    }
    
    private func makeStackView() -> UIStackView {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 16
        stack.isHidden = true
        return stack
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
//        view.addSubview(errorView)
        
        let frame = CGRect(origin: CGPoint(x: newsList.bounds.minX,
                                           y: newsList.bounds.minY + 7),
                           size: newsList.frame.size)
        skeletonsStackView.frame = frame
        skeletonsBackgroundViewsStackView.frame = skeletonsStackView.frame
        
//        errorView.center
        
        view.addSubview(upButton)
        
        NSLayoutConstraint.activate([
            upButton.heightAnchor.constraint(equalToConstant: 40),
            upButton.widthAnchor.constraint(equalToConstant: 40),
            upButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -35),
            upButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
        ])
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
        let topicVC = TopicViewController()
        topicVC.title = topic?.title
        topicVC.topicLabel.text = topic?.description ?? Errors.topicLabelNoInfo.rawValue
        topicVC.newsImage.downLoadImage(from: topic?.urlToImage ?? Errors.timeout.rawValue)
        topicVC.moreInfo = topic?.url ?? Errors.timeout.rawValue
        navigationController?.pushViewController(topicVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Refresh control settings
extension NewsViewController {
    func configureRefreshControl () {
        refreshContol.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        newsList.refreshControl = refreshContol
        newsList.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        SoundManager.shared.playSound(soundFileName: SoundManager.shared.randomRefreshJedySound)
        UIView.animate(withDuration: 0.2,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 1,
                       options: [.curveEaseInOut],
                       animations: {
            self.refreshContol.transform = CGAffineTransform(scaleX: 1, y: 1)
        }, completion: { [weak self] finished in
            guard let self else { return }
            
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           usingSpringWithDamping: 1,
                           initialSpringVelocity: 1,
                           options: [.curveEaseInOut],
                           animations: {
                self.refreshContol.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            }, completion: { [weak self] _ in
                self?.loadNews()
            })
        })
    }
    
    // MARK: - Loading
    private func loadNews(searching keyword: String? = nil) {
        removeError()
        internetService?.newsArray.removeAll()
        newsList.reloadData()
        animateLoading()
        internetService?.getData(with: keyword, category: StorageService.shared.selectedCategory)
    }
    
    private func stopLoading() {
        stopAnimatingAndHide()
        newsList.reloadData()
        view.endEditing(true)
    }
    
    private func showError(title: String) {
        let hostingController = UIHostingController(rootView: ErrorView(title: title,
                                                                        action: { [weak self] in
            self?.loadNews()
        }))
        addChild(hostingController)
        hostingController.view.frame = newsList.bounds
        guard let errorView = hostingController.view else { return }
        errorView.accessibilityIdentifier = "errorView"
        newsList.addSubview(errorView)
        hostingController.didMove(toParent: self)
        self.hostingViewController = hostingController
        self.errorView = errorView
    }
    
    private func removeError() {
        guard let hostingViewController, let errorView else { return }
        hostingViewController.removeFromParent()
        errorView.removeFromSuperview()
    }
}

// MARK: NewsView
extension NewsViewController: NewsView {
    func handleResponseSuccess() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            if isInitialLoading {
                SoundManager.shared.playSound(soundFileName: SoundName.loaded.rawValue)
                isInitialLoading.toggle()
            }
            
            stopLoading()
        }
    }
    
    func handleResponseFailure(with error: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            SoundManager.shared.playSound(soundFileName: SoundName.error.rawValue)
            VibrateManager.shared.vibrate(.error)
            
            stopLoading()
            showError(title: error)
        }
    }
}

// MARK: Search bar delegate settings
extension NewsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadNews(searching: searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchBar.text?.filter{ $0.isLetter && $0 != " " }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text?.removeAll()
    }
}

// MARK: - CellDelegate
extension NewsViewController: CellDelegate {
    func sendDetailsForPresenting(vc: UIActivityViewController, contentView: UIView) {
        vc.prepairForIPad(withVCView: contentView, withVC: self)
        // For some reason close button doesn't work, so i made my own
        vc.injectCloseButton()
        present(vc, animated: true, completion: nil)
    }
}

// MARK: - ScrollViewDidScroll
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
