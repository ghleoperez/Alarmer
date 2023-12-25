//
//  AllowNotificationViewController.swift
//  AlarmApp
//
//  Created by Leo on 06/07/22.
//

import UIKit

class AllowNotificationViewController: UIViewController {

    @IBOutlet var allowNotificationView: UIView!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var borderView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func setUpUI() {
//        self.allowNotificationView.layer.cornerRadius = 12.0
//        self.allowNotificationView.layer.shadowColor = UIColor.darkGray.cgColor
//        self.allowNotificationView.layer.shadowOpacity = 0.2
//        self.allowNotificationView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
//        self.allowNotificationView.layer.shadowRadius = 4
//      //  self.allowNotificationView.layer.shadowPath = UIBezierPath(rect: self.allowNotificationView.bounds).cgPath
//      //  self.allowNotificationView.layer.shouldRasterize = true
//        self.borderView.layer.cornerRadius = self.borderView.frame.size.width / 2
//        self.borderView.layer.borderColor = #colorLiteral(red: 0.3773675859, green: 0.3775456846, blue: 0.6961981654, alpha: 1)
//        self.borderView.layer.borderWidth = 5.0
        
        self.okButton.layer.cornerRadius = 25.0
    }
    
    //MARK: - Button Action Methods
    
    @IBAction func clickOnOkButton(_ sender: UIButton) {
        isFirstTimeLaunched = true
        Scheduler.shared.registerUserNotification { result in
            DispatchQueue.main.async {
                if let sd: SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    sd.setHomeRootViewController()
                }
            }
        }
    }
}
