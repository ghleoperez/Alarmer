//
//  AudioPlayerManager.swift
//  AlarmApp
//
//  Created by Leo on 20/06/22.
//

import UIKit
import AVFoundation
import AudioToolbox

class AudioPlayerManager: NSObject {
    static let shared: AudioPlayerManager = AudioPlayerManager()
    var audioPlayer: AVAudioPlayer?
    var activeTimer: Timer?
    var work: DispatchWorkItem?
    
    func setAudioSessionPlayback() {
        var error: NSError?
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error1 as NSError {
            error = error1
            print("could not set session. err:\(error!.localizedDescription)")
        }
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
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
        }
        audioPlayer!.numberOfLoops = noOfLoops
        audioPlayer?.volume = volume
        audioPlayer!.play()
    }
    
    func stopAudioPlayer() {
        self.audioPlayer?.stop()
    }
    
    func audioPlayerUrl(alarmDetail: AlarmDetail) -> URL {
        var mediaName: String = ""
        if alarmDetail.mediaName == "" {
            mediaName = "alarm_1"
        } else {
            mediaName = alarmDetail.mediaName
            if alarmDetail.mediaId != "" {
                mediaName = alarmDetail.mediaId
            }
        }
        
        var soundURL: URL = URL(fileURLWithPath: "")
        if mediaName.contains("ipod-library:") {
            soundURL = URL (string: mediaName) ?? URL(fileURLWithPath: "")
        } else {
            if let url = Bundle.main.path(forResource: mediaName, ofType: "mp3") {
                soundURL = URL(fileURLWithPath: url)
            }
        }
        return soundURL
    }
}

//MARK: - AvAudioPlayer Delegate Methods

extension AudioPlayerManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Finish audio player playing....")
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Decode error.............")
    }
}
