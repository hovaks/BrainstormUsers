//
//  TabsContainerViewController.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 23.04.21.
//

import TinyConstraints
import UIKit

// MARK: - UsersViewController

final class UsersViewController: UIViewController {
    // MARK: - Tab

    private enum Tab: Int, CaseIterable {
        case remoteUsers
        case localUsers

        var index: Int { rawValue }

        var title: String {
            switch self {
            case .remoteUsers: return "Users"
            case .localUsers: return "Saved Users"
            }
        }
    }

    // MARK: - Outlets

    @IBOutlet private var tableView: UITableView! { didSet { configureTableView() } }

    private func configureTableView() {
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.delegate = self
    }

    // MARK: - Views

    private var navigationBar: UINavigationBar! {
        navigationController?.navigationBar
    }

    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: Tab.allCases.map { $0.title })
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged(sender:)), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = selectedTab.index
        return segmentedControl
    }()

    private lazy var emptyView: UIView = {
        let emptyLabel = UILabel()
        emptyLabel.text = "No results"
        emptyLabel.textAlignment = .center
        emptyLabel.font = .preferredFont(forTextStyle: .headline)
        return emptyLabel
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureSegmentedControl()
        configureSearchController()
        configureDataSource()
    }

    private func configureSegmentedControl() {
        navigationBar.addSubview(segmentedControl)
        segmentedControl.edgesToSuperview(excluding: .bottom, insets: .init(top: 8, left: 16, bottom: 0, right: 16))
    }

    private func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search"
        searchController.automaticallyShowsCancelButton = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        UIView.animate(withDuration: 0.3) { self.segmentedControl.alpha = 1 }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIView.animate(withDuration: 0.3) { self.segmentedControl.alpha = 0 }
    }

    // MARK: - Tabs

    private var selectedTab: Tab = .remoteUsers {
        didSet {
            if !(search?.isEmpty ?? true) {
                performSearch()
            } else {
                switch selectedTab {
                case .remoteUsers: getRemoteUsers()
                case .localUsers: getLocalUsers()
                }
            }
        }
    }

    @objc
    private func segmentedControlChanged(sender: UISegmentedControl) {
        guard let tab = Tab(rawValue: sender.selectedSegmentIndex) else { return }
        selectedTab = tab
    }

    // MARK: - DataSource

    private typealias TableViewDataSource = UITableViewDiffableDataSource<Section, User>
    private typealias TableViewSnapshot = NSDiffableDataSourceSnapshot<Section, User>

    private var datasource: TableViewDataSource!
    private var users: [User] = [] { didSet { refreshTableView() } }

    private func configureDataSource() {
        datasource = TableViewDataSource(tableView: tableView) { tv, _, user in
            guard let cell = tv.dequeueReusableCell(type: UserTableViewCell.self) else { fatalError() }
            cell.user = user
            return cell
        }
    }

    private func refreshTableView() {
        tableView.backgroundView = users.isEmpty ? emptyView : nil

        var snapshot = TableViewSnapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(users, toSection: .main)
        datasource.apply(snapshot)

        tableView.visibleCells.compactMap { $0 as? UserTableViewCell }.forEach { $0.search = self.search }
    }

    // MARK: - REST

    private var isLoading = false
    private var remoteUsers: [User] = []

    private func getRemoteUsers() {
        let itemsPerPage = 20
        guard remoteUsers.count % itemsPerPage == 0 else { return }

        isLoading = true
        let nextPage = (remoteUsers.count / itemsPerPage) + 1

        UsersService.shared.getRemoteUsers(with: .init(results: itemsPerPage, page: nextPage)) { [weak self] results in
            guard let self = self else { return }
            switch results {
            case .success(let users):
                self.remoteUsers += users
                self.users = self.remoteUsers
            case .failure(let error):
                print(error)
            }
            self.isLoading = false
        }
    }

    // MARK: - Realm

    private var localUsers: [User] = UsersService.shared.getSavedUsers()

    private func getLocalUsers() {
        localUsers = UsersService.shared.getSavedUsers()
        users = localUsers
    }

    // MARK: - Search

    private var search: String? { didSet { performSearch() } }

    private func performSearch() {
        if let search = search, !search.isEmpty {
            let scope = selectedTab == .remoteUsers ? remoteUsers : localUsers
            users = scope.filter { $0.searchFields.first(where: { $0.contains(search) }) != nil }
        } else {
            users = selectedTab == .remoteUsers ? remoteUsers : localUsers
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let userDetailsVC = segue.destination as? UserDetailsViewController {
            guard let user = sender as? User else { return }
            userDetailsVC.user = user
            userDetailsVC.delegate = self
            userDetailsVC.isLocal = localUsers.contains(user)
        }
    }
}

private extension UsersViewController {
    enum Section {
        case main
    }
}

// MARK: UITableViewDelegate

extension UsersViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if !isLoading, search?.isEmpty ?? true, selectedTab == .remoteUsers,
           offsetY > contentHeight - scrollView.frame.height * 4
        { getRemoteUsers() }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        performSegue(to: UserDetailsViewController.self, sender: user)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}

// MARK: UISearchResultsUpdating

extension UsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        search = searchController.searchBar.text
    }
}

// MARK: UserDetailsViewControllerDelegate

extension UsersViewController: UserDetailsViewControllerDelegate {
    func didAdd(_ user: User) {
        if selectedTab == .localUsers { getLocalUsers() }
    }

    func didDelete(_ user: User) {
        if selectedTab == .localUsers { getLocalUsers() }
    }
}
