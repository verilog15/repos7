//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

#if USE_DEBUG_UI

class DebugUITableViewController: OWSTableViewController {

    // MARK: Public

    static func presentDebugUI(from fromViewController: UIViewController, appReadiness: AppReadinessSetter) {
        let viewController = DebugUITableViewController()

        let subsectionItems: [OWSTableItem] = [
            itemForSubsection(DebugUICallsTab(), viewController: viewController),
            itemForSubsection(DebugUIContacts(), viewController: viewController),
            itemForSubsection(DebugUIDiskUsage(), viewController: viewController),
            itemForSubsection(DebugUISessionState(), viewController: viewController),
            itemForSubsection(DebugUISyncMessages(), viewController: viewController),
            itemForSubsection(DebugUIGroupsV2(), viewController: viewController),
            itemForSubsection(DebugUIPayments(), viewController: viewController),
            itemForSubsection(DebugUIMisc(appReadiness: appReadiness), viewController: viewController)
        ]
        viewController.contents = OWSTableContents(
            title: "Debug UI",
            sections: [ OWSTableSection(title: "Sections", items: subsectionItems) ]
        )
        viewController.present(fromViewController: fromViewController)
    }

    static func presentDebugUIForThread(_ thread: TSThread, from fromViewController: UIViewController) {
        let viewController = DebugUITableViewController()

        var subsectionItems: [OWSTableItem] = [
            itemForSubsection(DebugUICallsTab(), viewController: viewController, thread: thread),
            itemForSubsection(DebugUIMessages(), viewController: viewController, thread: thread),
            itemForSubsection(DebugUIContacts(), viewController: viewController, thread: thread),
            itemForSubsection(DebugUIDiskUsage(), viewController: viewController, thread: thread),
            itemForSubsection(DebugUISessionState(), viewController: viewController, thread: thread)
        ]
        if thread is TSContactThread {
            subsectionItems.append(itemForSubsection(DebugUICalling(), viewController: viewController, thread: thread))
        }
        subsectionItems += [
            itemForSubsection(DebugUIStress(contactsManager: SSKEnvironment.shared.contactManagerRef, databaseStorage: SSKEnvironment.shared.databaseStorageRef, messageSender: SSKEnvironment.shared.messageSenderRef), viewController: viewController, thread: thread),
            itemForSubsection(DebugUISyncMessages(), viewController: viewController, thread: thread),

            OWSTableItem(
                title: "📁 Shared Container", actionBlock: {
                    let baseURL = OWSFileSystem.appSharedDataDirectoryURL()
                    let fileBrowser = DebugUIFileBrowser(fileURL: baseURL)
                    viewController.navigationController?.pushViewController(fileBrowser, animated: true)
                }
            ),

            OWSTableItem(
                title: "📁 App Container", actionBlock: {
                    let libraryPath = OWSFileSystem.appLibraryDirectoryPath()
                    guard let baseURL = NSURL(string: libraryPath)?.deletingLastPathComponent else { return }
                    let fileBrowser = DebugUIFileBrowser(fileURL: baseURL)
                    viewController.navigationController?.pushViewController(fileBrowser, animated: true)
                }
            ),

            itemForSubsection(DebugUIGroupsV2(), viewController: viewController, thread: thread),
            itemForSubsection(DebugUIPayments(), viewController: viewController, thread: thread),
            itemForSubsection(DebugUIMisc(appReadiness: nil), viewController: viewController, thread: thread)
        ]

        viewController.contents = OWSTableContents(
            title: "Debug: Conversation",
            sections: [OWSTableSection(title: "Sections", items: subsectionItems)]
        )
        viewController.present(fromViewController: fromViewController)
    }

    // MARK: -

    private func pushPageWithSection(_ section: OWSTableSection) {
        let viewController = DebugUITableViewController()
        viewController.contents = OWSTableContents(title: section.headerTitle, sections: [section])
        navigationController?.pushViewController(viewController, animated: true )
    }

    private static func itemForSubsection(
        _ page: DebugUIPage,
        viewController: DebugUITableViewController,
        thread: TSThread? = nil
    ) -> OWSTableItem {
        return OWSTableItem.disclosureItem(
            withText: page.name,
            actionBlock: { [weak viewController] in
                guard let viewController, let section = page.section(thread: thread) else { return }
                viewController.pushPageWithSection(section)
            }
        )
    }
}

#endif
