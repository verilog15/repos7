//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
public import SignalUI

public class BadgeGiftingChooseBadgeViewController: OWSTableViewController2 {
    typealias GiftConfiguration = DonationSubscriptionManager.DonationConfiguration.GiftConfiguration
    typealias PaymentMethodsConfiguration = DonationSubscriptionManager.DonationConfiguration.PaymentMethodsConfiguration

    // MARK: - State management

    enum State {
        case initializing
        case loading
        case loadFailed
        case loaded(
            selectedCurrencyCode: Currency.Code,
            giftConfiguration: GiftConfiguration,
            paymentMethodsConfiguration: PaymentMethodsConfiguration
        )

        public var canContinue: Bool {
            switch self {
            case .initializing, .loading, .loadFailed:
                return false
            case let .loaded(selectedCurrencyCode, giftConfiguration, _):
                let isValid = giftConfiguration.presetAmount[selectedCurrencyCode] != nil
                owsAssertDebug(isValid, "State was loaded but it was invalid")
                return isValid
            }
        }

        public func selectCurrencyCode(_ newCurrencyCode: Currency.Code) -> State {
            switch self {
            case .initializing, .loading, .loadFailed:
                assertionFailure("Invalid state; cannot select currency code")
                return self
            case let .loaded(_, giftConfiguration, paymentMethodsConfiguration):
                guard giftConfiguration.presetAmount[newCurrencyCode] != nil else {
                    assertionFailure("Tried to select a currency code that doesn't exist")
                    return self
                }
                return .loaded(
                    selectedCurrencyCode: newCurrencyCode,
                    giftConfiguration: giftConfiguration,
                    paymentMethodsConfiguration: paymentMethodsConfiguration
                )
            }
        }
    }

    private var state: State = .initializing {
        didSet {
            updateTableContents()
            updateBottomFooter()
        }
    }

    private func loadDataIfNecessary() {
        switch state {
        case .initializing, .loadFailed:
            state = .loading
            Task { @MainActor in
                self.state = await loadData()
            }
        case .loading, .loaded:
            break
        }
    }

    private func loadData() async -> State {
        do {
            Logger.info("[Gifting] Fetching donation configuration...")
            let donationConfiguration = try await DonationSubscriptionManager.fetchDonationConfiguration()
            Logger.info("[Gifting] Populating badge assets...")
            let giftBadge = donationConfiguration.gift.badge
            try await SSKEnvironment.shared.profileManagerRef.badgeStore.populateAssetsOnBadge(giftBadge)
            let defaultCurrencyCode = DonationUtilities.chooseDefaultCurrency(
                preferred: [
                    Locale.current.currencyCode?.uppercased(),
                    "USD",
                    donationConfiguration.gift.presetAmount.keys.first
                ],
                supported: donationConfiguration.gift.presetAmount.keys
            )
            guard let defaultCurrencyCode = defaultCurrencyCode else {
                // This indicates a bug, either in the iOS app or the server.
                owsFailBeta("[Gifting] Successfully loaded data, but a preferred currency could not be found")
                return .loadFailed
            }

            return .loaded(
                selectedCurrencyCode: defaultCurrencyCode,
                giftConfiguration: donationConfiguration.gift,
                paymentMethodsConfiguration: donationConfiguration.paymentMethods
            )
        } catch {
            Logger.warn("\(error)")
            return .loadFailed
        }
    }

