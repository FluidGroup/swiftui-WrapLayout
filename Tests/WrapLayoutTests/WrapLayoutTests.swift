import XCTest
import SwiftUI

@testable import WrapLayout
import SnapshotTesting

final class WrapLayoutTests: XCTestCase {

  override class func setUp() {
    isRecording = false
  }

  func testWrapping() throws {

    struct Content: View {

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

    assertSnapshot(matching: Content(), as: .image)

  }
}
