import SwiftUI

@available(iOS 16, *)
public struct Wrap: Layout {

  public struct CacheStorage {

    struct CalculatedElement {
      let element: LayoutSubviews.Element
      let size: CGSize
    }

    struct Line {

      var width: CGFloat = 0
      var height: CGFloat = 0

      var elements: [CalculatedElement] = []
    }

    var lines: [Line] = []

    func calculateSize(verticalSpacing: CGFloat) -> CGSize {

      let maxWidth = lines.max(by: { $0.width < $1.width })?.width ?? 0

      let totalHeight =
        lines.reduce(CGFloat(0.0)) { partialResult, line in
          partialResult + (line.height + verticalSpacing)
        } - verticalSpacing /* removing space after the last line */

      return .init(width: maxWidth, height: totalHeight)

    }
  }

  public let horizontalSpacing: CGFloat
  public let verticalSpacing: CGFloat

  init(
    horizontalSpacing: CGFloat = 4,
    verticalSpacing: CGFloat = 4
  ) {
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
  }

  public func makeCache(subviews: Subviews) -> CacheStorage {
    return .init()
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout CacheStorage
  ) -> CGSize {

    let bounds = CGRect(
      origin: .zero,
      size: .init(
        width: proposal.width ?? .infinity,
        height: proposal.height ?? .infinity
      )
    )

    var offsetX: Double = 0
    var currentLine: CacheStorage.Line = .init()

    cache.lines = []

    for (_, view) in subviews.enumerated() {

      let calculatedSize = view.sizeThatFits(.init(width: bounds.width, height: bounds.height))

      if (calculatedSize.width + offsetX) >= bounds.width {
        // line break
        currentLine.width = offsetX

        offsetX = 0
        cache.lines.append(currentLine)
        currentLine = .init()
      }

      let calculatedElement = CacheStorage.CalculatedElement(
        element: view,
        size: calculatedSize
      )

      currentLine.elements.append(calculatedElement)

      offsetX += calculatedSize.width + horizontalSpacing

      if currentLine.height < calculatedElement.size.height {
        currentLine.height = calculatedElement.size.height
      }

    }

    cache.lines.append(currentLine)

    let size = cache.calculateSize(verticalSpacing: verticalSpacing)

    return size
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout CacheStorage
  ) {

    var cursorY: CGFloat = 0
    var cursorX: CGFloat = 0

    for line in cache.lines {

      for element in line.elements {

        element.element.place(
          at: .init(
            x: bounds.minX + cursorX,
            y: bounds.minY + cursorY
          ),
          proposal: .init(width: element.size.width, height: element.size.height)
        )

        cursorX += element.size.width + horizontalSpacing

      }

      cursorX = 0
      cursorY += line.height + verticalSpacing

    }

  }

}

#if DEBUG
@available(iOS 16, *)
struct BookWrapLayout_Previews: PreviewProvider {
  static var previews: some View {
    BookWrapLayout()
  }
}

/// very beginning
@available(iOS 16, *)
struct BookWrapLayout: View {

  private func content(_ text: String) -> some View {
    Text(text)
      .padding(4)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(.blue)
      )
  }

  var body: some View {

    HStack {
      VStack {

        Wrap {

          Group {
            content("👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻")
            content("👨🏻🐵👨🏻👨🏻👨🏻")
            content("👨🏻👨🏻")
            content("👨🏻👨🏻👨🏻")
            content("👨🏻👨🏻")
            content("👨🏻👨🏻👨🏻👨🏻")
            content("👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻")
            content("🐵🍌")
          }

          Group {
            content("👨🏻👨🏻👨🏻👨🏻👨🏻🍎👨🏻👨🏻👨🏻👨🏻🍎🍎🍎👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻")
            content("👨🏻🐵👨🏻")
            content("👨🏻👨🏻")
            content("👨🏻👨🏻👨🏻")
            Circle().fill(.yellow).frame(width: nil, height: 70)
            content("👨🏻👨🏻")
            content("👨🏻👨🏻👨🏻👨🏻")
            content("👨🏻👨🏻👨🏻👨🏻👨🏻👨🏻")
            content("🐵🍌")
          }
        }
        .background(.black.opacity(0.1))
        .transition(.scale)

      }

      Text("Wrap")
    }
  }
}
#endif
