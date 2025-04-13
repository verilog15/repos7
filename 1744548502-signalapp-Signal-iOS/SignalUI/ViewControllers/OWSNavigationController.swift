//
// Copyright 2022 Signal Messenger, LLC
// SPDX-License-Identifier: AGPL-3.0-only
//

import SignalServiceKit

/// Any view controller which wants to be able cancel back button
/// presses and back gestures should implement this protocol.
public protocol OWSNavigationChildController: AnyObject {

    /// If non-nil, will use the provided child (should be a child view controller) for
    /// all other protocol methods.
    var childForOWSNavigationConfiguration: OWSNavigationChildController? { get }

    /// Will be called if the back button was pressed or if a back gesture
    /// was performed but not if the view is popped programmatically.
    /// Default false.
    var shouldCancelNavigationBack: Bool { get }

    /// The style to apply to the nav bar on view appearance in the navigation stack.
    /// Defaults to `blur`.
    var preferredNavigationBarStyle: OWSNavigationBarStyle { get }

    /// A background color to use for the navbar in certain styles.
    /// Defaults to nil (default color for style)
    var navbarBackgroundColorOverride: UIColor? { get }

    /// A tint color to use for the navbar in certain styles.
    /// Defaults to nil (default color for style)
    var navbarTintColorOverride: UIColor? { get }

    /// Whether the navigation bar should show or hide when this view controller appears.
    /// Defaults to false.
    var prefersNavigationBarHidden: Bool { get }
}

extension OWSNavigationChildController {

    public var childForOWSNavigationConfiguration: OWSNavigationChildController? { nil }

    public var shouldCancelNavigationBack: Bool { false }

    public var preferredNavigationBarStyle: OWSNavigationBarStyle { .blur }

    public var navbarBackgroundColorOverride: UIColor? { nil }

    public var navbarTintColorOverride: UIColor? { nil }

    public var prefersNavigationBarHidden: Bool { false }
}

/// This navigation controller subclass should be used anywhere we might
/// want to cancel back button presses or back gestures due to, for example,
/// unsaved changes.
open class OWSNavigationController: UINavigationController {

    private var owsNavigationBar: OWSNavigationBar {
        return navigationBar as! OWSNavigationBar
    }

    private weak var externalDelegate: UINavigationControllerDelegate?

    public override var delegate: UINavigationControllerDelegate? {
        get {
            return externalDelegate
        }
        set {
            if newValue === self {
                owsFailDebug("Self is already the delegate! Override methods instead.")
                return
            }
            externalDelegate = newValue
        }
    }

    public init() {
        super.init(navigationBarClass: OWSNavigationBar.self, toolbarClass: nil)

        super.delegate = self

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(themeDidChange),
            name: .themeDidChange,
            object: nil
        )
    }

    public override convenience init(rootViewController: UIViewController) {
        self.init()
        self.pushViewController(rootViewController, animated: false)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let delegateOrientations = self.delegate?.navigationControllerSupportedInterfaceOrientations?(self) {
            return delegateOrientations
        } else if let visibleViewController = self.visibleViewController {
            return visibleViewController.supportedInterfaceOrientations
        } else {
            return UIDevice.current.defaultSupportedOrientations
        }
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        interactivePopGestureRecognizer?.delegate = self
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateNavbarAppearance(animated: animated)
    }

    // MARK: - Theme and Style

    @objc
    private func themeDidChange() {
        updateNavbarAppearance()
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        if let forcedStyle = owsNavigationBar.forcedStatusBarStyle {
            return forcedStyle
        }
        if !CurrentAppContext().isMainApp {
            return super.preferredStatusBarStyle
        } else if let presentedViewController = self.presentedViewController {
            return presentedViewController.preferredStatusBarStyle
        } else {
            return Theme.isDarkThemeEnabled ? .lightContent : .darkContent
        }
    }

    /// Apply any changes to navbar appearance from the top view controller in the stack.
    /// Changes will be automatically applied when a view controller is pushed or popped;
    /// this method is just for use if state changes while the view is on screen.
    public func updateNavbarAppearance(animated: Bool = UIView.areAnimationsEnabled) {
        if let topViewController = topViewController {
            updateNavbarAppearance(for: topViewController, fromViewControllerTransition: false, animated: animated)
        }
    }

    private func updateNavbarAppearance(
        for viewController: UIViewController,
        fromViewControllerTransition: Bool,
        animated: Bool
    ) {
        // If currently presenting or dismissing, animating these changes looks off.
        // In these cases, force the changes to apply un-animated.
        let animated = animated && !(self.isBeingPresented || self.isBeingDismissed)
        let navChildController = viewController.getFinalNavigationChildController()
        let shouldHideNavbar = navChildController?.prefersNavigationBarHidden ?? false

        if !shouldHideNavbar {
            // Only update visible attributes if we aren't hiding; if its hidden anyway
            // they won't matter and seeing them blink then hide is weird.
            owsNavigationBar.navbarBackgroundColorOverride = navChildController?.navbarBackgroundColorOverride
            owsNavigationBar.navbarTintColorOverride = navChildController?.navbarTintColorOverride
            owsNavigationBar.setStyle(navChildController?.preferredNavigationBarStyle ?? .blur, animated: animated)
        }

        // NOTE: UIKit sets isNavigationBarHidden immediately at the start of
        // setNavigationBarHidden, without waiting for the animation to complete.
        // If UIKit didn't do that, we'd have a race condition where we hide it,
        // then unhide before the animation finishes, but get stale state.
        // UIKit saves us this headache.

        // Only update when necessary to preserve performance and safe area changes.
        if shouldHideNavbar != isNavigationBarHidden {
            // Don't do our custom shenanigans if we are changing the hidden state
            // as a result of view controler transitions.
            if fromViewControllerTransition {
                super.setNavigationBarHidden(shouldHideNavbar, animated: animated)
            } else {
                self.setNavigationBarHidden(shouldHideNavbar, animated: animated)
            }
        }
    }

    override open func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        guard hidden != self.isNavigationBarHidden else {
            return
        }
        guard animated else {
            super.setNavigationBarHidden(hidden, animated: false)
            return
        }
        if !hidden {
            // When showing, immediately show it first so the sizing of child views works,
            // then apply transition animations.
            super.setNavigationBarHidden(hidden, animated: false)
        }
        UIView.transition(
            with: self.view,
            duration: Self.hideShowBarDuration,
            options: .transitionCrossDissolve,
            animations: {
                super.setNavigationBarHidden(hidden, animated: false)
            }
        )
    }
}

