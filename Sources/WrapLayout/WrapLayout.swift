import SwiftUI

public struct WrapLayout: Layout {

  /// Horizontal alignment of each line within the layout's available width.
  public enum LineHorizontalAlignment: Sendable, Hashable {
    case leading
    case center
    case trailing
  }

  /// Vertical alignment of elements within a single line.
  public enum LineVerticalAlignment: Sendable, Hashable {
    case top
    case center
    case bottom
  }

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
      let maxWidth = lines.lazy.map(\.width).max() ?? 0
      let totalHeight = lines.reduce(0) { $0 + $1.height }
      let totalVerticalSpacing = CGFloat(max(0, lines.count - 1)) * verticalSpacing
      return CGSize(width: maxWidth, height: totalHeight + totalVerticalSpacing)
    }
  }

  public let horizontalSpacing: CGFloat
  public let verticalSpacing: CGFloat
  public let lineHorizontalAlignment: LineHorizontalAlignment
  public let lineVerticalAlignment: LineVerticalAlignment

  public init(
    horizontalSpacing: CGFloat = 4,
    verticalSpacing: CGFloat = 4,
    lineHorizontalAlignment: LineHorizontalAlignment = .leading,
    lineVerticalAlignment: LineVerticalAlignment = .top
  ) {
    self.horizontalSpacing = horizontalSpacing
    self.verticalSpacing = verticalSpacing
    self.lineHorizontalAlignment = lineHorizontalAlignment
    self.lineVerticalAlignment = lineVerticalAlignment
  }

  public func makeCache(subviews: Subviews) -> CacheStorage {
    return .init()
  }

  public func sizeThatFits(
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout CacheStorage
  ) -> CGSize {

    let maxWidth = proposal.width ?? .infinity
    let maxHeight = proposal.height ?? .infinity

    cache.lines = []

    var currentLine = CacheStorage.Line()

    for view in subviews {

      let size = view.sizeThatFits(.init(width: maxWidth, height: maxHeight))

      // Width of the current line if we appended this element to it.
      let candidateWidth: CGFloat
      if currentLine.elements.isEmpty {
        candidateWidth = size.width
      } else {
        candidateWidth = currentLine.width + horizontalSpacing + size.width
      }

      // Break to a new line only when the current line already has at least
      // one element. A single element wider than maxWidth still occupies its
      // own line rather than being skipped.
      if !currentLine.elements.isEmpty, candidateWidth > maxWidth {
        cache.lines.append(currentLine)
        currentLine = CacheStorage.Line()
      }

      let element = CacheStorage.CalculatedElement(element: view, size: size)

      if currentLine.elements.isEmpty {
        currentLine.width = size.width
      } else {
        currentLine.width += horizontalSpacing + size.width
      }
      currentLine.height = max(currentLine.height, size.height)
      currentLine.elements.append(element)
    }

    if !currentLine.elements.isEmpty {
      cache.lines.append(currentLine)
    }

    return cache.calculateSize(verticalSpacing: verticalSpacing)
  }

  public func placeSubviews(
    in bounds: CGRect,
    proposal: ProposedViewSize,
    subviews: Subviews,
    cache: inout CacheStorage
  ) {

    var cursorY: CGFloat = 0

    for line in cache.lines {

      let remainingWidth = max(bounds.width - line.width, 0)

      let lineOffsetX: CGFloat
      switch lineHorizontalAlignment {
      case .leading:
        lineOffsetX = 0
      case .center:
        lineOffsetX = remainingWidth / 2
      case .trailing:
        lineOffsetX = remainingWidth
      }

      var cursorX: CGFloat = bounds.minX + lineOffsetX

      for element in line.elements {

        let elementY: CGFloat
        switch lineVerticalAlignment {
        case .top:
          elementY = bounds.minY + cursorY
        case .center:
          elementY = bounds.minY + cursorY + (line.height - element.size.height) / 2
        case .bottom:
          elementY = bounds.minY + cursorY + (line.height - element.size.height)
        }

        element.element.place(
          at: .init(x: cursorX, y: elementY),
          anchor: .topLeading,
          proposal: .init(width: element.size.width, height: element.size.height)
        )

        cursorX += element.size.width + horizontalSpacing
      }

      cursorY += line.height + verticalSpacing
    }
  }
}

#if DEBUG

