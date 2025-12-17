
import Foundation;
import UIKit;

class CommonUtils {
   
    static func OSVersion() -> Float {
        return Float(UIDevice.current.systemVersion)!;
    }
    
    static func formatTime(seconds totalSeconds: Int64) -> String{
        let (hours,minutes,_) = CommonUtils.secondsToHoursMinutesSeconds(seconds: totalSeconds)
        let formatedHours = hours == 0 ? "" : ("\(hours)h");
        return "\(formatedHours)\(minutes)m";
    }
    
    static func secondsToHoursMinutesSeconds (seconds : Int64) -> (Int64, Int64, Int64) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    static func dipslayTimeEvent(_ from: Date, _ to: Date) -> String {
        let startStr = DateFormatter.displayTime.string(from: from)
        let endStr = DateFormatter.displayTime.string(from: to)
        
        return "\(startStr) - \(endStr)"
    }
    
    static func imageWithSize(image: UIImage?, size: CGSize) -> UIImage {
        if UIScreen.main.responds(to: NSSelectorFromString("scale")) {
            UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
            
        } else {
            UIGraphicsBeginImageContext(size)
        }
        
        image?.draw(in: CGRectMake(0, 0, size.width, size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage ?? UIImage()
    }
    
    static func getTwoFirstLetter(string:String) -> String {
       var str = ""
       let arr = string.trim(characters: CharacterSet.whitespacesAndNewlines).components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        if arr.count == 1 {
            str = arr[0];
            str = str.substring(to: MIN(2, str.length)).uppercased()
            return str
        }
        
        for item in arr {
            if !isEmpty(item){
                str = str.appending(item.substring(to: 1))
            }
        }
        
        if str.length >= 2 {
            return str.uppercased()
        }
        
        return str
    }
    
    static func convertKilometer(miles:Double) -> Double {
        let km = miles * 1.609344
        return km.rounded(toPlaces: 1)
    }
    
    static func convertKilometer(met:Double) -> Double {
        let km = met / 1000
        return km.rounded(toPlaces: 1)
    }
    
    static func convertMiles(met:Double) -> Double {
        let mi = met / 1609.34
        return mi.rounded(toPlaces: 2)
    }
    
    static func currentWeekdays() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOfWeek = calendar.component(.weekday, from: today)
        let weekdays = calendar.range(of: .weekday, in: .weekOfYear, for: today)!
        let days = (weekdays.lowerBound ..< weekdays.upperBound)
            .compactMap { calendar.date(byAdding: .day, value: $0 - dayOfWeek, to: today) }  // use `flatMap` in Xcode versions before 9.3
            .filter { !calendar.isDateInWeekend($0) }
        
        return days
    }
    
    static func getAllDefaultDate() -> [Date] {
        var data:[Date] = [Date.now]
        let days = (1..<7).map { (index) -> Date in
            var dayComponent    = DateComponents()
            dayComponent.day    = +index
            let theCalendar     = Calendar.current
            let nextDate        = theCalendar.date(byAdding: dayComponent, to: Date())
            
            return nextDate ?? Date.now
        }
        
        data.append(contentsOf: days)
        
        return data
    }
    
    static func decode(jwtToken jwt: String) -> [String: Any] {
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [: ]
    }

    static func base64UrlDecode(_ value: String) -> Data? {
         var base64 = value
         .replacingOccurrences(of: "-", with: "+")
         .replacingOccurrences(of: "_", with: "/")
         let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
         let requiredLength = 4 * ceil(length / 4.0)
         let paddingLength = requiredLength-length
         if paddingLength > 0 {
         let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
         base64 = base64 + padding
         }
         return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }

    static func decodeJWTPart(_ value: String) -> [String: Any]? {
        guard let bodyData = base64UrlDecode(value),
              let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else { return nil }

        return payload
    }
    
    /// Check if url is from S3, open by webview, otherwise open web browser
    static func isOpenBrowser(url: String) -> Bool {
        return url.starts(with: "http") && url.contains("driverterms_eng")
    }
}
