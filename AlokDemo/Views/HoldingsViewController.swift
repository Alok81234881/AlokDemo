//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import UIKit

final class HoldingsViewController: UIViewController, HoldingsListViewModelDelegate {
    private let viewModel: HoldingsListViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    private let profitFooterView = ProfitLossFooterView()

    init(viewModel: HoldingsListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupFooter()
        setupTable()
        setupFooterToggle()

        viewModel.load { [weak self] in
            self?.reloadUI()
        }
    }

    // MARK: - Setup

    private func setupFooter() {
        profitFooterView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profitFooterView)

        NSLayoutConstraint.activate([
            profitFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profitFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profitFooterView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: profitFooterView.topAnchor)
        ])

        tableView.register(HoldingCell.self, forCellReuseIdentifier: HoldingCell.reuseID)
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        refreshControl.addTarget(self, action: #selector(pulled), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func setupFooterToggle() {
        profitFooterView.onToggle = { [weak self] in
            guard let self = self else { return }
            self.viewModel.isSummaryExpanded.toggle()
            self.updateFooter()
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    // MARK: - UI Updates

    private func reloadUI() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        updateFooter()
        if case .error(let message) = viewModel.state {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func updateFooter() {
        profitFooterView.configure(with: viewModel.summary,
                                   expanded: viewModel.isSummaryExpanded)
    }

    @objc private func pulled() {
        viewModel.load { [weak self] in
            self?.reloadUI()
        }
    }

    // MARK: - HoldingsListViewModelDelegate
    func holdingsListViewModel(_ viewModel: HoldingsListViewModel,
                               didUpdateState state: State) {
        reloadUI()
    }
}

// MARK: - UITableViewDataSource
extension HoldingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HoldingCell.reuseID,
                                                 for: indexPath) as! HoldingCell
        let holding = viewModel.holding(at: indexPath.row)
        cell.configure(with: HoldingCellViewModel(holding))
        return cell
    }
}

