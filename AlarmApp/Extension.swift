//
//  Extension.swift
//  AlarmApp
//
//  Created by Leo on 20/05/22.
//

import Foundation
import UIKit
import MediaPlayer

extension Date {
    var alarmDateString: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.string(from: self)
    }
    
    var time: String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: self)
    }
    
    func adding(days: Int) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = days
        dateComponents.timeZone = TimeZone.init(identifier: "UTC")
        return Calendar.current.date(byAdding: dateComponents, to: self)
    }
    
    func offsetFrom(date: Date) -> String {
        let dayHourMinuteSecond: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        let difference = NSCalendar.current.dateComponents(dayHourMinuteSecond, from: date, to: self)

        let seconds = (difference.second ?? 0) > 1 ? ("\(difference.second ?? 0) seconds") : ("\(difference.second ?? 0) second")
                
        var minutes = ""
        if (difference.minute ?? 0) != 0 {
            minutes = (difference.minute ?? 0) > 1 ? ("\(difference.minute ?? 0) minutes") : ("\(difference.minute ?? 0) minute")
        }
        
        var hours = ""
        if (difference.hour ?? 0) == 0 {
            hours = minutes
        } else {
            hours = (difference.hour ?? 0) > 1 ? ("\(difference.hour ?? 0) hours" + " " + minutes) : ("\(difference.hour ?? 0) hour" + " " + minutes)
        }
        
        let days = (difference.day ?? 0) > 1 ? ("\(difference.day ?? 0) days" + " " + hours) : ("\(difference.day ?? 0) day" + " " + hours)

        if let day = difference.day, day > 0 {
            return days
        }
        if let hour = difference.hour, hour > 0 {
            return hours
        }
        if let minute = difference.minute, minute > 0 {
            return minutes
        }
        if let second = difference.second, second > 0 {
            return seconds
        }
        return ""
    }
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}

extension String {
    var alarmDate: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        dateFormatter.amSymbol = "AM"
        dateFormatter.pmSymbol = "PM"
        return dateFormatter.date(from: self) ?? Date()
    }
    
    var shortDayString: String {
        let dayArray = self.components(separatedBy: ",")
        var shortDayName = ""
        if dayArray.count != 0 {
            if dayArray.count == StaticArray.daysArray.count {
                shortDayName = "Everyday"
            } else if dayArray.count == 5 && dayArray.contains("2") && dayArray.contains("3") && dayArray.contains("4") && dayArray.contains("5") && dayArray.contains("6") {
                shortDayName = "Weekdays"
            } else if dayArray.count == 2 && dayArray.contains("1") && dayArray.contains("7") {
                shortDayName = "Weekend"
            } else {
                for day in dayArray {
                    if shortDayName == "" {
                        shortDayName = StaticArray.daysArray[day] ?? ""
                    } else {
                        shortDayName = shortDayName + " \u{2022} " + (StaticArray.daysArray[day] ?? "")
                    }
                }
            }
            return shortDayName
        }
        return ""
    }
    
    var isValidHexString: Bool {
        let regEx = "^#(?:[0-9a-fA-F]{3}){1,2}$"
        let test = NSPredicate(format: "SELF MATCHES %@", regEx)
        return test.evaluate(with: self)
    }
    
    var colorWithHexString: UIColor {
        var colorString = self.trimmingCharacters(in: .whitespacesAndNewlines)
        colorString = colorString.replacingOccurrences(of: "#", with: "").uppercased()
        
        let alpha: CGFloat = 1.0
        let red: CGFloat = self.colorComponentFrom(colorString: colorString, start: 0, length: 2)
        let green: CGFloat = self.colorComponentFrom(colorString: colorString, start: 2, length: 2)
        let blue: CGFloat = self.colorComponentFrom(colorString: colorString, start: 4, length: 2)
        
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
    
    func colorComponentFrom(colorString: String, start: Int, length: Int) -> CGFloat {
        let startIndex = colorString.index(colorString.startIndex, offsetBy: start)
        let endIndex = colorString.index(startIndex, offsetBy: length)
        let subString = colorString[startIndex..<endIndex]
        let fullHexString = length == 2 ? subString : "\(subString)\(subString)"
        var hexComponent: UInt64 = 0
        
        guard Scanner(string: String(fullHexString)).scanHexInt64(&hexComponent) else {
            return 0
        }
        let hexFloat: CGFloat = CGFloat(hexComponent)
        let floatValue: CGFloat = CGFloat(hexFloat / 255.0)
        print(floatValue)
        return floatValue
    }
}

