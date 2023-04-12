import SwiftUI
import Placement

public struct WrapLayout: PlacementLayout {

  public struct CacheStorage {

    struct CalculatedElement {
      let element: Subviews.Element
      let size: CGSize
    }

    struct Line {

      var width: CGFloat = 0
      var height: CGFloat = 0

      var elements: [CalculatedElement] = []
    }

    var lines: [Line] = []

    func calculateSize(verticalSpacing: CGFloat) -> CGSize {

      // get a lenght from the longest line.
      let maxWidth = lines.max(by: { $0.width < $1.width })?.width ?? 0

      // get a total height by all lines.
      let totalHeight: CGFloat = lines.reduce(0) { partialResult, line in
          partialResult + line.height
      }
      
      // total spacing from each line.
      let verticalSpacing: CGFloat = (CGFloat(max(0, (lines.count - 1))) * verticalSpacing)

      return .init(width: maxWidth, height: totalHeight + verticalSpacing)

    }
  }

  public let horizontalSpacing: CGFloat
  public let verticalSpacing: CGFloat

  public init(
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
    proposal: PlacementProposedViewSize,
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

      if (calculatedSize.width + offsetX + horizontalSpacing) >= bounds.width {
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

      offsetX += calculatedSize.width

      if currentLine.height < calculatedElement.size.height {
        currentLine.height = calculatedElement.size.height
      }

    }

    currentLine.width = offsetX
    cache.lines.append(currentLine)

    let size = cache.calculateSize(verticalSpacing: verticalSpacing)

    return size
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: PlacementProposedViewSize,
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
          anchor: .topLeading,
          proposal: .init(width: element.size.width, height: element.size.height)
        )

        cursorX += element.size.width + horizontalSpacing

      }

      cursorX = 0
      cursorY += line.height + verticalSpacing

    }

  }

}
