//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import UIKit

class PortfolioSummaryFooterView: UIView {
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let currentValueLabel = UILabel()
    private let currentValueValue = UILabel()
    private let totalInvestmentLabel = UILabel()
    private let totalInvestmentValue = UILabel()
    private let todaysPnLLabel = UILabel()
    private let todaysPnLValue = UILabel()
    private let separator = UIView()
    private let profitAndLossRow = UIControl()
    private let profitAndLossLabel = UILabel()
    private let profitAndLossValue = UILabel()
    private let expandIcon = UIImageView()
    private var expanded = false
    private var model: PortfolioSummaryDisplayModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = .clear
        layer.masksToBounds = true
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])

        // hidden when collapsed
        let topRows = UIStackView()
        topRows.axis = .vertical
        topRows.spacing = 8
        topRows.addArrangedSubview(row(label: currentValueLabel, value: currentValueValue, labelText: "Current value*"))
        topRows.addArrangedSubview(row(label: totalInvestmentLabel, value: totalInvestmentValue, labelText: "Total investment*"))
        topRows.addArrangedSubview(row(label: todaysPnLLabel, value: todaysPnLValue, labelText: "Today’s Profit & Loss*"))
        stackView.addArrangedSubview(topRows)
        
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(separator)
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1)
        ])

        // Expandable row
        profitAndLossRow.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        profitAndLossRow.translatesAutoresizingMaskIntoConstraints = false
        profitAndLossRow.heightAnchor.constraint(equalToConstant: 32).isActive = true
        profitAndLossRow.isUserInteractionEnabled = true

        let profitStack = UIStackView(arrangedSubviews: [profitAndLossLabel, UIView(), profitAndLossValue, expandIcon])
        profitStack.axis = .horizontal
        profitStack.spacing = 8
        profitStack.alignment = .center
        profitAndLossLabel.text = "Profit & Loss*"
        profitAndLossLabel.font = .preferredFont(forTextStyle: .body)
        profitAndLossValue.font = .preferredFont(forTextStyle: .body)
        expandIcon.image = UIImage(systemName: "chevron.up")
        expandIcon.tintColor = .secondaryLabel
        expandIcon.contentMode = .scaleAspectFit
        expandIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        expandIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        profitStack.translatesAutoresizingMaskIntoConstraints = false
        profitAndLossRow.addSubview(profitStack)
        NSLayoutConstraint.activate([
            profitStack.leadingAnchor.constraint(equalTo: profitAndLossRow.leadingAnchor),
            profitStack.trailingAnchor.constraint(equalTo: profitAndLossRow.trailingAnchor),
            profitStack.topAnchor.constraint(equalTo: profitAndLossRow.topAnchor),
            profitStack.bottomAnchor.constraint(equalTo: profitAndLossRow.bottomAnchor)
        ])
        stackView.addArrangedSubview(profitAndLossRow)

        collapse(animated: false)
    }

    private func row(label: UILabel, value: UILabel, labelText: String) -> UIStackView {
        label.text = labelText
        label.font = .preferredFont(forTextStyle: .body)
        value.font = .preferredFont(forTextStyle: .body)
        let stack = UIStackView(arrangedSubviews: [label, UIView(), value])
        stack.axis = .horizontal
        return stack
    }

    func configure(with model: PortfolioSummaryDisplayModel, expanded: Bool = false) {
        self.model = model
        currentValueValue.text = model.currentValue
        totalInvestmentValue.text = model.totalInvestment
        todaysPnLValue.text = model.todaysPnL
        profitAndLossValue.text = "\(model.profitAndLoss) (\(model.profitAndLossPercent))"
        profitAndLossValue.textColor = model.isProfit ? .systemGreen : .systemRed
        todaysPnLValue.textColor = model.isTodaysProfit ? .systemGreen : .systemRed
        self.expanded = expanded
        updateExpandedState(animated: false)
    }

    @objc private func toggle() {
        expanded.toggle()
        updateExpandedState(animated: true)
    }

    private func updateExpandedState(animated: Bool) {
        guard stackView.arrangedSubviews.count >= 2 else { return }
        let topRows = stackView.arrangedSubviews.first
        let sep = stackView.arrangedSubviews[1]
        if expanded {
            topRows?.isHidden = false
            sep.isHidden = false
            expandIcon.image = UIImage(systemName: "chevron.down")
        } else {
            topRows?.isHidden = true
            sep.isHidden = true
            expandIcon.image = UIImage(systemName: "chevron.up")
        }
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
    
    private func collapse(animated: Bool) {
        expanded = false
        updateExpandedState(animated: animated)
    }
}
