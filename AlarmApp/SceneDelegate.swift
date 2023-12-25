//
//  SceneDelegate.swift
//  AlarmApp
//
//  Created by Leo on 16/05/22.
//

import UIKit
import MediaPlayer

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    // Audio session object
    private let audioSession = AVAudioSession.sharedInstance()
    // Observer
    private var progressObserver: NSKeyValueObservation!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        do {
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
        } catch {
            print("cannot activate session")
        }
        
        //Set Device volume according to alarm current volume level.
        progressObserver = audioSession.observe(\.outputVolume) { [weak self] (session, value) in
            if (AudioPlayerManager.shared.audioPlayer != nil) && (AudioPlayerManager.shared.audioPlayer?.currentTime != 0.0) {
                let sessionVolume = self?.audioSession.outputVolume
                let alarmVolume = Float (AudioPlayerManager.shared.audioPlayer?.accessibilityLabel ?? "") ?? 0.0
                if sessionVolume != alarmVolume {
                    MPVolumeView.setVolume(alarmVolume)
                }
            }
        }

        if isFirstTimeLaunched == true {
            self.setHomeRootViewController()
            Scheduler.shared.rescheduleNotification()
        } else {
            self.setAllowNotificationRootViewController()
        }
        
        //While app was killed and open app with notification
        if connectionOptions.notificationResponse != nil {
            guard let notificationDetails = connectionOptions.notificationResponse?.notification else {
                return
            }
//            DispatchQueue.main.async {
//                let topVC = topViewController()
//                topVC?.view.makeToast("ide >> \(notificationDetails.request.identifier)")
//            }

            guard notificationDetails.request.identifier != "terminate" else {
                self.openDismissViewFromDeliverdNotification()
                return
            }
            let idArray = notificationDetails.request.identifier.components(separatedBy: "_")
            if idArray.count >= 1 {
//                print("Open dismiss view from tap on notiifcaiton while app was killed ")
                self.openDismissAlarmView(alarmId: Int (idArray.first ?? "") ?? 0, isOpenFromKilledMode: true)
            }
        } else {
            self.openDismissViewFromDeliverdNotification()
        }
    }
    
    func openDismissViewFromDeliverdNotification() {
        Scheduler.shared.center.getDeliveredNotifications { notifications in
//            print("Deliverd Notifications >>> \(notifications)")
            
            var deliveredNotifications = notifications
            guard let notificationDetails = deliveredNotifications.first else {
                return
            }
//            print("Notification Identifier >>> \(notificationDetails.request.identifier)")
            
            guard notificationDetails.request.identifier != "terminate" else {
                //If delivered first notification is terminate then first delete this notification from list and get second notification details.
                if deliveredNotifications.count > 1 {
                    deliveredNotifications.remove(at: 0)
                    guard let notificationDetails = deliveredNotifications.first else {
                        return
                    }
                    let idArray = notificationDetails.request.identifier.components(separatedBy: "_")
                    if idArray.count >= 1 {
//                        print("Open dismiss view while directly open the app in kill mode")
                        self.openDismissAlarmView(alarmId: Int (idArray.first ?? "") ?? 0, isOpenFromKilledMode: true)
                    }
                }
                return
            }
            let idArray = notificationDetails.request.identifier.components(separatedBy: "_")
            if idArray.count >= 1 {
//                print("Open dismiss view while directly open the app in kill mode")
                self.openDismissAlarmView(alarmId: Int (idArray.first ?? "") ?? 0, isOpenFromKilledMode: true)
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
//        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
//        Scheduler.shared.scheduleTerminateAppLocalNotification()
//        Scheduler.shared.scheduleTerminateAppLocalNotification()
//        sleep(2)
        print("sceneDidDisconnect:")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        //Scheduler.shared.center.removeAllDeliveredNotifications()
        
        //This is for manage alarm dismiss view while alarm goes off and app open without tap on notification while in background.
        if (AudioPlayerManager.shared.audioPlayer != nil) && (AudioPlayerManager.shared.audioPlayer?.currentTime != 0.0) {
            print("Open dismiss view on did become active methods")
            self.openDismissAlarmView(alarmId: Int (AudioPlayerManager.shared.audioPlayer?.accessibilityHint ?? "") ?? 0, isOpenFromKilledMode: false)
        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

}

extension SceneDelegate: UNUserNotificationCenterDelegate {

    //This method is called while app in Foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let idArray = notification.request.identifier.components(separatedBy: "_")
        if idArray.count >= 1 {
            print("Open dismiss view on willPresent notiifation methods")
            self.openDismissAlarmView(alarmId: Int (idArray.first ?? "") ?? 0, isOpenFromKilledMode: false)
        }
        completionHandler([])
    }

    //This method is called while app in Background and tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let idArray = response.notification.request.identifier.components(separatedBy: "_")
            if idArray.count >= 1 {
                print("Open dismiss view on didReceive notiifation methods")
                self.openDismissAlarmView(alarmId: Int (idArray.first ?? "") ?? 0, isOpenFromKilledMode: false)
            }
        }
        completionHandler ()
    }
    
    //MARK: - Views Navigation Methods

    func setHomeRootViewController() {
        let navigationView = storyBoard.instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController
        let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeViewController.alarmid = 0
        homeViewController.isOpenFromKilledMode = false
        navigationView.setViewControllers([homeViewController], animated: true)
        self.window?.rootViewController = navigationView
        self.window?.makeKeyAndVisible()
    }

    func setAllowNotificationRootViewController() {
        let navigationView = storyBoard.instantiateViewController(withIdentifier: "AllowNotificationNavigationController") as! UINavigationController
        self.window?.rootViewController = navigationView
        self.window?.makeKeyAndVisible()
    }

    func openDismissAlarmView(alarmId: Int, isOpenFromKilledMode: Bool) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            let dismissAlarmView = storyBoard.instantiateViewController(withIdentifier: "DismissAlarmViewController") as! DismissAlarmViewController
//            dismissAlarmView.alarmId = alarmId
//            dismissAlarmView.isOpenFromKilledMode = isOpenFromKilledMode
//            if #available(iOS 13.0, *) {
//                dismissAlarmView.isModalInPresentation = true
//            } else {
//    //             Fallback on earlier versions
//            }
//            dismissAlarmView.modalPresentationStyle = .overFullScreen
//            if ((UIApplication.shared.keyWindow?.rootViewController?.presentedViewController) != nil) && (UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.isKind(of: DismissAlarmViewController.self) != true) {
//                print("Open in presented View.......")
//                dismissAlarmView.presentInKeyWindowPresentedController(animated: false)
//            } else {
//                print("Open on current View.......")
//                dismissAlarmView.presentInKeyWindow(animated: false, completion: nil)
//            }
//        }
        Scheduler.shared.changeStatusForDismissScreen(isComeFromDismiss: true,currentPlayingAlarmId: alarmId)
        DispatchQueue.main.async {
            let navigationView = storyBoard.instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController
            let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            homeViewController.alarmid = alarmId
            homeViewController.isOpenFromKilledMode = isOpenFromKilledMode
            navigationView.setViewControllers([homeViewController], animated: true)
            self.window?.rootViewController = navigationView
            self.window?.makeKeyAndVisible()
        }

    }
}


