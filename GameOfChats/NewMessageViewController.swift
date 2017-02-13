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
    private let collectionNode = ASCollectionNode(
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    private let disposeBag = DisposeBag()
    fileprivate var users: [User] = []
    private let updater = IGListAdapterUpdater()
    private lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(
            updater: self.updater,
            viewController: self,
            workingRangeSize: 0
        )

        adapter.dataSource = self
        return adapter
    }()

    init() {
        super.init(node: collectionNode)
        title = NSLocalizedString("new_message", comment: "")
        node.backgroundColor = .lightBackground
        adapter.setASDKCollectionNode(collectionNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
    }

    @objc private func fetchUsers() {
        DatabaseManager.shared.getUsersList()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.users.append(user)
                strongSelf.adapter.performUpdates(
                    animated: true,
                    completion: nil
                )
            }, onError: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.showAlert(
                    title: NSLocalizedString("error", comment: ""),
                    message: NSLocalizedString("unknown_error", comment: "")
                )
            })
            .addDisposableTo(disposeBag)
    }
}

extension NewMessageViewController: IGListAdapterDataSource {
    func objects(for listAdapter: IGListAdapter) -> [IGListDiffable] {
        return users
    }

    func listAdapter(_ listAdapter: IGListAdapter,
                     sectionControllerFor object: Any) -> IGListSectionController {
        return UsersListSectionController()
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        let label = UILabel()

        label.text = NSLocalizedString("no_users", comment: "")
        label.textAlignment = .center
        label.textColor = .darkText
        return label
    }
}