    private func didTapNext() {
        switch state {
        case .initializing, .loading, .loadFailed:
            owsFailBeta("Tapped next when the state wasn't loaded")
        case let .loaded(selectedCurrencyCode, giftConfiguration, paymentMethodsConfiguration):
            guard let price = giftConfiguration.presetAmount[selectedCurrencyCode] else {
                owsFailBeta("State is invalid. We selected a currency code that we don't have a price for")
                return
            }
            let vc = BadgeGiftingChooseRecipientViewController(
                badge: giftConfiguration.badge,
                price: price,
                paymentMethodsConfiguration: paymentMethodsConfiguration
            )
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    // MARK: - Callbacks

    public override func viewDidLoad() {
        super.viewDidLoad()

        let isPresentedStandalone = navigationController?.viewControllers.first == self
        if isPresentedStandalone {
            navigationItem.leftBarButtonItem = .cancelButton(dismissingFrom: self)
        }

        loadDataIfNecessary()
        updateTableContents()
        setUpBottomFooter()
    }

    public override func themeDidChange() {
        super.themeDidChange()
        updateTableContents()
        updateBottomFooter()
    }

    // MARK: - Table contents

    private func updateTableContents() {
        self.contents = OWSTableContents(sections: getTableSections())
    }

    private func getTableSections() -> [OWSTableSection] {
        let introSection: OWSTableSection = {
            let section = OWSTableSection()
            section.hasBackground = false
            section.customHeaderView = {
                let introStack = UIStackView()
                introStack.axis = .vertical
                introStack.spacing = 12

                let imageName = Theme.isDarkThemeEnabled ? "badge-gifting-promo-image-dark" : "badge-gifting-promo-image-light"
                let imageView = UIImageView(image: UIImage(named: imageName))
                introStack.addArrangedSubview(imageView)
                imageView.contentMode = .scaleAspectFit

                let titleLabel = UILabel()
                introStack.addArrangedSubview(titleLabel)
                titleLabel.text = OWSLocalizedString(
                    "DONATION_ON_BEHALF_OF_A_FRIEND_CHOOSE_BADGE_TITLE",
                    comment: "Users can donate on behalf of a friend, and the friend will receive a badge. This is the title on the screen where users choose the badge their friend will receive."
                )
                titleLabel.textAlignment = .center
                titleLabel.font = UIFont.dynamicTypeTitle2.semibold()
                titleLabel.numberOfLines = 0
                titleLabel.lineBreakMode = .byWordWrapping
                titleLabel.autoPinWidthToSuperview(withMargin: 26)

                let paragraphLabel = UILabel()
                introStack.addArrangedSubview(paragraphLabel)
                paragraphLabel.text = OWSLocalizedString(
                    "DONATION_ON_BEHALF_OF_A_FRIEND_CHOOSE_BADGE_DESCRIPTION",
                    comment: "Users can donate on behalf of a friend, and the friend will receive a badge. This is a short paragraph on the screen where users choose the badge their friend will receive."
                )
                paragraphLabel.textAlignment = .center
                paragraphLabel.font = UIFont.dynamicTypeBody
                paragraphLabel.numberOfLines = 0
                paragraphLabel.lineBreakMode = .byWordWrapping
                paragraphLabel.autoPinWidthToSuperview(withMargin: 26)

                return introStack
            }()
            return section
        }()

        var result: [OWSTableSection] = [introSection]

        switch state {
        case .initializing, .loading:
            result += loadingSections()
        case .loadFailed:
            result += loadFailedSections()
        case let .loaded(selectedCurrencyCode, giftConfiguration, _):
            result += loadedSections(
                selectedCurrencyCode: selectedCurrencyCode,
                badge: giftConfiguration.badge,
                pricesByCurrencyCode: giftConfiguration.presetAmount
            )
        }

        return result
    }

    private func loadingSections() -> [OWSTableSection] {
        let section = OWSTableSection()
        section.add(AppSettingsViewsUtil.loadingTableItem(cellOuterInsets: cellOuterInsets))
        section.hasBackground = false
        return [section]
    }

    private func loadFailedSections() -> [OWSTableSection] {
        let section = OWSTableSection()
        section.add(.init(customCellBlock: { [weak self] in
            guard let self = self else { return UITableViewCell() }
            let cell = AppSettingsViewsUtil.newCell(cellOuterInsets: self.cellOuterInsets)

            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.spacing = 16

            let textLabel = UILabel()
            stackView.addArrangedSubview(textLabel)
            textLabel.text = OWSLocalizedString("DONATION_VIEW_LOAD_FAILED",
                                               comment: "Text that's shown when the donation view fails to load data, probably due to network failure")
            textLabel.font = .dynamicTypeBody2
            textLabel.textAlignment = .center
            textLabel.textColor = Theme.primaryTextColor
            textLabel.numberOfLines = 0

            let retryButton = OWSButton { [weak self] in self?.loadDataIfNecessary() }
            stackView.addArrangedSubview(retryButton)
            retryButton.setTitle(CommonStrings.retryButton, for: .normal)
            if Theme.isDarkThemeEnabled {
                retryButton.setTitleColor(.ows_gray05, for: .normal)
                retryButton.setBackgroundImage(UIImage.image(color: .ows_gray85), for: .normal)
            } else {
                retryButton.setTitleColor(.ows_gray90, for: .normal)
                retryButton.setBackgroundImage(UIImage.image(color: .ows_gray05), for: .normal)
            }
            retryButton.ows_contentEdgeInsets = UIEdgeInsets(hMargin: 16, vMargin: 6)
            retryButton.autoPinWidthToSuperviewMargins(relation: .lessThanOrEqual)
            retryButton.autoHCenterInSuperview()
            retryButton.setContentHuggingHigh()
            retryButton.layer.cornerRadius = 16
            retryButton.clipsToBounds = true

            cell.contentView.addSubview(stackView)
            stackView.autoPinEdgesToSuperviewMargins()

            return cell
        }))
        return [section]
    }

    private func loadedSections(
        selectedCurrencyCode: Currency.Code,
        badge: ProfileBadge,
        pricesByCurrencyCode: [Currency.Code: FiatMoney]
    ) -> [OWSTableSection] {
        let currencyButtonSection = OWSTableSection()
        currencyButtonSection.hasBackground = false
        currencyButtonSection.add(.init(customCellBlock: { [weak self] in
            guard let self = self else { return UITableViewCell() }
            let cell = AppSettingsViewsUtil.newCell(cellOuterInsets: self.cellOuterInsets)

            let currencyPickerButton = DonationCurrencyPickerButton(
                currentCurrencyCode: selectedCurrencyCode,
                hasLabel: true
            ) { [weak self] in
                guard let self = self else { return }
                let vc = CurrencyPickerViewController(
                    dataSource: StripeCurrencyPickerDataSource(currentCurrencyCode: selectedCurrencyCode,
                                                               supportedCurrencyCodes: Set(pricesByCurrencyCode.keys))
                ) { [weak self] currencyCode in
                    guard let self = self else { return }
                    self.state = self.state.selectCurrencyCode(currencyCode)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }

            cell.contentView.addSubview(currencyPickerButton)
            currencyPickerButton.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))

            return cell
        }))

        let badgeSection = OWSTableSection()
        badgeSection.add(.init(customCellBlock: { [weak self] in
            guard let self = self else { return UITableViewCell() }
            let cell = AppSettingsViewsUtil.newCell(cellOuterInsets: self.cellOuterInsets)

            guard let price = pricesByCurrencyCode[selectedCurrencyCode] else {
                owsFailBeta("State is invalid. We selected a currency code that we don't have a price for.")
                return cell
            }
            let badgeCellView = GiftBadgeCellView(badge: badge, price: price)
            cell.contentView.addSubview(badgeCellView)
            badgeCellView.autoPinEdgesToSuperviewMargins()

            return cell
        }))

        return [currencyButtonSection, badgeSection]
    }

    // MARK: - Footer contents

    open override var bottomFooter: UIView? {
        get { bottomFooterStackView }
        set {}
    }
    private let nextButton = OWSButton()
    private let bottomFooterStackView = UIStackView()

    private func setUpBottomFooter() {
        bottomFooterStackView.axis = .vertical
        bottomFooterStackView.alignment = .center
        bottomFooterStackView.layoutMargins = UIEdgeInsets(top: 10, leading: 23, bottom: 10, trailing: 23)
        bottomFooterStackView.spacing = 16
        bottomFooterStackView.isLayoutMarginsRelativeArrangement = true

        bottomFooterStackView.addArrangedSubview(nextButton)
        nextButton.block = { [weak self] in
            self?.didTapNext()
        }
        nextButton.setTitle(CommonStrings.nextButton, for: .normal)
        nextButton.dimsWhenHighlighted = true
        nextButton.layer.cornerRadius = 8
        nextButton.backgroundColor = .ows_accentBlue
        nextButton.titleLabel?.font = UIFont.dynamicTypeBody.semibold()
        nextButton.autoSetDimension(.height, toSize: 48)
        nextButton.autoPinWidthToSuperviewMargins()

        updateBottomFooter()
    }

    private func updateBottomFooter() {
        bottomFooterStackView.layer.backgroundColor = self.tableBackgroundColor.cgColor

        nextButton.isEnabled = state.canContinue
        nextButton.backgroundColor = .ows_accentBlue
        if !nextButton.isEnabled {
            nextButton.backgroundColor = nextButton.backgroundColor?.withAlphaComponent(0.5)
        }
    }
}
