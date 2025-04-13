//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

final class PrivateStorySettingsViewController: OWSTableViewController2 {
    private let thread: TSPrivateStoryThread
    private var sortedAddresses = [SignalServiceAddress]()

    init(thread: TSPrivateStoryThread) {
        self.thread = thread
        super.init()
    }

    private func updateSortedAddresses() {
        let contactManager = SSKEnvironment.shared.contactManagerRef
        let databaseStorage = SSKEnvironment.shared.databaseStorageRef
        let storyRecipientManager = DependenciesBridge.shared.storyRecipientManager

        self.sortedAddresses = databaseStorage.read { tx in
            return contactManager.sortSignalServiceAddresses(
                failIfThrows {
                    try storyRecipientManager.fetchRecipients(forStoryThread: thread, tx: tx)
                }.map { $0.address },
                transaction: tx
            )
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateBarButtons()
        updateSortedAddresses()
        updateTableContents()
    }

    private func updateBarButtons() {
        title = thread.name

        navigationItem.rightBarButtonItem = .systemItem(.edit) { [weak self] in
            self?.editPressed()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: ContactTableViewCell.reuseIdentifier)

        updateTableContents()
    }

    private var isShowingAllViewers = false
    private func updateTableContents(shouldReload: Bool = true) {
        let contents = OWSTableContents()
        defer { self.setContents(contents, shouldReload: shouldReload) }

        let viewersSection = OWSTableSection()
        viewersSection.headerTitle = OWSLocalizedString(
            "STORY_SETTINGS_WHO_CAN_VIEW_THIS_HEADER",
            comment: "Section header for the 'viewers' section on the 'story settings' view"
        )
        // TODO: Add 'learn more' sheet button
        viewersSection.footerTitle = OWSLocalizedString(
            "STORY_SETTINGS_WHO_CAN_VIEW_THIS_FOOTER",
            comment: "Section footer for the 'viewers' section on the 'story settings' view"
        )
        viewersSection.separatorInsetLeading = Self.cellHInnerMargin + CGFloat(AvatarBuilder.smallAvatarSizePoints) + ContactCellView.avatarTextHSpacing
        contents.add(viewersSection)

        // "Add Viewers" cell.
        viewersSection.add(OWSTableItem(customCellBlock: {
            let cell = OWSTableItem.newCell()
            cell.preservesSuperviewLayoutMargins = true
            cell.contentView.preservesSuperviewLayoutMargins = true

            let iconView = OWSTableItem.buildIconInCircleView(
                icon: .groupInfoAddMembers,
                iconSize: AvatarBuilder.smallAvatarSizePoints,
                innerIconSize: 20,
                iconTintColor: Theme.primaryTextColor
            )

            let rowLabel = UILabel()
            rowLabel.text = OWSLocalizedString(
                "PRIVATE_STORY_SETTINGS_ADD_VIEWER_BUTTON",
                comment: "Button to add a new viewer on the 'private story settings' view"
            )
            rowLabel.textColor = Theme.primaryTextColor
            rowLabel.font = OWSTableItem.primaryLabelFont
            rowLabel.lineBreakMode = .byTruncatingTail

            let contentRow = UIStackView(arrangedSubviews: [ iconView, rowLabel ])
            contentRow.spacing = ContactCellView.avatarTextHSpacing

            cell.contentView.addSubview(contentRow)
            contentRow.autoPinWidthToSuperviewMargins()
            contentRow.autoPinHeightToSuperview(withMargin: 7)

            return cell
        }, actionBlock: { [weak self] in
            self?.showAddViewerView()
        }))

        let totalViewersCount = sortedAddresses.count
        let maxViewersToShow = 6

        var viewersToRender = sortedAddresses
        let hasMoreViewers = !isShowingAllViewers && viewersToRender.count > maxViewersToShow
        if hasMoreViewers {
            viewersToRender = Array(viewersToRender.prefix(maxViewersToShow - 1))
        }

        for viewerAddress in viewersToRender {
            viewersSection.add(OWSTableItem(customCellBlock: { [weak self] in
                guard let cell = self?.tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier) as? ContactTableViewCell else {
                    owsFailDebug("Missing cell.")
                    return UITableViewCell()
                }

                SSKEnvironment.shared.databaseStorageRef.read { transaction in
                    let configuration = ContactCellConfiguration(address: viewerAddress, localUserDisplayMode: .asLocalUser)
                    cell.configure(configuration: configuration, transaction: transaction)
                }

                return cell
            }, actionBlock: { [weak self] in
                self?.didSelectViewer(viewerAddress)
            }))
        }

        if hasMoreViewers {
            let expandedViewerIndices = (viewersToRender.count..<totalViewersCount).map {
                // offset by one to account for the "Add viewers" row.
                IndexPath(row: $0 + 1, section: contents.sections.count - 1)
            }

            viewersSection.add(OWSTableItem(
                customCellBlock: {
                    let cell = OWSTableItem.newCell()
                    cell.preservesSuperviewLayoutMargins = true
                    cell.contentView.preservesSuperviewLayoutMargins = true

                    let iconView = OWSTableItem.buildIconInCircleView(
                        icon: .groupInfoShowAllMembers,
                        iconSize: AvatarBuilder.smallAvatarSizePoints,
                        innerIconSize: 20,
                        iconTintColor: Theme.primaryTextColor
                    )

                    let rowLabel = UILabel()
                    rowLabel.text = CommonStrings.seeAllButton
                    rowLabel.textColor = Theme.primaryTextColor
                    rowLabel.font = OWSTableItem.primaryLabelFont
                    rowLabel.lineBreakMode = .byTruncatingTail

                    let contentRow = UIStackView(arrangedSubviews: [ iconView, rowLabel ])
                    contentRow.spacing = ContactCellView.avatarTextHSpacing

                    cell.contentView.addSubview(contentRow)
                    contentRow.autoPinWidthToSuperviewMargins()
                    contentRow.autoPinHeightToSuperview(withMargin: 7)

                    return cell
                },
                actionBlock: { [weak self] in
                    self?.showAllViewers(revealingIndices: expandedViewerIndices)
                }
            ))
        }

        let repliesSection = OWSTableSection()
        repliesSection.headerTitle = StoryStrings.repliesAndReactionsHeader
        repliesSection.footerTitle = StoryStrings.repliesAndReactionsFooter
        contents.add(repliesSection)

        repliesSection.add(.switch(
            withText: StoryStrings.repliesAndReactionsToggle,
            isOn: { [thread] in thread.allowsReplies },
            target: self,
            selector: #selector(didToggleReplies(_:))
        ))

        let deleteSection = OWSTableSection()
        contents.add(deleteSection)
        deleteSection.add(.actionItem(
            withText: OWSLocalizedString(
                "PRIVATE_STORY_SETTINGS_DELETE_BUTTON",
                comment: "Button to delete the story on the 'private story settings' view"
            ),
            textColor: .ows_accentRed,
            accessibilityIdentifier: nil,
            actionBlock: { [weak self] in
                self?.deleteStoryWithConfirmation()
            }))
    }

