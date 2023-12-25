//
//  MusicViewController.swift
//  AlarmApp
//
//  Created by Leo on 16/06/22.
//

import UIKit
import MediaPlayer

class MusicViewController: UIViewController {
    
    @IBOutlet var musicTableView: UITableView!
    
    var mediaName: String = ""
    var mediaId: String = ""
    var selectedRow: Int = 0
    var songName: String = ""
    var songId: String = ""
    var delegate: UpdateMusic?
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.mediaId != "" {
            self.songName = self.mediaName
            self.songId = self.mediaId
        }
    }
    
    //MARK: - Button Action
    
    @IBAction func clickOnBackButton(_ sender: UIButton) {
        if self.audioPlayer?.isPlaying == true {
            self.audioPlayer?.stop()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func clickOnDoneButton(_ sender: UIButton) {
        if self.audioPlayer?.isPlaying == true {
            self.audioPlayer?.stop()
        }
        if self.mediaId != "" {
            self.mediaName = self.songName
        }
        self.delegate?.updateSelectedMusic(musicName: self.mediaName, musicId: self.mediaId, selectedRow: self.selectedRow)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func tapOnSongLabel(_ sender: UITapGestureRecognizer) {
        if self.audioPlayer?.isPlaying == true {
            self.audioPlayer?.stop()
        }
        self.mediaName = self.songName
        self.mediaId = self.songId
        self.playSound(soundName: self.mediaId, isVibrate: 0, volume: 1.0, noOfLoops: -1)
        self.musicTableView.reloadData()
    }
    
    @objc func tapOnSelectSongLabel(_ sender: UITapGestureRecognizer) {
        if self.audioPlayer?.isPlaying == true {
            self.audioPlayer?.stop()
        }
        self.libraryMusicView()
    }
    
    func playSound(soundName: String, isVibrate: Int, volume: Float, noOfLoops: Int) {
        var soundURL: URL?
        if soundName.contains("ipod-library:") {
            soundURL = URL (string: soundName)
        } else {
            guard let url = Bundle.main.path(forResource: soundName, ofType: "mp3") else {
                return
            }
            soundURL = URL(fileURLWithPath: url)
        }
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioPlayer!.prepareToPlay()
        }
        audioPlayer!.numberOfLoops = noOfLoops
        audioPlayer?.volume = volume
        audioPlayer!.play()
    }
}

//MARK: - TableView Methods

extension MusicViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell: MusicHeaderTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MusicHeaderTableViewCell") as! MusicHeaderTableViewCell
        if section == 0 {
            cell.headerTitleLabel.text = "Songs"
        } else if section == 1 {
            cell.headerTitleLabel.text = "Ringtons"
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return StaticArray.ringtonArray.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MusicTableViewCell = tableView.dequeueReusableCell(withIdentifier: "MusicTableViewCell", for: indexPath) as! MusicTableViewCell
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.songId != "" {
                    cell.containerStackView.insertArrangedSubview(cell.selectedMusicStackView, at: 0)
                    cell.selectedMusicNameLabel.text = self.songName
                    cell.selectedMusicNameLabel.textColor = themeColor
                    
                    let tapGesture = UITapGestureRecognizer (target: self, action: #selector(self.tapOnSongLabel(_:)))
                    cell.selectedMusicStackView.isUserInteractionEnabled = true
                    cell.selectedMusicStackView.addGestureRecognizer(tapGesture)
                    
                    if self.mediaName == self.songName {
                        cell.checkmarkImageView.isHidden = false
                        cell.checkmarkImageView.tintColor = themeColor
                    } else {
                        cell.checkmarkImageView.isHidden = true
                    }
                } else {
                    cell.selectedMusicStackView.removeFromSuperview()
                    cell.selectedMusicNameLabel.text = ""
                    cell.checkmarkImageView.isHidden = true
                }
                
                cell.musicTitleLabel.text = "Select a song"
                cell.arrowImageView.image = #imageLiteral(resourceName: "right_arrow")
                cell.arrowImageView.tintColor = .black
                cell.arrowImageView.isHidden = false
                let selectSongTapGesture = UITapGestureRecognizer (target: self, action: #selector(self.tapOnSelectSongLabel(_:)))
                cell.musicStackView.isUserInteractionEnabled = true
                cell.musicStackView.addGestureRecognizer(selectSongTapGesture)
            }
        } else if indexPath.section == 1 {
            cell.selectedMusicStackView.removeFromSuperview()
            cell.selectedMusicNameLabel.text = ""
            cell.checkmarkImageView.isHidden = true
            
            cell.musicTitleLabel.text = StaticArray.ringtonArray[indexPath.row]
            
            cell.selectedMusicStackView.isUserInteractionEnabled = false
            cell.musicStackView.isUserInteractionEnabled = false
            
            if StaticArray.ringtonArray[indexPath.row] == self.mediaName {
                cell.arrowImageView.image = #imageLiteral(resourceName: "checkmark")
                cell.arrowImageView.tintColor = themeColor
                cell.arrowImageView.isHidden = false
            } else {
                cell.arrowImageView.isHidden = true
            }
        }
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.audioPlayer?.isPlaying == true {
            self.audioPlayer?.stop()
        }
        if indexPath.section == 1 {
            self.playSound(soundName: StaticArray.ringtonArray[indexPath.row], isVibrate: 0, volume: 1.0, noOfLoops: -1)
            self.mediaName = StaticArray.ringtonArray[indexPath.row]
            self.mediaId = ""
            tableView.reloadData()
        }
    }
}

//MARK: - MpMediaPickerController Delegate Methods

extension MusicViewController: MPMediaPickerControllerDelegate {
    
    func libraryMusicView() {
        let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
        mediaPicker.delegate = self
        mediaPicker.prompt = "Select any song!"
        mediaPicker.allowsPickingMultipleItems = false
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        if !mediaItemCollection.items.isEmpty {
            let aMediaItem = mediaItemCollection.items[0]
            let mediaItem = aMediaItem
            self.mediaName = mediaItem.value(forProperty: MPMediaItemPropertyTitle) as? String ?? ""
            self.songName = self.mediaName
            guard let url = mediaItem.value(forProperty: MPMediaItemPropertyAssetURL) as? URL else {
                return
            }
            self.mediaId = url.absoluteString
            self.songId = self.mediaId
            self.dismiss(animated: true) {
                self.musicTableView.reloadData()
            }
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
