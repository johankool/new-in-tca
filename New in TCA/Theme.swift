import Foundation
import DeckUI
import SwiftUI

extension Theme {
  public static let egeniq: Theme = Theme(
    background: Color(hex: "#1C4862"),
    title: Foreground(
      color: Color(hex: "#FFFFFF"),
      font: Font.custom("Uni Sans Bold", size: 100, relativeTo: .title)
    ),
    subtitle: Foreground(
      color: Color(hex: "#FFFFFF"),
      font: Font.custom("Uni Sans Regular Italic", size: 72, relativeTo: .title2)
    ),
    body: Foreground(
      color: Color(hex: "#FFFFFF"),
      font: Font.custom("Franklin Gothic Book", size: 60, relativeTo: .body)
    ),
    code: Foreground(
      color: Color(hex: "#FFFFFF"),
      font: Font.custom("Menlo", size: 26, relativeTo: .body)
    ),
    codeHighlighted: (Color(hex: "#48728B"), Foreground(
      color: Color(hex: "#FFFFFF"),
      font: Font.custom("Menlo", size: 26, relativeTo: .body)
    ))
  )
}
