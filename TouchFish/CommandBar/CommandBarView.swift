import SwiftUI

struct CommandBarView: View {
    
    @Binding var commandText: String
    @Binding var commandCell: [String]
    
    var body: some View {
        ZStack {
            HStack {
                ForEach(Array(commandCell.enumerated()), id: \.0) { _, cellText in
                    Text(cellText)
                        .background(
                            GeometryReader { geometry in
                                Rectangle()
                                    .cornerRadius(5)
                                    .foregroundColor(Config.selectedItemBackgroundColor.color)
                                    .frame(width: geometry.size.width+5, height: geometry.size.height+8)
                                    .offset(x: -2.5, y: -4)
                            }
                        )
                        .foregroundColor(.white)
                        .font(.custom("Menlo", size: 16))
                        .padding([.leading], 3)
                }
                CommandField(commandText: $commandText)
                    .frame(height: Config.promptBarHeight-12) // todo: add config
                    .offset(y: 2)
            }
            .padding([.leading], 6)
            .frame(height: Config.promptBarHeight)
        }
        .background(Config.promptBarBackgroundColor.color) // todo: change name
        .cornerRadius(10)
        .padding(10)
    }
}
