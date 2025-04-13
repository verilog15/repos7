//
// Copyright 2021 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit
import SignalUI

class DisappearingMessagesTimerSettingsViewController: OWSTableViewController2 {
    let thread: TSThread?
    let originalConfiguration: OWSDisappearingMessagesConfiguration
    var configuration: OWSDisappearingMessagesConfiguration
    let completion: (OWSDisappearingMessagesConfiguration) -> Void
    let isUniversal: Bool
    let useCustomPicker: Bool
    private lazy var pickerView = CustomTimePicker { [weak self] duration in
        guard let self = self else { return }
        self.configuration = self.originalConfiguration.copyAsEnabled(
            withDurationSeconds: duration,
            timerVersion: self.originalConfiguration.timerVersion + 1
        )
        self.updateNavigation()
    }

    init(
        thread: TSThread? = nil,
        configuration: OWSDisappearingMessagesConfiguration,
        isUniversal: Bool = false,
        useCustomPicker: Bool = false,
        completion: @escaping (OWSDisappearingMessagesConfiguration) -> Void
    ) {
        self.thread = thread
        self.originalConfiguration = configuration
        self.configuration = configuration
        self.isUniversal = isUniversal
        self.useCustomPicker = useCustomPicker
        self.completion = completion

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = OWSLocalizedString(
            "DISAPPEARING_MESSAGES",
            comment: "table cell label in conversation settings"
        )

        defaultSeparatorInsetLeading = Self.cellHInnerMargin + 24 + OWSTableItem.iconSpacing

        if useCustomPicker {
            self.configuration = self.originalConfiguration.copyAsEnabled(
                withDurationSeconds: pickerView.selectedDuration,
                timerVersion: self.originalConfiguration.timerVersion + 1
            )
        }

        updateNavigation()
        updateTableContents()
    }

    private var hasUnsavedChanges: Bool {
        originalConfiguration.asToken != configuration.asToken
    }

    // Don't allow interactive dismiss when there are unsaved changes.
    override var isModalInPresentation: Bool {
        get { hasUnsavedChanges }
        set {}
    }

    private func updateNavigation() {
        if !useCustomPicker {
            navigationItem.leftBarButtonItem = .cancelButton(
                dismissingFrom: self,
                hasUnsavedChanges: { [weak self] in self?.hasUnsavedChanges }
            )
        }

        if hasUnsavedChanges {
            navigationItem.rightBarButtonItem = .button(
                title: CommonStrings.setButton,
                style: .done,
                action: { [weak self] in
                    self?.didTapDone()
                }
            )
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    func updateTableContents() {
        let contents = OWSTableContents()
        defer { self.contents = contents }

        let footerHeaderSection = OWSTableSection()
        footerHeaderSection.footerTitle = isUniversal
            ? OWSLocalizedString(
                "DISAPPEARING_MESSAGES_UNIVERSAL_DESCRIPTION",
                comment: "subheading in privacy settings"
            )
            : OWSLocalizedString(
                "DISAPPEARING_MESSAGES_DESCRIPTION",
                comment: "subheading in conversation settings"
            )
        contents.add(footerHeaderSection)

        guard !useCustomPicker else {
            let section = OWSTableSection()
            section.add(.init(
                customCellBlock: { [weak self] in
                    let cell = OWSTableItem.newCell()
                    guard let self = self else { return cell }

                    cell.selectionStyle = .none
                    cell.contentView.addSubview(self.pickerView)
                    self.pickerView.autoPinEdgesToSuperviewMargins()

                    return cell
                },
                actionBlock: {}
            ))
            contents.add(section)
            return
        }

        let section = OWSTableSection()
        section.add(.item(
            icon: configuration.isEnabled ? .empty : .checkmark,
            name: CommonStrings.switchOff,
            accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "timer_off"),
            actionBlock: { [weak self] in
                guard let self = self else { return }
                self.configuration = self.originalConfiguration.copy(
                    withIsEnabled: false,
                    timerVersion: self.originalConfiguration.timerVersion + 1
                )
                self.updateNavigation()
                self.updateTableContents()
            }
        ))

        for duration in disappearingMessagesDurations {
            section.add(.item(
                icon: (configuration.isEnabled && duration == configuration.durationSeconds) ? .checkmark : .empty,
                name: DateUtil.formatDuration(seconds: duration, useShortFormat: false),
                accessibilityIdentifier: UIView.accessibilityIdentifier(in: self, name: "timer_\(duration)"),
                actionBlock: { [weak self] in
                    guard let self = self else { return }
                    self.configuration = self.originalConfiguration.copyAsEnabled(
                        withDurationSeconds: duration,
                        timerVersion: self.originalConfiguration.timerVersion + 1
                    )
                    self.updateNavigation()
                    self.updateTableContents()
                }
            ))
        }

        let isCustomTime = configuration.isEnabled && !disappearingMessagesDurations.contains(configuration.durationSeconds)

        section.add(.disclosureItem(
            icon: isCustomTime ? .checkmark : .empty,
            withText: OWSLocalizedString(
                "DISAPPEARING_MESSAGES_CUSTOM_TIME",
                comment: "Disappearing message option to define a custom time"
            ),
            accessoryText: isCustomTime ? DateUtil.formatDuration(seconds: configuration.durationSeconds, useShortFormat: false) : nil,
            actionBlock: { [weak self] in
                guard let self = self else { return }
                let vc = DisappearingMessagesTimerSettingsViewController(
                    thread: self.thread,
                    configuration: self.originalConfiguration,
                    isUniversal: self.isUniversal,
                    useCustomPicker: true,
                    completion: self.completion
                )
                self.navigationController?.pushViewController(vc, animated: true)
            }
        ))

        contents.add(section)
    }

    var disappearingMessagesDurations: [UInt32] {
        return OWSDisappearingMessagesConfiguration.presetDurationsSeconds().map { $0.uint32Value }.reversed()
    }

    private func didTapDone() {
        let configuration = self.configuration

        // We use this view some places that don't have a thread like the
        // new group view and the universal timer in privacy settings. We
        // only need to do the extra "save" logic to apply the timer
        // immediately if we have a thread.
        guard let thread = thread, hasUnsavedChanges else {
            completion(configuration)
            dismiss(animated: true)
            return
        }

        GroupViewUtils.updateGroupWithActivityIndicator(
            fromViewController: self,
            updateDescription: "Update disappearing messages configuration",
            updateBlock: {
                await withCheckedContinuation { continuation in
                    DispatchQueue.global().async {
                        // We're sending a message, so we're accepting any pending message request.
                        ThreadUtil.addThreadToProfileWhitelistIfEmptyOrPendingRequestAndSetDefaultTimerWithSneakyTransaction(thread)
                        continuation.resume()
                    }
                }

                try await self.localUpdateDisappearingMessagesConfiguration(
                    thread: thread,
                    newToken: configuration.asVersionedToken
                )
            },
            completion: { [weak self] in
                self?.completion(configuration)
                self?.dismiss(animated: true)
            }
        )
    }

    private func localUpdateDisappearingMessagesConfiguration(
        thread: TSThread,
        newToken: VersionedDisappearingMessageToken
    ) async throws {
        if let contactThread = thread as? TSContactThread {
            await SSKEnvironment.shared.databaseStorageRef.awaitableWrite { tx in
                GroupManager.localUpdateDisappearingMessageToken(
                    newToken,
                    inContactThread: contactThread,
                    tx: tx
                )
            }
        } else if let groupThread = thread as? TSGroupThread {
            if let groupV2Model = groupThread.groupModel as? TSGroupModelV2 {
                try await GroupManager.updateGroupV2(
                    groupModel: groupV2Model,
                    description: "Update disappearing messages"
                ) { changeSet in
                    changeSet.setNewDisappearingMessageToken(newToken.unversioned)
                }
            } else {
                throw OWSAssertionError("Cannot update disappearing message config for V1 groups!")
            }
        } else {
            throw OWSAssertionError("Unexpected thread type in disappearing message update! \(type(of: thread))")
        }
    }
}

private class CustomTimePicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    enum Component: Int {
        case duration = 0
        case unit = 1
    }

