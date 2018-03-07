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
        parser.add(markExpression: strongExpression)
        parser.add(markExpression: emphasisExpression)
    }

    // MARK: - Styling

    var defaultAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular)]
    var strongAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)]
    var emphasisAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.italicSystemFont(ofSize: 17)]

    // MARK: - Strong

    private static let strongPattern = "(\\*\\*|__)(.+?)(\\1)"

    private var strongExpression: MarkExpression {
        return enclosedExpression(pattern: Markdown.strongPattern) { (range, mutableContent) in
            mutableContent.addAttributes(self.strongAttributes, range: range)
        }
    }

    // MARK: - Emphasis

    /*
     Use *emphasized* or _two_ dashes to emphasize text
     */
    private static let emphasisPattern = "(\\*|_)(.+?)(\\1)"

    private var emphasisExpression: MarkExpression {
        return enclosedExpression(pattern: Markdown.emphasisPattern) { (range, mutableContent) in
            mutableContent.addAttributes(self.emphasisAttributes, range: range)
        }
    }

    // MARK: - Helpers

    /**
     Finds an enclosing expressions (ie *test* or __test__).

     - parameter pattern: Regex expression with that have to contain 3 matchings (symbol)(content)(symbol). Symbol matches are automatically deleted.
     - parameter action: Closure for defining action on found content. Attributes are content that we want to mutate and range of content that is intended for the mutation.

     - returns: New expression
     */
    private func enclosedExpression(pattern: String, action: @escaping (NSRange, inout NSMutableAttributedString) -> ()) -> MarkExpression {
        let expression = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())

        return MarkExpression(expression: expression) { (match, mutableContent) in
            mutableContent.deleteCharacters(in: match.range(at: 3))
            action(match.range(at: 2), &mutableContent)
            mutableContent.deleteCharacters(in: match.range(at: 1))
        }
    }

    // MARK: - Public API

    public class func attributedString(fromMarkdown markdown: String) -> NSAttributedString {
        let md = Markdown()
        return md.parser.attributedString(from: markdown, defaultAttributes: md.defaultAttributes)
    }
}
