import SwiftUI

struct StatsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("Fish").bold().font(.title2).padding()
                Text("  total: \(Cache.totalCount)")
                Divider()
                Text("  marked: \(Cache.markCount)")
                Text("  unMarked: \(Cache.unMarkCount)")
                Divider()
                Text("  locked: \(Cache.lockCount)")
                Text("  unLocked: \(Cache.unLockCount)")
                Divider()
                Text("  type").font(.title3).bold()
                ForEach(Cache.typeCount.sorted(by: {$0.key<$1.key}), id: \.key) { (type, count) in
                    Text("      \(type): \(count)")
                }
                Divider()
                Text("  tag").font(.title3).bold()
                ForEach(Cache.tagCount.sorted(by: {$0.key<$1.key}), id: \.key) { (tag, count) in
                    Text("      \(tag): \(count)")
                }
                Divider()
                Text("preview").bold().font(.title2).padding()
                Text("  total: \(Cache.previewDataCache.count)")
                Text("  totalSize: \(Functions.descByteCount(Cache.previewDataCache.values.reduce(into: 0) {(sum, data) in sum+=data.count}))")
            }
            .padding()
        }
        .onAppear {
                Cache.refresh()
        }
    }
}

