import SwiftUI
import WrapLayout

struct BookTextWrapping: View, PreviewProvider {
  var body: some View {
    Content()
  }

  static var previews: some View {
    Self()
  }

  private struct Content: View {

    private let data = [
      "🚕 A",
      "Hello",
      "☠️",
      "危険: 押すな",
      "🔘",
      "🍫: Chocolate",
      "B",
      "🐕",
    ]

    var body: some View {
      WrapLayout(horizontalSpacing: 4, verticalSpacing: 16) {
        ForEach(data, id: \.self) { item in
          Text(item)
        }
      }
      .background(Color.gray)
      .frame(width: 200)
    }
  }
}

