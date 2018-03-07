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
        parser.add(markExpression: monospaceExpression)
        parser.add(markExpression: headerExpression)
    }

    // MARK: - Styling

    var defaultAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .regular)]
    var strongAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.systemFont(ofSize: 17.0, weight: .bold)]
    var emphasisAttributes: [NSAttributedStringKey: Any] = [.font: UIFont.italicSystemFont(ofSize: 17)]
    var monospaceAttributes: [NSAttributedStringKey: Any] = [
        .font: UIFont(name: "Courier New", size: 17.0)!,
        .foregroundColor: UIColor(white: 0.1, alpha: 1.0),
        .backgroundColor: UIColor(white: 0.95, alpha: 1.0)
    ]


    var headerAttributes: [[NSAttributedStringKey: Any]] = [
        [.font: UIFont.systemFont(ofSize: 28.0, weight: .bold)],
        [.font: UIFont.systemFont(ofSize: 24.0, weight: .bold)],
        [.font: UIFont.systemFont(ofSize: 20.0, weight: .semibold)],
        [.font: UIFont.systemFont(ofSize: 17.0, weight: .semibold)],
        [.font: UIFont.systemFont(ofSize: 16.0, weight: .semibold)],
        [.font: UIFont.systemFont(ofSize: 15.0, weight: .medium)]
    ]

    typealias EditAction = (inout NSMutableAttributedString, NSRange) -> Void
    typealias LevelEditAction = (inout NSMutableAttributedString, NSRange, Int) -> Void

    // MARK: - Strong

    /*
     Use **strong** or __two__ dashes to make text bolder
     */
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

    // MARK: - Monospace
    private static let monospacePattern = "(`+)(\\s*.*?[^`]\\s*)(\\1)(?!`)"

    private var monospaceExpression: MarkExpression {
        return enclosedExpression(pattern: Markdown.monospacePattern) { (range, mutableContent) in
            mutableContent.addAttributes(self.monospaceAttributes, range: range)
        }
    }

    // MARK: - Headers

    private static let headerPattern = "^(#{1,%@})\\s+(.+)$"

    private var headerExpression: MarkExpression {
        return leadingExpression(pattern: Markdown.headerPattern, maxLevel: 6, formatAction: { (mutableContent, range, level) in

            let attributeLevel = level - 1

            if attributeLevel < self.headerAttributes.count {
                mutableContent.addAttributes(self.headerAttributes[attributeLevel], range: range)
            }

        }, markEditAction: { (mutableContent, range, _) in
            // Just get rid of the ####
            mutableContent.deleteCharacters(in: range)
        })
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

    /**
     Finds a leading expressions (ie `# Text` or `* Text`).

     - parameter pattern: Regex expression with that have to contain 2 matchings (symbol)(content).
     - parameter maxLevel: Max level of repetition (ie #### is level 4)
     - parameter formatAction: Closure for defining how to format the content in given range (ie set font)
     - parameter markEditAction: What to do with the mark expression (ie delete it)

     - returns: New expression
     */
    private func leadingExpression(pattern: String, maxLevel: Int, formatAction: @escaping LevelEditAction, markEditAction: @escaping LevelEditAction) -> MarkExpression {
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

    // MARK: - Public API

    public class func attributedString(fromMarkdown markdown: String) -> NSAttributedString {
        let md = Markdown()
        return md.parser.attributedString(from: markdown, defaultAttributes: md.defaultAttributes)
    }
}