    private func deleteStoryWithConfirmation() {
        let format = OWSLocalizedString(
            "PRIVATE_STORY_SETTINGS_DELETE_CONFIRMATION_FORMAT",
            comment: "Action sheet title confirming deletion of a private story on the 'private story settings' view. Embeds {{ $1%@ private story name }}"
        )

        let actionSheet = ActionSheetController(
            message: String.localizedStringWithFormat(format, thread.name)
        )
        actionSheet.addAction(OWSActionSheets.cancelAction)
        actionSheet.addAction(.init(
            title: OWSLocalizedString(
                "PRIVATE_STORY_SETTINGS_DELETE_BUTTON",
                comment: "Button to delete the story on the 'private story settings' view"
            ),
            style: .destructive,
            handler: { [weak self] _ in
                self?.deleteStory()
            }))
        presentActionSheet(actionSheet)
    }

    private func deleteStory() {
        guard let dlistIdentifier = thread.distributionListIdentifier else {
            return owsFailDebug("Missing dlist identifier for thread \(thread.logString)")
        }

        ModalActivityIndicatorViewController.present(fromViewController: self, canCancel: false) { modal in
            SSKEnvironment.shared.databaseStorageRef.asyncWrite { transaction in
                StoryFinder.enumerateStoriesForContext(self.thread.storyContext, transaction: transaction) { storyMessage, _ in
                    storyMessage.remotelyDelete(for: self.thread, transaction: transaction)
                }

                // Because we're sending delete messages to this thread, we need to keep it
                // (and its list of recipients!) in the database even though it will no
                // longer be rendered to the user. We'll clean it up later when we clean up
                // records from storage service.
                self.thread.updateWithStoryViewMode(
                    .disabled,
                    storyRecipientIds: .noChange,
                    updateStorageService: true,
                    transaction: transaction
                )

                DependenciesBridge.shared.privateStoryThreadDeletionManager.recordDeletedAtTimestamp(
                    Date.ows_millisecondTimestamp(),
                    forDistributionListIdentifier: dlistIdentifier,
                    tx: transaction
                )

                transaction.addSyncCompletion {
                    Task { @MainActor in
                        modal.dismiss {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }

    private func showAddViewerView() {
        let vc = PrivateStoryAddRecipientsSettingsViewController(thread: thread)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAllViewers(revealingIndices: [IndexPath]) {
        isShowingAllViewers = true

        if let firstIndex = revealingIndices.first {
            tableView.beginUpdates()

            // Delete the "See All" row.
            tableView.deleteRows(at: [IndexPath(row: firstIndex.row, section: firstIndex.section)], with: .bottom)

            // Insert the new rows.
            tableView.insertRows(at: revealingIndices, with: .top)

            updateTableContents(shouldReload: false)
            tableView.endUpdates()
        } else {
            updateTableContents()
        }
    }

    private func didSelectViewer(_ address: SignalServiceAddress) {
        let format = OWSLocalizedString(
            "PRIVATE_STORY_SETTINGS_REMOVE_VIEWER_TITLE_FORMAT",
            comment: "Action sheet title prompting to remove a viewer from a story on the 'private story settings' view. Embeds {{ viewer name }}"
        )

        let actionSheet = ActionSheetController(
            title: String.localizedStringWithFormat(format, SSKEnvironment.shared.databaseStorageRef.read { tx in
                return SSKEnvironment.shared.contactManagerRef.displayName(for: address, tx: tx).resolvedValue()
            }),
            message: OWSLocalizedString(
                "PRIVATE_STORY_SETTINGS_REMOVE_VIEWER_DESCRIPTION",
                comment: "Action sheet description prompting to remove a viewer from a story on the 'private story settings' view."
            )
        )
        actionSheet.addAction(OWSActionSheets.cancelAction)
        actionSheet.addAction(.init(title: OWSLocalizedString(
            "PRIVATE_STORY_SETTINGS_REMOVE_BUTTON",
            comment: "Action sheet button to remove a viewer from a story on the 'private story settings' view."
        ), style: .destructive, handler: { [unowned self] _ in
            let databaseStorage = SSKEnvironment.shared.databaseStorageRef
            databaseStorage.write { transaction in
                let recipientDatabaseTable = DependenciesBridge.shared.recipientDatabaseTable
                guard
                    let storyThread = TSPrivateStoryThread.anyFetchPrivateStoryThread(uniqueId: self.thread.uniqueId, transaction: transaction),
                    storyThread.storyViewMode == .explicit,
                    let recipientId = recipientDatabaseTable.fetchRecipient(address: address, tx: transaction)?.id
                else {
                    return
                }
                let storyRecipientManager = DependenciesBridge.shared.storyRecipientManager
                failIfThrows {
                    try storyRecipientManager.removeRecipientIds(
                        [recipientId],
                        for: storyThread,
                        shouldUpdateStorageService: true,
                        tx: transaction
                    )
                }
            }
            self.updateSortedAddresses()
            self.updateTableContents()
        }))

        presentActionSheet(actionSheet)
    }

    private func editPressed() {
        let vc = PrivateStoryNameSettingsViewController(thread: thread) { [weak self] in
            self?.title = self?.thread.name
            self?.updateTableContents()
        }
        presentFormSheet(OWSNavigationController(rootViewController: vc), animated: true)
    }

    @objc
    private func didToggleReplies(_ toggle: UISwitch) {
        guard thread.allowsReplies != toggle.isOn else { return }
        SSKEnvironment.shared.databaseStorageRef.write { transaction in
            thread.updateWithAllowsReplies(toggle.isOn, updateStorageService: true, transaction: transaction)
        }
    }
}
