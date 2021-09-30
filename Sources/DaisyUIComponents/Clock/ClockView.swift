import SwiftUI
struct TimeArcShape : Shape {
    var lineWidth:CGFloat
    var start:Date
    var end:Date
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(
            center: CGPoint(x: rect.size.width/2, y:rect.size.width/2),
            radius: rect.size.width/2,
            startAngle: Self.angle(from: end),
            endAngle: Self.angle(from: start),
            clockwise: true)
        return p.strokedPath(.init(lineWidth: lineWidth))
    }
    static func angle(from date:Date) -> Angle {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return Angle(degrees: Double(360/12 * hour) + Double(360/60 * minute) / 12 - 90)
    }
}
public struct ClockView: View {
    @EnvironmentObject var viewModel: ClockViewModel
    var action:ClockItemAction?
    static func angle(from date:Date) -> Angle {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        return Angle(degrees: Double(360/12 * hour) + Double(360/60 * minute) / 12 - 180)
    }
    var startDate:Date { relativeDateFrom(time: self.viewModel.dayStarts) }
    var endDate:Date { relativeDateFrom(time: self.viewModel.dayEnds) }
    var startAngle:Angle { Self.angle(from: startDate) }
    var endAngle:Angle { Self.angle(from: endDate) }
    var nowAngle:Angle { Self.angle(from: Date()) }
    public init(action:ClockItemAction? = nil) {
        self.action = action
    }
    public var body: some View {
        GeometryReader() { geometry in
            let size:CGFloat = geometry.size.width
            let arcWidth:CGFloat = size * 0.025
            let endHeight:CGFloat = arcWidth * 1.4
            let endWidth:CGFloat = size * 0.006
            let endOffset:CGFloat = (size/2 - arcWidth * 0.3 - endHeight/2 + (endHeight - arcWidth))

            ZStack {
                if viewModel.showItems {
                    ClockItemsView(size: size, action: self.action) { centerSize, borderWidth in
                        ClockBaseView(size: centerSize)
                    }
                    .zIndex(4)
                } else {
                    if viewModel.showTimeSpan {
                        ClockBaseView(size: size).padding(arcWidth * 0.99)
                    } else {
                        ClockBaseView(size: size)
                    }
                }
                if viewModel.showTimeSpan {
                    TimeArcShape(
                        lineWidth: arcWidth,
                        start: startDate,
                        end: endDate
                    )
                    .fill(viewModel.timeSpanBackgroundColor)
                    .padding(arcWidth/2)
                    .padding(arcWidth * 0.3)
                    .zIndex(2)
                    
                    TimeArcShape(
                        lineWidth: arcWidth,
                        start: startDate,
                        end: Date()
                    )
                    .fill(viewModel.timeSpanColor)
                    .padding(arcWidth/2)
                    .padding(arcWidth * 0.3)
                    .zIndex(3)
                    
                    RoundedRectangle(cornerRadius:endWidth)
                        .fill(viewModel.timeSpanColor)
                        .frame(width:endWidth, height: endHeight)
                        .offset(y: endOffset)
                        .rotationEffect(startAngle)
                        .zIndex(2)
                    RoundedRectangle(cornerRadius:endWidth)
                        .fill(viewModel.timeSpanColor)
                        .frame(width:endWidth, height: endHeight)
                        .offset(y: endOffset)
                        .rotationEffect(nowAngle)
                        .zIndex(2)
                    RoundedRectangle(cornerRadius:endWidth)
                        .fill(viewModel.timeSpanBackgroundColor)
                        .frame(width:endWidth, height: endHeight)
                        .offset(y: endOffset)
                        .rotationEffect(endAngle)
                        .zIndex(2)
                }
            }.position(x:geometry.size.width/2,y:geometry.size.height/2)
        }
        .frame(maxWidth:.infinity,maxHeight:.infinity)
        .aspectRatio(1, contentMode: .fit)
    }
}
//struct ClockView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            ClockView()
//                .padding(20)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .environmentObject(ClockViewModel.dummyModel)
//            ClockView()
//                .preferredColorScheme(.dark)
//                .padding(20)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .environmentObject(ClockViewModel.dummyModel)
//        }
//        
//    }
//}
