//
// Copyright 2023 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import Contacts
public import SignalServiceKit
import UIKit

public protocol ContactPickerDelegate: AnyObject {
    func contactPickerDidCancel(_: ContactPickerViewController)
    func contactPicker(_: ContactPickerViewController, didSelect contact: SystemContact)
    func contactPicker(_: ContactPickerViewController, didSelectMultiple contacts: [SystemContact])
    func contactPicker(_: ContactPickerViewController, shouldSelect contact: SystemContact) -> Bool
}

public enum SubtitleCellValue {
    case phoneNumber, email, none
}

open class ContactPickerViewController: OWSViewController, OWSNavigationChildController {

    public weak var delegate: ContactPickerDelegate?

    private let allowsMultipleSelection: Bool

    private let subtitleCellType: SubtitleCellValue

    public init(allowsMultipleSelection: Bool, subtitleCellType: SubtitleCellValue) {
        self.allowsMultipleSelection = allowsMultipleSelection
        self.subtitleCellType = subtitleCellType

        super.init()
    }

    // MARK: UIViewController

    public override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = .cancelButton { [weak self] in
            guard let self else { return }
            self.delegate?.contactPickerDidCancel(self)
        }
        if allowsMultipleSelection {
            navigationItem.rightBarButtonItem = .doneButton { [weak self] in
                guard let self else { return }
                self.delegate?.contactPicker(self, didSelectMultiple: self.selectedContacts)
            }
        }

        addChild(tableViewController)
        view.addSubview(tableViewController.view)
        tableView.autoPinEdgesToSuperviewEdges()

