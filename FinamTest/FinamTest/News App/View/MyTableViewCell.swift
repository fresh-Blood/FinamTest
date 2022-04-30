import UIKit

final class MyTableViewCell: UITableViewCell {
    
    struct Layout {
        let contentInsets: UIEdgeInsets
        
        static var `default`: Layout {
            Layout(contentInsets: UIEdgeInsets(top: 10, left: 0, bottom: -10, right: 0))
        }
    }
    
    var layout: Layout = .default
    
    static let id = "MyTableViewCell"
    
    private lazy var bgView: UIView = {
        let bgView = UIView()
        bgView.layer.cornerRadius = 8
        bgView.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        return bgView
    }()
    
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
        lbl.font = .systemFont(ofSize: 18, weight: .regular)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        bgView.addSubview(newsDate)
        bgView.addSubview(titleLabel)
        bgView.addSubview(newsSource)
        contentView.addSubview(bgView)
        
        selectionStyle = .none
        
        NSLayoutConstraint.activate([
            
            bgView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layout.contentInsets.top),
            bgView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: layout.contentInsets.left),
            bgView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: layout.contentInsets.right),
            bgView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: layout.contentInsets.bottom),
            
            titleLabel.topAnchor.constraint(equalTo: bgView.topAnchor, constant: 5),
            titleLabel.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10),
            titleLabel.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -5),
            
            newsDate.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            newsDate.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10),
            newsDate.leftAnchor.constraint(equalTo: bgView.leftAnchor, constant: 10),
            
            newsSource.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            newsSource.rightAnchor.constraint(equalTo: bgView.rightAnchor, constant: -10),
            newsSource.bottomAnchor.constraint(equalTo: bgView.bottomAnchor, constant: -10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension String {
    func configureNewsTitle() -> String {
        String(self.reversed().drop(while: { $0 != "-" }).dropFirst(1).reversed())
    }
    
    func configureTime() -> String {
        String(self.replacingOccurrences(of: "T", with: "   ")
                    .dropLast(4)).replacingOccurrences(of: "-", with: ".")
    }
}
