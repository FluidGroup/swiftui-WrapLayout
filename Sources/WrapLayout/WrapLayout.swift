import SwiftUI

@available(iOS 16, *)
public struct WrapLayout: Layout {

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

extension String {
  static func randomEmoji() -> String {
    let range = 0x1F601...0x1F64F
    let ascii = range.lowerBound + Int(arc4random_uniform(UInt32(range.count)))

    var view = UnicodeScalarView()
    view.append(UnicodeScalar(ascii)!)

    let emoji = String(view)

    return emoji
  }

}

func makeRandom() -> String {

  let count = (0..<20).map { $0 }
    .randomElement()!

  return (0..<count)
    .map { _ in
      String.randomEmoji()
    }
    .joined()

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
  
  @State var elements: [String] = []

  var body: some View {

    HStack {
      VStack {

        WrapLayout {
          
          ForEach(elements, id: \.self) { element in
            content(element)
              .transition(
                .scale.animation(.interactiveSpring())
              )
          }
          
          content("🐵")

        }
        .background(.black.opacity(0.1))
        
        Spacer()
        
        HStack {
          Button {
            elements.append(makeRandom())
          } label: {
            Text("Add")
          }
          
          Button {
            guard elements.isEmpty == false else { return }
            elements.removeLast()
          } label: {
            Text("Remove")
          }
          
          Button {
            guard elements.isEmpty == false else { return }
            elements.removeAll()
          } label: {
            Text("Clear")
          }
        }
        .font(.caption)
        .padding(16)

      }
              

    }
  }
}
#endif
