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

class Parser {

    private(set) var markExpressions: [MarkExpression] = []

    func add(markExpression: MarkExpression) {
        markExpressions.append(markExpression)
    }

    func attributedString(from markdown: String, defaultAttributes: [NSAttributedStringKey: Any]? = nil) -> NSAttributedString {
        // Apply default attributes to the whole content
        let attributed = NSAttributedString(string: markdown, attributes: defaultAttributes)
        return attributedString(from: attributed)
    }

    /// Applies mark expressions on given markdowned string
    func attributedString(from markdown: NSAttributedString) -> NSAttributedString {
        var mutableContent = NSMutableAttributedString(attributedString: markdown)

        for markExpression in markExpressions {
            findAndApplyAllOccurences(of: markExpression, mutableContent: &mutableContent)
        }

        return mutableContent
    }

    private func findAndApplyAllOccurences(of markExpression: MarkExpression, mutableContent: inout NSMutableAttributedString) {
        var location = 0
        /// Iterate every match and do adjustments
        while let match = markExpression.expression.firstMatch(in: mutableContent.string, options: [.withoutAnchoringBounds], range: NSRange(location: location, length: mutableContent.length - location)) {

            let oldLength = mutableContent.length
            markExpression.action(match, &mutableContent)
            let newLength = mutableContent.length
            // Calculate location for next range to search
            location = match.range.location + match.range.length + newLength - oldLength
        }
    }
}
