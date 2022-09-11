import SwiftUI
import DeckUI

@main
struct New_in_TCAApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}

struct ContentView: View {
  var body: some View {
    Presenter(deck: self.deck, showCamera: true, cameraConfig: .init(alignment: .topTrailing))
  }
}
