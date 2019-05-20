//
//  StoreSearchListViewController.swift
//  iTunesSearch
//
//  Created by Brian Sipple on 5/18/19.
//  Copyright © 2019 Brian Sipple. All rights reserved.
//

import UIKit

class StoreSearchListViewController: UIViewController {
    @IBOutlet private weak var searchResultsTableView: UITableView!
    
    private var dataSource: TableViewDataSource<StoreItem>!
    
    private lazy var storeItemLoader = StoreItemLoader()
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    private var searchTask = DispatchWorkItem(block: {})
    private var searchScopes: [MediaType] = [.book, .podcast, .app, .music]
}



// MARK: - Computed Properties

extension StoreSearchListViewController {
    
    var currentSearchText: String {
        return searchController.searchBar.text ?? ""
    }
    
    
    var hasSearchText: Bool {
        return !currentSearchText.isEmpty
    }
    
    
    var selectedMediaType: MediaType {
        let selectedScopeIndex = searchController.searchBar.selectedScopeButtonIndex
        
        guard selectedScopeIndex > -1 else {
            return .all
        }
        
        return searchScopes[selectedScopeIndex]
    }
}


// MARK: - Lifecycle

extension StoreSearchListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupSearchBar()
        setupResultsTable()
    }
}



// MARK: - Private Helper Methods

private extension StoreSearchListViewController {
    
    func performSearch(for term: String, in scope: MediaType) {
        storeItemLoader.performSearch(for: term, in: scope) { [weak self] (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let storeItems):
                    self?.dataSource.models = storeItems.results
                    self?.searchResultsTableView.reloadData()
                case .failure(let error):
                    print(error)
                    self?.display(alertMessage: error.localizedDescription, title: "Error while fetching data")
                }
            }
        }
    }
    
    
    func setupSearchBar() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search the iTunes Store"
        searchController.searchResultsUpdater = self
        
        searchController.searchBar.scopeButtonTitles = searchScopes.map { $0.searchScopeTitle }
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    
    
    func setupResultsTable() {
        let dataSource = TableViewDataSource(
            models: [StoreItem](),
            cellReuseIdentifier: R.reuseIdentifier.storeItemCell.identifier,
            cellConfigurator: { [weak self] (storeItem, cell) in
                guard let storeItemCell = cell as? StoreItemTableViewCell else {
                    preconditionFailure("Unknown cell dequeued from table")
                }
                
                self?.configure(storeItemCell, with: storeItem)
            }
        )
        
        self.dataSource = dataSource
        searchResultsTableView.dataSource = dataSource
    }
    
    
    func configure(_ storeItemCell: StoreItemTableViewCell, with storeItem: StoreItem) {
        storeItemCell.viewModel = StoreItemTableCellViewModel(
            title: storeItem.trackName ?? storeItem.collectionName ?? "",
            subtitle: storeItem.description ?? storeItem.collectionName ?? "",
            image: UIImage(named: R.image.storeIconThumbnail.name)!
        )
        
        URLSession.shared.load(with: URLRequest(url: storeItem.artworkURL)) { [weak storeItemCell] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    storeItemCell?.viewModel?.image = UIImage(data: data)
                case .failure(let error):
                    print("Error while attempting to fetch store item image:\n\(error.localizedDescription)")
                }
            }
        }
    }
}


// MARK: - UISearchBarDelegate

extension StoreSearchListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        guard hasSearchText else { return }

        performSearch(for: currentSearchText, in: selectedMediaType)
    }
}


// MARK: - Delegate

extension StoreSearchListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard hasSearchText else { return }
        
        let searchTerm = currentSearchText
        let scope = selectedMediaType
        
        searchTask.cancel()
        searchTask = DispatchWorkItem { [weak self] in
            self?.performSearch(for: searchTerm, in: scope)
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.25, execute: searchTask)
    }
}
