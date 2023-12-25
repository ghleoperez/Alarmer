//
//  DismissAlarmViewController.swift
//  AlarmApp
//
//  Created by Leo on 14/06/22.
//

import UIKit
import AudioToolbox
import MediaPlayer

class DismissAlarmViewController: UIViewController {

    @IBOutlet var scanNfcLabel: UILabel!
    @IBOutlet var scanButton: UIButton!
    @IBOutlet var dismissButton: UIButton!
    
    var isNfcActive: Int = 0
    var alarmId: Int = 0
    var alarmDetail: AlarmDetail = AlarmDetail()
    var isOpenFromKilledMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alarmDetail = CoreDataManager.shared.getAlarmDetail(alarmId: self.alarmId)
        self.setUpView()
    }
    
    func setUpView() {
        if self.alarmDetail.isNfcActive == 1 {
            self.scanNfcLabel.isHidden = false
            self.scanNfcLabel.text = "Scan NFC tag to dismiss the alarm."
            self.scanButton.isHidden = false
            self.dismissButton.isHidden = true
        } else {
            self.scanNfcLabel.isHidden = true
            self.scanNfcLabel.text = ""
            self.dismissButton.isHidden = false
            self.scanButton.isHidden = true
        }
        self.dismissButton.setTitleColor(themeColor, for: .normal)
        self.scanButton.setTitleColor(themeColor, for: .normal)
        
        if self.isOpenFromKilledMode {
            do {
                AudioPlayerManager.shared.audioPlayer = try AVAudioPlayer (contentsOf: AudioPlayerManager.shared.audioPlayerUrl(alarmDetail: self.alarmDetail))
            } catch let error {
                print(error)
            }
            AudioPlayerManager.shared.audioPlayer?.delegate = AudioPlayerManager.shared.self
            AudioPlayerManager.shared.audioPlayer?.prepareToPlay()
            AudioPlayerManager.shared.audioPlayer?.numberOfLoops = -1
            AudioPlayerManager.shared.audioPlayer?.accessibilityHint = String (alarmId)
            AudioPlayerManager.shared.audioPlayer?.accessibilityValue = self.alarmDetail.date
            AudioPlayerManager.shared.audioPlayer?.accessibilityLabel = String (self.alarmDetail.volume)
            AudioPlayerManager.shared.audioPlayer?.play()
            
            MPVolumeView.setVolume(self.alarmDetail.volume)
            
            if self.alarmDetail.isVibrate == 1 {
                UIDevice.vibrate()
            }
        }
    }
    
    @IBAction func clickOnScanButton(_ sender: UIButton) {
        NFCSessionManager.shared.alarmIndetifier = String (self.alarmDetail.id ?? 0)
        NFCSessionManager.shared.setUpNFCSession()
    }
    
    @IBAction func clickOnDismissButton(_ sender: UIButton) {
        Scheduler.shared.changeStatusForDismissScreen(isComeFromDismiss: false, currentPlayingAlarmId: 0)
        Scheduler.shared.center.removeAllDeliveredNotifications()
        self.updateAlarmOnDismiss()
    }
    
    func updateAlarmOnDismiss() {
        AudioPlayerManager.shared.stopAudioPlayer()
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate)
        Scheduler.shared.setAudio()
        self.dismiss(animated: true) {
            if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                if let rootView = sd.window?.rootViewController as? UINavigationController {
                    let views = rootView.viewControllers
                    views.forEach { currentView in
                        if currentView.isKind(of: HomeViewController.self) == true {
                            if let homeView = currentView as? HomeViewController {
                                homeView.alarmTableview.reloadData()
                            }
                        }
                    }
                }
            }
            Scheduler.shared.checkUserNotificationAuthStatus { result in
                if result == false {
                    Scheduler.shared.alertForNotificationAccess(title: string.notification_alert_title, message: string.notification_alert_message)
                }
            }
        }
    }
}
