//
//  AppearanceViewController.swift
//  AlarmApp
//
//  Created by Leo on 01/06/22.
//

import UIKit

class AppearanceViewController: UIViewController {

    @IBOutlet var appearanceTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    //MARK: - Button Actions
    
    @IBAction func clickOnBackButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Tableview Methods

extension AppearanceViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StaticArray.appearanceOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: AppearanceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "AppearanceTableViewCell", for: indexPath) as! AppearanceTableViewCell
        let appearanceDetail = StaticArray.appearanceOptions[indexPath.row]
        cell.titleLabel.text = appearanceDetail.title
        cell.subTitleLabel.text = appearanceDetail.subTitle
        
        cell.colorButton.layer.cornerRadius = cell.colorButton.frame.width / 2
        cell.colorButton.backgroundColor = appearanceDetail.color
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let colorPickerViewController = storyboard?.instantiateViewController(withIdentifier: "ColorPickerViewController") as! ColorPickerViewController
        colorPickerViewController.delegate = self
        let appearanceDetail = StaticArray.appearanceOptions[indexPath.row]
        colorPickerViewController.currentColor = appearanceDetail.color
        colorPickerViewController.tag = appearanceDetail.tag
        colorPickerViewController.modalPresentationStyle = .overCurrentContext
        self.present(colorPickerViewController, animated: true)
    }
}

//MARK: - Custom Delegate

extension AppearanceViewController: UpdateColor {
    func updateSelectedColor(tag: String, selectedColor: UIColor) {
        switch tag {
        case "THEME":
            themeColor = selectedColor
            break
        case "NAME":
            nameColor = selectedColor
            break
        case "DAYS":
            daysColor = selectedColor
            break
        case "TIME":
            timeColor = selectedColor
            break
        case "AM":
            amColor = selectedColor
            break
        case "PM":
            pmColor = selectedColor
            break
        default:
            break
        }
        
        if let index = StaticArray.appearanceOptions.firstIndex(where: {$0.tag == tag}) {
            StaticArray.appearanceOptions[index].color = selectedColor
        }
        self.appearanceTableView.reloadData()
    }
}
