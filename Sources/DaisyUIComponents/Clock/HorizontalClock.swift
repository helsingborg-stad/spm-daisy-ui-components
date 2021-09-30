import SwiftUI

struct TimeLineFont: ViewModifier {
    var size:CGFloat
    var sizeClass: UserInterfaceSizeClass? = nil
    var foregroundColor = Color("DefaultTextColor")
    func body(content:Content) -> some View {
        content
            .font(Font.system(size: sizeClass == .regular ? size : size * 0.85, weight: .heavy, design: Font.Design.rounded))
            .foregroundColor(foregroundColor)
    }
}

struct TimeLineItemView: View {
    @EnvironmentObject var viewModel: ClockViewModel
    var item: ClockItem
    var selected:Bool = false
    var color:Color {
        return item.color  ?? viewModel.itemBorderColor
    }
    var action:ClockItemAction? = nil
    var body: some View {
        GeometryReader() { proxy in
            let size:CGFloat = 30
            let fontSize:CGFloat = size * 0.8
            let itemSize:CGFloat = size
            let itemPadding:CGFloat = itemSize * 0.2
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 0).frame(width: 3, height: 53).foregroundColor(self.color)
                Button(action: {
                    self.action?(self.item)
                }) {
                    Text(item.emoji)
                        .frame(width: itemSize, height: itemSize)
                        .padding(itemPadding)
                        .background(Circle().strokeBorder(color,lineWidth:itemPadding/2))
                        .background(item.color.opacity(0.2))
                        .background(Color.white)
                        .clipShape(Circle())
                        .font(Font.system(size: fontSize, weight: .semibold, design: .rounded))
                        .shadow(
                            color: item.date > Date() ? Color.black.opacity(0.5) : Color.clear,
                            radius: item.date > Date() ? 3.5 : 0,x: 0, y:0)
                }
                Text(timeStringfrom(date: self.item.date))
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(self.item.color.opacity(0.2).background(Color.white))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(self.color , lineWidth: 2)
                    ).modifier(TimeLineFont(size: 14, sizeClass: .regular, foregroundColor: viewModel.timeTextColor)).padding(.top, 5)
            }
            .frame(maxHeight:.infinity,alignment: .topLeading)
            .offset(x: proxy.size.width/2 * -1)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }.frame(alignment: .topLeading)
    }
}
struct TimeLinePeripheryView: View {
    @EnvironmentObject var viewModel: ClockViewModel
    var date: Date
    var text: String
    var color:Color
    
    var body: some View {
        GeometryReader() { proxy in
            VStack(spacing: 0) {
                Text(self.text).padding(.bottom, 3)
                Text(timeStringfrom(date: self.date))
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .background(self.color.opacity(0.2).background(Color.white))
                    .cornerRadius(20)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(self.color, lineWidth: 2)
                )
                RoundedRectangle(cornerRadius: 0).frame(width: 3, height: 48).foregroundColor(self.color)
            }
            .modifier(TimeLineFont(size: 14, sizeClass: .regular, foregroundColor: viewModel.timeTextColor))
            .frame(maxHeight:.infinity,alignment: .topLeading)
            .offset(x: proxy.size.width/2 * -1)
            .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
        }.frame(alignment: .topLeading)
    }
}
// brun = WatchColorRimr
public struct HorizontalTimeLineView: View {
    func position(for date:Date) -> CGFloat {
        let diff = dayEnds.timeIntervalSince(dayStarts)
        return CGFloat(date.timeIntervalSince(dayStarts)/diff)
    }
    var dayStarts:Date {
        relativeDateFrom(time: viewModel.dayStarts)
    }
    var dayEnds:Date {
        relativeDateFrom(time: viewModel.dayEnds)
    }
    var timePassed: CGFloat {
        return position(for: now)
    }
    var ios14:Bool {
        if #available(iOS 14.0, *) {
            return true
        } else {
            return false
        }
    }
    @EnvironmentObject var viewModel: ClockViewModel
    var action:ClockItemAction? = nil
    public init(_ action:ClockItemAction? = nil) {
        self.action = action
    }
    @State var now:Date = Date()
    var hours:[Date] {
        var arr = [Date]()
        
        for t in dayStarts.hour...dayEnds.hour {
            if t < 10 {
                arr.append(relativeDateFrom(time: "0\(t):00"))
            } else {
                arr.append(relativeDateFrom(time: "\(t):00"))
            }
        }
        return arr
    }
    fileprivate func image(_ name:String,color:Color) -> some View {
        return Image(systemName:name).resizable().aspectRatio(contentMode: .fit).frame(width: 30, height: 30).foregroundColor(color)
    }
    let timer = Timer.publish(every: 10, on: .current, in: .common).autoconnect()
    public var body: some View {
        HStack(alignment: .top) {
            image("sunrise", color: viewModel.timeSpanColor).offset(y: 58)
            GeometryReader() { proxy in
                Group() {
                    HStack() {
                        Rectangle().foregroundColor(viewModel.timeSpanColor).frame(width: proxy.size.width * self.timePassed,height:40)
                        Spacer()
                    }.background(viewModel.timeSpanBackgroundColor)
                    ForEach(self.hours,id: \.hashValue) { hour in
                        Rectangle()
                            .foregroundColor(hour > self.now ? viewModel.timeSpanBackgroundColor : viewModel.timeSpanColor)
                            .frame(width: 3, height: 45)
                            .offset(x: proxy.size.width * self.position(for: hour) - 1.5,y:-5)
                    }
                }.offset(y:53)
                TimeLinePeripheryView(
                    date: relativeDateFrom(time: timeStringfrom(date: self.dayStarts)),
                    text: "Morgon",
                    color:viewModel.timeSpanColor
                )
                TimeLinePeripheryView(
                    date: relativeDateFrom(time: timeStringfrom(date: self.dayEnds)),
                    text: "Kväll",
                    color:viewModel.timeSpanBackgroundColor
                ).offset(x: proxy.size.width)
                TimeLinePeripheryView(
                    date: self.now,
                    text: "Nu",
                    color:viewModel.hoursHandColor
                ).offset(x: proxy.size.width * self.position(for: self.now))
                ForEach(self.viewModel.items, id: \.self) { item in
                    TimeLineItemView(item:item, selected:Date() < item.date, action:self.action)
                        .offset(x: proxy.size.width * self.position(for: item.date),y:48)
                }
            }
            .frame(maxHeight:.infinity,alignment: .topLeading)
            image("sunset",color:viewModel.timeSpanBackgroundColor).offset(y: 58)
        }.frame(height: 183).onReceive(timer) { timer in
            self.now = Date()
        }
    }
}

struct HorizontalTimeLineView_Previews: PreviewProvider {
    static var previews: some View {
        HorizontalTimeLineView()
            .padding(40)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .background(Color("TopBackground"))
            .environmentObject(ClockViewModel.dummyModel)
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (9.7-inch)"))
            
    }
}