extension UIColor {
    var hexStringFromColor: String {
        let components = self.cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String.init(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
        return hexString
    }
}

extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var colorReturnded: UIColor?
        if let colorData = data(forKey: key) {
            do {
                if let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
                    colorReturnded = color
                }
            } catch {
                print("Error UserDefaults")
            }
        }
        return colorReturnded
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: false) as NSData?
                colorData = data
            } catch {
                print("Error UserDefaults")
            }
        }
        set(colorData, forKey: key)
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        subView.layer.cornerRadius = 28.0
        insertSubview(subView, at: 0)
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
            var viewController = self.keyWindow?.rootViewController
            
            // If root `UIViewController` is a `UITabBarController`
            if let presentedController = viewController as? UITabBarController {
                // Move to selected `UIViewController`
                viewController = presentedController.selectedViewController
            }
            
            // Go deeper to find the last presented `UIViewController`
            while let presentedController = viewController?.presentedViewController {
                // If root `UIViewController` is a `UITabBarController`
                if let presentedController = presentedController as? UITabBarController {
                    // Move to selected `UIViewController`
                    viewController = presentedController.selectedViewController
                } else {
                    // Otherwise, go deeper
                    viewController = presentedController
                }
            }
            return viewController
        }
}

extension UIViewController {
    func presentInKeyWindow(animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.rootViewController?
                .present(self, animated: animated, completion: completion)
        }
    }
    
    func presentInKeyWindowPresentedController(animated: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.shared.keyWindowPresentedController?
                .present(self, animated: animated, completion: completion)
        }
    }
}

func topViewController(_ base: UIViewController? = UIApplication.shared.windows.first() {$0.isKeyWindow}?.rootViewController) -> UIViewController? {
    if let navigation = base as? UINavigationController {
        let topVC = topViewController(navigation.visibleViewController)
        return topVC
    }
    if let tab = base as? UITabBarController {
        if let selected = tab.selectedViewController {
            return topViewController(selected)
        }
    }
    if let presented = base?.presentedViewController {
        let topVC = topViewController(presented)
        return topVC
    }
    return base
}

@IBDesignable
class GradientView: UIView {

    @IBInspectable var startColor:   UIColor = .black { didSet { updateColors() }}
    @IBInspectable var endColor:     UIColor = .white { didSet { updateColors() }}
    @IBInspectable var startLocation: Double =   0.05 { didSet { updateLocations() }}
    @IBInspectable var endLocation:   Double =   0.95 { didSet { updateLocations() }}
    @IBInspectable var horizontalMode:  Bool =  false { didSet { updatePoints() }}
    @IBInspectable var diagonalMode:    Bool =  false { didSet { updatePoints() }}

    override public class var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer { layer as! CAGradientLayer }

    func updatePoints() {
        gradientLayer.startPoint = .init(x: 0, y: 0)
        gradientLayer.endPoint   = .init(x: 1, y: 0)
    }
    func updateLocations() {
        gradientLayer.locations = [startLocation as NSNumber, endLocation as NSNumber]
    }
    func updateColors() {
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
    }
    override public func layoutSubviews() {
        super.layoutSubviews()
        updatePoints()
        updateLocations()
        updateColors()
    }
}

extension MPVolumeView {
    static func setVolume(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
//            sliderVolume = slider?.value ?? 0.0
            slider?.value = volume
        }
    }
}

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID (kSystemSoundID_Vibrate))
        //set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
                                              nil, { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }, nil)
    }
}
extension DateComponents {
   static func triggerFor(hour: Int, minute: Int) -> DateComponents {
      var component = DateComponents()
      component.calendar = Calendar.current
      component.hour = hour
      component.minute = minute
      component.weekday = 1
      return component
   }
}
