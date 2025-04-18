//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
public import SignalServiceKit

open class ContactTableViewCell: UITableViewCell, ReusableTableViewCell {

    open class var reuseIdentifier: String { "ContactTableViewCell" }

    private let cellView = ContactCellView()

    public var tooltipTailReferenceView: UIView { return cellView.tooltipTailReferenceView }

    public override var accessoryView: UIView? {
        didSet {
            owsFailDebug("Use ows_setAccessoryView instead.")
        }
    }

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        self.preservesSuperviewLayoutMargins = true
        self.contentView.preservesSuperviewLayoutMargins = true

        contentView.addSubview(cellView)
        cellView.autoPinWidthToSuperviewMargins()
        cellView.autoPinHeightToSuperview(withMargin: 7)
    }

    public func configureWithSneakyTransaction(address: SignalServiceAddress,
                                               localUserDisplayMode: LocalUserDisplayMode) {
        SSKEnvironment.shared.databaseStorageRef.read { transaction in
            configure(address: address,
                      localUserDisplayMode: localUserDisplayMode,
                      transaction: transaction)
        }
    }

    public func configure(address: SignalServiceAddress,
                          localUserDisplayMode: LocalUserDisplayMode,
                          transaction: DBReadTransaction) {
        let configuration = ContactCellConfiguration(address: address,
                                                     localUserDisplayMode: localUserDisplayMode)
        configure(configuration: configuration, transaction: transaction)
    }

    public func configure(thread: TSContactThread,
                          localUserDisplayMode: LocalUserDisplayMode,
                          transaction: DBReadTransaction) {
        let configuration = ContactCellConfiguration(address: thread.contactAddress,
                                                     localUserDisplayMode: localUserDisplayMode)
        configure(configuration: configuration, transaction: transaction)
    }

    open func configure(
        configuration: ContactCellConfiguration,
        transaction: DBReadTransaction
    ) {
        OWSTableItem.configureCell(self)
        cellView.configure(configuration: configuration, transaction: transaction)
    }

    public override func prepareForReuse() {
        super.prepareForReuse()

        cellView.reset()

        self.accessoryType = .none
    }
}
