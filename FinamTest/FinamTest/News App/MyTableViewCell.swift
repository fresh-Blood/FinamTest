import UIKit




@available(iOS 15.0, *)
final class MyTableViewCell: UITableViewCell {
    
    static let id = "MyTableViewCell"
    
    let newsDate: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        return lbl
    }()
    let newsSource: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        return lbl
    }()
    let titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.font = .systemFont(ofSize: 20, weight: .medium)
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(newsDate)
        contentView.addSubview(titleLabel)
        contentView.addSubview(newsSource)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lazy var inset: CGFloat = 8
        titleLabel.frame = CGRect(x: contentView.bounds.minX + inset,
                                  y: contentView.bounds.minY + inset,
                                  width: contentView.bounds.width - inset * 2,
                                  height: contentView.bounds.height/3*2)
        newsDate.frame = CGRect(x: contentView.bounds.minX + inset,
                                y: titleLabel.bounds.maxY + inset,
                                width: contentView.bounds.width/3*2 - inset,
                                height: (contentView.bounds.height - titleLabel.bounds.height) - inset)
        newsSource.frame = CGRect(x: newsDate.bounds.maxX + inset,
                                  y: titleLabel.bounds.maxY + inset,
                                  width: contentView.bounds.width/3 - inset,
                                  height: (contentView.bounds.height - titleLabel.bounds.height) - inset)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
