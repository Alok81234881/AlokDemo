//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import UIKit

final class HoldingCell: UITableViewCell {
    static let reuseID = "HoldingCell"

    private let symbolLabel = UILabel()
    private let qtyLabel = UILabel()
    private let avgLabel = UILabel()
    private let ltpLabel = UILabel()
    private let pnlLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        symbolLabel.font = .preferredFont(forTextStyle: .headline)
        qtyLabel.font = .preferredFont(forTextStyle: .subheadline)
        avgLabel.font = .preferredFont(forTextStyle: .subheadline)
        ltpLabel.font = .preferredFont(forTextStyle: .subheadline)
        pnlLabel.font = .preferredFont(forTextStyle: .subheadline)

        let topRow = UIStackView(arrangedSubviews: [symbolLabel, UIView(), pnlLabel])
        topRow.axis = .horizontal

        let midRow = UIStackView(arrangedSubviews: [qtyLabel, UIView()])
        midRow.axis = .horizontal

        let bottomRow = UIStackView(arrangedSubviews: [avgLabel, ltpLabel])
        bottomRow.axis = .horizontal
        bottomRow.spacing = 12

        stack.axis = .vertical
        stack.spacing = 6
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        [topRow, midRow, bottomRow].forEach { stack.addArrangedSubview($0) }

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with vm: HoldingCellViewModel) {
        symbolLabel.text = vm.symbol
        qtyLabel.text = "Qty: " + vm.qtyText
        avgLabel.text = vm.avgText
        ltpLabel.text = vm.ltpText
        pnlLabel.text = vm.pnlText
        pnlLabel.textColor = (vm.pnlText.contains("-")) ? .systemRed : .systemGreen
        accessibilize()
    }

    private func accessibilize() {
        isAccessibilityElement = true
        accessibilityLabel = [symbolLabel.text, qtyLabel.text, avgLabel.text, ltpLabel.text, pnlLabel.text]
            .compactlyJoined()
    }
}

extension Array where Element == String? {
    func compactlyJoined() -> String {
        self.compactMap { $0 }.joined(separator: ", ")
    }
}
