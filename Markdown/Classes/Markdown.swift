//
//  Markdown.swift
//  Markdown
//
//  Created by Aleš Kocur on 06/03/2018.
//

import Foundation

public class Markdown {
    let parser = BaseParser()

    init() {
        parser.add(markExpression: boldExpression)
    }

    // MARK: - Styling

    var defaultAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular)]
    var boldAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)]

    // MARK: - Rules

    private static let boldPattern = "(\\*\\*|__)(.+?)(\\1)"

    private var boldExpression: MarkExpression {
        let expression = try! NSRegularExpression(pattern: Markdown.boldPattern, options: NSRegularExpression.Options())

        return MarkExpression(expression: expression) { (match, mutableContent) in
            mutableContent.deleteCharacters(in: match.range(at: 3))
            mutableContent.addAttributes(self.boldAttributes, range: match.range(at: 2))
            mutableContent.deleteCharacters(in: match.range(at: 1))
        }
    }

    // MARK: - Public API

    public class func attributedString(fromMarkdown markdown: String) -> NSAttributedString {
        let md = Markdown()
        return md.parser.attributedString(from: markdown, defaultAttributes: md.defaultAttributes)
    }
}