private struct WrapLayoutPreviewTag: View {
  let text: String
  let color: Color

  init(_ text: String, color: Color = .blue) {
    self.text = text
    self.color = color
  }

  var body: some View {
    Text(text)
      .padding(.horizontal, 8)
      .padding(.vertical, 4)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(color.opacity(0.2))
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .stroke(color, lineWidth: 1)
      )
  }
}

private struct WrapLayoutPreviewContainer<Content: View>: View {
  let title: String
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(title)
        .font(.caption)
        .foregroundStyle(.secondary)
      content()
        .background(Color.gray.opacity(0.15))
    }
  }
}

private let _previewTags = [
  "SwiftUI", "Layout", "Wrap", "Alignment", "iOS",
  "Demo", "Preview", "Tags", "Center", "Trailing",
]

@available(iOS 17.0, *)
#Preview("leading (default)") {
  ScrollView {
    WrapLayoutPreviewContainer(title: "leading (default)") {
      WrapLayout(horizontalSpacing: 8, verticalSpacing: 8) {
        ForEach(_previewTags, id: \.self) { WrapLayoutPreviewTag($0) }
      }
    }
    .padding()
  }
}

@available(iOS 17.0, *)
#Preview("center") {
  ScrollView {
    WrapLayoutPreviewContainer(title: "center") {
      WrapLayout(
        horizontalSpacing: 8,
        verticalSpacing: 8,
        lineHorizontalAlignment: .center
      ) {
        ForEach(_previewTags, id: \.self) { WrapLayoutPreviewTag($0, color: .purple) }
      }
    }
    .padding()
  }
}

@available(iOS 17.0, *)
#Preview("trailing") {
  ScrollView {
    WrapLayoutPreviewContainer(title: "trailing") {
      WrapLayout(
        horizontalSpacing: 8,
        verticalSpacing: 8,
        lineHorizontalAlignment: .trailing
      ) {
        ForEach(_previewTags, id: \.self) { WrapLayoutPreviewTag($0, color: .orange) }
      }
    }
    .padding()
  }
}

@available(iOS 17.0, *)
#Preview("vertical: center") {
  ScrollView {
    WrapLayoutPreviewContainer(title: "vertical: center (mixed heights)") {
      WrapLayout(
        horizontalSpacing: 8,
        verticalSpacing: 8,
        lineVerticalAlignment: .center
      ) {
        Text("Short").font(.caption)
        Text("Medium").font(.body)
        Text("Tall").font(.largeTitle)
        Text("Mid").font(.title3)
        Text("xs").font(.caption2)
        Text("Big").font(.title)
      }
    }
    .padding()
  }
}

@available(iOS 17.0, *)
#Preview("vertical: bottom") {
  ScrollView {
    WrapLayoutPreviewContainer(title: "vertical: bottom (mixed heights)") {
      WrapLayout(
        horizontalSpacing: 8,
        verticalSpacing: 8,
        lineVerticalAlignment: .bottom
      ) {
        Text("Short").font(.caption)
        Text("Medium").font(.body)
        Text("Tall").font(.largeTitle)
        Text("Mid").font(.title3)
        Text("xs").font(.caption2)
        Text("Big").font(.title)
      }
    }
    .padding()
  }
}

@available(iOS 17.0, *)
#Preview("combined alignments") {
  ScrollView {
    VStack(alignment: .leading, spacing: 24) {
      WrapLayoutPreviewContainer(title: "center + vertical center") {
        WrapLayout(
          horizontalSpacing: 8,
          verticalSpacing: 8,
          lineHorizontalAlignment: .center,
          lineVerticalAlignment: .center
        ) {
          Text("A").font(.caption)
          Text("Bb").font(.body)
          Text("CcC").font(.largeTitle)
          Text("Dd").font(.title3)
          Text("E").font(.caption2)
        }
      }

      WrapLayoutPreviewContainer(title: "trailing + bottom") {
        WrapLayout(
          horizontalSpacing: 8,
          verticalSpacing: 8,
          lineHorizontalAlignment: .trailing,
          lineVerticalAlignment: .bottom
        ) {
          ForEach(_previewTags.prefix(6), id: \.self) {
            WrapLayoutPreviewTag($0, color: .green)
          }
        }
      }
    }
    .padding()
  }
}

#endif