    enum Unit: Int {
        case second = 0
        case minute = 1
        case hour = 2
        case day = 3
        case week = 4

        var maxValue: Int {
            switch self {
            case .second: return 59
            case .minute: return 59
            case .hour: return 23
            case .day: return 6
            case .week: return 4
            }
        }

        var name: String {
            switch self {
            case .second: return OWSLocalizedString(
                "DISAPPEARING_MESSAGES_SECONDS",
                comment: "The unit for a number of seconds"
            )
            case .minute: return OWSLocalizedString(
                "DISAPPEARING_MESSAGES_MINUTES",
                comment: "The unit for a number of minutes"
            )
            case .hour: return OWSLocalizedString(
                "DISAPPEARING_MESSAGES_HOURS",
                comment: "The unit for a number of hours"
            )
            case .day: return OWSLocalizedString(
                "DISAPPEARING_MESSAGES_DAYS",
                comment: "The unit for a number of days"
            )
            case .week: return OWSLocalizedString(
                "DISAPPEARING_MESSAGES_WEEKS",
                comment: "The unit for a number of weeks"
            )
            }
        }

        var interval: TimeInterval {
            switch self {
            case .second: return .second
            case .minute: return .minute
            case .hour: return .hour
            case .day: return .day
            case .week: return .week
            }
        }
    }

    var selectedUnit: Unit = .second {
        didSet {
            guard oldValue != selectedUnit else { return }
            reloadComponent(Component.duration.rawValue)
            durationChangeCallback(selectedDuration)
        }
    }
    var selectedTime: Int = 1 {
        didSet {
            guard oldValue != selectedTime else { return }
            durationChangeCallback(selectedDuration)
        }
    }
    var selectedDuration: UInt32 { UInt32(selectedUnit.interval) * UInt32(selectedTime) }

    let durationChangeCallback: (UInt32) -> Void
    init(durationChangeCallback: @escaping (UInt32) -> Void) {
        self.durationChangeCallback = durationChangeCallback
        super.init(frame: .zero)
        dataSource = self
        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int { 2 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch Component(rawValue: component) {
        case .duration: return selectedUnit.maxValue
        case .unit: return 5
        default:
            owsFailDebug("Unexpected component")
            return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch Component(rawValue: component) {
        case .duration: return OWSFormat.formatInt(row + 1)
        case .unit: return (Unit(rawValue: row) ?? .second).name
        default:
            owsFailDebug("Unexpected component")
            return nil
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch Component(rawValue: component) {
        case .duration: selectedTime = row + 1
        case .unit: selectedUnit = Unit(rawValue: row) ?? .second
        default: owsFailDebug("Unexpected component")
        }
    }
}
