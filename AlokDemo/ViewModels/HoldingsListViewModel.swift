//
//  AppDelegate.swift
//  AlokDemo
//
//  Created by Alok SIngh on 18/08/25.
//

import Foundation

protocol HoldingsListViewModelDelegate: AnyObject {
    func holdingsListViewModel(_ viewModel: HoldingsListViewModel, didUpdateState state: State)
}

final class HoldingsListViewModel {
    
    private let api: APIClientProtocol
    private let offline: OfflineHoldingsStoreProtocol
    private(set) var holdings: [Holding] = []
    private(set) var summary: PortfolioSummary = .init(currentValue: 0, totalInvestment: 0, totalPnL: 0, todaysPnL: 0)
    var state: State = .idle
    var isSummaryExpanded: Bool = false

    weak var delegate: HoldingsListViewModelDelegate?

    init(api: APIClientProtocol = APIClient(), offline: OfflineHoldingsStoreProtocol = OfflineHoldingsStore()) {
        self.api = api
        self.offline = offline
    }

    func load(completion: (() -> Void)? = nil) {
        state = .loading
        delegate?.holdingsListViewModel(self, didUpdateState: state)
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.api.fetchHoldings { result in
                switch result {
                case .success(let response):
                    self.holdings = response.data.userHolding as [Holding]
                    self.summary = PortfolioSummary.compute(from: response.data.userHolding as [Holding])
                    self.state = .loaded
                    try? self.offline.save(response)
                case .failure(let error):
                    // For offline
                    if let cached = self.offline.load() {
                        self.holdings = cached.data.userHolding as [Holding]
                        self.summary = PortfolioSummary.compute(from: cached.data.userHolding as [Holding])
                        self.state = .loaded
                    } else {
                        self.state = .error(error.localizedDescription)
                    }
                }
                DispatchQueue.main.async {
                    self.delegate?.holdingsListViewModel(self, didUpdateState: self.state)
                    completion?()
                }
            }
        }
    }

    func numberOfRows() -> Int { holdings.count }
    func holding(at index: Int) -> Holding { holdings[index] }
}