// MARK: - UIGestureRecognizerDelegate

extension OWSNavigationController: UIGestureRecognizerDelegate {

    public func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        owsAssertDebug(gestureRecognizer === self.interactivePopGestureRecognizer)

        guard viewControllers.count > 1 else {
            return false
        }

        if let child = topViewController?.getFinalNavigationChildController() {
            return !child.shouldCancelNavigationBack
        } else {
            return topViewController != viewControllers.first
        }
    }
}

// MARK: - UINavigationBarDelegate

extension OWSNavigationController: UINavigationBarDelegate {

    // All OWSNavigationController serve as the UINavigationBarDelegate for their navbar.
    // We override shouldPopItem: in order to cancel some back button presses - for example,
    // if a view has unsaved changes.
    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        owsAssertDebug(interactivePopGestureRecognizer?.delegate === self)

        // wasBackButtonClicked is true if the back button was pressed but not
        // if a back gesture was performed or if the view is popped programmatically.
        let wasBackButtonClicked = topViewController?.navigationItem == item
        if wasBackButtonClicked, let child = topViewController?.getFinalNavigationChildController() {
            return !child.shouldCancelNavigationBack
        }
        return true
    }
}

// MARK: - UINavigationControllerDelegate

extension OWSNavigationController: UINavigationControllerDelegate {

    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        // The `viewController` parameter is non-Optional. It is annotated as such
        // in Apple's header. However, on iOS 16, they pass `nil`, and that causes
        // our code to blow up. Detect when they've given us nil in a non-Optional
        // parameter and avoid calling the method that causes things to blow up.
        if let viewController = viewController as AnyObject as? UIViewController {
            updateNavbarAppearance(for: viewController, fromViewControllerTransition: true, animated: animated)
        }
        externalDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        externalDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return externalDelegate?.navigationController?(
            navigationController,
            animationControllerFor: operation,
            from: fromVC,
            to: toVC
        )
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        return externalDelegate?.navigationController?(
            navigationController,
            interactionControllerFor: animationController
        )
    }

    public func navigationControllerPreferredInterfaceOrientationForPresentation(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientation {
        return externalDelegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(
            navigationController
        ) ?? .portrait
    }

    public func navigationControllerSupportedInterfaceOrientations(
        _ navigationController: UINavigationController
    ) -> UIInterfaceOrientationMask {
        return externalDelegate?.navigationControllerSupportedInterfaceOrientations?(
            navigationController
        ) ?? supportedInterfaceOrientations
    }
}

// MARK: - OWSNavigationChildController children

extension UIViewController {

    func getFinalNavigationChildController() -> OWSNavigationChildController? {
        guard let child = self as? OWSNavigationChildController else { return nil }
        return child.getFinalChild()
    }
}

extension OWSNavigationChildController {

    func getFinalChild() -> OWSNavigationChildController {
        if let child = childForOWSNavigationConfiguration {
            return child.getFinalChild()
        }
        return self
    }
}