        updateTableContents()
        applyTheme()
    }

    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateSearchBarMargins()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateSearchBarMargins()
    }

    // MARK: UI

    private lazy var tableViewController: OWSTableViewController2 = {
        let viewController = OWSTableViewController2()
        viewController.delegate = self
        // Do not automatically deselect - keep cell selected until screen becomes not visible.
        viewController.selectionBehavior = .toggleSelectionWithAction
        viewController.defaultSeparatorInsetLeading = OWSTableViewController2.cellHInnerMargin
        + CGFloat(AvatarBuilder.smallAvatarSizePoints) + ContactCellView.avatarTextHSpacing
        viewController.tableView.register(ContactCell.self)
        viewController.tableView.allowsMultipleSelection = allowsMultipleSelection
        viewController.tableView.tableHeaderView = searchBar
        viewController.view.setCompressionResistanceVerticalHigh()
        viewController.view.setContentHuggingVerticalHigh()
        return viewController
    }()

    private var tableView: UITableView { tableViewController.tableView }

    public override func themeDidChange() {
        super.themeDidChange()
        applyTheme()
    }

    private func applyTheme() {
        tableViewController.applyTheme(to: self)
        searchBar.searchFieldBackgroundColorOverride = Theme.searchFieldElevatedBackgroundColor
        tableView.sectionIndexColor = Theme.primaryTextColor
        if let owsNavigationController = navigationController as? OWSNavigationController {
            owsNavigationController.updateNavbarAppearance()
        }
    }

    public var preferredNavigationBarStyle: OWSNavigationBarStyle { .solid }

    public var navbarBackgroundColorOverride: UIColor? { tableViewController.tableBackgroundColor }

    public func applyTheme(to viewController: UIViewController) {
        tableViewController.applyTheme(to: viewController)
    }

    // MARK: Contacts

    private let collation = UILocalizedIndexedCollation.current()

    private let allowedContactKeys: [CNKeyDescriptor] = ContactsFrameworkContactStoreAdaptee.fullContactKeys

    private let sortOrder: CNContactSortOrder = CNContactsUserDefaults.shared().sortOrder

    private let contactStore = CNContactStore()

    private var selectedContacts = [SystemContact]()

    private func updateTableContents() {
        guard SSKEnvironment.shared.contactManagerImplRef.sharingAuthorization == .authorized else {
            return owsFailDebug("Not authorized.")
        }

        let contents: OWSTableContents
        if let searchResults {
            // Single section for all search results
            let contacts = searchResults.map({ tableItem(for: $0) })
            contents = OWSTableContents(sections: [OWSTableSection(items: contacts)])
        } else {
            var contacts = [CNContact]()
            let contactFetchRequest = CNContactFetchRequest(keysToFetch: allowedContactKeys)
            contactFetchRequest.sortOrder = .userDefault
            do {
                try contactStore.enumerateContacts(with: contactFetchRequest) { (contact, _) -> Void in
                    contacts.append(contact)
                }
            } catch {
                Logger.error("Failed to fetch contacts with error: \(error)")
            }
            contents = OWSTableContents(sections: contactsSections(for: contacts))
            contents.sectionForSectionIndexTitleBlock = { [weak self] (sectionIndexTitle, index) in
                return self?.collation.section(forSectionIndexTitle: index) ?? 0
            }
            contents.sectionIndexTitlesForTableViewBlock = { [weak self] in
                return self?.collation.sectionIndexTitles ?? []
            }
        }

        tableViewController.contents = contents
    }

    private func contactsSections(for contacts: [CNContact]) -> [OWSTableSection] {
        let selector: Selector
        if sortOrder == .familyName {
            selector = #selector(getter: CNContact.collationNameSortedByFamilyName)
        } else {
            selector = #selector(getter: CNContact.collationNameSortedByGivenName)
        }

        let sections = collation.sectionTitles.map({ OWSTableSection(title: $0) })
        for contact in contacts {
            let sectionNumber = collation.section(for: contact, collationStringSelector: selector)
            sections[sectionNumber].add(tableItem(for: contact))
        }

        // Set section titles to nil for empty sections - that'll prevent those sections from being displayed.
        for section in sections {
            if section.itemCount == 0 {
                section.headerTitle = nil
            }
        }

        return sections
    }

    private func tableItem(for cnContact: CNContact) -> OWSTableItem {
        let systemContact = SystemContact(cnContact: cnContact)
        return OWSTableItem(
            dequeueCellBlock: { [weak self] tableView in
                self?.cell(for: systemContact, tableView: tableView) ?? UITableViewCell()
            },
            actionBlock: { [weak self] in
                self?.tryToSelectContact(systemContact)
            }
        )
    }

    private func cell(for systemContact: SystemContact, tableView: UITableView) -> UITableViewCell? {
        guard let cell = tableView.dequeueReusableCell(ContactCell.self) else { return nil }

        cell.configure(
            systemContact: systemContact,
            sortOrder: sortOrder,
            subtitleType: subtitleCellType,
            showsWhenSelected: allowsMultipleSelection
        )

        if let delegate, !delegate.contactPicker(self, shouldSelect: systemContact) {
            cell.selectionStyle = .none
            cell.isSelected = false
        } else {
            cell.selectionStyle = .default
            cell.isSelected = selectedContacts.contains(where: { $0.cnContactId == systemContact.cnContactId })
        }

        return cell
    }

    private func tryToSelectContact(_ systemContact: SystemContact) {
        if let delegate, !delegate.contactPicker(self, shouldSelect: systemContact) {
            return
        }

        guard allowsMultipleSelection else {
            delegate?.contactPicker(self, didSelect: systemContact)
            return
        }

        let isCellSelected = selectedContacts.contains(where: { $0.cnContactId == systemContact.cnContactId })
        if isCellSelected {
            selectedContacts.removeAll(where: { $0.cnContactId == systemContact.cnContactId })
        } else {
            selectedContacts.append(systemContact)
        }
    }

    // MARK: Search

    private lazy var searchBar: OWSSearchBar = {
        let searchBar = OWSSearchBar()
        searchBar.placeholder = CommonStrings.searchBarPlaceholder
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.setCompressionResistanceVerticalHigh()
        searchBar.setContentHuggingVerticalHigh()
        return searchBar
    }()

    private var _searchResults = Atomic<[CNContact]?>(wrappedValue: nil)

    private var searchResults: [CNContact]? {
        get {
            _searchResults.wrappedValue
        }
        set {
            guard _searchResults.wrappedValue != newValue else { return }

            _searchResults.wrappedValue = newValue
            updateTableContents()
        }
    }

    private func performSearch() {
        let searchText = searchBar.text?.stripped ?? ""

        guard searchText.count > 1 else {
            searchResults = nil
            return
        }

        let predicate = CNContact.predicateForContacts(matchingName: searchText)
        do {
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: allowedContactKeys)
            searchResults = contacts
        } catch {
            Logger.error("updating search results failed with error: \(error)")
            searchResults = nil
        }
    }

    private func updateSearchBarMargins() {
        // This should ideally compute the insets for self.tableView, but that
        // view's size hasn't been updated when the viewDidLayoutSubviews method is
        // called. As a quick fix, use self.view's size, which matches the eventual
        // width of self.tableView. (A more complete fix would likely add a
        // callback when self.tableView’s size is available.)
        searchBar.layoutMargins = OWSTableViewController2.cellOuterInsets(in: view)
    }
}

extension ContactPickerViewController: UISearchBarDelegate {

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        performSearch()
    }

    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
        searchBar.resignFirstResponder()
    }
}

extension ContactPickerViewController: OWSTableViewControllerDelegate {

    public func tableViewWillBeginDragging(_ tableView: UITableView) {
        searchBar.resignFirstResponder()
    }
}

extension CNContact {
    @objc
    fileprivate var collationNameSortedByGivenName: String { collationName(sortOrder: .givenName) }

    @objc
    fileprivate var collationNameSortedByFamilyName: String { collationName(sortOrder: .familyName) }

    func collationName(sortOrder: CNContactSortOrder) -> String {
        return (collationContactName(sortOrder: sortOrder) ?? (emailAddresses.first?.value as String?) ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func collationContactName(sortOrder: CNContactSortOrder) -> String? {
        let contactNames: [String] = [familyName.nilIfEmpty, givenName.nilIfEmpty].compacted()
        guard !contactNames.isEmpty else {
            return nil
        }
        return ((sortOrder == .familyName) ? contactNames : contactNames.reversed()).joined(separator: " ")
    }
}
