//
//  AlarmSchedulerDelegate.swift
//  AlarmApp
//
//  Created by Leo on 25/05/22.
//

import Foundation
import UIKit

protocol AlarmSchedulerDelegate {
    func setNotificationWithDate(alarmDetail: AlarmDetail)
}
