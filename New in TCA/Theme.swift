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
    code: CodeTheme(
      font: Font.custom("Menlo", size: 26, relativeTo: .body),
      plainTextColor: Color(hex: "#FFFFFF"),
      backgroundColor: .clear,
      tokenColors: [
        .keyword:       Color(hex: "#FF79B3"),
        .string:        Color(hex: "#FF8170"),
        .type:          Color(hex: "#DABAFF"),
        .call:          Color(hex: "#78C2B4"),
        .number:        Color(hex: "#DAC87C"),
        .comment:       Color(hex: "#808B98"),
        .property:      Color(hex: "#79C2B4"),
        .dotAccess:     Color(hex: "#79C2B4"),
        .preprocessing: Color(hex: "#FFA14F")
      ]
    ),
    codeHighlighted: (Color(hex: "#48728B"), Foreground(
      color: Color(hex: "#FFFFFF"),
      font: Font.custom("Menlo", size: 26, relativeTo: .body)
    ))
  )
}
