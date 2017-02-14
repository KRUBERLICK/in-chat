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
    let collectionNode = ASCollectionNode(
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    let disposeBag = DisposeBag()
    var users: [User] = []
    let updater = IGListAdapterUpdater()

    lazy var adapter: IGListAdapter = {
        let adapter = IGListAdapter(
            updater: self.updater,
            viewController: self,
            workingRangeSize: 0
        )

        adapter.dataSource = self
        return adapter
    }()

    let presentationManager: PresentationManager
    let databaseManager: DatabaseManager

    init(presentationManager: PresentationManager,
         databaseManager: DatabaseManager) {
        self.presentationManager = presentationManager
        self.databaseManager = databaseManager
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

    func fetchUsers() {
        databaseManager.getUsersList()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] user in
                self?.users.append(user)
                self?.adapter.performUpdates(
                    animated: true,
                    completion: nil
                )
            }, onError: { [weak self] _ in
                self?.showAlert(
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
        return presentationManager.getUsersListSectionController()
    }

    func emptyView(for listAdapter: IGListAdapter) -> UIView? {
        let label = UILabel()

        label.text = NSLocalizedString("no_users", comment: "")
        label.textAlignment = .center
        label.textColor = .darkText
        return label
    }
}
