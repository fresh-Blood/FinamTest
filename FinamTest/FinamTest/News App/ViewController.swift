import UIKit


protocol UserView {
    var controller: UserController? { get set }
    func reload()
    func animateResponseError(with error: String)
}

final class ViewController: UIViewController, UserView {
    
    var controller: UserController?
    
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
        stack.spacing = 10
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
        return responseErrorView
    }()
    
    private func makeNewGhostView(with name: String) -> UIView {
        let name = UIView()
        name.backgroundColor = Colors.valueForLoading
        name.layer.cornerRadius = 8
        name.alpha = 0
        return name
    }
    
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
            }, completion: { finished in
                self?.animateChanges()
            })
        }
    }
    
    internal func reload() {
        commonTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        configureNavigationBar()
        setupUI()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "News ಠ_ಠ"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 40,
                                     weight: .heavy),
            .foregroundColor: UIColor.label
        ]
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.tintColor = Colors.valueForColor
    }
    
    private func setupUI() {
        commonTable.delegate = self
        commonTable.dataSource = self
        commonTable.frame = view.bounds
        commonTable.estimatedRowHeight = 44
        commonTable.rowHeight = UITableView.automaticDimension
        view.addSubview(commonTable)
        for number in 1...10 {
            stackViewForGhostLoadingViews
                .addArrangedSubview(makeNewGhostView(with: "loadingGhostView\(number)"))
        }
        view.addSubview(stackViewForGhostLoadingViews)
        view.addSubview(responseErrorNotificationLabel)
        guard let navBarHeight = self.navigationController?
                .navigationBar
                .frame.height else { return }
        stackViewForGhostLoadingViews.frame = CGRect(x: view.safeAreaInsets.left,
                                                     y: view.safeAreaInsets.top + navBarHeight*2,
                                                     width: view.frame.width,
                                                     height: view.frame.height)
        
        NSLayoutConstraint.activate([
            responseErrorNotificationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            responseErrorNotificationLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            responseErrorNotificationLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            responseErrorNotificationLabel.heightAnchor.constraint(equalToConstant: 0)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let newsArray = controller?.newsArray else { return }
        if newsArray.isEmpty {
            animateLoading()
            controller?.getData(completion: {
                DispatchQueue.main.async {
                    self.stopAnimatingAndHide()
                }
            })
        }
    }
    
    private func animateLoading() {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: [.autoreverse,.repeat,.curveEaseIn],
                       animations: {
            _ = self.stackViewForGhostLoadingViews.arrangedSubviews.map {
                $0.alpha = 1
            }
        }, completion: { finished in
            _ = self.stackViewForGhostLoadingViews.arrangedSubviews.map {
                $0.alpha = 0
            }
        })
    }
    
    private func stopAnimatingAndHide() {
        _ = stackViewForGhostLoadingViews.arrangedSubviews.map{
            $0.layer.removeAllAnimations()
        }
        stackViewForGhostLoadingViews.isHidden = true
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return controller?.newsArray.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.id, for: indexPath) as! MyTableViewCell
        let model = controller?.newsArray[indexPath.row]
        cell.titleLabel.text = model?.title
        cell.newsDate.text = model?.publishedAt
        cell.newsSource.text = model?.source?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topic = controller?.newsArray[indexPath.row]
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


extension ViewController {
    func configureRefreshControl () {
        commonTable.refreshControl = UIRefreshControl()
        commonTable.refreshControl?.addTarget(self, action:
                                                #selector(handleRefreshControl),
                                              for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        controller?.getData(completion: {})
        self.commonTable.refreshControl?.endRefreshing()
        self.reload()
    }
}

enum Errors: String {
    case topicLabelNoInfo = "Тут должно быть описание, но его нет - это не ошибка, попробуйте прочитать подробнее по кнопке ниже."
    case badRequest = "Error 400 - Чёто с интернетом, попробуйте позже"
    case unauthorized = "Error 401 - Чёто с авторизацией запроса, попробуйте позже"
    case tooManyRequests = "Error 429 - Превышено кол-во запросов в сутки, возвращайтесь завтра"
    case serverError = "Error 500 - Ошибка сервера, пойду посплю тогда, мб позже заработает"
    case error = "Error"
}

extension ViewController {
    func setErrorResponseLabelHeightConstraint(to oneValue: CGFloat, from anotherValue: CGFloat) {
        _ = self.responseErrorNotificationLabel.constraints.map{
            if $0.constant == oneValue {
                self.responseErrorNotificationLabel.removeConstraint($0)
            }
        }
        self.responseErrorNotificationLabel.heightAnchor.constraint(equalToConstant: anotherValue).isActive = true
    }
    
    func animateChanges() {
        self.setErrorResponseLabelHeightConstraint(to: 0, from: 100)
        UIView.animate(withDuration: 2.0,
                       delay: 1.0,
                       usingSpringWithDamping: 0.1,
                       initialSpringVelocity: 0.1,
                       options: .curveLinear,
                       animations: {
            self.view.layoutIfNeeded()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        })
    }
}
