//
//  NameViewController.swift
//  AlarmApp
//
//  Created by Leo on 24/05/22.
//

import UIKit

class NameViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var okButton: UIButton!
    var delegate: UpdateName?
    var selectedRow: Int = 0
    var name: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    func setUpUI() {
        self.containerView.layer.cornerRadius = 20.0
        self.nameLabel.textColor = themeColor
        self.nameTextField.layer.cornerRadius = 20.0
        self.nameTextField.becomeFirstResponder()
        self.nameTextField.text = self.name
        self.cancelButton.setTitleColor(themeColor, for: .normal)
        self.okButton.setTitleColor(themeColor, for: .normal)
    }
    
    //MARK: - Button Action
    
    @IBAction func clickOnOkButton(sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.setAlarmName(name: self.nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "", selectedRow: self.selectedRow)
        }
    }
    
    @IBAction func clickOnCancelButton(sender: UIButton) {
        self.dismiss(animated: true)
    }
}

//MARK: - UITextField Delegate Methods

extension NameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
