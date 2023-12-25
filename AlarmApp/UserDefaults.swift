//
//  UserDefaults.swift
//  AlarmApp
//
//  Created by Leo on 20/05/22.
//

import Foundation
import UIKit

let userDefults = UserDefaults.standard

var isFirstTimeLaunched: Bool {
    get {
        userDefults.bool(forKey: UserDefaultKey.isFirstTimeLaunched)
    }
    set {
        userDefults.set(newValue, forKey: UserDefaultKey.isFirstTimeLaunched)
    }
}

var isNotificationAccessAlertShow: Bool {
    get {
        userDefults.bool(forKey: UserDefaultKey.isNotificationAccessAlertShow)
    }
    set {
        userDefults.set(newValue, forKey: UserDefaultKey.isNotificationAccessAlertShow)
    }
}

var isAudioObserverStart: Bool {
    get {
        userDefults.bool(forKey: UserDefaultKey.isAudioObserverStart)
    }
    set {
        userDefults.set(newValue, forKey: UserDefaultKey.isAudioObserverStart)
    }
}

var alarmCount: Int {
    get {
        return userDefults.integer(forKey: UserDefaultKey.alarmCount)
    }
    set {
        userDefults.set(newValue, forKey: UserDefaultKey.alarmCount)
    }
}

var sliderVolume: Float {
    get {
        return userDefults.float(forKey: UserDefaultKey.sliderVolume)
    }
    set {
        userDefults.set(newValue, forKey: UserDefaultKey.sliderVolume)
    }
}


var themeColor: UIColor {
    get {
        userDefults.colorForKey(key: UserDefaultKey.themeColor) ?? #colorLiteral(red: 0.3764705882, green: 0.3764705882, blue: 0.6980392157, alpha: 1)
    }
    set {
        userDefults.setColor(color: newValue, forKey: UserDefaultKey.themeColor)
    }
}

var nameColor: UIColor {
    get {
        userDefults.colorForKey(key: UserDefaultKey.nameColor) ?? #colorLiteral(red: 0, green: 0.737254902, blue: 0.9529411765, alpha: 1)
    }
    set {
        userDefults.setColor(color: newValue, forKey: UserDefaultKey.nameColor)
    }
}

var daysColor: UIColor {
    get {
        userDefults.colorForKey(key: UserDefaultKey.daysColor) ?? #colorLiteral(red: 0.3764705882, green: 0.3764705882, blue: 0.6980392157, alpha: 1)
    }
    set {
        userDefults.setColor(color: newValue, forKey: UserDefaultKey.daysColor)
    }
}

var timeColor: UIColor {
    get {
        userDefults.colorForKey(key: UserDefaultKey.timeColor) ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    set {
        userDefults.setColor(color: newValue, forKey: UserDefaultKey.timeColor)
    }
}


var amColor: UIColor {
    get {
        userDefults.colorForKey(key: UserDefaultKey.amColor) ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    set {
        userDefults.setColor(color: newValue, forKey: UserDefaultKey.amColor)
    }
}

var pmColor: UIColor {
    get {
        userDefults.colorForKey(key: UserDefaultKey.pmColor) ?? #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    set {
        userDefults.setColor(color: newValue, forKey: UserDefaultKey.pmColor)
    }
}
