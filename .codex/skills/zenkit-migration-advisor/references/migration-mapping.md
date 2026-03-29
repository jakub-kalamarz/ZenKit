# Migration Mapping

Use these defaults:

- `NavigationStack + ScrollView/VStack` -> `ZenScreen`
- `List` screens -> `ZenScreen(containerStyle: .list, ...)`
- `Form` sections with labels/messages -> `ZenFieldSection` + `ZenField` + input primitive
- button groups -> `ZenControlGroup` or `ZenButton` variants
- `Menu` flows -> `ZenMenu` stack
- empty/loading/status states -> `ZenEmpty`, `ZenLoading`, `ZenSkeleton`, `ZenStatusBanner`
- settings rows -> `ZenSettingGroup` + `ZenSettingRow`

Keep native SwiftUI when:

- the UI is highly custom and the catalog has no equivalent
- the requirement depends on unsupported platform behavior
- ZenKit would only wrap the same primitive without adding value
