import SwiftUI
import Testing
@testable import ZenKit
#if canImport(AppKit)
import AppKit
#endif

struct ZenKitPublicSurfaceSmokeTests {
    private enum Filter: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        case archived = "Archived"
    }

    private enum NotificationLanguage: String, CaseIterable {
        case english = "English"
        case polish = "Polish"
        case german = "German"
    }

    @Test
    func exportedComponentsComposeInSingleView() {
        let view = ZenScreen(header: {
            ZenScreenHeader(title: "Hello", subtitle: "World")
        }) {
            VStack(spacing: ZenSpacing.small) {
                ZenSegmentedControl(
                    title: "Filter",
                    selection: .constant(Filter.all),
                    segments: Filter.allCases
                ) { value, _ in
                    Text(value.rawValue)
                }

                ZenCard(title: "Profile", subtitle: "Manage your account") {
                    ZenFieldSection(title: "Basics", subtitle: "Shown to collaborators") {
                        ZenFieldGroup {
                            ZenField(label: "Email", message: "We never share this.", state: .normal) {
                                ZenTextInput(text: .constant("alex@example.com"), prompt: "Email")
                            }
                            ZenField(label: "Password", message: "Must be at least 8 characters.", state: .invalid) {
                                ZenTextInput(text: .constant(""), prompt: "Password", kind: .secure, state: .invalid)
                            }
                        }
                    }

                    ZenNavigationRow(title: "Notifications", subtitle: "Configure alerts", leadingIconAsset: "Bell")
                    ZenToggle("Biometric unlock", isOn: .constant(true), subtitle: "Use Face ID when available")
                    ZenProgressBar(progress: 0.4)
                    ZenStatusBanner(message: "All good")
                } footer: {
                    ZenInlineAction("Learn more") {}
                }

                ZenEmpty {
                        ZenEmptyHeader {
                            ZenEmptyMedia(variant: .icon) {
                                ZenIcon(assetName: "Tray", size: 24)
                        }
                        ZenEmptyTitle {
                            Text("No sessions")
                        }
                        ZenEmptyDescription {
                            Text("Create a session to see activity here.")
                        }
                    }
                    ZenEmptyContent {
                        ZenButton("Create session", fullWidth: true) {}
                        ZenButton("Dismiss", variant: .secondary, fullWidth: true) {}
                    }
                }

                ZenSheetContainer(title: "Filters", subtitle: "Choose what to show") {
                    ZenButton("Continue", fullWidth: true) {}
                } footer: {
                    ZenButton("Apply", variant: .secondary, fullWidth: true) {}
                }

                ZenConfirmationDialog(
                    title: "Sign out?",
                    message: "You will need to sign back in.",
                    isPresented: .constant(false),
                    actions: [
                        ZenConfirmationDialogAction("Cancel", role: .cancel) {},
                        ZenConfirmationDialogAction("Sign out", role: .destructive) {},
                    ]
                ) {
                    ZenButton("Open dialog") {}
                }
            }
        }

        _ = view
    }

    @Test
    func zenIconSupportsAssetBackedRendering() {
        let view = ZenIcon(assetName: "Envelope", size: 18)

        _ = view
    }

    @Test
    func zenButtonSupportsShadcnInspiredVariantsAndSizes() {
        let view = VStack(spacing: ZenSpacing.small) {
            ZenButton("Default") {}
            ZenButton("Outline", variant: .outline) {}
            ZenButton("Secondary", variant: .secondary, size: .sm) {}
            ZenButton("Ghost", variant: .ghost, size: .xs) {}
            ZenButton("Destructive", variant: .destructive, size: .lg) {}
            ZenButton("Link", variant: .link) {}
            ZenButton(variant: .default, size: .icon) {
            } label: {
                ZenIcon(assetName: "Plus", size: 17)
            }
            ZenButton("Full Width", isLoading: true, fullWidth: true) {}
        }

        _ = view
    }

    @Test
    func zenMenuComposesWithNestedActions() {
        let view = ZenMenu {
            ZenMenuTrigger {
                ZenAvatar(name: "Alex Morgan", imageURL: nil, size: 40)
            }
        } content: {
            ZenMenuContent {
                ZenMenuItem("Profile") {}
                ZenMenu {
                    ZenMenuItem("Teams") {}
                } label: {
                    Text("More")
                }
                ZenMenuSeparator()
                ZenMenuItem("Delete workspace", variant: .destructive) {}
            }
        }

        _ = view
    }

    @Test
    func zenMultiSelectComposesImmediateAndDeferredModes() {
        enum Column: String, CaseIterable, Hashable {
            case name = "Name"
            case owner = "Owner"
            case status = "Status"
        }

        let view = VStack {
            ZenMultiSelect(
                title: "Columns",
                selection: .constant([.name, .status]),
                options: Column.allCases
            ) { option in
                Text(option.rawValue)
            }

            ZenMultiSelect(
                title: "Filters",
                selection: .constant([.owner]),
                options: Column.allCases,
                mode: .deferred
            ) { option in
                Text(option.rawValue)
            }
        }

        _ = view
    }

    @Test
    func zenOnboardingComposesModelAndBuilderVariants() {
        struct DemoPage: Identifiable, Equatable {
            let id: String
            let title: String
        }

        let pages = [
            DemoPage(id: "welcome", title: "Welcome"),
            DemoPage(id: "focus", title: "Focus"),
        ]

        let modelDriven = ZenOnboarding(
            pages: pages,
            selection: .constant("welcome"),
            backgroundStyle: .animatedMesh(),
            transitionStyle: .default
        ) { page in
            Text(page.title)
        }

        let builderDriven = ZenOnboarding(selection: .constant("welcome")) {
            ZenOnboardingStep(id: "welcome") {
                Text("Welcome")
            }
            ZenOnboardingStep(id: "focus") {
                Text("Focus")
            }
        }

        _ = modelDriven
        _ = builderDriven
    }

    @Test
    func zenOnboardingUsesExternalSelectionBinding() {
        struct DemoPage: Identifiable, Equatable {
            let id: String
            let title: String
        }

        let pages = [
            DemoPage(id: "welcome", title: "Welcome"),
            DemoPage(id: "focus", title: "Focus"),
            DemoPage(id: "sync", title: "Sync"),
        ]

        var currentSelection = "focus"
        let selection = Binding(
            get: { currentSelection },
            set: { currentSelection = $0 }
        )

        let modelDriven = ZenOnboarding(
            pages: pages,
            selection: selection,
            backgroundStyle: .animatedMesh(),
            transitionStyle: .default
        ) { page in
            Text(page.title)
        }

        let builderDriven = ZenOnboarding(selection: selection) {
            ZenOnboardingStep(id: "welcome") {
                Text("Welcome")
            }
            ZenOnboardingStep(id: "focus") {
                Text("Focus")
            }
            ZenOnboardingStep(id: "sync") {
                Text("Sync")
            }
        }

        #expect(modelDriven.resolvedSelectedIndex == 1)
        #expect(modelDriven.resolvedSelectedStepID == "focus")
        #expect(builderDriven.resolvedSelectedIndex == 1)
        #expect(builderDriven.resolvedSelectedStepID == "focus")

        selection.wrappedValue = "sync"

        #expect(currentSelection == "sync")
        #expect(modelDriven.resolvedSelectedIndex == 2)
        #expect(modelDriven.resolvedSelectedStepID == "sync")
        #expect(builderDriven.resolvedSelectedIndex == 2)
        #expect(builderDriven.resolvedSelectedStepID == "sync")
    }

    @Test
    func zenOnboardingStylePresetsCompose() {
        let subtle = ZenOnboardingBackgroundStyle.animatedMesh()
        let expressiveBackground = ZenOnboardingBackgroundStyle.animatedMesh(intensity: .expressive)
        let expressiveTransition = ZenOnboardingTransitionStyle.expressive

        _ = subtle
        _ = expressiveBackground
        _ = expressiveTransition
    }

    @Test
    func zenOnboardingComposesDefaultAndExpressiveTransitions() {
        struct DemoPage: Identifiable, Equatable {
            let id: String
            let title: String
        }

        let pages = [
            DemoPage(id: "welcome", title: "Welcome"),
            DemoPage(id: "focus", title: "Focus"),
        ]

        let subtle = ZenOnboarding(
            pages: pages,
            selection: .constant("welcome"),
            backgroundStyle: .animatedMesh(),
            transitionStyle: .default
        ) { page in
            Text(page.title)
        }

        let expressive = ZenOnboarding(
            pages: pages,
            selection: .constant("focus"),
            backgroundStyle: .animatedMesh(intensity: .expressive),
            transitionStyle: .expressive
        ) { page in
            Text(page.title)
        }

        let reducedMotion = ZenOnboarding(
            pages: pages,
            selection: .constant("welcome"),
            backgroundStyle: .animatedMesh(),
            transitionStyle: .default,
            reduceMotionOverride: true
        ) { page in
            Text(page.title)
        }

        #expect(subtle.transitionConfiguration == .defaultMotion)
        #expect(expressive.transitionConfiguration == .expressiveMotion)
        #expect(reducedMotion.transitionConfiguration == .reduceMotion)

        _ = subtle
        _ = expressive
        _ = reducedMotion
    }

    @Test
    func zenOnboardingBackgroundComposesAnimatedMeshStyle() {
        let view = ZenOnboardingBackgroundView(
            pageIndex: 0,
            style: .animatedMesh()
        )

        _ = view
    }

    @Test
    func zenControlGroupComposesWithButtons() {
        let view = ZenControlGroup(layout: .adaptive) {
            ZenButton("Edit") {}
            ZenButton("Duplicate", variant: .secondary) {}
        } label: {
            Text("Actions")
        }

        _ = view
    }

    @Test
    func zenAutoSizingSheetComposesWithHostViews() {
        let view = Text("Host")
            .zenAutoSizingSheet(isPresented: .constant(false)) {
                ZenSheetContainer(title: "Invite collaborators", subtitle: "Add teammates by email") {
                    ZenButton("Continue", fullWidth: true) {}
                }
            }

        _ = view
    }

    @Test
    func zenSpinnerSupportsSharedLoadingContexts() {
        let view = VStack(spacing: ZenSpacing.small) {
            ZenSpinner()
            ZenSpinner(size: .small, tint: .zenPrimary)
            ZenSpinner(size: .large, tint: .zenTextPrimary, showsTrack: false)
        }

        _ = view
    }

    @Test
    func zenLoadingSupportsCenteredMinimalAndMessageVariants() {
        let view = VStack(spacing: ZenSpacing.small) {
            ZenLoading()
            ZenLoading(title: "Syncing", message: "Fetching the latest dashboard data.")
        }

        _ = view
    }

    @Test
    func confirmationDialogUsesCenteredOverlayHostMotion() {
        #expect(ZenConfirmationDialogMotion.presentationStyle == .centeredOverlay)
        #expect(ZenConfirmationDialogMotion.backdropOpacity == 0.18)
        #expect(ZenConfirmationDialogMotion.enterOffsetY == 12)
        #expect(ZenConfirmationDialogMotion.enterScale == 0.945)
        #expect(ZenConfirmationDialogMotion.exitOffsetY == 6)
        #expect(ZenConfirmationDialogMotion.exitScale == 0.985)
        #expect(ZenConfirmationDialogMotion.contentEnterOffsetY == 10)
    }

    @Test
    func confirmationDialogRenderStateRetainsDialogDuringDismissal() {
        let dialog = ZenOverlayPresenter.ConfirmationDialogState(
            id: UUID(),
            title: "Delete workspace?",
            message: "This action cannot be undone.",
            actions: []
        )
        var renderState = ZenConfirmationDialogRenderState()

        renderState.sync(with: dialog)

        #expect(renderState.renderedDialog?.id == dialog.id)
        #expect(renderState.isPresented == true)

        renderState.sync(with: nil)

        #expect(renderState.renderedDialog?.id == dialog.id)
        #expect(renderState.isPresented == false)

        renderState.finishDismissalIfNeeded()

        #expect(renderState.renderedDialog == nil)
        #expect(renderState.isPresented == false)
    }

    @Test
    func overlayHostComposesSingleOverlayContent() {
        let view = ZenOverlayHost(
            configuration: .centeredModal(
                overlayTransition: .opacity,
                scrimPresentAnimation: .easeOut(duration: 0.16),
                scrimDismissAnimation: .easeOut(duration: 0.12),
                presentAnimation: .easeInOut(duration: 0.2),
                dismissAnimation: .easeOut(duration: 0.16)
            )
        ) {
            Color.clear
        } overlay: {
            Text("Overlay")
        }

        _ = view
    }

    @Test
    func overlayRootComposesWrappedContent() {
        let view = ZenOverlayRoot {
            Text("Root")
        }

        _ = view
    }

    @Test
    func presentedConfirmationDialogStillComposesInPublicSurfaceSmokeView() {
        let view = ZenOverlayRoot {
            ZenConfirmationDialog(
                title: "Delete workspace?",
                message: "This action cannot be undone.",
                isPresented: .constant(true),
                actions: [
                    ZenConfirmationDialogAction("Cancel", role: .cancel) {},
                    ZenConfirmationDialogAction("Delete", role: .destructive) {},
                ]
            ) {
                ZenButton("Open dialog") {}
            }
        }

        _ = view
    }

    @Test
    func reusablePrimitivesComposeForSettingsAndLoadingStates() {
        let view = VStack(spacing: ZenSpacing.small) {
            ZenBadge("Active", tone: .success)
            ZenBadge("Selected", isSelected: true) {}
            ZenBadge("Swift", onRemove: {})
            ZenBadge("Design", tone: .warning, isSelected: true, action: {}, onRemove: {})

            ZenSection {
                ZenNavigationRow(
                    title: "Members",
                    subtitle: "Manage access",
                    leadingIconAsset: "UsersThree"
                )
            } header: {
                ZenSectionHeader {
                    Text("Workspace")
                } subtitle: {
                    Text("Shared settings")
                }
            } footer: {
                ZenSectionFooter {
                    Text("Admins can update access.")
                }
            }

            ZenSkeleton(width: 120, height: 16)
        }

        _ = view
    }

    @Test
    func settingsPrimitivesComposeInsideZenCard() {
        let view = ZenCard {
            ZenCardHeader(
                title: "Notifications",
                subtitle: "Manage delivery settings",
                leadingIconSystemName: "bell.badge.fill",
                iconTint: .zenPrimary
            )

            ZenSettingGroup {
                ZenSettingRow(
                    title: "Access",
                    subtitle: "System permission granted",
                    leadingIconSystemName: "checkmark.circle.fill"
                ) {
                    Text("Enabled")
                }

                ZenPickerRow(
                    title: "Language",
                    subtitle: "Used for notifications",
                    leadingIconSystemName: "globe",
                    selection: .constant(NotificationLanguage.english),
                    options: NotificationLanguage.allCases
                ) { option in
                    Text(option.rawValue)
                }
            }
        }

        _ = view
    }

    @Test
    func navigationRowUsesSubtleLeadingIconBadgeStyling() {
        #expect(ZenNavigationRow.leadingIconBadgeSize == 28)
        #expect(ZenNavigationRow.leadingIconBadgeCornerRadius == 10)
    }

    @Test
    func catalogComponentsRenderTogether() {
        let view = ZenScreen(header: {
            ZenScreenHeader(title: "Catalog")
        }) {
            VStack(spacing: ZenSpacing.small) {
                ZenBadge("Beta")
                ZenSkeleton(height: 14)
                ZenSection {
                    ZenField(label: "Email") {
                        ZenTextInput(text: .constant(""), prompt: "Email")
                    }
                } header: {
                    ZenSectionHeader {
                        Text("Inputs")
                    }
                }
            }
        }

        _ = view
    }

    @Test
    func themeAndCoreHostsComposeForPackageConsumers() {
        ZenTheme.apply(.default)

        let view = ZenScreen(header: {
            ZenScreenHeader(title: "Host")
        }) {
            ZenStatusBanner(message: "Ready")
        }

        _ = view
    }

    @Test
    func squareCornerThemeComposesAcrossShapeVariants() {
        ZenTheme.apply(ZenTheme(cornerStyle: .none))

        let view = VStack(spacing: ZenSpacing.small) {
            ZenButton("Square") {}
            ZenBadge("Neutral")
            ZenProgressBar(progress: 0.6)
            ZenAvatar(name: "Alex Morgan", imageURL: nil)
            ZenSpinner()
            ZenStatRow(
                title: "Workspace",
                subtitle: "Metrics",
                metrics: [ZenMetricValue(label: "CTR", value: "4.2%")]
            )
        }

        _ = view
    }

    @Test
    func zenScreenSupportsInlineTitleHeaderAndBidirectionalToolbarContent() {
        let view = NavigationStack {
            ZenScreen(
                navigationTitle: ZenScreenTitle(
                    "Dashboard",
                    leadingIconAsset: "ChartBar",
                    trailingIconAsset: "Lightning"
                ),
                navigationBarTitleDisplayMode: .inline,
                backButton: ZenScreenBackButton("Overview"),
                header: {
                    VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                        Text("Custom intro")
                            .font(.zenTitle)
                        Text("Summary below the custom bar")
                            .font(.zenCaption)
                    }
                },
                toolbarLeading: {
                    ZenIcon(assetName: "Sidebar", size: 18)
                },
                toolbarTrailing: {
                    ZenIcon(assetName: "UserCircle", size: 18)
                }
            ) {
                ZenStatusBanner(message: "Ready")
            }
        }

        _ = view
    }

    @Test
    func zenScreenSupportsPrincipalToolbarContent() {
        let view = NavigationStack {
            ZenScreen(
                navigationTitle: ZenScreenTitle("Dashboard"),
                navigationBarTitleDisplayMode: .inline,
                header: {
                    EmptyView()
                },
                toolbarPrincipal: {
                    Text("Zen")
                },
                toolbarTrailing: {
                    ZenIcon(assetName: "UserCircle", size: 18)
                }
            ) {
                ZenStatusBanner(message: "Ready")
            }
        }

        _ = view
    }

    @Test
    func zenScreenSupportsLargeTitleWithBodyHeaderContent() {
        let view = NavigationStack {
            ZenScreen(
                navigationTitle: ZenScreenTitle("Reports"),
                navigationBarTitleDisplayMode: .large,
                header: {
                    VStack(alignment: .leading, spacing: ZenSpacing.xSmall) {
                        Text("Weekly summary")
                            .font(.zenTitle)
                        Text("Body content should remain separate from native navigation")
                            .font(.zenCaption)
                    }
                }
            ) {
                ZenStatusBanner(message: "Ready")
            }
        }

        _ = view
    }

    @Test
    func zenScreenSupportsCustomBackOverrideWithToolbarContent() {
        let view = NavigationStack {
            ZenScreen(
                navigationTitle: ZenScreenTitle("Detail"),
                navigationBarTitleDisplayMode: .inline,
                backButton: ZenScreenBackButton("Dashboard") {},
                header: {
                    EmptyView()
                },
                toolbarTrailing: {
                    ZenIcon(assetName: "DotsThree", size: 18)
                }
            ) {
                ZenStatusBanner(message: "Ready")
            }
        }

        _ = view
    }

    @Test
    func zenScreenSupportsPullToRefresh() {
        let view = NavigationStack {
            ZenScreen(
                navigationTitle: ZenScreenTitle("Dashboard"),
                onRefresh: {}
            ) {
                ZenStatusBanner(message: "Ready")
            }
        }

        _ = view
    }

    @Test
    func zenScreensAllowOptingOutOfHiddenSharedToolbarBackground() {
        let screen = NavigationStack {
            ZenScreen(
                navigationTitle: ZenScreenTitle("Dashboard"),
                hidesSharedToolbarBackground: false,
                header: {
                    EmptyView()
                },
                toolbarTrailing: {
                    ZenIcon(assetName: "UserCircle", size: 18)
                }
            ) {
                ZenStatusBanner(message: "Ready")
            }
        }

        let listScreen = NavigationStack {
            ZenListScreen(
                navigationTitle: "Settings",
                hidesSharedToolbarBackground: false,
                toolbarTrailing: {
                    ZenButton("Edit", variant: .secondary, size: .sm) {}
                }
            ) {
                Section("Workspace") {
                    ZenNavigationRow(
                        title: "Members",
                        subtitle: "Manage access",
                        leadingIconAsset: "UsersThree"
                    )
                }
            }
        }

        _ = screen
        _ = listScreen
    }

    @Test
    func zenScreenNavigationContextModifierPublishesDefaults() {
        let view = NavigationStack {
            ZenScreen(
                navigationTitle: ZenScreenTitle("Child"),
                navigationBarTitleDisplayMode: .large
            ) {
                ZenStatusBanner(message: "Ready")
            }
            .zenScreenNavigationContext(
                title: ZenScreenTitle("Parent"),
                backButton: ZenScreenBackButton("Workspace")
            )
        }

        _ = view
    }

    @Test
    func zenNavigationLinkPublishesBackTitleToDestination() {
        let view = NavigationStack {
            ZenScreen(navigationTitle: ZenScreenTitle("Parent")) {
                ZenNavigationLink {
                    ZenScreen(navigationTitle: ZenScreenTitle("Child")) {
                        ZenStatusBanner(message: "Ready")
                    }
                } label: {
                    Text("Open")
                }
            }
        }

        _ = view
    }

    @Test
    func zenScreenSupportsPlainScrollContainerWithoutNavigationTitle() {
        let view = ZenScreen(header: {
            Text("Standalone intro")
                .font(.zenTitle)
        }) {
            ZenStatusBanner(message: "Ready")
        }

        _ = view
    }

    @Test
    func emptySupportsCustomMediaAndCustomContent() {
        let view = ZenEmpty {
            ZenEmptyHeader {
                ZenEmptyMedia {
                    Circle()
                        .fill(Color.zenSurfaceMuted)
                        .frame(width: 40, height: 40)
                }
                ZenEmptyTitle {
                    Text("No members")
                }
                ZenEmptyDescription {
                    Text("Invite someone to get started.")
                }
            }
            ZenEmptyContent {
                TextField("Email", text: .constant(""))
            }
        }

        _ = view
    }

    @Test
    func emptyUsesSinglePlainSurfaceStyle() {
        let view = ZenEmpty {
                ZenEmptyHeader {
                    ZenEmptyMedia(variant: .icon) {
                        ZenIcon(assetName: "Tray", size: 24)
                    }
                ZenEmptyTitle {
                    Text("Nothing here yet")
                }
                ZenEmptyDescription {
                    Text("Create an item to get started.")
                }
            }
            ZenEmptyContent {
                ZenButton("Create item", fullWidth: true) {}
            }
        }

        _ = view
    }

    @Test
    func secondaryGhostAndLinkResolveToDistinctStyles() {
        let secondary = ZenButtonResolvedStyle(variant: .secondary)
        let ghost = ZenButtonResolvedStyle(variant: .ghost)
        let link = ZenButtonResolvedStyle(variant: .link)

        #expect(secondary.backgroundStyle != ghost.backgroundStyle)
        #expect(ghost.foregroundStyle != link.foregroundStyle)
        #expect(link.isTextOnly)
        #expect(!ghost.isTextOnly)
    }

    @Test
    func filledAndDestructiveButtonsUseSemanticPressedVariants() {
        let colors = ZenTheme.default.resolvedColors
        let filled = ZenButtonResolvedStyle(variant: .default)
        let destructive = ZenButtonResolvedStyle(variant: .destructive)

        #expect(filled.pressedBackgroundToken == colors.primaryPressed)
        #expect(destructive.pressedBackgroundToken == colors.criticalPressed)
    }

    @Test
    func inlineActionResolvesAccentCaptionStylingFromTheme() {
        let style = ZenInlineActionResolvedStyle()
        let caption = ZenTheme.current.resolvedTypography.fontSpec(for: .caption)

        #expect(style.fontSpec.familyRole == caption.familyRole)
        #expect(style.fontSpec.size == caption.size)
        #expect(style.fontSpec.source == caption.source)
        #expect(style.fontSpec.resolvedSource == caption.resolvedSource)
        #expect(style.fontSpec.weight == .semibold)
        #expect(style.foregroundStyle == .accent)
    }

    @Test
    func customThemeColorsComposeAcrossCoreSurfaceComponents() {
        let originalTheme = ZenTheme.current
        defer {
            ZenTheme.apply(originalTheme)
        }

        ZenTheme.apply(
            ZenTheme(
                colors: ZenThemeColors(
                    background: ZenNativeThemeTokens.defaultResolvedColors.background,
                    surface: ZenNativeThemeTokens.defaultResolvedColors.surface,
                    surfaceMuted: ZenNativeThemeTokens.defaultResolvedColors.surfaceMuted,
                    border: ZenNativeThemeTokens.defaultResolvedColors.border,
                    textPrimary: ZenNativeThemeTokens.defaultResolvedColors.textPrimary,
                    textMuted: ZenNativeThemeTokens.defaultResolvedColors.textMuted,
                    accent: .init(light: .rgb(0.0, 0.6275, 0.702), dark: .rgb(0.2784, 0.7765, 0.8314)),
                    primary: .init(light: .rgb(0.1294, 0.3882, 0.9725), dark: .rgb(0.3765, 0.6471, 0.9804)),
                    primaryPressed: ZenNativeThemeTokens.defaultResolvedColors.primaryPressed,
                    primarySubtle: ZenNativeThemeTokens.defaultResolvedColors.primarySubtle,
                    primaryForeground: ZenNativeThemeTokens.defaultResolvedColors.primaryForeground,
                    focusRing: ZenNativeThemeTokens.defaultResolvedColors.focusRing,
                    success: ZenNativeThemeTokens.defaultResolvedColors.success,
                    successSubtle: ZenNativeThemeTokens.defaultResolvedColors.successSubtle,
                    successBorder: ZenNativeThemeTokens.defaultResolvedColors.successBorder,
                    warning: ZenNativeThemeTokens.defaultResolvedColors.warning,
                    warningSubtle: ZenNativeThemeTokens.defaultResolvedColors.warningSubtle,
                    warningBorder: ZenNativeThemeTokens.defaultResolvedColors.warningBorder,
                    critical: ZenNativeThemeTokens.defaultResolvedColors.critical,
                    criticalPressed: ZenNativeThemeTokens.defaultResolvedColors.criticalPressed,
                    criticalSubtle: ZenNativeThemeTokens.defaultResolvedColors.criticalSubtle,
                    criticalBorder: ZenNativeThemeTokens.defaultResolvedColors.criticalBorder
                )
            )
        )

        let view = VStack(spacing: ZenSpacing.medium) {
            ZenCard(title: "Palette", subtitle: "Preview workbench") {
                VStack(alignment: .leading, spacing: ZenSpacing.small) {
                    ZenInfoCard(title: "Primary", value: "#2163F8")
                    ZenButton("Apply Theme") {}
                    ZenTextInput(
                        text: .constant("#00A0B3"),
                        prompt: "Accent hex"
                    )
                    ZenNavigationRow(
                        title: "Review Components",
                        subtitle: "Cards, buttons and text fields",
                        leadingIconAsset: "Swatches"
                    )
                }
            }
        }

        _ = view
    }

    @Test
    func zenSymbolReplaceTransitionCompilesForSymbolViews() {
        let iconAsset = ProcessInfo.processInfo.environment["ZENKIT_ICON_ASSET"] ?? "Star"
        let view = Label {
            Text("Toggle Favorite")
        } icon: {
            ZenIcon(assetName: iconAsset, size: 16)
        }
            .zenSymbolReplaceTransition()

        _ = view
    }

    #if canImport(AppKit)
    @Test
    @MainActor
    func defaultButtonKeepsCompactZenKitHeight() {
        let host = NSHostingView(rootView: ZenButton("Continue") {})
        let size = host.fittingSize

        #expect(size.height <= 48)
    }

    @Test
    @MainActor
    func iconOnlyLoadingButtonStaysSquare() {
        let host = NSHostingView(
            rootView: ZenButton(variant: .secondary, size: .iconSm, isLoading: true) {
            } label: {
                ZenIcon(assetName: "ArrowsClockwise", size: 14)
            }
        )
        let size = host.fittingSize

        #expect(abs(size.width - size.height) <= 2)
    }

    @Test
    @MainActor
    func standaloneSpinnerRespectsLargeSizing() {
        let host = NSHostingView(
            rootView: ZenSpinner(size: .large)
        )
        let size = host.fittingSize

        #expect(size.width >= 24)
        #expect(abs(size.width - size.height) <= 1)
    }

    @Test
    @MainActor
    func segmentedControlKeepsCompactZenKitHeight() {
        let host = NSHostingView(
            rootView: ZenSegmentedControl(
                selection: .constant(Filter.all),
                segments: Filter.allCases
            ) { value, _ in
                Text(value.rawValue)
            }
        )
        let size = host.fittingSize

        #expect(size.height <= 48)
    }
    #endif

    @Test
    func metricsTableTypesAreAvailableFromPublicSurface() {
        let segment = ZenMetricsTableSegment(
            id: "all",
            count: 3,
            iconAssetName: "Hash",
            title: "All"
        )
        let values = ZenMetricsTableValues(
            clicks: "120",
            impressions: "4.2K",
            ctr: "2.9%",
            position: "3.1"
        )

        #expect(segment.title == "All")
        #expect(segment.count == 3)
        #expect(values.clicks == "120")
        #expect(values.position == "3.1")
    }

    @Test
    func metricsTableHeaderUsesWebMetricOrder() {
        #expect(ZenMetricsTableHeader.defaultTitles == ["Clicks", "Impr.", "CTR", "Pos."])
    }

    @Test
    func metricsTableValueColorsMatchDashboardPalette() {
        let palette = ZenMetricsTableValues.defaultPalette

        #expect(palette.clicksRole == .clicks)
        #expect(palette.impressionsRole == .impressions)
        #expect(palette.ctrRole == .ctr)
        #expect(palette.positionRole == .position)
    }

    @Test
    func zenListScreenHostsNativeListContent() {
        let view = NavigationStack {
            ZenListScreen(
                navigationTitle: "Settings",
                onRefresh: {},
                toolbarLeading: {
                    ZenButton("Back", variant: .ghost, size: .sm) {}
                },
                toolbarTrailing: {
                    ZenButton("Edit", variant: .secondary, size: .sm) {}
                }
            ) {
                Section("Workspace") {
                    ZenNavigationRow(
                        title: "Members",
                        subtitle: "Manage access",
                        leadingIconAsset: "UsersThree"
                    )
                }
            }
        }

        _ = view
    }

    @Test
    func timelinePrimitivesComposeFromPublicSurface() {
        let view = ZenTimeline {
            ZenTimelineItem(showsSeparator: false) {
                ZenTimelineIndicator {
                    ZenIcon(systemName: "plus.circle.fill", size: 12)
                }
            } header: {
                ZenTimelineHeader {
                    ZenTimelineTitle("Task created")
                    ZenTimelineDate("9:00 AM")
                }
            } separator: {
                ZenTimelineSeparator()
            } content: {
                ZenTimelineContent {
                    Text("Created by Alex Johnson")
                }
            }
        }

        _ = view
    }

    @Test
    func timelinePrimitivesExposeExpectedLayoutMetrics() {
        #expect(ZenTimelineIndicator.defaultSize == 28)
        #expect(ZenTimelineSeparator.lineWidth == 1)
    }

    @Test
    func timelinePrimitivesUsePrimaryAxisStylingByDefault() {
        let indicatorStyle = ZenTimelineIndicatorResolvedStyle()
        let separatorStyle = ZenTimelineSeparatorResolvedStyle()

        #expect(indicatorStyle.backgroundRole == .textPrimary)
        #expect(indicatorStyle.foregroundRole == .background)
        #expect(separatorStyle.colorRole == .textPrimary)
    }
}
