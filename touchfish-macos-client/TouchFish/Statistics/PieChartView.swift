import SwiftUI

struct PieSlice {
    var label: String
    var value: Int
    var color: Color
    var extraColor: [Color]? = nil
    
    var colors: [Color] {
        var ret = [self.color]
        if let extraColor = extraColor {
            ret.append(contentsOf: extraColor)
        }
        return ret
    }
    
}

struct PieChartView: View {
    
    @State var title: String
    @State var slices: [PieSlice]
    @State var radius: [CGFloat]
    
    var maxRadius: CGFloat
    var angles: [Angle]
    
    init(title: String, slices: [PieSlice], radius: CGFloat) {
        self.title = title
        self.slices = slices
        let total: Double = Double(slices.reduce(0) { $0 + $1.value })
        var sum: Double = 0
        var angles: [Angle] = []
        var radiuses: [CGFloat] = []
        angles.append(Angle(degrees: 0))
        for slice in slices {
            sum += Double(slice.value)
            angles.append(Angle(degrees: sum/total*360))
            radiuses.append(0)
        }
        self.angles = angles
        self.radius = radiuses
        self.maxRadius = radius
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(radius: 10)
            VStack {
                HStack {
                    Text(title)
                        .font(.title2)
                        .padding()
                    Spacer()
                }
                HStack {
                    ZStack {
                        ForEach(Array(slices.enumerated()), id: \.0) { (idx, slice) in
                            PieSliceShape(startAngle: angles[idx], endAngle: angles[idx+1], radius: radius[idx])
                                .fill(LinearGradient(colors: slice.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                        }
                    }
                    VStack(alignment: .leading) {
                        ForEach(Array(slices.enumerated()), id: \.0) { (idx, slice) in
                            VStack {
                                HStack {
                                    Circle()
                                        .fill(LinearGradient(colors: slice.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                                        .frame(width: 20, height: 20)
                                    Text(slice.label)
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                        .padding(5)
                                }
                                Text(String(slice.value))
                                    .font(.title3)
                                    .padding(3)
                                    .offset(x: -CGFloat(idx)*3)
                            }
                            .offset(x: -CGFloat(idx)*2)
                        }
                    }
                }
            }
            
        }
        .onAppear {
            for i in 0..<slices.count {
                withAnimation(.easeInOut(duration: Double.random(in: 0.2...0.8))) {
                    radius[i] = maxRadius
                }
            }
        }
    }
}

struct PieSliceShape: Shape {
    
    var startAngle: Angle
    var endAngle: Angle
    var radius: CGFloat
    
    var animatableData: CGFloat {
        get { radius }
        set { radius = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        return path
    }
}
