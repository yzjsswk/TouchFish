import SwiftUI

struct BarSlice {
    
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

struct BarChartView: View {
    
    @State var title: String
    @State var slices: [BarSlice]
    @State var heights: [CGFloat]
    
    var maxHeights: [CGFloat]
    
    init(title: String, slices: [BarSlice], maxHeight: Int) {
        self.title = title
        self.slices = slices
        let maxValue: Int = slices.reduce(0) { max($0, $1.value) }
        var heights: [CGFloat] = []
        var maxHeights: [CGFloat] = []
        for slice in slices {
            heights.append(0)
            maxHeights.append(Double(slice.value * maxHeight / maxValue))
        }
        self.heights = heights
        self.maxHeights = maxHeights
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
                Spacer()
                if slices.count > 12 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 16) {
                            ForEach(Array(slices.enumerated()), id: \.0) { (idx, slice) in
                                BarSliceView(slice: slice, height: $heights[idx])
                            }
                        }
                    }
                    .padding(.horizontal, 5)
                } else {
                    HStack(alignment: .bottom, spacing: 16) {
                        ForEach(Array(slices.enumerated()), id: \.0) { (idx, slice) in
                            BarSliceView(slice: slice, height: $heights[idx])
                        }
                    }
                }

            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: Double.random(in: 0.2...0.8))) {
                for i in 0..<slices.count {
                    heights[i] = maxHeights[i]
                }
            }
        }
    }
}

struct BarSliceView: View {
    
    @State var slice: BarSlice
    @Binding var height: CGFloat
    
    @State var isSelected: Bool = false
    
    var body: some View {
        VStack {
            Text(slice.label)
                .font(.title3)
                .foregroundStyle(.gray)
                .italic()
                .padding(5)
            Text(String(slice.value))
                .font(.title3)
                .padding(.bottom, 5)
            Rectangle()
                .fill(slice.color)
                .frame(width: isSelected ? 40 : 30, height: height+(isSelected ? 10 : 0))
                .padding(.bottom, 5)
        }
        .onHover { isHovered in
            withAnimation {
                isSelected = isHovered
            }
        }
    }
    
}
