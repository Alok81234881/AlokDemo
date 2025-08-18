//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import UIKit

final class ProfitLossFooterView: UIView {
    var onToggle: (() -> Void)?
    
    // MARK: - UI
    private let profitLossContainer = UIStackView()
    private let profitLossLabel = UILabel()
    private let profitLossAmountLabel = UILabel()
    private let expandButton = UIButton(type: .system)
    
    private let detailsStack = UIStackView()
    private let currentValueLabel = UILabel()
    private let currentValueAmountLabel = UILabel()
    private let investmentLabel = UILabel()
    private let investmentAmountLabel = UILabel()
    private let todaysPnLLabel = UILabel()
    private let todaysPnLAmountLabel = UILabel()
    
    private let divider = UIView()
    
    // MARK: - State
    private var expanded = false
    private var currentSummary: PortfolioSummary?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }
    
    // MARK: - Setup
    private func setup() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // --- Profit & Loss row (always visible) ---
        profitLossContainer.axis = .horizontal
        profitLossContainer.alignment = .center
        profitLossContainer.distribution = .equalSpacing
        
        profitLossLabel.text = "Profit & Loss*"
        profitLossLabel.font = .systemFont(ofSize: 16)
        profitLossLabel.textColor = .label
        
        profitLossAmountLabel.font = .systemFont(ofSize: 16, weight: .medium)
        profitLossAmountLabel.textAlignment = .right
        
        expandButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        expandButton.tintColor = .label
        expandButton.addTarget(self, action: #selector(toggleTapped), for: .touchUpInside)
        
        profitLossContainer.addArrangedSubview(profitLossLabel)
        profitLossContainer.addArrangedSubview(profitLossAmountLabel)
        profitLossContainer.addArrangedSubview(expandButton)
        
        // --- Details stack (hidden until expanded) ---
        detailsStack.axis = .vertical
        detailsStack.spacing = 8
        
        currentValueLabel.text = "Current value*"
        investmentLabel.text = "Total investment*"
        todaysPnLLabel.text = "Today's Profit & Loss*"
        
        [currentValueLabel, investmentLabel, todaysPnLLabel].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .label
        }
        [currentValueAmountLabel, investmentAmountLabel, todaysPnLAmountLabel].forEach {
            $0.font = .systemFont(ofSize: 16, weight: .medium)
            $0.textAlignment = .right
        }
        
        detailsStack.addArrangedSubview(makeDetailRow(label: currentValueLabel, amount: currentValueAmountLabel))
        detailsStack.addArrangedSubview(makeDetailRow(label: investmentLabel, amount: investmentAmountLabel))
        detailsStack.addArrangedSubview(makeDetailRow(label: todaysPnLLabel, amount: todaysPnLAmountLabel))
        
        divider.backgroundColor = .systemGray4
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // --- Parent stack ---
        let parentStack = UIStackView(arrangedSubviews: [profitLossContainer, divider, detailsStack])
        parentStack.axis = .vertical
        parentStack.spacing = 8
        parentStack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(parentStack)
        NSLayoutConstraint.activate([
            parentStack.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            parentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            parentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            parentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
        
        // Start collapsed
        detailsStack.isHidden = true
        divider.isHidden = true
    }
    
    private func makeDetailRow(label: UILabel, amount: UILabel) -> UIStackView {
        let s = UIStackView(arrangedSubviews: [label, UIView(), amount])
        s.axis = .horizontal
        return s
    }
    
    // MARK: - Configure
    func configure(with summary: PortfolioSummary, expanded: Bool) {
        currentSummary = summary
        self.expanded = expanded
        
        // Update amounts
        currentValueAmountLabel.text = summary.currentValue.asRupee()
        investmentAmountLabel.text = summary.totalInvestment.asRupee()
        
        todaysPnLAmountLabel.text = summary.todaysPnL.asRupee(sign: true)
        todaysPnLAmountLabel.textColor = summary.todaysPnL >= 0 ? .systemGreen : .systemRed
        
        let totalPnL = summary.totalPnL
        let percent = summary.totalInvestment != 0 ? totalPnL / summary.totalInvestment : 0
        profitLossAmountLabel.text = totalPnL.asRupee(sign: true, showPercent: true, percent: percent)
        profitLossAmountLabel.textColor = totalPnL >= 0 ? .systemGreen : .systemRed
        
        // Expand / collapse
        detailsStack.isHidden = !expanded
        divider.isHidden = !expanded
        
        UIView.animate(withDuration: 0.25) {
            self.expandButton.transform = expanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc private func toggleTapped() {
        expanded.toggle()
        if let summary = currentSummary {
            configure(with: summary, expanded: expanded)
        }
        onToggle?()
    }
}
