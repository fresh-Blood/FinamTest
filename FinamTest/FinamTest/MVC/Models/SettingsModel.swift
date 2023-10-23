//
//  SettingsModel.swift
//  ТехноНовости
//
//  Created by Ярослав Куприянов on 02.04.2023.
//

import Foundation

typealias Action = () -> Void

struct SettingsModel {
    let name: String
    var action: Action?
}
