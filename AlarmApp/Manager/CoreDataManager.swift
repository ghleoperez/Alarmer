//
//  CoreDataManager.swift
//  AlarmApp
//
//  Created by Leo on 20/05/22.
//

import CoreData

class CoreDataManager: NSObject {
    static let shared: CoreDataManager = CoreDataManager()
    let managedContext = appDelegate.persistentContainer.viewContext
    var currentAlarmList = [AlarmDetail]()

    
    func alarmExists(alarm: AlarmDetail) {
        let featchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.alarm)
        
        let idPredicate = NSPredicate(format: "id == %d", alarmCount)
        featchRequest.predicate = idPredicate
        
        do {
            let result = try managedContext.fetch(featchRequest) as! [NSManagedObject]
            if result.count == 0 {
                self.addAlarm(alarm: alarm)
            } else {
                self.updateAlarm(updatedAlarmDetail: alarm)
            }
        } catch {
            
        }
    }
    
    func addAlarm(alarm: AlarmDetail) {
        guard let alarmEntity = NSEntityDescription.entity(forEntityName: Entity.alarm, in: managedContext) else {
            return
        }
        
        let alarmDetail = NSManagedObject (entity: alarmEntity, insertInto: managedContext)
        
        alarmDetail.setValue(alarmCount, forKey: AlarmEntityKey.id)
        alarmDetail.setValue(alarm.date, forKey: AlarmEntityKey.date)
        alarmDetail.setValue(alarm.time, forKey: AlarmEntityKey.time)
        alarmDetail.setValue(alarm.name, forKey: AlarmEntityKey.name)
        alarmDetail.setValue(alarm.status, forKey: AlarmEntityKey.status)
        alarmDetail.setValue(alarm.isRepeat, forKey: AlarmEntityKey.is_repeat)
        alarmDetail.setValue(alarm.isVibrate, forKey: AlarmEntityKey.is_vibrate)
        alarmDetail.setValue(alarm.isNfcActive, forKey: AlarmEntityKey.is_nfc_active)
        alarmDetail.setValue(alarm.nfcText, forKey: AlarmEntityKey.nfc_text)
        alarmDetail.setValue(alarm.mediaName, forKey: AlarmEntityKey.media_name)
        alarmDetail.setValue(alarm.mediaId, forKey: AlarmEntityKey.media_id)
        alarmDetail.setValue(alarm.isDelete, forKey: AlarmEntityKey.is_delete)
        alarmDetail.setValue(alarm.volume, forKey: AlarmEntityKey.volume)
        alarmDetail.setValue(alarm.days, forKey: AlarmEntityKey.days)
        alarmDetail.setValue(alarm.audioOption, forKey: AlarmEntityKey.audio_option)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print(error)
        }
        self.refreshAlarmList()
    }
    
    func updateAlarm(updatedAlarmDetail: AlarmDetail ) {
        let featchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.alarm)
        
        let idPredicate = NSPredicate(format: "id == %d", updatedAlarmDetail.id ?? 0)
        featchRequest.predicate = idPredicate
        
        do {
            let result = try managedContext.fetch(featchRequest) as! [NSManagedObject]
            if result.count != 0, let alarmObject = result.first {
                alarmObject.setValue(updatedAlarmDetail.time, forKey: AlarmEntityKey.time)
                alarmObject.setValue(updatedAlarmDetail.date, forKey: AlarmEntityKey.date)
                alarmObject.setValue(updatedAlarmDetail.name, forKey: AlarmEntityKey.name)
                alarmObject.setValue(updatedAlarmDetail.status, forKey: AlarmEntityKey.status)
                alarmObject.setValue(updatedAlarmDetail.isRepeat, forKey: AlarmEntityKey.is_repeat)
                alarmObject.setValue(updatedAlarmDetail.isVibrate, forKey: AlarmEntityKey.is_vibrate)
                alarmObject.setValue(updatedAlarmDetail.isNfcActive, forKey: AlarmEntityKey.is_nfc_active)
                alarmObject.setValue(updatedAlarmDetail.nfcText, forKey: AlarmEntityKey.nfc_text)
                alarmObject.setValue(updatedAlarmDetail.mediaName, forKey: AlarmEntityKey.media_name)
                alarmObject.setValue(updatedAlarmDetail.mediaId, forKey: AlarmEntityKey.media_id)
                alarmObject.setValue(updatedAlarmDetail.isDelete, forKey: AlarmEntityKey.is_delete)
                alarmObject.setValue(updatedAlarmDetail.volume, forKey: AlarmEntityKey.volume)
                alarmObject.setValue(updatedAlarmDetail.days, forKey: AlarmEntityKey.days)
                alarmObject.setValue(updatedAlarmDetail.audioOption, forKey: AlarmEntityKey.audio_option)
                
                try managedContext.save()
            }
        } catch {
            
        }
        self.refreshAlarmList()
    }
    
    func getAlarmList() -> [AlarmDetail] {
        var alarmList = [AlarmDetail]()
        
        let featchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.alarm)
        
        let deletePredicate = NSPredicate(format: "is_delete == %d", 0)
        featchRequest.predicate = deletePredicate        
        
        do {
            let result = try managedContext.fetch(featchRequest)
            
            for data in result as! [NSManagedObject] {
                let alarmDetail: AlarmDetail = AlarmDetail()
                alarmDetail.id = data.value(forKey: AlarmEntityKey.id) as? Int ?? 0
                alarmDetail.time = data.value(forKey: AlarmEntityKey.time) as? String ?? ""
                alarmDetail.date = data.value(forKey: AlarmEntityKey.date) as? String ?? ""
                alarmDetail.name = data.value(forKey: AlarmEntityKey.name) as? String ?? ""
                alarmDetail.status = data.value(forKey: AlarmEntityKey.status) as? Int ?? 0
                alarmDetail.isRepeat = data.value(forKey: AlarmEntityKey.is_repeat) as? Int ?? 0
                alarmDetail.isVibrate = data.value(forKey: AlarmEntityKey.is_vibrate) as? Int ?? 0
                alarmDetail.isNfcActive = data.value(forKey: AlarmEntityKey.is_nfc_active) as? Int ?? 0
                alarmDetail.nfcText = data.value(forKey: AlarmEntityKey.nfc_text) as? String ?? ""
                alarmDetail.mediaName = data.value(forKey: AlarmEntityKey.media_name) as? String ?? ""
                alarmDetail.mediaId = data.value(forKey: AlarmEntityKey.media_id) as? String ?? ""
                alarmDetail.isDelete = data.value(forKey: AlarmEntityKey.is_delete) as? Int ?? 0
                alarmDetail.volume = data.value(forKey: AlarmEntityKey.volume) as? Float ?? 0.0
                alarmDetail.days = data.value(forKey: AlarmEntityKey.days) as? String ?? ""
                alarmDetail.audioOption = data.value(forKey: AlarmEntityKey.audio_option) as? String ?? ""
                alarmList.append(alarmDetail)
            }
            
        } catch {
            
        }
        self.currentAlarmList = alarmList
        return alarmList
    }
    
    func getAlarmListWithStatusOn() -> [AlarmDetail] {
        var alarmList = [AlarmDetail]()
        
        let featchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.alarm)
        
        let deletePredicate = NSPredicate(format: "is_delete == %d", 0)
        let statusPredicate = NSPredicate(format: "status == %d", 1)
        featchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [deletePredicate,statusPredicate])
        
        do {
            let result = try managedContext.fetch(featchRequest)
            
            for data in result as! [NSManagedObject] {
                let alarmDetail: AlarmDetail = AlarmDetail()
                alarmDetail.id = data.value(forKey: AlarmEntityKey.id) as? Int ?? 0
                alarmDetail.time = data.value(forKey: AlarmEntityKey.time) as? String ?? ""
                alarmDetail.date = data.value(forKey: AlarmEntityKey.date) as? String ?? ""
                alarmDetail.name = data.value(forKey: AlarmEntityKey.name) as? String ?? ""
                alarmDetail.status = data.value(forKey: AlarmEntityKey.status) as? Int ?? 0
                alarmDetail.isRepeat = data.value(forKey: AlarmEntityKey.is_repeat) as? Int ?? 0
                alarmDetail.isVibrate = data.value(forKey: AlarmEntityKey.is_vibrate) as? Int ?? 0
                alarmDetail.isNfcActive = data.value(forKey: AlarmEntityKey.is_nfc_active) as? Int ?? 0
                alarmDetail.nfcText = data.value(forKey: AlarmEntityKey.nfc_text) as? String ?? ""
                alarmDetail.mediaName = data.value(forKey: AlarmEntityKey.media_name) as? String ?? ""
                alarmDetail.mediaId = data.value(forKey: AlarmEntityKey.media_id) as? String ?? ""
                alarmDetail.isDelete = data.value(forKey: AlarmEntityKey.is_delete) as? Int ?? 0
                alarmDetail.volume = data.value(forKey: AlarmEntityKey.volume) as? Float ?? 0.0
                alarmDetail.days = data.value(forKey: AlarmEntityKey.days) as? String ?? ""
                alarmDetail.audioOption = data.value(forKey: AlarmEntityKey.audio_option) as? String ?? ""
                alarmList.append(alarmDetail)
            }
        } catch {
            
        }
        self.currentAlarmList = alarmList
        return alarmList
    }
    
    func getAlarmDetail(alarmId: Int) -> AlarmDetail {
        let alarmDetail: AlarmDetail = AlarmDetail()
        let featchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.alarm)
        
        let deletePredicate = NSPredicate(format: "id == %d", alarmId)
        featchRequest.predicate = deletePredicate
        do {
            let result = try managedContext.fetch(featchRequest)
            if result.count != 0 {
                let data = result.first as! NSManagedObject
                alarmDetail.id = data.value(forKey: AlarmEntityKey.id) as? Int ?? 0
                alarmDetail.time = data.value(forKey: AlarmEntityKey.time) as? String ?? ""
                alarmDetail.date = data.value(forKey: AlarmEntityKey.date) as? String ?? ""
                alarmDetail.name = data.value(forKey: AlarmEntityKey.name) as? String ?? ""
                alarmDetail.status = data.value(forKey: AlarmEntityKey.status) as? Int ?? 0
                alarmDetail.isRepeat = data.value(forKey: AlarmEntityKey.is_repeat) as? Int ?? 0
                alarmDetail.isVibrate = data.value(forKey: AlarmEntityKey.is_vibrate) as? Int ?? 0
                alarmDetail.isNfcActive = data.value(forKey: AlarmEntityKey.is_nfc_active) as? Int ?? 0
                alarmDetail.nfcText = data.value(forKey: AlarmEntityKey.nfc_text) as? String ?? ""
                alarmDetail.mediaName = data.value(forKey: AlarmEntityKey.media_name) as? String ?? ""
                alarmDetail.mediaId = data.value(forKey: AlarmEntityKey.media_id) as? String ?? ""
                alarmDetail.isDelete = data.value(forKey: AlarmEntityKey.is_delete) as? Int ?? 0
                alarmDetail.volume = data.value(forKey: AlarmEntityKey.volume) as? Float ?? 0.0
                alarmDetail.days = data.value(forKey: AlarmEntityKey.days) as? String ?? ""
                alarmDetail.audioOption = data.value(forKey: AlarmEntityKey.audio_option) as? String ?? ""
            }
        } catch {
            
        }
        return alarmDetail
    }
    
    func deleteAlarm(id: Int) {
        let featchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Entity.alarm)
        
        let idPredicate = NSPredicate(format: "id == %d", id)
        featchRequest.predicate = idPredicate
        
        do {
            let result = try managedContext.fetch(featchRequest) as! [NSManagedObject]
            if result.count != 0 {
                let deletedObject = result.first
                deletedObject?.setValue(1, forKey: AlarmEntityKey.is_delete)
                try managedContext.save()
            }
        } catch {
            
        }
        self.refreshAlarmList()
    }
    
    func refreshAlarmList() {
        self.currentAlarmList = self.getAlarmList()
    }
}
