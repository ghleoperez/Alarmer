//
//  Protocol.swift
//  AlarmApp
//
//  Created by Leo on 31/05/22.
//

import Foundation
import UIKit

protocol UpdateName {
    func setAlarmName(name: String, selectedRow: Int)
}

protocol UpdateColor {
    func updateSelectedColor(tag: String, selectedColor: UIColor)
}

protocol UpdateMusic {
    func updateSelectedMusic(musicName: String, musicId: String, selectedRow: Int)
}
