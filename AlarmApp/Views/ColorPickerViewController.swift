//
//  ColorPickerViewController.swift
//  AlarmApp
//
//  Created by Leo on 02/06/22.
//

import UIKit
import Colorful
import Toast_Swift

class ColorPickerViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    @IBOutlet var colorPicker: ColorPicker!
    @IBOutlet var selectedColorView: UIView!
    @IBOutlet var colorTextField: UITextField!
    @IBOutlet var defaultButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var okButton: UIButton!
    
    var currentColor: UIColor = .red
    var selectedColor: UIColor = .red
    var tag: String = ""
    var delegate: UpdateColor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.containerView.layer.cornerRadius = 20.0
        self.selectedColor = self.currentColor
        colorPicker.set(color: self.currentColor, colorSpace: .sRGB)
        colorPicker.addTarget(self, action: #selector(self.handleColorChanged(picker:)), for: .valueChanged)
        self.handleColorChanged(picker: colorPicker)
        self.selectedColorView.layer.cornerRadius = self.selectedColorView.frame.width / 2
        self.addBottomLineWithTextField()
        self.defaultButton.setTitleColor(themeColor, for: .normal)
        self.cancelButton.setTitleColor(themeColor, for: .normal)
        self.okButton.setTitleColor(themeColor, for: .normal)
    }
    
    func addBottomLineWithTextField() {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect (x: 0, y: self.colorTextField.frame.height + 1, width: self.colorTextField.frame.width, height: 2)
        bottomLine.backgroundColor = themeColor.cgColor
        self.colorTextField.borderStyle = .none
        self.colorTextField.layer.addSublayer(bottomLine)
    }

    //MARK: - Button Action
    
    @objc func handleColorChanged(picker: ColorPicker) {
        self.selectedColor = picker.color
        self.selectedColorView.backgroundColor = picker.color
        self.colorTextField.text = picker.color.hexStringFromColor
    }
    
    @IBAction func clickOnOkButton(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.delegate?.updateSelectedColor(tag: self.tag, selectedColor: self.selectedColor)
        }
    }
    
    @IBAction func clickOnCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func clickOnDefaultButton(_ sender: UIButton) {
        self.selectedColor = self.currentColor
        self.colorPicker.set(color: self.currentColor, colorSpace: .sRGB)
        self.selectedColorView.backgroundColor = self.currentColor
        self.colorTextField.text = self.currentColor.hexStringFromColor
    }
}

//MARK: - UITextField Delegate
extension ColorPickerViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard (textField.text ?? "").isValidHexString == true else {
            self.view.makeToast("Please enter valid hex string")
            return
        }
        self.currentColor = (textField.text ?? "").colorWithHexString
        self.colorPicker.set(color: self.currentColor, colorSpace: .sRGB)
        self.selectedColorView.backgroundColor = self.currentColor
        self.selectedColor = self.currentColor
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}
