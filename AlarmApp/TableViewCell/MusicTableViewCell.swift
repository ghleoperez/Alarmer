//
//  MusicTableViewCell.swift
//  AlarmApp
//
//  Created by Leo on 16/06/22.
//

import UIKit

class MusicTableViewCell: UITableViewCell {

    @IBOutlet var containerStackView: UIStackView!
    @IBOutlet var selectedMusicStackView: UIStackView!
    @IBOutlet var selectedMusicNameLabel: UILabel!
    @IBOutlet var checkmarkImageView: UIImageView!
    @IBOutlet var musicStackView: UIStackView!
    @IBOutlet var musicTitleLabel: UILabel!
    @IBOutlet var arrowImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
