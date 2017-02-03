//
//  NewMessageViewController.swift
//  InChat
//
//  Created by Daniel Ilchishyn on 2/2/17.
//  Copyright © 2017 KRUBERLICK. All rights reserved.
//

import AsyncDisplayKit
import RxSwift

class NewMessageViewController: ASViewController<ASDisplayNode> {
    private let tableNode = ASTableNode(style: .plain)
    private var disposeBag = DisposeBag()
    fileprivate var users: [User] = []
    private let activityIndicatorView = UIActivityIndicatorView(
        activityIndicatorStyle: .gray
    )
    private let refreshControl = UIRefreshControl()

    init() {
        super.init(node: tableNode)
        title = NSLocalizedString("new_message", comment: "")
        tableNode.dataSource = self
        tableNode.delegate = self
        node.backgroundColor = .lightBackground
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableNode.view.separatorStyle = .none
        view.addSubview(activityIndicatorView)
        activityIndicatorView.frame = CGRect(x: tableNode.frame.midX - 25,
                                             y: tableNode.frame.midY - 70,
                                             width: 50,
                                             height: 50)
        tableNode.view.addSubview(refreshControl)
        refreshControl.addTarget(self,
                                 action: #selector(NewMessageViewController.refreshFeed),
                                 for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicatorView.startAnimating()
        fetchUsers()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }

    @objc private func fetchUsers() {
        DatabaseManager.shared.getUsersList()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.activityIndicatorView.stopAnimating()
                strongSelf.refreshControl.endRefreshing()
                strongSelf.users.append(user)
                strongSelf.tableNode.performBatch(animated: true, updates: {
                    strongSelf.tableNode
                        .insertRows(at: [IndexPath(
                            row: strongSelf.users.count - 1,
                            section: 0)], with: .fade)
                }, completion: nil)
            }, onError: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.activityIndicatorView.stopAnimating()
                strongSelf.refreshControl.endRefreshing()
            })
            .addDisposableTo(disposeBag)
    }

    @objc private func refreshFeed() {
        users = []
        tableNode.reloadData {
            self.perform(#selector(NewMessageViewController.fetchUsers),
                         with: nil,
                         afterDelay: 0)
        }
    }
}

extension NewMessageViewController: ASTableDataSource, ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode,
                   numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableNode(_ tableNode: ASTableNode,
                   nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        let user = users[indexPath.row]
        return {
            let cellNode = UserCellNode(user: user)

            //TODO: Setup cell tap callback

            return cellNode
        }
    }

    func tableNode(_ tableNode: ASTableNode,
                   constrainedSizeForRowAt indexPath: IndexPath) -> ASSizeRange {
        let size = CGSize(width: tableNode.bounds.width, height: 70)

        return ASSizeRangeMake(size)
    }
}
