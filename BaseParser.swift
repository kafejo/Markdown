//
//  BaseParser.swift
//  Markdown
//
//  Created by Aleš Kocur on 06/03/2018.
//

import Foundation

struct MarkExpression {
    let expression: NSRegularExpression
    let action: (NSTextCheckingResult, inout NSMutableAttributedString) -> Void
}

class BaseParser {

    private(set) var markExpressions: [MarkExpression] = []

    func attributedString(from markdown: String, baseAttributes: [NSAttributedStringKey: Any]? = nil) -> NSAttributedString {
        let attributed = NSAttributedString(string: markdown, attributes: baseAttributes)
        return attributedString(from: attributed)
    }

    func attributedString(from markdown: NSAttributedString) -> NSAttributedString {
        var mutableContent = NSMutableAttributedString(attributedString: markdown)

        for markExpression in markExpressions {
            var location = 0

            while let match = markExpression.expression.firstMatch(in: mutableContent.string, options: [.withoutAnchoringBounds], range: NSRange(location: location, length: mutableContent.length - location)) {

                let oldLength = mutableContent.length
                markExpression.action(match, &mutableContent)
                let newLength = mutableContent.length
                location = match.range.location + match.range.length + newLength - oldLength
            }
        }

        return mutableContent
    }
}
