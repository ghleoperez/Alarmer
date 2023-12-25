//
//  SettingViewController.swift
//  AlarmApp
//
//  Created by Leo on 01/06/22.
//

import UIKit

class SettingViewController: UIViewController {

    @IBOutlet var settingTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Button Actions
    
    @IBAction func clickOnBackButton (_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - TableView Methods

extension SettingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StaticArray.settingOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: SettingTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SettingTableViewCell", for: indexPath) as! SettingTableViewCell
        let optionDetail = StaticArray.settingOptions[indexPath.row]
        cell.iconImageView.image = UIImage (named: optionDetail.image)
        cell.titleLabel.text = optionDetail.title
        cell.subTitleLabel.text = optionDetail.subTitle
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let optionDetail = StaticArray.settingOptions[indexPath.row]
        
        switch optionDetail.tag {
        case "APPEARANCE":
            let appearanceView: AppearanceViewController = storyboard?.instantiateViewController(identifier: "AppearanceViewController") as! AppearanceViewController
            self.navigationController?.pushViewController(appearanceView, animated: true)

            break
        default:
            break
        }
    }
}
