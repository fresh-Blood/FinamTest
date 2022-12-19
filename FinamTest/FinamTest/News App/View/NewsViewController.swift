import UIKit
import AVKit

typealias CompletionForAnimation = ((Bool) -> Void)?

protocol UserView {
    var internetService: UserInternetService? { get set }
    func reload()
    func animateResponseError(with error: String)
    func animateGoodConnection()
}

final class NewsViewController: UIViewController, UserView {
    private lazy var isInitialLoading = true
    private lazy var isSettingsVCPresenting = false
    
    struct Layout {
        let contentInsets: UIEdgeInsets
        
        static var `default`: Layout {
            Layout(contentInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    
    private lazy var layout: Layout = .default
    var internetService: UserInternetService?
    
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
        list.register(TopicCell.self, forCellReuseIdentifier: TopicCell.id)
        return list
    }()
    
    private lazy var stackViewForGhostLoadingViews: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 16
        stack.isHidden = true
        return stack
    }()
    
    private lazy var stackViewForGhostLoadingViewsBG: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 16
        stack.isHidden = true
        return stack
    }()
    
    var responseErrorNotificationLabel: UILabel = {
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
    
    private func makeNewGhostView() -> UIView {
        let name = UIView()
        name.backgroundColor = Colors.valueForGradientAnimation
        name.layer.cornerRadius = 16
        return name
    }
    
    private func makeNewGhostViewBG() -> UIView {
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
        setRightBarButtonItemGesture()
        setLeftBarButtonItemGesture()
        configureRefreshControl()
        configureNavigationBar()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showOnBoardingMessageIfNeeded()
        leftBarButtonItem.isHidden = false
        rightBarButtonItem.isHidden = false
        guard let newsArray = internetService?.newsArray else { return }
        if newsArray.isEmpty {
            animateLoading()
            Task {
                try await internetService?.getData(completion: {
                    DispatchQueue.main.async {
                        self.stopAnimatingAndHide()
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
    private lazy var rightBarButtonItem: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.tag = 0
        btn.isHidden = true
        return btn
    }()
    
    private lazy var leftBarButtonItem: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.tag = 1
        btn.isHidden = true
        return btn
    }()
    
    private func setRightBarButtonItemGesture() {
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(searchAction))
        gesture.minimumPressDuration = 0
        rightBarButtonItem.addGestureRecognizer(gesture)
    }
    
    private func setLeftBarButtonItemGesture() {
        let gesture = UILongPressGestureRecognizer(
            target: self,
            action: #selector(showSettings))
        gesture.minimumPressDuration = 0
        leftBarButtonItem.addGestureRecognizer(gesture)
    }
    
    @objc private func searchAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            VibrateManager.shared.makeLoadingResultVibration()
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseIn,
                           animations: { [self] in
                if navigationItem.searchController != nil {
                    navigationItem.searchController = nil
                } else {
                    setSearchVC()
                    navigationItem.hidesSearchBarWhenScrolling = false
                }
            })
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = DeveloperInfo.appTitle.rawValue
        navigationItem.backButtonTitle = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "slider.vertical.3"), style: .plain, target: self, action: nil)
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = Colors.valueForColor
    }
    
    @objc private func showSettings() {
        // Тк дефолтные кнопки нав бара не нажимались по какой то причине, я сделал костыли в виде прозрачных кнопок, у которых есть обработка нажатий. И теперь тут чтобы 2 раза не открывался vc настроек, сделал костыльный флаг. (Непонятно почему отрабатывает дважды нажатие тут, как и непонятно почему при нажатии _поделиться_ открывается контроллер на котором в верхнем правом углу есть кнопка _закрыть_ и она тоже не нажимается( , поэтому пришлось сделать костыль по инжекту кнопки прозрачной с закрытием его ниже)
        isSettingsVCPresenting.toggle()
        if isSettingsVCPresenting {
            let settingsVC = SettingsViewController()
            settingsVC.closeCompletion = { [weak self] in
                self?.isSettingsVCPresenting.toggle()
            }
            VibrateManager.shared.makeLoadingResultVibration()
//            navigationController?.pushViewController(settingsVC, animated: true)
            settingsVC.modalPresentationStyle = .popover
            settingsVC.modalTransitionStyle = .coverVertical
            present(settingsVC, animated: true)
        }
    }
    
    private func setSearchVC() {
        let searchVC = UISearchController()
        navigationItem.searchController = searchVC
        searchVC.searchBar.keyboardType = .asciiCapable
        searchVC.searchBar.delegate = self
        searchVC.searchBar.placeholder = "Keyword?"
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        for _ in 1...6 {
            stackViewForGhostLoadingViews.addArrangedSubview(makeNewGhostView())
            stackViewForGhostLoadingViewsBG.addArrangedSubview(makeNewGhostViewBG())
        }
        newsList.addSubview(stackViewForGhostLoadingViewsBG)
        newsList.addSubview(stackViewForGhostLoadingViews)
        view.addSubview(newsList)
        view.addSubview(responseErrorNotificationLabel)
        navigationController?.navigationBar.addSubview(rightBarButtonItem)
        navigationController?.navigationBar.addSubview(leftBarButtonItem)
        leftBarButtonItem.frame = CGRect(x: 0,
                                         y: 0,
                                         width: 60,
                                         height: 50)
        rightBarButtonItem.frame = CGRect(x: view.bounds.maxX - 60,
                                                   y: 0,
                                                   width: 60,
                                                   height: 50)
        stackViewForGhostLoadingViews.frame = newsList.bounds
        stackViewForGhostLoadingViewsBG.frame = newsList.bounds
        NSLayoutConstraint.activate([
            responseErrorNotificationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            responseErrorNotificationLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            responseErrorNotificationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            responseErrorNotificationLabel.heightAnchor.constraint(equalToConstant: 0)
        ])
    }
    
    // MARK: Good connection animations 
    func animateGoodConnection() {
        if isInitialLoading {
            DispatchQueue.main.async {
                SoundManager.shared.playSound(soundFileName: SoundName.loaded.rawValue)
            }
            isInitialLoading.toggle()
        }
        DispatchQueue.main.async { [weak self] in
            if let view = self?.view {
                self?.removePowerOffImage(fromView: view)
            }
            if self?.navigationController?.navigationBar.layer.shadowColor != Colors.valueForButtonColor.cgColor {
                self?.animateNaVbarBackGrColor(completion: nil)
            }
        }
    }
    
    private func animateNaVbarBackGrColor(completion: CompletionForAnimation) {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseIn,
                       animations: {
            self.navigationController?.navigationBar.configureShadow(configureBorder: false, withAlpha: 0.5)
        }, completion: completion)
    }
    
