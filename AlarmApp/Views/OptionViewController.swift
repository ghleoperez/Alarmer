//
//  OptionViewController.swift
//  AlarmApp
//
//  Created by Leo on 06/06/22.
//

import UIKit
import StoreKit
import MediaPlayer

class OptionViewController: UIViewController, MPMediaPickerControllerDelegate {

    @IBOutlet var audioSourceButton: UIButton!
    let controller = SKCloudServiceController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Button Action
    
    @IBAction func clickOnAudioOptions(sender: UIButton) {
        if sender.tag == 100 {
            self.selectAudioOption()
        }
    }
    
    func selectAudioOption() {
        self.checkMediaAccessAuthorization()
    }
    
    func checkMediaAccessAuthorization()  {
        SKCloudServiceController.requestAuthorization {(status: SKCloudServiceAuthorizationStatus) in
            switch status {
            case .denied, .restricted:
                print("Denined Restricted")
            case .authorized:
                print("Authorized")
                self.libraryMusicView()
            default: break
            }
        }
    }
    
    func displayMusicView() {
        controller.requestCapabilities {(capabilities: SKCloudServiceCapability, error: Error?) in
           guard error == nil else { return }
           if capabilities.contains(.musicCatalogPlayback) {
              // Allows playback of songs in the Apple Music catalog.
           }
        }
    }
    
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
            let mediaID = (mediaItem.value(forProperty: MPMediaItemPropertyPersistentID)) as! String
            print("MediaItem >>> \(mediaItem) &&& MediaId >>> \(mediaID)")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
