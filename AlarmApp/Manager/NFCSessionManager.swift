//
//  NFCSessionManager.swift
//  AlarmApp
//
//  Created by Leo on 14/06/22.
//

import Foundation
import CoreNFC
import UIKit
import AudioToolbox

class NFCSessionManager: NSObject, NFCNDEFReaderSessionDelegate {
    static let shared: NFCSessionManager = NFCSessionManager()
    var session: NFCNDEFReaderSession?
    var alarmIndetifier: String = ""
    var nfcText: String = ""
    
    func setUpNFCSession() {
        if !NFCNDEFReaderSession.readingAvailable {
            return
        }
        self.session = NFCNDEFReaderSession (delegate: self, queue: nil, invalidateAfterFirstRead: true)
        self.session?.alertMessage = "Please scan a NFC tag."
        self.session?.accessibilityHint = self.alarmIndetifier
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
            topViewController()?.view.makeToast(string.nfc_not_messages)
            return
        }
        
        let result = nfcndefPayload.wellKnownTypeTextPayload().0 ?? ""

        // Step 8: didDetectNDEFs callback is run in background thread. All UI updates must be handled carefully.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard result == NFCTEXT else {
                topViewController()?.view.makeToast(string.scan_valid_nfc)
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if topViewController()?.isKind(of: DismissAlarmViewController.self) == true {
                    if let dismissView = topViewController() as? DismissAlarmViewController {
                        Scheduler.shared.center.removeAllDeliveredNotifications()
                        dismissView.updateAlarmOnDismiss()
                    }
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("NFC error >>> \(error.localizedDescription)")
        DispatchQueue.main.async {
            if error.localizedDescription != string.first_ndef_tag_read {
                topViewController()?.view.makeToast(error.localizedDescription)
            }
        }
    }
}
