//
//  AlarmDetailTableViewCell.swift
//  AlarmApp
//
//  Created by Leo on 16/05/22.
//

import UIKit

class AlarmDetailTableViewCell: UITableViewCell {

    @IBOutlet var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var topView: UIView!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var bottomTimeLabelConstraint: NSLayoutConstraint!
    @IBOutlet var timeFormatLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusSwitch: UISwitch!
    @IBOutlet var daysLabel: UILabel!
    @IBOutlet var remainTimeLabel: UILabel!
    @IBOutlet var downButton: UIButton!
    @IBOutlet var widthDownButtonConstraint: NSLayoutConstraint!
    @IBOutlet var headerSeperatorView: UIView!
    
    @IBOutlet var bottomViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bottomView: UIView!
    @IBOutlet var daysButtonStackView: UIStackView!
    @IBOutlet var daysButtonCollection: [UIButton]!
    @IBOutlet var repeatButton: UIButton!
    @IBOutlet var vibrateButton: UIButton!
    @IBOutlet var nfcButton: UIButton!
    @IBOutlet var musicImageView: UIImageView!
    @IBOutlet var musicButton: UIButton!    
    @IBOutlet var volumeImageView: UIImageView!
    @IBOutlet var volumeSliderView: UISlider!
    @IBOutlet var optionButton: UIButton!
    @IBOutlet var nameButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var upButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = #colorLiteral(red: 0.1483550668, green: 0.1483550668, blue: 0.1483550668, alpha: 1)
        self.daysButtonCollection.forEach { button in
            button.layer.cornerRadius = button.frame.height / 2
            button.layer.masksToBounds = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
