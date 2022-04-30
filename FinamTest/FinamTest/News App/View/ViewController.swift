import UIKit

typealias CompletionForAnimation = ((Bool) -> Void)?

protocol UserView {
    var internetService: UserInternetService? { get set }
    func reload()
    func animateResponseError(with error: String)
    func animateGoodConnection()
}

final class ViewController: UIViewController, UserView {
    
    struct Layout {
        let contentInsets: UIEdgeInsets
        
        static var `default`: Layout {
            Layout(contentInsets: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }
    
    var layout: Layout = .default
    var internetService: UserInternetService?
    
    private let commonTable: UITableView = {
        let tbl = UITableView()
        tbl.register(MyTableViewCell.self, forCellReuseIdentifier: MyTableViewCell.id)
        return tbl
    }()
    
    private let stackViewForGhostLoadingViews: UIStackView = {
        let stack = UIStackView()
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.axis = .vertical
        stack.spacing = 16
        stack.isHidden = true
        return stack
    }()
    
    private let stackViewForGhostLoadingViewsBG: UIStackView = {
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
        responseErrorView.layer.cornerRadius = 8
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
        name.layer.cornerRadius = 8
        return name
    }
    
    private func makeNewGhostViewBG() -> UIView {
        let name = UIView()
        name.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        name.layer.cornerRadius = 8
        return name
    }
    
    func reload() {
        commonTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightBarButtonItemGesture()
        setLeftBarButtonItemGesture()
        configureRefreshControl()
        configureNavigationBar()
        setupUI()
    }
    
    // MARK: Configure navigation bar
    private let rightBarButtonItem: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.tag = 0
        btn.isHidden = true
        return btn
    }()
    
    private let leftBarButtonItem: UIButton = {
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
            action: #selector(tapInfo))
        gesture.minimumPressDuration = 0
        leftBarButtonItem.addGestureRecognizer(gesture)
    }
    
    @objc private func searchAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
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
        navigationItem.title = InfoMessage.appTitle.rawValue
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = ""
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "magnifyingglass"), style: .plain, target: self, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: nil)
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 30,
                                     weight: .heavy),
            .foregroundColor: UIColor.label
        ]
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = Colors.valueForColor
    }
    
    @objc private func tapInfo() {
        let alertVC = UIAlertController(title: InfoMessage.infoTitle.rawValue, message: InfoMessage.infoMessage.rawValue, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { [weak self] action in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(alertVC, animated: true, completion: nil)
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
        commonTable.delegate = self
        commonTable.dataSource = self
        commonTable.frame = CGRect(x: view.frame.minX + layout.contentInsets.left,
                                   y: view.frame.minY,
                                   width: view.frame.width - layout.contentInsets.right*2,
                                   height: view.frame.height)
        commonTable.estimatedRowHeight = 44
        commonTable.rowHeight = UITableView.automaticDimension
        commonTable.showsVerticalScrollIndicator = false
        commonTable.separatorStyle = .none
        
        for _ in 1...6 {
            stackViewForGhostLoadingViews.addArrangedSubview(makeNewGhostView())
            stackViewForGhostLoadingViewsBG.addArrangedSubview(makeNewGhostViewBG())
        }
        commonTable.addSubview(stackViewForGhostLoadingViewsBG)
        commonTable.addSubview(stackViewForGhostLoadingViews)
        view.addSubview(commonTable)
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
        stackViewForGhostLoadingViews.frame = commonTable.bounds
        stackViewForGhostLoadingViewsBG.frame = commonTable.bounds
        NSLayoutConstraint.activate([
            responseErrorNotificationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            responseErrorNotificationLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            responseErrorNotificationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            responseErrorNotificationLabel.heightAnchor.constraint(equalToConstant: 0)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func animateGoodConnection() {
        DispatchQueue.main.async { [weak self] in
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
            self.navigationController?.navigationBar.setShadow(configureBorder: false)
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
extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return internetService?.newsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.id, for: indexPath) as! MyTableViewCell
        let model = internetService?.newsArray[indexPath.row]
        cell.titleLabel.text = model?.title
        cell.newsDate.text = model?.publishedAt?.configureTime()
        cell.newsSource.text = model?.source?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = internetService?.newsArray[indexPath.row]
        let secondVC = SecondViewController()
        secondVC.topicLabel.text = topic?.description ?? Errors.topicLabelNoInfo.rawValue
        secondVC.newsImage.downLoadImage(from: topic?.urlToImage ?? Errors.error.rawValue, completion: {
            secondVC.counter += 1
        })
        secondVC.moreInfo = topic?.url ?? Errors.error.rawValue
        navigationController?.pushViewController(secondVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: Refresh control settings
extension ViewController {
    func configureRefreshControl () {
        commonTable.refreshControl = UIRefreshControl()
        commonTable.refreshControl?.addTarget(self, action:
                                                #selector(handleRefreshControl),
                                              for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        internetService?.newsArray.removeAll()
        reload()
        commonTable.refreshControl?.endRefreshing()
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
extension ViewController {
    
    func animateResponseError(with error: String) {
        DispatchQueue.main.async { [weak self] in
            self?.responseErrorNotificationLabel.text = error
            self?.setErrorResponseLabelHeightConstraint(to: 100, from: 0)
            UIView.animate(withDuration: 2.0,
                           delay: 0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 0.1,
                           options: .curveEaseIn,
                           animations: {
                self?.view.layoutIfNeeded()
                UINotificationFeedbackGenerator().notificationOccurred(.error)
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
extension ViewController: UISearchBarDelegate {
    
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