    // MARK: Skeletons animations
    private func animateLoading() {
        stackViewForGhostLoadingViews.isHidden.toggle()
        stackViewForGhostLoadingViewsBG.isHidden.toggle()
        stackViewForGhostLoadingViews.arrangedSubviews.forEach {
            $0.animateGradient()
        }
    }
    
    private func stopAnimatingAndHide() {
        stackViewForGhostLoadingViews.isHidden = true
        stackViewForGhostLoadingViewsBG.isHidden = true
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
        let secondVC = SelectedTopicViewController()
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
        newsList.refreshControl = UIRefreshControl()
        newsList.refreshControl?.addTarget(self, action:
                                                #selector(handleRefreshControl),
                                              for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        removePowerOffImage(fromView: view)
        SoundManager.shared.playSound(soundFileName: SoundManager.shared.randomRefreshJedySound)
        internetService?.newsArray.removeAll()
        reload()
        newsList.refreshControl?.endRefreshing()
        animateLoading()
        Task {
            try await internetService?.getData(completion: {
                DispatchQueue.main.async {
                    self.stopAnimatingAndHide()
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
            self?.responseErrorNotificationLabel.text = error
            self?.setErrorResponseLabelHeightConstraint(to: 100, from: 0)
            UIView.animate(withDuration: 2.0,
                           delay: 0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseIn,
                           animations: {
                self?.view.layoutIfNeeded()
                VibrateManager.shared.makeErrorVibration()
                self?.navigationController?.navigationBar.layer.shadowColor = UIColor.clear.cgColor
            }, completion: { finished in
                self?.animateChanges()
            })
        }
    }
    
    func setErrorResponseLabelHeightConstraint(to oneValue: CGFloat, from anotherValue: CGFloat) {
        responseErrorNotificationLabel.constraints.forEach {
            if $0.constant == anotherValue {
                responseErrorNotificationLabel.removeConstraint($0)
            }
        }
        responseErrorNotificationLabel.heightAnchor.constraint(equalToConstant: oneValue).isActive = true
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
            try await internetService?.getData(completion: {
                DispatchQueue.main.async {
                    self.stopAnimatingAndHide()
                    searchBar.text?.removeAll()
                    self.view.endEditing(true)
                }
            }, with: searchBar.text)
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        guard let text = searchBar.text else { return false }
        if text.isEmpty {
            rightBarButtonItem.isHidden = true
        }
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        rightBarButtonItem.isHidden.toggle()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchBar.text = searchBar.text?.filter{ $0.isLetter && $0 != " " }
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
        // Bad idea, but for some reason close button doesn't work, so i made my own =)
        // Костыль на закрытие контроллера _Поделиться_ 
        injectCloseButtonTo(vc: vc)
        present(vc, animated: true, completion: nil)
    }
    
    @objc private func close() {
        if let presentingVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController {
            presentingVC.dismiss(animated: true)
        }
    }
}
