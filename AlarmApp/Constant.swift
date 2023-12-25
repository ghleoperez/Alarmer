//
//  Constant.swift
//  AlarmApp
//
//  Created by Leo on 16/05/22.
//

import UIKit

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let scene = UIApplication.shared.connectedScenes.first

let storyBoard = UIStoryboard.init(name: "Main", bundle: nil)

let NFCTEXT = "Moti Alarm App"

struct UserDefaultKey {
    static let isFirstTimeLaunched = "is_first_time_launched"
    static let isNotificationAccessAlertShow = "is_notification_access_alert_show"
    static let isAudioObserverStart = "is_audio_observer_start"
    static let alarmCount = "alarm_count"
    static let sliderVolume = "slider_volume"
    static let themeColor = "theme_color"
    static let nameColor = "name_color"
    static let daysColor = "days_color"
    static let timeColor = "time_color"
    static let amColor = "am_color"
    static let pmColor = "pm_color"
}

struct Entity {
    static let alarm = "Alarm"
}

struct AlarmEntityKey {
    static let id = "id"
    static let time = "time"
    static let date = "date"
    static let name = "name"
    static let status = "status"
    static let is_repeat = "is_repeat"
    static let is_vibrate = "is_vibrate"
    static let is_nfc_active = "is_nfc_active"
    static let nfc_text = "nfc_text"
    static let media_name = "media_name"
    static let media_id = "media_id"
    static let is_delete = "is_delete"
    static let volume = "volume"
    static let days = "days"
    static let audio_option = "audio_option"
}

struct StaticArray {
    static let daysArray = ["1": "Sun",
                            "2": "Mon",
                            "3": "Tue",
                            "4": "Wed",
                            "5": "Thu",
                            "6": "Fri",
                            "7": "Sat"]
    
    static let settingOptions = [
        Setting (id: 1, image: "appearance", title: "Appearance", subTitle: "Customize how the app looks", tag: "APPEARANCE"),
    ]
    
    static let appearanceOptions = [
        Appearance (id: 1, title: "Theme", subTitle: "The theme color.", color: themeColor, tag: "THEME"),
        Appearance (id: 2, title: "Name", subTitle: "e.g. Work", color: nameColor, tag: "NAME"),
        Appearance (id: 3, title: "Days", subTitle: "e.g. Mon \u{2022} Tue \u{2022} Wed \u{2022} Thu \u{2022} Fri", color: daysColor, tag: "DAYS"),
        Appearance (id: 4, title: "Time", subTitle: "e.g. 12:30", color: timeColor, tag: "TIME"),
        Appearance (id: 5, title: "AM", subTitle: "Colored if AM is in the alarm time.", color: amColor, tag: "AM"),
        Appearance (id: 6, title: "PM", subTitle: "Colored if PM is in the alarm time.", color: pmColor, tag: "PM")
    ]
    
    static let ringtonArray = [
        "Astro Alert",
        "Basic Bell",
        "Beep Once",
        "Beep X2"
        
    ]
}

struct string {
    static let repeat_alarm = "Repeat alarm"
    static let not_repeat_alarm = "Do not repeat alarm"
    static let vibrate_off = "Vibrate off"
    static let vibrate_on = "Vibrate on"
    static let nfc_optional = "NFC optional"
    static let device_not_support_nfc = "Device Not support NFC"
    static let scan_nfc = "Please scan a NFC tag."
    static let nfc_not_messages = "NFC tag have not messages. Please scan valid tag."
    static let scan_valid_nfc = "Please scan valid tag."
    static let session_invalid_by_user = "Session invalidated by user"
    static let first_ndef_tag_read = "First NDEF tag read"
    static let first_notification_alert_title = "Congrats on your First Alarm! \n One More Thing Needed for Alarms"
    static let first_notification_alert_message = "Moti Alarm needs notifications access to wake you up on time."
    
    static let notification_alert_title = "Did You Not Hear Your Alarm?"
    static let notification_alert_message = "Turn on notifications from device settings for Moti Alarm to ring"
    static let cancel = "Cancel"
    static let setting = "Setting"
    static let app_terminate_notification_title = "Oops, you terminated Moti Alarm!"
    static let app_terminate_notification_body = "Your alarm may not ring. Please open Moti Alarm so that your upcoming alarm can ring with sound."
}

