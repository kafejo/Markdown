//
//  Markdown.swift
//  Markdown
//
//  Created by Aleš Kocur on 06/03/2018.
//

import Foundation

public class Markdown {
    let parser = Parser()

    init() {
        parser.add(markExpression: MarkdownExpressions.strongExpression(attributes: strongAttributes))
        parser.add(markExpression: MarkdownExpressions.emphasisExpression(attributes: emphasisAttributes))
        parser.add(markExpression: MarkdownExpressions.monospaceExpression(attributes: monospaceAttributes))
        parser.add(markExpression: MarkdownExpressions.headerExpression(attributes: headerAttributes))
    }

    // MARK: - Styles

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

    // MARK: - Public API

    public class func attributedString(fromMarkdown markdown: String) -> NSAttributedString {
        let md = Markdown()
        return md.parser.attributedString(from: markdown, defaultAttributes: md.defaultAttributes)
    }
}
