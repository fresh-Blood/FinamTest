import UIKit



final class MyTableViewCell: UITableViewCell {
    
    static let id = "MyTableViewCell"
    
    let newsDate: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 17, weight: .light)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let newsSource: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 17, weight: .light)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 17, weight: .regular)
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        contentView.addSubview(newsDate)
        contentView.addSubview(titleLabel)
        contentView.addSubview(newsSource)
        
        NSLayoutConstraint.activate([
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5),
            
            newsDate.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            newsDate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            newsDate.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            
            newsSource.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            newsSource.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            newsSource.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
