//
//  HomeViewController.swift
//  AlarmApp
//
//  Created by Leo on 16/05/22.
//

import UIKit
import CoreNFC
import Toast_Swift
import SVProgressHUD

class HomeViewController: UIViewController {

    @IBOutlet var alarmTableview: UITableView!
    @IBOutlet var addAlarmView: UIView!
    @IBOutlet var addAlarmButton: UIButton!
    
    var alarmList = [AlarmDetail]()
    var expandableRows = Set<Int>()
    var session: NFCNDEFReaderSession?
    
    var alarmid:Int = 0
    var isOpenFromKilledMode:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alarmList = CoreDataManager.shared.getAlarmList()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpUI()
        self.alarmTableview.reloadData()
        if self.alarmid != 0 {
            self.checkAndOpenDismissScreen()
        }
    }

    
    //MARK: - Setup UI Methods
    
    func setUpUI() {
        self.alarmTableview.backgroundColor = UIColor (named: "AppBackgroundColor")
        self.addAlarmButton.layer.cornerRadius = self.addAlarmButton.frame.size.width / 2
        self.addAlarmButton.layer.masksToBounds = true
        self.addAlarmButton.backgroundColor = themeColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.manageAddAlarmView()
        }
    }
    
    func checkAndOpenDismissScreen() {
        let dismissAlarmView = storyBoard.instantiateViewController(withIdentifier: "DismissAlarmViewController") as! DismissAlarmViewController
        dismissAlarmView.alarmId = alarmid
        dismissAlarmView.isOpenFromKilledMode = isOpenFromKilledMode
        dismissAlarmView.isModalInPresentation = true
        dismissAlarmView.modalPresentationStyle = .overFullScreen
        self.present(dismissAlarmView, animated: false)
//        if ((UIApplication.shared.keyWindow?.rootViewController?.presentedViewController) != nil) && (UIApplication.shared.keyWindow?.rootViewController?.presentedViewController?.isKind(of: DismissAlarmViewController.self) != true) {
//            print("Open in presented View.......")
//            dismissAlarmView.presentInKeyWindowPresentedController(animated: false)
//        } else {
//            print("Open on current View.......")
//            dismissAlarmView.presentInKeyWindow(animated: false, completion: nil)
//        }
    }
 
    func manageAddAlarmView() {
        if self.alarmList.count == 0 {
            self.addAlarmView.isHidden = false
            self.alarmTableview.isHidden = true
            guard self.view.layer.sublayers?.filter({$0.accessibilityHint == "PulseAnimation"}).count == 0 else {
                self.view.layer.sublayers?.filter({$0.accessibilityHint == "PulseAnimation"}).first?.removeFromSuperlayer()
                self.addPulseAnimation()
                return
            }
            self.addPulseAnimation()
        } else {
            self.addAlarmView.isHidden = true
            self.alarmTableview.isHidden = false
        }
    }
    
    func addPulseAnimation() {
        let pluse = PulseAnimation (numberOfPulse: Float.infinity, radius: 90, postion: self.addAlarmButton.center)
        pluse.accessibilityHint = "PulseAnimation"
        pluse.animationDuration = 1.2
        pluse.backgroundColor = themeColor.cgColor
        self.view.layer.insertSublayer(pluse, below: self.view.layer)
    }

    //MARK: - Button Action
    
    @IBAction func clickOnAddAlarm(sender: UIButton) {
        self.addNewAlarm()
    }
    
    @IBAction func clickOnSettingButton(sender: UIButton) {
        let settingView: SettingViewController = storyBoard.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        self.navigationController?.pushViewController(settingView, animated: true)
    }
    
    @objc func expandCollapseRows(sender: UIButton) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        
        if self.expandableRows.contains(row) {
            self.expandableRows.remove(row)
            Scheduler.shared.scheduleNewNotification(alarmDetail: self.alarmList[row])
        } else {
            self.expandableRows.insert(row)
        }
        self.alarmTableview.reloadData()
    }
    
    @objc func tapOnAlarmTimeLabel(sender: UITapGestureRecognizer) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        
        let updateAlarmDetail = alarmList[row]
        let timeArray = updateAlarmDetail.time.components(separatedBy: " ")
        
        if timeArray.count == 2 {
            let timeSelector = TimeSelector()
            timeSelector.timeSelected = {
                (timeSelector) in
                
                //Check alarm exits or not
                self.checkSameTimeAlarmAlreadyExits(newAlarmTime: timeSelector.date.time ?? "") { result in
                    if let index = self.alarmList.firstIndex(of: updateAlarmDetail) {
                        Scheduler.shared.scheduleNewNotification(alarmDetail: self.alarmList[index])
                        self.alarmList[index].time = timeSelector.date.time ?? ""
                        self.alarmList[index].date = timeSelector.date.alarmDateString ?? ""
                        
                        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[index])
                        self.alarmTableview.reloadRows(at: [IndexPath (row: index, section: 0)], with: .none)
                    }
                }
            }
            timeSelector.overlayAlpha = 0.7
            let array = timeArray.first?.components(separatedBy: ":")
            if array?.count == 2 {
                timeSelector.minutes = Int (array?.last ?? "") ?? 0
                timeSelector.hours = Int (array?.first ?? "") ?? 0
                if (timeArray.last ?? "") == "AM" {
                    timeSelector.isAm = true
                } else {
                    timeSelector.isAm = false
                }
                timeSelector.presentOnView(view: self.view)                
            }
        }
    }
    
    @objc func alarmStatusValueChanged(sender: UISwitch) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        self.alarmList[row].status = sender.isOn == true ? 1 : 0
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[row])
        if sender.isOn == true {
            sender.thumbTintColor = .white
            sender.onTintColor = themeColor
            Scheduler.shared.scheduleNewNotification(alarmDetail: self.alarmList[row])
        } else {
            sender.thumbTintColor = .white
            sender.tintColor = themeColor
            sender.layer.cornerRadius = sender.frame.height / 2.0
            sender.backgroundColor = themeColor
            sender.clipsToBounds = true
            Scheduler.shared.cancelScheduledNotification(alarmDetail: self.alarmList[row])
        }
        self.alarmTableview.reloadRows(at: [IndexPath (row: row, section: 0)], with: .none)
    }
    
    @objc func clickOnDays(sender: UIButton) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        
        var dayArray: [String] = []
        if self.alarmList[row].days != "" {
            dayArray = self.alarmList[row].days.components(separatedBy: ",")
        }
        
        if dayArray.contains(String(sender.tag)) {
            if let index = dayArray.firstIndex(of: String(sender.tag)) {
                dayArray.remove(at: index)
            }
        } else {
            dayArray.append(String(sender.tag))
        }
        dayArray.sort()
        self.alarmList[row].days = dayArray.joined(separator:",")
        
        if let cell = self.alarmTableview.cellForRow(at: IndexPath (row: row, section: 0)) as? AlarmDetailTableViewCell {
            cell.daysButtonCollection.forEach { button in
                if dayArray.contains(String(button.tag)) {
                    button.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.3764705882, blue: 0.6980392157, alpha: 1)
                    button.setTitleColor(.white, for: .normal)
                } else {
                    button.backgroundColor = #colorLiteral(red: 0.9181428552, green: 0.9181428552, blue: 0.9181428552, alpha: 1)
                    button.setTitleColor(.black, for: .normal)
                }
            }
        }
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[row])
    }
    
    @objc func sliderValueChanged(sender: UISlider) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        self.alarmList[row].volume = sender.value
        print("Slider value >>> \(sender.value)")
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[row])
        self.alarmTableview.reloadRows(at: [IndexPath (row: row, section: 0)], with: .none)
    }
    
    @objc func clickOnRepeatButton(sender: UIButton) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        self.alarmList[row].isRepeat = self.alarmList[row].isRepeat == 1 ? 0 : 1
        self.view.makeToast(self.alarmList[row].isRepeat == 1 ? string.repeat_alarm : string.not_repeat_alarm)
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[row])
        self.alarmTableview.reloadRows(at: [IndexPath (row: row, section: 0)], with: .none)
    }
    
    @objc func clickOnVibrateButton(sender: UIButton) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        self.alarmList[row].isVibrate = self.alarmList[row].isVibrate == 1 ? 0 : 1
        self.view.makeToast(self.alarmList[row].isVibrate == 1 ? string.vibrate_on : string.vibrate_off)
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[row])
        self.alarmTableview.reloadRows(at: [IndexPath (row: row, section: 0)], with: .none)
    }
    
    @objc func clickOnNfcButton(sender: UIButton) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        if self.alarmList[row].isNfcActive == 0 {
            self.setUpNFCSession(currentIndex: sender.accessibilityHint ?? "")
        } else {
            self.alarmList[row].isNfcActive = 0
            self.view.makeToast("NFC disabled")
            CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[row])
            self.alarmTableview.reloadRows(at:  [IndexPath (row: row, section: 0)], with: .none)
        }
    }
    
    @objc func clickOnMusicOrRingtoneButton(sender: UIButton) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        let musicViewController = storyBoard.instantiateViewController(withIdentifier: "MusicViewController") as! MusicViewController
        musicViewController.delegate = self
        musicViewController.selectedRow = row
        musicViewController.mediaName = self.alarmList[row].mediaName
        musicViewController.mediaId = self.alarmList[row].mediaId
        self.navigationController?.pushViewController(musicViewController, animated: true)
    }
    
    @objc func clickOnOptionsButton(sender: UIButton) {
//        let audioOptionViewController = storyBoard.instantiateViewController(withIdentifier: "OptionViewController") as! OptionViewController
//        audioOptionViewController.modalPresentationStyle = .overCurrentContext
//        self.present(audioOptionViewController, animated: true)
    }
    
    @objc func clickOnNameButton(sender: UIButton) {
        let nameViewController = storyBoard.instantiateViewController(withIdentifier: "NameViewController") as! NameViewController
        nameViewController.selectedRow = Int(sender.accessibilityHint ?? "") ?? 0
        nameViewController.name = self.alarmList[Int(sender.accessibilityHint ?? "") ?? 0].name
        nameViewController.delegate = self
        nameViewController.modalPresentationStyle = .overCurrentContext
        self.present(nameViewController, animated: true)
    }
    
    @objc func deleteAlarm(sender: UIButton) {
        let row = Int (sender.accessibilityHint ?? "") ?? 0
        self.alarmList[row].isDelete = 1
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[row])
        Scheduler.shared.cancelScheduledNotification(alarmDetail: self.alarmList[row])
        self.alarmList.remove(at: row)
        self.deleteRowsFromExpandableRows(deleteRow: row)
        self.alarmTableview.reloadData()
        self.manageAddAlarmView()
    }
    
    func addNewAlarm() {
        let timeArray = (Date().addingTimeInterval(120).time ?? "").components(separatedBy: " ")
        let timeSelector = TimeSelector()
        timeSelector.timeSelected = {
            (timeSelector) in
            self.view.layer.sublayers?.filter({$0.accessibilityHint == "PulseAnimation"}).first?.removeFromSuperlayer()
            alarmCount += 1
            let alarmDetail: AlarmDetail = AlarmDetail()
            alarmDetail.id = alarmCount
            alarmDetail.date = timeSelector.date.alarmDateString ?? ""
            alarmDetail.time = timeSelector.date.time ?? ""
            alarmDetail.mediaName = ""
            alarmDetail.audioOption = "song"
            
          self.checkSameTimeAlarmAlreadyExits(newAlarmTime: timeSelector.date.time ?? "") { result in

                Scheduler.shared.scheduleNewNotification(alarmDetail: alarmDetail)
                self.alarmList.append(alarmDetail)
                CoreDataManager.shared.alarmExists(alarm: alarmDetail)
                self.expandableRows.insert(self.alarmList.count - 1)
                self.alarmTableview.reloadData()
                self.alarmTableview.scrollToRow(at: IndexPath (row: self.alarmList.count - 1, section: 0), at: .bottom, animated: true)
                self.manageAddAlarmView()
                SVProgressHUD.dismiss(withDelay: 1)
            }
        }
        timeSelector.overlayAlpha = 0.7
        let array = timeArray.first?.components(separatedBy: ":")
        if array?.count == 2 {
            timeSelector.minutes = Int (array?.last ?? "") ?? 0
            timeSelector.hours = Int (array?.first ?? "") ?? 0
            if (timeArray.last ?? "") == "AM" {
                timeSelector.isAm = true
            } else {
                timeSelector.isAm = false
            }
            timeSelector.presentOnView(view: self.view)
        }
    }
    
    func checkSameTimeAlarmAlreadyExits(newAlarmTime: String, completionBlock: @escaping (_ result: Bool) -> ()) {
        let filteredArray = self.alarmList.filter({$0.time == newAlarmTime})
        guard filteredArray.count != 0 else {
            completionBlock (false)
            return
        }
        guard let filterdAlarmDetail = filteredArray.first else {
            return
        }
        if let index = self.alarmList.firstIndex(of: filterdAlarmDetail) {
            //If alarm exists then set delete flag in core data and cancel the scheduled notifications.
            self.alarmList[index].isDelete = 1
            CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[index])
            Scheduler.shared.cancelScheduledNotification(alarmDetail: self.alarmList[index])
            self.alarmList.remove(at: index)
            self.deleteRowsFromExpandableRows(deleteRow: index)
            self.alarmTableview.reloadData()
            completionBlock (true)
        }
    }
    
    func deleteRowsFromExpandableRows(deleteRow: Int) {
        for row in self.expandableRows.sorted() {
            if row > deleteRow {
                self.expandableRows.remove(row)
                self.expandableRows.insert(row - 1)
            }
        }
    }
}
//MARK: - TableView Methods

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alarmList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.expandableRows.contains(indexPath.row) {
            return 420//428
        } else {
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AlarmDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AlarmDetailTableViewCell", for: indexPath) as! AlarmDetailTableViewCell
        let alarmDetail = self.alarmList[indexPath.row]

        if self.expandableRows.contains(indexPath.row) {
            cell.topViewHeightConstraint.constant = 62
            cell.bottomViewHeightConstraint.constant = 358
            cell.bottomView.isHidden = false
            
            cell.bottomTimeLabelConstraint.constant = 0
            cell.downButton.isHidden = true
            cell.widthDownButtonConstraint.constant = 0
            cell.upButton.isHidden = false
            cell.headerSeperatorView.isHidden = true
            cell.daysLabel.text = ""
            cell.nameLabel.text = ""
            cell.remainTimeLabel.text = ""
            cell.contentView.backgroundColor = #colorLiteral(red: 0.9607843137, green: 0.9607843137, blue: 0.9607843137, alpha: 1)
            
        } else {
            cell.topViewHeightConstraint.constant = 110
            cell.bottomViewHeightConstraint.constant = 0
            cell.bottomView.isHidden = true
            cell.bottomTimeLabelConstraint.constant = 10
            cell.downButton.isHidden = false
            cell.widthDownButtonConstraint.constant = 25
            cell.upButton.isHidden = true
            cell.headerSeperatorView.isHidden = false
            
            cell.nameLabel.text = alarmDetail.name
            cell.nameLabel.textColor = nameColor
            cell.daysLabel.text = alarmDetail.days.shortDayString
            cell.daysLabel.textColor = daysColor
            
            cell.remainTimeLabel.text = Scheduler.shared.alarmLeftTime(alarmDetail: alarmDetail)
            
            cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        cell.timeLabel.textColor = timeColor
        
        let timeArray = (alarmDetail.time).components(separatedBy: " ")
        if  timeArray.count == 2 {
            cell.timeLabel.text = timeArray.first ?? ""
            cell.timeFormatLabel.text = timeArray.last ?? ""
            
            if cell.timeFormatLabel.text == "AM" {
                cell.timeFormatLabel.textColor = amColor
            } else if cell.timeFormatLabel.text == "PM" {
                cell.timeFormatLabel.textColor = pmColor
            }
        }
        let tapGeature = UITapGestureRecognizer (target: self, action: #selector(self.tapOnAlarmTimeLabel(sender:)))
        tapGeature.accessibilityHint = String (indexPath.row)
        cell.timeLabel.addGestureRecognizer(tapGeature)
        
        cell.statusSwitch.isOn = alarmDetail.status == 1 ? true : false
        if cell.statusSwitch.isOn == true {
            cell.statusSwitch.thumbTintColor = .white
            cell.statusSwitch.onTintColor = themeColor
            cell.timeLabel.textColor = cell.timeLabel.textColor
            cell.timeFormatLabel.textColor = cell.timeFormatLabel.textColor
            cell.nameLabel.textColor = cell.nameLabel.textColor
            cell.daysLabel.textColor = cell.daysLabel.textColor
            cell.remainTimeLabel.isHidden = false
        } else {
            cell.statusSwitch.thumbTintColor = .white
            cell.statusSwitch.tintColor = themeColor
            cell.statusSwitch.layer.cornerRadius = cell.statusSwitch.frame.height / 2.0
            cell.statusSwitch.backgroundColor = themeColor
            cell.statusSwitch.clipsToBounds = true
            
            cell.timeLabel.textColor = cell.timeLabel.textColor.withAlphaComponent(0.3)
            cell.timeFormatLabel.textColor = cell.timeFormatLabel.textColor.withAlphaComponent(0.3)
            cell.nameLabel.textColor = cell.nameLabel.textColor.withAlphaComponent(0.3)
            cell.daysLabel.textColor = cell.daysLabel.textColor.withAlphaComponent(0.3)
            cell.remainTimeLabel.isHidden = true
        }
        cell.statusSwitch.accessibilityHint = String(indexPath.row)
        cell.statusSwitch.addTarget(self, action: #selector(self.alarmStatusValueChanged(sender:)), for: .valueChanged)
        
        cell.downButton.accessibilityHint = String(indexPath.row)
        cell.downButton.addTarget(self, action: #selector(self.expandCollapseRows(sender:)), for: .touchUpInside)
        
        cell.daysButtonStackView.addBackground(color: .white)
        cell.daysButtonStackView.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        cell.daysButtonStackView.isLayoutMarginsRelativeArrangement = true
        
        let dayArray = alarmDetail.days.components(separatedBy: ",")
        cell.daysButtonCollection.forEach { button in
            button.accessibilityHint = String(indexPath.row)
            button.addTarget(self, action: #selector(self.clickOnDays(sender:)), for: .touchUpInside)
            if dayArray.contains(String(button.tag)) {
                button.backgroundColor = #colorLiteral(red: 0.3764705882, green: 0.3764705882, blue: 0.6980392157, alpha: 1)
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = #colorLiteral(red: 0.9181428552, green: 0.9181428552, blue: 0.9181428552, alpha: 1)
                button.setTitleColor(.black, for: .normal)
            }
        }
        
        if (alarmDetail.isRepeat) == 1 {
            cell.repeatButton.tintColor = themeColor
        } else {
            cell.repeatButton.tintColor = .black
        }
        cell.repeatButton.accessibilityHint = String (indexPath.row)
        cell.repeatButton.addTarget(self, action: #selector(self.clickOnRepeatButton(sender:)), for: .touchUpInside)
        
        if (alarmDetail.isVibrate) == 1 {
            cell.vibrateButton.tintColor = themeColor
        } else {
            cell.vibrateButton.tintColor = .black
        }
        cell.vibrateButton.accessibilityHint = String (indexPath.row)
        cell.vibrateButton.addTarget(self, action: #selector(self.clickOnVibrateButton(sender:)), for: .touchUpInside)
 
        if (alarmDetail.isNfcActive) == 1 {
            cell.nfcButton.tintColor = themeColor
        } else {
            cell.nfcButton.tintColor = .black
        }
        cell.nfcButton.accessibilityHint = String (indexPath.row)
        cell.nfcButton.addTarget(self, action: #selector(self.clickOnNfcButton(sender:)), for: .touchUpInside)
        
        if alarmDetail.mediaName == "" {
            cell.musicImageView.tintColor = #colorLiteral(red: 0.6745098039, green: 0.6745098039, blue: 0.6745098039, alpha: 1)
            cell.musicButton.setTitleColor( #colorLiteral(red: 0.6745098039, green: 0.6745098039, blue: 0.6745098039, alpha: 1), for: .normal)
            cell.musicButton.setTitle("Music or Ringtone", for: .normal)
        } else {
            cell.musicImageView.tintColor = .black
            cell.musicButton.setTitleColor(.black, for: .normal)
            cell.musicButton.setTitle(alarmDetail.mediaName, for: .normal)
        }
        
        cell.musicButton.accessibilityHint = String (indexPath.row)
        cell.musicButton.addTarget(self, action: #selector(self.clickOnMusicOrRingtoneButton(sender:)), for: .touchUpInside)
        
        cell.volumeSliderView.thumbTintColor = themeColor
        cell.volumeSliderView.minimumTrackTintColor = themeColor
        cell.volumeSliderView.value = alarmDetail.volume
        cell.volumeSliderView.accessibilityHint = String (indexPath.row)
        cell.volumeSliderView.addTarget(self, action: #selector(self.sliderValueChanged(sender:)), for: .valueChanged)
        
        cell.optionButton.accessibilityHint = String (indexPath.row)
        cell.optionButton.addTarget(self, action: #selector(self.clickOnOptionsButton(sender:)), for: .touchDragInside)
        
        cell.nameButton.layer.cornerRadius = 25.0
        if alarmDetail.name == "" {
            cell.nameButton.setTitleColor(UIColor.init(red: 193.0/255.0, green: 193.0/255.0, blue: 193.0/255.0, alpha: 1.0), for: .normal)
            cell.nameButton.setTitle("Alarm Name", for: .normal)
        } else {
            cell.nameButton.setTitleColor(.black, for: .normal)
            cell.nameButton.setTitle(alarmDetail.name, for: .normal)
        }
        cell.nameButton.accessibilityHint = String (indexPath.row)
        cell.nameButton.addTarget(self, action: #selector(self.clickOnNameButton(sender:)), for: .touchUpInside)
                
        cell.deleteButton.accessibilityHint = String(indexPath.row)
        cell.deleteButton.addTarget(self, action: #selector(self.deleteAlarm(sender:)), for: .touchUpInside)
        
        cell.upButton.accessibilityHint = String(indexPath.row)
        cell.upButton.addTarget(self, action: #selector(self.expandCollapseRows(sender:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? AlarmDetailTableViewCell {
            self.expandCollapseRows(sender: cell.upButton)
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let copyAction = UIContextualAction (style: .normal, title: "COPY") { _, _, complete in
            let timeArray = (Date().time ?? "").components(separatedBy: " ")
            let timeSelector = TimeSelector()
            timeSelector.timeSelected = {
                (timeSelector) in
                self.view.layer.sublayers?.filter({$0.accessibilityHint == "PulseAnimation"}).first?.removeFromSuperlayer()
                alarmCount += 1
                
                let currentAlarmDetail = self.alarmList[indexPath.row]
                
                let copyAlarmDetail: AlarmDetail = AlarmDetail()
                copyAlarmDetail.id = alarmCount
                copyAlarmDetail.name = currentAlarmDetail.name
                copyAlarmDetail.status = currentAlarmDetail.status
                copyAlarmDetail.isRepeat = currentAlarmDetail.isRepeat
                copyAlarmDetail.isVibrate = currentAlarmDetail.isVibrate
                copyAlarmDetail.isNfcActive = currentAlarmDetail.isNfcActive
                copyAlarmDetail.nfcText = currentAlarmDetail.nfcText
                copyAlarmDetail.mediaName = currentAlarmDetail.mediaName
                copyAlarmDetail.mediaId = currentAlarmDetail.mediaId
                copyAlarmDetail.isDelete = 0
                copyAlarmDetail.volume = currentAlarmDetail.volume
                copyAlarmDetail.days = currentAlarmDetail.days
                copyAlarmDetail.audioOption = currentAlarmDetail.audioOption
                
                self.checkSameTimeAlarmAlreadyExits(newAlarmTime: timeSelector.date.time ?? "") { result in
                    Scheduler.shared.scheduleNewNotification(alarmDetail: copyAlarmDetail)
                    copyAlarmDetail.date = timeSelector.date.alarmDateString ?? ""
                    copyAlarmDetail.time = timeSelector.date.time ?? ""
                    self.alarmList.append(copyAlarmDetail)
                    CoreDataManager.shared.alarmExists(alarm: copyAlarmDetail)
                    self.expandableRows.insert(self.alarmList.count - 1)
                    self.alarmTableview.reloadData()
                    self.alarmTableview.scrollToRow(at: IndexPath (row: self.alarmList.count - 1, section: 0), at: .bottom, animated: true)
                    self.manageAddAlarmView()
                    SVProgressHUD.dismiss(withDelay: 1)
                }
            }
            timeSelector.overlayAlpha = 0.7
            let array = timeArray.first?.components(separatedBy: ":")
            if array?.count == 2 {
                timeSelector.minutes = Int (array?.last ?? "") ?? 0
                timeSelector.hours = Int (array?.first ?? "") ?? 0
                if (timeArray.last ?? "") == "AM" {
                    timeSelector.isAm = true
                } else {
                    timeSelector.isAm = false
                }
                timeSelector.presentOnView(view: self.view)
            }
            complete (true)
        }
        copyAction.backgroundColor = #colorLiteral(red: 0, green: 0.50326401, blue: 0, alpha: 1)
        copyAction.image = UIImage (named: "copy")
        let configuration = UISwipeActionsConfiguration (actions: [copyAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "DELETE") { _, _, complete in
            self.alarmList[indexPath.row].isDelete = 1
            CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[indexPath.row])
            Scheduler.shared.cancelScheduledNotification(alarmDetail: self.alarmList[indexPath.row])
            self.alarmList.remove(at: indexPath.row)
            self.deleteRowsFromExpandableRows(deleteRow: indexPath.row)
            self.alarmTableview.reloadData()
            self.manageAddAlarmView()
            complete(true)
        }
        deleteAction.backgroundColor = .red
        deleteAction.image = UIImage (named: "delete")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.expandableRows.contains(indexPath.row) {
            return false
        } else {
            return true
        }
    }
}

//MARK: - Custom Delegate

extension HomeViewController: UpdateName, UpdateMusic {
    func setAlarmName(name: String, selectedRow: Int) {
        self.alarmList[selectedRow].name = name
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[selectedRow])
        self.alarmTableview.reloadRows(at: [IndexPath (row: selectedRow, section: 0)], with: .none)
    }
    
    func updateSelectedMusic(musicName: String, musicId: String, selectedRow: Int) {
        self.alarmList[selectedRow].mediaName = musicName
        self.alarmList[selectedRow].mediaId = musicId
        CoreDataManager.shared.updateAlarm(updatedAlarmDetail: self.alarmList[selectedRow])
        self.alarmTableview.reloadRows(at: [IndexPath (row: selectedRow, section: 0)], with: .none)
    }
}

//MARK: - NFC Delegate Methods

extension HomeViewController: NFCNDEFReaderSessionDelegate {
    func setUpNFCSession(currentIndex: String) {
        if !NFCNDEFReaderSession.readingAvailable {
            self.view.makeToast(string.device_not_support_nfc)
            return
        }
        
        self.session = NFCNDEFReaderSession (delegate: self, queue: nil, invalidateAfterFirstRead: true)
        self.session?.alertMessage = string.scan_nfc
        self.session?.accessibilityHint = currentIndex
        self.session?.begin()
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        print("NFC session active")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard messages.count != 0,
        let nfcndefMessage = messages.first,
        nfcndefMessage.records.count != 0,
        let nfcndefPayload = nfcndefMessage.records.first else {
            self.view.makeToast(string.nfc_not_messages)
            return
        }
        
        let result = nfcndefPayload.wellKnownTypeTextPayload().0 ?? ""
        print("Message >>> \(result)")

        // Step 8: didDetectNDEFs callback is run in background thread. All UI updates must be handled carefully.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
//            self?.session?.invalidate()
            guard result == NFCTEXT else {
                self?.view.makeToast(string.scan_valid_nfc)
                return
            }
            let row = Int (self?.session?.accessibilityHint ?? "") ?? 0
            self?.alarmList[row].isNfcActive = 1
            CoreDataManager.shared.updateAlarm(updatedAlarmDetail: (self?.alarmList[row])!)
            self?.alarmTableview.reloadRows(at:  [IndexPath (row: row, section: 0)], with: .none)
            self?.view.makeToast("NFC enabled")
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC error >>> \(error.localizedDescription)")
        DispatchQueue.main.async {
            if error.localizedDescription != string.first_ndef_tag_read {
                self.view.makeToast(error.localizedDescription)
            }
        }
    }
}
