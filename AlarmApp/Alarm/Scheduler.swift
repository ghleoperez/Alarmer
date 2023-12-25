//
//  Scheduler.swift
//  AlarmApp
//
//  Created by Leo on 25/05/22.
//

import Foundation
import UIKit
import UserNotifications
import AVFAudio
import CoreHaptics
import MediaPlayer
import AVFoundation


class Scheduler: AlarmSchedulerDelegate {
    
    static let shared = Scheduler()
    var isComeFromDismiss:Bool = false
    var currentPlayingAlarmId:Int = 0
    
    init(){}
    
    let center = UNUserNotificationCenter.current()
    
    enum weekdaysComparisonResult {
        case before
        case same
        case after
    }
    
    func changeStatusForDismissScreen(isComeFromDismiss:Bool,currentPlayingAlarmId:Int) {
        self.isComeFromDismiss = isComeFromDismiss
        self.currentPlayingAlarmId = currentPlayingAlarmId
        
        print("is Come Dismiss From \(isComeFromDismiss) & Current Playing Alarm Id \(currentPlayingAlarmId)")
    }
    
    func checkUserNotificationAuthStatus(completionBlock: @escaping (_ result: Bool) -> ()) {
        center.getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized) {
                completionBlock (true)
            } else {
                completionBlock (false)
            }
        }
    }
    
    func registerUserNotification(completionBlock: @escaping (_ result: Bool) -> ()) {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("granted")
                completionBlock (true)
            } else {
                print("error")
                completionBlock (false)
            }
        }
    }
    
    func alertForNotificationAccess(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        alert.addAction(UIAlertAction(title: string.cancel, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: string.setting, style: .cancel, handler: { (alert) -> Void in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }))
        DispatchQueue.main.async {
            let topVC = topViewController()
            topVC?.present(alert, animated: true, completion: nil)
        }
    }
    
    func scheduleNewNotification(alarmDetail: AlarmDetail) {
        self.checkUserNotificationAuthStatus { result in
            if result == true {
                //Do further process
                self.setNotificationWithDate(alarmDetail: alarmDetail)
            } else {
                if isNotificationAccessAlertShow == false && CoreDataManager.shared.getAlarmList().count == 1 {
                    //When access not granted then only first time alert can display.
                    isNotificationAccessAlertShow = true
                    self.alertForNotificationAccess(title: string.first_notification_alert_title, message: string.first_notification_alert_message)
                }
                //                else {
                //Otherwise continue to set alarm.
                self.setNotificationWithDate(alarmDetail: alarmDetail)
                //                }
            }
        }
    }
    
    func setNotificationWithDate(alarmDetail: AlarmDetail) {
        guard alarmDetail.status == 1 else {
            return
        }
        
        self.checkNotificationAlreadyScheduled(alarmDetail: alarmDetail) {
            DispatchQueue.main.async {
                if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    self.center.delegate = sd.self
                }
            }
            
            var weekDays: [Int] = []
            if alarmDetail.days.count != 0 {
                weekDays = alarmDetail.days.components(separatedBy: ",").map({Int ($0) ?? 0})
            }
            
            let notificationDateArray = self.scheduledDate(alarmDetail.date.alarmDate, onWeekDaysForNotify: weekDays)
            print("####################", notificationDateArray)
            for (i, notificationDate) in notificationDateArray.enumerated() {
                
                let notificationId = String (alarmDetail.id ?? 0) + "_" + String(i)
                
                let alarmNotification = UNMutableNotificationContent()
                alarmNotification.title = "NFC Alarm Clock"
                
                var alarmBodyText = ""
                if alarmDetail.isNfcActive == 1 {
                    alarmBodyText = "Open the app to scan the nfc tag for dismiss the alarm."
                } else {
                    alarmBodyText = "Open the app to dismiss the alarm."
                }
                
                if alarmDetail.name != "" {
                    alarmNotification.body = alarmDetail.name + "\n" + alarmBodyText
                } else {
                    alarmNotification.body =  alarmBodyText
                }
                
                alarmNotification.categoryIdentifier = "ALARM_IDENTIFIER"
                
                var mediaName: String = ""
                if alarmDetail.mediaName == "" {
                    mediaName = "alarm_1"
                } else {
                    mediaName = alarmDetail.mediaName
                    if alarmDetail.mediaId != "" {
                        mediaName = "alarm_1"
                    }
                }
                //                print("Selected Media >>>>>>>>>>>>>>>>>>>>>>>>>. \(mediaName)")
                //                alarmNotification.sound = UNNotificationSound (named: UNNotificationSoundName (mediaName + ".mp3"))
                
                let dateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: notificationDate)
                
                alarmNotification.userInfo = ["is_nfc_active": alarmDetail.isNfcActive,
                                              "notification_date": notificationDate,
                                              "sound_name": mediaName]
                
                var isRepeat: Bool = false
                if alarmDetail.isRepeat == 1 {
                    isRepeat = true
                }
                let trigger = UNCalendarNotificationTrigger (dateMatching: dateComponents, repeats: isRepeat)
                let request = UNNotificationRequest (identifier: notificationId, content: alarmNotification, trigger: trigger)
                self.center.add(request) { error in
                }
            }
            self.setAudio()
        }
    }
    
    func setAudio() {
        var alarmList = CoreDataManager.shared.getAlarmList()
        alarmList = alarmList.filter{($0.status == 1)}
        
        var alarmTimeArray: [[String: Any]] = []
        for alarm in alarmList {
            var weekDays: [Int] = []
            if alarm.days.count != 0 {
                weekDays = alarm.days.components(separatedBy: ",").map({Int ($0) ?? 0})
            }
            let notificationDateArray = self.scheduledDate(alarm.date.alarmDate, onWeekDaysForNotify: weekDays)
            
            let soundURL = AudioPlayerManager.shared.audioPlayerUrl(alarmDetail: alarm)
            
            notificationDateArray.forEach { date in
                alarmTimeArray.append(["date": date,
                                       "sound_url": soundURL,
                                       "volume": alarm.volume,
                                       "id": alarm.id ?? 0,
                                       "is_vibrate": alarm.isVibrate])
            }
        }
        
        let result = alarmTimeArray.sorted { firstObject, secondObject in
            guard let firstDate = firstObject["date"] as? Date,
                  let secondDate = secondObject["date"] as? Date else {
                return false
            }
            return firstDate < secondDate
        }
        
        let details = result.first
        guard let soundURL = details?["sound_url"] as? URL else {
            return
        }
        guard let alarmDate = details?["date"] as? Date else {
            return
        }
        guard let volume = details?["volume"] as? Float else {
            return
        }
        guard let alarmId = details?["id"] as? Int else {
            return
        }
        guard let isVibrate = details?["is_vibrate"] as? Int else {
            return
        }
        
        do {
            AudioPlayerManager.shared.audioPlayer = try AVAudioPlayer (contentsOf: soundURL)
        } catch let error {
            print(error)
        }
        AudioPlayerManager.shared.audioPlayer?.delegate = AudioPlayerManager.shared.self
        AudioPlayerManager.shared.audioPlayer?.prepareToPlay()
        AudioPlayerManager.shared.audioPlayer?.numberOfLoops = -1
        AudioPlayerManager.shared.audioPlayer?.accessibilityHint = String (alarmId)
        AudioPlayerManager.shared.audioPlayer?.accessibilityValue = alarmDate.alarmDateString
        AudioPlayerManager.shared.audioPlayer?.accessibilityLabel = String (volume)
        
        let timeInterval = (AudioPlayerManager.shared.audioPlayer?.deviceCurrentTime ?? 0.0)
        let dateTimeInterval = alarmDate.timeIntervalSinceNow
        
        print("Alarm Details >>> \(String(describing: details)) && Time Interval >> \(dateTimeInterval)")
        AudioPlayerManager.shared.audioPlayer?.play(atTime: timeInterval + dateTimeInterval)
        
        AudioPlayerManager.shared.work?.cancel()
        AudioPlayerManager.shared.work = DispatchWorkItem  {
            if AudioPlayerManager.shared.work?.isCancelled != true {
                MPVolumeView.setVolume(volume)
                if isVibrate == 1 {
                    UIDevice.vibrate()
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dateTimeInterval, execute: AudioPlayerManager.shared.work!)
    }
    
    func setupNotificationSettings() {
        let dismissAction = UNNotificationAction(identifier: "DISMISS_ACTION",
                                                 title: "Dismiss",
                                                 options: [])
        
        // Define the notification type
        let alarmCategory =
        UNNotificationCategory(identifier: "ALARM_IDENTIFIER",
                               actions: [dismissAction],
                               intentIdentifiers: [])
        
        // Register the notification type.
        self.center.setNotificationCategories([alarmCategory])
    }
    
    func checkNotificationAlreadyScheduled(alarmDetail: AlarmDetail, completionBlock: @escaping () -> ()) {
        center.getPendingNotificationRequests { notifications in
            let notificationList = notifications
            let notificationId = String (alarmDetail.id ?? 0) + "_"
            let filterdList = notificationList.filter({$0.identifier.contains(notificationId)})
            if filterdList.count == 0 {
                completionBlock ()
            } else {
                var pendingIds: [String] = []
                for current in filterdList {
                    pendingIds.append(current.identifier)
                }
                self.center.removePendingNotificationRequests(withIdentifiers: pendingIds)
                completionBlock ()
            }
        }
    }
    
    func cancelScheduledNotification(alarmDetail: AlarmDetail) {
        center.getPendingNotificationRequests { notifications in
            let notificationList = notifications
            let notificationId = String (alarmDetail.id ?? 0) + "_"
            let filterdList = notificationList.filter({$0.identifier.contains(notificationId)})
            var pendingIds: [String] = []
            for current in filterdList {
                pendingIds.append(current.identifier)
            }
            self.center.removePendingNotificationRequests(withIdentifiers: pendingIds)
            AudioPlayerManager.shared.audioPlayer?.stop()
            AudioPlayerManager.shared.work?.cancel()
            
            self.setAudio()
        }
    }
    
    func scheduledDate(_ date: Date, onWeekDaysForNotify weekdays: [Int]) -> [Date] {
        var scheduledDateArray: [Date] = [Date]()
        let calendar = Calendar (identifier: .gregorian)
        let now = Date()
        let flags: NSCalendar.Unit = [.weekday, .weekdayOrdinal, .day]
        let dateComponents = (calendar as NSCalendar).components(flags, from: date)
        let todayWeekday: Int = dateComponents.weekday ?? 0
        
        //No Repeat
        if weekdays.isEmpty {
            if date < now {
                scheduledDateArray.append((calendar as NSCalendar).date(byAdding: .day, value: 1, to: date, options: .matchStrictly) ?? Date())
            } else {
                scheduledDateArray.append(date)
            }
            return scheduledDateArray
        } else { //Repeat
            let daysInWeek = 7
            scheduledDateArray.removeAll(keepingCapacity: true)
            for weekDay in weekdays {
                var scheduleDate: Date = Date()
                //schedule on next week
                if compare(weekday: weekDay, with: todayWeekday) == .before {
                    scheduleDate = (calendar as NSCalendar).date(byAdding: .day, value: weekDay+daysInWeek-todayWeekday, to: date, options: .matchStrictly) ?? Date()
                }
                //schedule on today or next week
                else if compare(weekday: weekDay, with: todayWeekday) == .same {
                    //scheduling date is eariler than current date, then schedule on next week
                    if date.compare(now) == .orderedAscending { //left is small
                        scheduleDate = (calendar as NSCalendar).date(byAdding: .day, value: daysInWeek, to: date, options: .matchStrictly) ?? Date()
                    } else {
                        scheduleDate = date
                    }
                }
                //schedule on next days of this week
                else if compare(weekday: weekDay, with: todayWeekday) == .after {
                    scheduleDate = (calendar as NSCalendar).date(byAdding: .day, value: weekDay-todayWeekday, to: date, options: .matchStrictly) ?? Date()
                }
                scheduleDate = self.correctSecondComponent(date: scheduleDate, calendar: calendar)
                scheduledDateArray.append(scheduleDate)
            }
            return scheduledDateArray
        }
    }
    
    func compare(weekday w1: Int, with w2: Int) -> weekdaysComparisonResult {
        if w1 == w2 {
            return .same
        } else if w1 < w2 {
            return .before
        } else {
            return .after
        }
    }
    
    func correctSecondComponent(date: Date, calendar: Calendar = Calendar(identifier: .gregorian))-> Date {
        let second = calendar.component(.second, from: date)
        let date = (calendar as NSCalendar).date(byAdding: .second, value: -second, to: date, options:.matchStrictly) ?? Date()
        return date
    }
    
    func alarmLeftTime(alarmDetail: AlarmDetail) -> String {
        var weekDays: [Int] = []
        if alarmDetail.days.count != 0 {
            weekDays = alarmDetail.days.components(separatedBy: ",").map({Int ($0) ?? 0})
        }
        let notificationDateArray = self.scheduledDate(alarmDetail.date.alarmDate, onWeekDaysForNotify: weekDays)
        let minAlarmDate = notificationDateArray.min() ?? Date()
        let remainTime = minAlarmDate.offsetFrom(date: Date())
        return remainTime
    }
    
    func rescheduleNotification() {
        center.removeAllPendingNotificationRequests()
        let alarmList = CoreDataManager.shared.getAlarmList()
        alarmList.forEach { alarmDetail in
            if alarmDetail.date.alarmDate.timeIntervalSinceNow.sign == .minus {
                let calendar = Calendar.current
                var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alarmDetail.date.alarmDate)
                components.year = calendar.component(.year, from: Date())
                components.month = calendar.component(.month, from: Date())
                components.day = calendar.component(.day, from: Date())
                let date = calendar.date(from: components)
                let updateAlarmDetail = alarmDetail
                updateAlarmDetail.date = date?.alarmDateString ?? ""
                CoreDataManager.shared.updateAlarm(updatedAlarmDetail: updateAlarmDetail)
                self.scheduleNewNotification(alarmDetail: updateAlarmDetail)
            } else {
                //myDate is equal or after than Now (date and time)
                self.scheduleNewNotification(alarmDetail: alarmDetail)
            }
        }
    }
    
    func scheduleTerminateAppLocalNotification() {
        print("scheduleTerminateAppLocalNotification start")
        let list = CoreDataManager.shared.currentAlarmList
        let filterdArray = list.filter({$0.status == 1})
        guard filterdArray.count != 0 else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = string.app_terminate_notification_title
        content.body = string.app_terminate_notification_body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let uuidString = "terminate"
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        // Schedule the request with the system.
        
        if Scheduler.shared.isComeFromDismiss == false {
            self.center.add(request)
        }
        self.tempNotificaitons(alarmList: filterdArray)
        print("scheduleTerminateAppLocalNotification end")
    }
    
    func tempNotificaitons(alarmList: [AlarmDetail]) {
        print("tempNotificaitons start")
        if Scheduler.shared.isComeFromDismiss  {
            print("ID >> \(currentPlayingAlarmId)")
            if let alarmDetail = alarmList.filter({$0.id == Scheduler.shared.currentPlayingAlarmId}).first {
                print("alarm found")
                self.repeatCurrentRingingAlarm(currentAlarmDetails: alarmDetail, currentAlarmDate: alarmDetail.date.alarmDate)
            }
            print("alarm not found \(alarmList.count) Alarm id:\(Scheduler.shared.currentPlayingAlarmId)")
        } else {
            self.getPendingNotificationDetails()
        }
        print("tempNotificaitons end")
    }
    
    func getPendingNotificationDetails() {
        print("tempNotificaitons stat")
        center.getPendingNotificationRequests { notifications in
            var notificationList = notifications
            
            if let index = notificationList.firstIndex(where: {$0.identifier == "terminate"}) {
                notificationList.remove(at: index)
            }
            
            let sortedList = notificationList.sorted { firstObject, secondObject in
                let firstNotificationDate = firstObject.content.userInfo["notification_date"] as? Date ?? Date()
                let secondNotificationDate = secondObject.content.userInfo["notification_date"] as? Date ?? Date()
                return firstNotificationDate < secondNotificationDate
            }
            
            guard let alarmDetails = sortedList.first else {
                return
            }
            
            print("Start to set multiple alarms")
            self.setMultipleAlarms(nextAlarmDetails: alarmDetails)
        }
        print("tempNotificaitons end")
    }
    
    func setMultipleAlarms(nextAlarmDetails: UNNotificationRequest) {
        print("setMultipleAlarms start")
        let content = UNMutableNotificationContent()
        content.title = nextAlarmDetails.content.title
        content.categoryIdentifier = nextAlarmDetails.content.categoryIdentifier
        content.userInfo = nextAlarmDetails.content.userInfo
        content.sound = UNNotificationSound (named: UNNotificationSoundName ((nextAlarmDetails.content.userInfo["sound_name"] as? String ?? "") + ".mp3"))
        var identifier = ""
        var isRepeat: Bool = false
        var latestDate:Date?
        var i = 0
        
        let notificationDate = nextAlarmDetails.content.userInfo["notification_date"] as? Date ?? Date()
        print("Notification Date : \(notificationDate)")
        for seconds in 0...60 {
            print(seconds)
            if seconds == 0 {
                identifier = nextAlarmDetails.identifier
                isRepeat = nextAlarmDetails.trigger?.repeats ?? false
                content.body = nextAlarmDetails.content.body
                let latestDate = Calendar.current.date(byAdding: .second , value: seconds, to: notificationDate)
                self.sendNotification(content: content, date: latestDate!, isRepeat: isRepeat, identifire: identifier)
                print("Main Notification date >>> \(latestDate!.description(with: .current)) && Identifier >>> \(identifier)")
            } else {
                identifier = nextAlarmDetails.identifier + "_" + String(seconds)
                isRepeat = nextAlarmDetails.trigger?.repeats ?? false
                content.body = nextAlarmDetails.content.body
                if seconds >= 1  &&  seconds <= 10 {
                    i = i + 2
                    latestDate = Calendar.current.date(byAdding: .second , value: i, to: notificationDate)
                } else if seconds > 10  &&  seconds <= 20 {
                    i = i + 3
                    latestDate = Calendar.current.date(byAdding: .second , value: i, to: notificationDate)
                } else if seconds > 20  &&  seconds <= 60 {
                    i = i + 4
                    latestDate = Calendar.current.date(byAdding: .second , value: i, to: notificationDate)
                }
                self.sendNotification(content: content, date: latestDate!, isRepeat: isRepeat, identifire: identifier)
                print("2 second Notification date >>>> \(latestDate!.description(with: .current)) && identifier >>>> \(identifier)")
            }
            //            }
        }
        print("setMultipleAlarms end")
    }
    
    func repeatCurrentRingingAlarm(currentAlarmDetails: AlarmDetail, currentAlarmDate: Date) {
        
        let content = UNMutableNotificationContent()
        content.title = "NFC Alarm Clock"
        content.categoryIdentifier = "ALARM_IDENTIFIER"
        
        var mediaName: String = ""
        if currentAlarmDetails.mediaName == "" {
            mediaName = "alarm_1"
        } else {
            mediaName = currentAlarmDetails.mediaName
            if currentAlarmDetails.mediaId != "" {
                mediaName = "alarm_1"
            }
        }
        
        content.userInfo = ["is_nfc_active": currentAlarmDetails.isNfcActive,
                            "notification_date": currentAlarmDate,
                            "sound_name": mediaName]
        content.sound = UNNotificationSound (named: UNNotificationSoundName (mediaName + ".mp3"))
        
        var alarmBodyText = ""
        if currentAlarmDetails.isNfcActive == 1 {
            alarmBodyText = "Open the app to scan the nfc tag for dismiss the alarm."
        } else {
            alarmBodyText = "Open the app to dismiss the alarm."
        }
        
        if currentAlarmDetails.name != "" {
            content.body = currentAlarmDetails.name + "\n" + alarmBodyText
        } else {
            content.body =  alarmBodyText
        }
        
        self.center.removeAllDeliveredNotifications()
        self.center.removeAllPendingNotificationRequests()
        
        var latestDate:Date?
        var i = 0
        let notificationDate = Date().addingTimeInterval(3)
        for seconds in 0...60 {
            if seconds == 0 {
                guard let latestDate = Calendar.current.date(byAdding: .second , value: seconds, to: notificationDate) else {
                    return
                }
                let identifier = String (currentAlarmDetails.id ?? 0) + "_" + String(seconds)
                self.sendNotification(content: content, date: latestDate, isRepeat: false, identifire: identifier)
                print("Curretn Ring 2 second Notification date >>>> \(latestDate.description(with: .current)) && identifier >>> \((String (currentAlarmDetails.id ?? 0)) + "_" + String(seconds))")
            } else {
                if seconds >= 1  &&  seconds <= 10 {
                    i = i + 2
                    latestDate = Calendar.current.date(byAdding: .second , value: i, to: notificationDate)
                } else if seconds > 10  &&  seconds <= 20 {
                    i = i + 3
                    latestDate = Calendar.current.date(byAdding: .second , value: i, to: notificationDate)
                } else if seconds > 20  &&  seconds <= 60 {
                    i = i + 4
                    latestDate = Calendar.current.date(byAdding: .second , value: i, to: notificationDate)
                }
                let identifier = String (currentAlarmDetails.id ?? 0) + "_" + String(seconds)
                self.sendNotification(content: content, date: latestDate!, isRepeat: false, identifire: identifier)
                print("Curretn Ring 2 second Notification dateComponents >>>> \(latestDate!.description(with: .current)) && identifier >>> \((String (currentAlarmDetails.id ?? 0)) + "_" + String(seconds))")
            }
        }
    }
    
    func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func sendNotification(content:UNMutableNotificationContent,date:Date,isRepeat:Bool,identifire:String) {
        let dateComponents = Calendar.current.dateComponents([.weekday, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger (dateMatching: dateComponents, repeats: isRepeat)
        let request = UNNotificationRequest (identifier: identifire, content: content, trigger: trigger)
        self.center.add(request){ (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
}
