import SwiftUI
import WrapLayout

struct ContentView: View {
  var body: some View {
    BookWrapLayout()
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

func makeRandom() -> BookWrapLayout.Element {

  let count = (0..<20).map { $0 }
    .randomElement()!

  let text = (0..<count)
    .map { _ in
      String.randomEmoji()
    }
    .joined()

  return .init(text: text)
}

/// very beginning
@available(iOS 16, *)
struct BookWrapLayout: View {
  
  struct Element: Equatable, Identifiable {
    let id: UUID = .init()
    var text: String
  }

  private func content(_ e: Element) -> some View {
    Text(e.text)
      .padding(4)
      .background(
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .fill(.blue)
      )
  }

  @State var elements: [Element] = []

  var body: some View {

    HStack {
      VStack {

        ScrollView {
          WrapLayout {
            
            ForEach(elements) { element in
              content(element)
                .onTapGesture {
                  withAnimation(.interactiveSpring()) {
                    elements.removeAll {
                      $0.id == element.id
                    }
                  }
                }
                .transition(
                  .scale.animation(.interactiveSpring())
                )
            }
                        
            content(.init(text: "🐵"))
              .animation(.interactiveSpring(), value: elements)
            
          }
          .background(.black.opacity(0.1))

        }
              
        Spacer()

        HStack {
          Button {
            elements.append(makeRandom())
          } label: {
            Text("Add")
          }
          
          Button {
            for _ in (0..<10) {
              elements.append(makeRandom())
            }
          } label: {
            Text("Batch")
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
