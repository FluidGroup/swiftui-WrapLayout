import XCTest
import SwiftUI

@testable import WrapLayout
import SnapshotTesting

final class WrapLayoutTests: XCTestCase {

  private static let data = [
    "🚕 A",
    "Hello",
    "☠️",
    "危険: 押すな",
    "🔘",
    "🍫: Chocolate",
    "B",
    "🐕",
  ]

  func testWrapping() throws {

    struct Content: View {

      var body: some View {
        WrapLayout(horizontalSpacing: 4, verticalSpacing: 16) {
          ForEach(WrapLayoutTests.data, id: \.self) { item in
            Text(item)
          }
        }
        .background(Color.gray)
        .frame(width: 200)
      }
    }

    assertSnapshot(matching: Content(), as: .image)
  }

  func testCenterAligned() throws {

    struct Content: View {
      var body: some View {
        WrapLayout(
          horizontalSpacing: 4,
          verticalSpacing: 8,
          lineHorizontalAlignment: .center
        ) {
          ForEach(WrapLayoutTests.data, id: \.self) { item in
            Text(item)
          }
        }
        .background(Color.gray)
        .frame(width: 200)
      }
    }

    assertSnapshot(matching: Content(), as: .image)
  }

  func testTrailingAligned() throws {

    struct Content: View {
      var body: some View {
        WrapLayout(
          horizontalSpacing: 4,
          verticalSpacing: 8,
          lineHorizontalAlignment: .trailing
        ) {
          ForEach(WrapLayoutTests.data, id: \.self) { item in
            Text(item)
          }
        }
        .background(Color.gray)
        .frame(width: 200)
      }
    }

    assertSnapshot(matching: Content(), as: .image)
  }

  func testVerticalCenterAligned() throws {

    struct Content: View {
      var body: some View {
        WrapLayout(
          horizontalSpacing: 4,
          verticalSpacing: 8,
          lineVerticalAlignment: .center
        ) {
          Text("Short")
          Text("Tall")
            .font(.largeTitle)
          Text("Mid")
            .font(.title2)
          Text("X")
        }
        .background(Color.gray)
        .frame(width: 240)
      }
    }

    assertSnapshot(matching: Content(), as: .image)
  }

  func testVerticalBottomAligned() throws {

    struct Content: View {
      var body: some View {
        WrapLayout(
          horizontalSpacing: 4,
          verticalSpacing: 8,
          lineVerticalAlignment: .bottom
        ) {
          Text("Short")
          Text("Tall")
            .font(.largeTitle)
          Text("Mid")
            .font(.title2)
          Text("X")
        }
        .background(Color.gray)
        .frame(width: 240)
      }
    }

    assertSnapshot(matching: Content(), as: .image)
  }
}
