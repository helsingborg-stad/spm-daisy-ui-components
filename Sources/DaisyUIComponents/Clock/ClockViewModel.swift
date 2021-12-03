import Foundation
import SwiftUI

extension Array where Element == ClockItem {
    func element(for date:Date) -> ClockItem? {
        var dict = [TimeInterval:ClockItem]()
        for el in self {
            dict[abs(el.date.timeIntervalSince(date))] = el
        }
        guard let first = dict.sorted(by: { $0.0 < $1.0 }).first?.value else {
            return nil
        }
        guard abs(first.date.timeIntervalSince(date)) < 60 * 60 * 24 * 11 else {
            return nil
        }
        return first
    }
}
public struct ClockItem : Hashable, Identifiable {
    public let id:String
    public var emoji:String
    public var date:Date
    public var text:String
    public var tag:String?
    public var color:Color?
    public var angle:Angle {
        ClockAngle.angle(from: date).hour
    }
    public init(id:String = UUID().uuidString,emoji:String,date:Date,text:String,tag:String? = nil, color:Color? = nil) {
        self.id = id
        self.emoji = emoji
        self.date = date
        self.text = text
        self.tag = tag
        self.color = color
    }
}
public class ClockViewModel : ObservableObject, Identifiable {
    @Published public var items:[ClockItem] = []
    @Published public var dayStarts:String
    @Published public var dayEnds:String
    @Published public var militaryTime = false
    @Published public var showClockMarkings = true
    @Published public var showClockSeconds = true
    @Published public var showClockHourText = true
    @Published public var showItems = true
    @Published public var showTimeSpan = true
    @Published public var showShadow:Bool = true
    @Published public var secondsHandImage:Image
    @Published public var minutesHandImage:Image
    @Published public var hoursHandImage:Image
    @Published public var secondsHandColor:Color
    @Published public var minutesHandColor:Color
    @Published public var hoursHandColor:Color
    @Published public var markingsColor:Color
    @Published public var timeTextColor:Color
    @Published public var faceColor:Color
    @Published public var itemBorderColor:Color
    @Published public var timeSpanBackgroundColor:Color
    @Published public var timeSpanColor:Color
    @Published public var timeLock:Date? = nil
    @Published public var horizontalMorningLabel:String = "Morgon"
    @Published public var horizontalNowLabel:String = "Nu"
    @Published public var horizontalEveningLabel:String = "Kväll"
    public init(bundle:Bundle? = nil, items:[ClockItem] = [], dayStarts:String = "08:00", dayEnds:String = "17:00") {
        let bundle:Bundle = bundle ?? Bundle.module
        self.items = items
        self.dayStarts = dayStarts
        self.dayEnds = dayEnds
        
        secondsHandImage = Image("ClockSecondsHand", bundle: bundle)
        minutesHandImage = Image("ClockMinutesHand", bundle: bundle)
        hoursHandImage = Image("ClockHoursHand", bundle: bundle)
        secondsHandColor = Color("ClockSecondsHandColor", bundle: bundle)
        minutesHandColor = Color("ClockMinutesHandColor", bundle: bundle)
        hoursHandColor = Color("ClockHoursHandColor", bundle: bundle)
        markingsColor = Color("ClockMarkingsColor", bundle: bundle)
        timeTextColor = Color("ClockTextColor", bundle: bundle)
        faceColor = Color("ClockFaceColor", bundle: bundle)
        itemBorderColor = Color("ClockEmojiBorderColor",bundle: bundle)
        timeSpanBackgroundColor = Color("ClockTimeSpanBackgroundColor",bundle: bundle)
        timeSpanColor = Color("ClockTimeSpanColor",bundle: bundle)
    }
    static var dummyModel:ClockViewModel {
        let m = ClockViewModel()
        m.showTimeSpan = true
        m.items = [
            .init(id: "1", emoji: "🧣", date: relativeDateFrom(time: "08:00"), text: "Test", color: Color("ClockSecondsHandColor", bundle:Bundle.module)),
            .init(id: "2", emoji: "☔️", date: relativeDateFrom(time: "11:00"), text: "Test", color: Color("ClockHoursHandColor", bundle:Bundle.module)),
            .init(id: "3", emoji: "❄️", date: relativeDateFrom(time: "16:30"), text: "Test", color: Color("ClockMinutesHandColor", bundle:Bundle.module)),
            //.init(id: "4", emoji: "🦊", date: relativeDateFrom(time: "19:30"), text: "Test", color: Color.orange),
            //.init(id: "5", emoji: "💁", date: relativeDateFrom(time: "03:00"), text: "Test", color: Color.gray)
        ]
        return m
    }
    var currentAngle:ClockAngle {
        if let d = timeLock {
            return ClockAngle.angle(from: d)
        }
        return ClockAngle.now
    }
}
