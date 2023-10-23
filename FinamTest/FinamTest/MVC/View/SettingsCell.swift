//
//  SettingsCell.swift
//  ТехноНовости
//
//  Created by Ярослав Куприянов on 02.04.2023.
//

import Foundation
import UIKit

typealias SwitcherAction = (Bool) -> Void

final class SettingsCell: UITableViewCell {
    
    static let id = String(describing: SettingsCell.self)
    
    private var model: SettingsModel?
    
    lazy var title: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .natural
        title.numberOfLines = .zero
        title.font = .systemFont(ofSize: 17, weight: .medium)
        return title
    }()
    
    lazy var rightTitle: UILabel = {
        let title = UILabel()
        title.textAlignment = .right
        title.textColor = .gray
        title.numberOfLines = .zero
        title.font = .systemFont(ofSize: 17, weight: .medium)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    private lazy var switcher: UISwitch = {
        let switcher = UISwitch()
        switcher.addTarget(self, action: #selector(tapped), for: .valueChanged)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        return switcher
    }()
    
    @objc private func tapped(sender: UISwitch) {
        switcher.setOn(sender.isOn, animated: true)
        StorageService.shared.save(sender.isOn, forKey: model?.name ?? "Error")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupUserSoundSettings()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(model: SettingsModel) {
        if model.rightTitle != nil {
            accessoryType = .disclosureIndicator
            contentView.backgroundColor = .clear
            backgroundColor = .systemGray4.withAlphaComponent(0.5)
            layer.cornerRadius = 16
        }
        self.model = model
        rightTitle.isHidden = model.rightTitle == nil
        switcher.isHidden = model.rightTitle != nil
        rightTitle.text = model.rightTitle
        title.text = model.name
    }
    
    private func setupUI() {
        contentView.backgroundColor = .systemGray4.withAlphaComponent(0.5)
        contentView.addSubview(title)
        contentView.addSubview(rightTitle)
        contentView.addSubview(switcher)
        contentView.layer.cornerRadius = 16
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            title.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            switcher.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 13),
            switcher.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            switcher.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -19),
            
            rightTitle.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            rightTitle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            rightTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            contentView.heightAnchor.constraint(equalToConstant: 57)
        ])
    }
    
    private func setupUserSoundSettings() {
        guard let switcherIsOn = StorageService.shared.getBool(for: SettingsKeys.soundSettings.rawValue) else { return }
        switcher.setOn(switcherIsOn, animated: false)
    }
}
