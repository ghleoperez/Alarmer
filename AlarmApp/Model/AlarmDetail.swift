//
//  AlarmDetail.swift
//  AlarmApp
//
//  Created by Leo on 20/05/22.
//

import UIKit

class AlarmDetail: NSObject {
    var id: Int?
    var date: String = ""
    var time: String = ""
    var name: String = ""
    var status: Int = 1
    var isRepeat: Int = 1
    var isVibrate: Int = 1
    var isNfcActive: Int = 0
    var nfcText: String = ""
    var mediaName: String = ""
    var mediaId: String = ""
    var isDelete: Int = 0
    var volume: Float = 0.5
    var days: String = "1,2,3,4,5,6,7"
    var audioOption: String = ""
    
    static func == (lhs: AlarmDetail, rhs: AlarmDetail) -> Bool {
        return lhs.time == rhs.time
    }
}

class Setting: NSObject {
    var id: Int?
    var image: String = ""
    var title: String = ""
    var subTitle: String = ""
    var tag: String = ""
    
    init(id: Int?, image: String, title: String, subTitle: String, tag: String) {
        self.id = id
        self.image = image
        self.title = title
        self.subTitle = subTitle
        self.tag = tag
    }
}

class Appearance: NSObject {
    var id: Int?
    var title: String = ""
    var subTitle: String = ""
    var color: UIColor = .red
    var tag = ""
    
    init(id: Int?, title: String, subTitle: String, color: UIColor, tag: String) {
        self.id = id
        self.title = title
        self.subTitle = subTitle
        self.color = color
        self.tag = tag
    }
}
