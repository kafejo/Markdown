//
//  MarkdownExpressions.swift
//  Markdown
//
//  Created by Aleš Kocur on 07/03/2018.
//

import Foundation


class MarkdownExpressions {
    private typealias EditAction = (inout NSMutableAttributedString, NSRange) -> Void
    private typealias LevelEditAction = (inout NSMutableAttributedString, NSRange, Int) -> Void

    // MARK: - Strong

    /*
     Use **strong** or __two__ dashes to make text bolder
     */
    private static let strongPattern = "(\\*\\*|__)(.+?)(\\1)"

    class func strongExpression(attributes: [NSAttributedStringKey: Any]) -> MarkExpression {
        return enclosedExpression(pattern: strongPattern) { (range, mutableContent) in
            mutableContent.addAttributes(attributes, range: range)
        }
    }

    // MARK: - Emphasis

    /*
     Use *emphasized* or _two_ dashes to emphasize text
     */
    private static let emphasisPattern = "(\\*|_)(.+?)(\\1)"

    class func emphasisExpression(attributes: [NSAttributedStringKey: Any]) -> MarkExpression {
        return enclosedExpression(pattern: emphasisPattern) { (range, mutableContent) in
            mutableContent.addAttributes(attributes, range: range)
        }
    }

    // MARK: - Monospace
    private static let monospacePattern = "(`+)(\\s*.*?[^`]\\s*)(\\1)(?!`)"

    class func monospaceExpression(attributes: [NSAttributedStringKey: Any]) -> MarkExpression {
        return enclosedExpression(pattern: monospacePattern) { (range, mutableContent) in
            mutableContent.addAttributes(attributes, range: range)
        }
    }

    // MARK: - Headers

    private static let headerPattern = "^(#{1,%@})\\s+(.+)$"

    class func headerExpression(attributes: [[NSAttributedStringKey: Any]]) -> MarkExpression {
        return leadingExpression(pattern: headerPattern, maxLevel: 6, formatAction: { (mutableContent, range, level) in

            let attributeLevel = level - 1

            if attributeLevel < attributes.count {
                mutableContent.addAttributes(attributes[attributeLevel], range: range)
            }

        }, markEditAction: { (mutableContent, range, _) in
            // Just get rid of the ####
            mutableContent.deleteCharacters(in: range)
        })
    }

    // MARK: - List

    private static let listPattern = "^([\\*\\+\\-]{1,%@})\\s+(.+)$"

    class func listExpression(attributes: [[NSAttributedStringKey: Any]]) -> MarkExpression {
        return leadingExpression(pattern: listPattern, maxLevel: 6, formatAction: { (mutableContent, range, level) in

            let attributeLevel = level - 1

            if attributeLevel < attributes.count {
                mutableContent.addAttributes(attributes[attributeLevel], range: range)
            }

        }, markEditAction: { (mutableContent, range, level) in
            // Replace * with •
            let indent = NSMutableAttributedString(string: " " + String(repeating: "\t", count: level - 1) + "•  ")
            let attributeLevel = level - 1
            // TODO: - Fix DRY code
            if attributeLevel < attributes.count {
                indent.setAttributes(attributes[attributeLevel], range: NSRange(location: 0, length: indent.length))
            }

            mutableContent.replaceCharacters(in: range, with: indent)
        })
    }

    // MARK: - Helpers

    /**
     Finds an enclosing expressions (ie *test* or __test__).

     - parameter pattern: Regex expression with that have to contain 3 matchings (symbol)(content)(symbol). Symbol matches are automatically deleted.
     - parameter action: Closure for defining action on found content. Attributes are content that we want to mutate and range of content that is intended for the mutation.

     - returns: New expression
     */
    private class func enclosedExpression(pattern: String, action: @escaping (NSRange, inout NSMutableAttributedString) -> ()) -> MarkExpression {
        let expression = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())

        return MarkExpression(expression: expression) { (match, mutableContent) in
            mutableContent.deleteCharacters(in: match.range(at: 3))
            action(match.range(at: 2), &mutableContent)
            mutableContent.deleteCharacters(in: match.range(at: 1))
        }
    }

    /**
     Finds a leading expressions (ie `# Text` or `* Text`).

     - parameter pattern: Regex expression with that have to contain 2 matchings (symbol)(content).
     - parameter maxLevel: Max level of repetition (ie #### is level 4)
     - parameter formatAction: Closure for defining how to format the content in given range (ie set font)
     - parameter markEditAction: What to do with the mark expression (ie delete it)

     - returns: New expression
     */
    private class func leadingExpression(pattern: String, maxLevel: Int, formatAction: @escaping LevelEditAction, markEditAction: @escaping LevelEditAction) -> MarkExpression {
        let regexPattern = String(format: pattern, "\(maxLevel)")
        let expression = try! NSRegularExpression(pattern: regexPattern, options: [.anchorsMatchLines])

        return MarkExpression(expression: expression) { (match, mutableContent) in
            let match1Range = match.range(at: 1)
            let match2Range = match.range(at: 2)
            let level = match1Range.length

            formatAction(&mutableContent, match2Range, level)

            let markRange = NSRange(location: match1Range.location, length: match2Range.location - match1Range.location)
            markEditAction(&mutableContent, markRange, level)
        }
    }
}
