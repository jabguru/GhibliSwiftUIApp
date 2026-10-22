# SwiftUI design & animation, the Flutter way

This app's UI shows off one SwiftUI technique per feature. This guide maps each one to the
Flutter idea you already know, then points you to the exact line where it's used, with a
small experiment to try. Open the file, change the number, and watch the `#Preview` update.

---

## 1. Cheat sheet: Flutter → SwiftUI

| Flutter | SwiftUI | Notes |
|---|---|---|
| `Widget` | `View` | A struct with a `body`. Views are cheap values, rebuilt constantly, like widgets. |
| `StatelessWidget` | `struct … : View` | Default. |
| `StatefulWidget` + `setState` | `@State private var x` | Mutating `x` re-runs `body`. No `setState` call needed. |
| `ChangeNotifier` / `Provider` | `@Observable class` | See `FilmsViewModel`. Views re-render when properties they *read* change. |
| `Theme.of(context)`, `InheritedWidget` | `@Environment(\.theme)` | Values flow down the tree. See `Design/Theme.swift`. |
| `SharedPreferences` | `@AppStorage("key")` | A property that reads and writes `UserDefaults` and re-renders on change. |
| `initState` async work / `dispose` | `.task { }` | Starts when the view appears and is **auto-cancelled** when it disappears. |
| `Column` / `Row` / `Stack` | `VStack` / `HStack` / `ZStack` | |
| `Container(decoration:)` | `.background`, `.clipShape`, `.overlay`, `.shadow` | SwiftUI composes small modifiers instead of one big widget. **Order matters**: each modifier wraps everything before it. |
| `AspectRatio` | `.aspectRatio(2/3, contentMode: .fit)` | |
| `ListView.builder` / `GridView` | `LazyVStack` / `LazyVGrid` in a `ScrollView` | |
| `PageView` | `ScrollView` + `.scrollTargetBehavior(.viewAligned)` | See `HeroCarousel`. |
| Wrapper widget you reuse | `ViewModifier` + an extension method | e.g. `.shimmer()`, `.staggeredAppear(index:)`. |
| `CustomPainter` | `Shape` (animatable) or `Canvas` (immediate mode) | |
| `HapticFeedback` | `.sensoryFeedback(_:trigger:)` | Declarative: fires when the trigger value changes. |

### The three kinds of animation

| Flutter | SwiftUI | When to use |
|---|---|---|
| `AnimatedContainer`, `AnimatedOpacity`… (implicit) | `.animation(.spring, value: x)` | "Whenever `x` changes, animate the modifiers above me." |
| `controller.forward()` (explicit) | `withAnimation(.snappy) { x.toggle() }` | "Animate *everything* this state change affects, anywhere on screen." |
| `AnimationController` + `Ticker` | `TimelineView`, `PhaseAnimator`, `KeyframeAnimator` | Continuous, looping or multi-step choreography. |

There is no controller to create or dispose. You change state, and SwiftUI interpolates between the
old and new view trees. **Curves** are values like `.spring(response:dampingFraction:)`, `.smooth`,
`.snappy`, `.bouncy` and `.easeInOut(duration:)`.

### Transitions = `AnimatedSwitcher`
When a view is **inserted or removed** (an `if`, a `switch` case, a `ForEach` item), its
`.transition(...)` decides how it enters and leaves. Transitions only run inside an animation
(`withAnimation` or `.animation(_:value:)`).

---

## 2. Tour of the app

### The theme (`ThemeData`)
- `GhibliSwiftUIApp/Design/Theme.swift:93`: `@Entry var theme` adds the theme to the environment.
- `GhibliSwiftUIApp/Design/Theme.swift:98`: `.ghibliTheme()` picks pastel or cinematic from light/dark mode. It's applied once in `ContentView`.
- **Try:** change `accent` in `static let pastel` and see every button, ring and dot update.

### Living background (`AnimationController` + `CustomPainter`)
- `GhibliSwiftUIApp/Design/AnimatedBackground.swift:21`: `TimelineView(.animation)` gives you the time every frame. Everything is a pure function of `t`.
- `GhibliSwiftUIApp/Design/AnimatedBackground.swift:25`: `MeshGradient`, a 3x3 grid of colors whose middle points wobble.
- `GhibliSwiftUIApp/Design/AnimatedBackground.swift:69`: `Canvas` paints the clouds (and the stars at line 111).
- **Try:** change `0.35` in `meshPoints(at:)` to `2` for a lava lamp.

### Press feedback (`GestureDetector` + `AnimatedScale`)
- `GhibliSwiftUIApp/Design/PressableButtonStyle.swift:13`: a `ButtonStyle` gets `isPressed` for free.
- `GhibliSwiftUIApp/Design/PressableButtonStyle.swift:22`: an implicit `.animation(_, value:)`.
- **Try:** change `scale: 0.95` to `0.8` and `dampingFraction` to `0.3` for a jelly effect.

### Shimmer skeletons (`shimmer` package)
- `GhibliSwiftUIApp/Design/Shimmer.swift:27`: `visualEffect` reads the view's size without a `GeometryReader`.
- `GhibliSwiftUIApp/Design/Shimmer.swift:36`: `withAnimation(...repeatForever)` is `controller.repeat()`.

### Staggered entrance (`flutter_staggered_animations`)
- `GhibliSwiftUIApp/Design/StaggeredAppear.swift:12`: each item fades and slides in after `index × 0.06s`.
- **Try:** set `baseDelay` to `0.2` and watch the grid cascade.

### Animated custom shape (`CustomPainter` + `Tween`)
- `GhibliSwiftUIApp/Design/ScoreRing.swift:19`: `animatableData` is the value SwiftUI interpolates every frame.
- `GhibliSwiftUIApp/Design/ScoreRing.swift:59`: `.contentTransition(.numericText())` rolls the digits.

### Image loading (`AnimatedSwitcher` around `FadeInImage`)
- `GhibliSwiftUIApp/Views/FilmImageView.swift:28`: a `transaction` animates every phase change.
- `GhibliSwiftUIApp/Views/FilmImageView.swift:38`: `.blurReplace`, so images sharpen in from a blur.

### Hero zoom into the detail screen (`Hero` / `OpenContainer`)
- `GhibliSwiftUIApp/Views/FilmListView.swift:30`: the `@Namespace` is the shared "tag space".
- `GhibliSwiftUIApp/Views/FilmListView.swift:75`: `.matchedTransitionSource` marks the card to zoom out of.
- `GhibliSwiftUIApp/Views/FilmListView.swift:67`: `.navigationTransition(.zoom(...))` on the destination. Swipe back slowly: the screen shrinks back into the card interactively.

### Animated list removal (`AnimatedList`)
- `GhibliSwiftUIApp/Views/FilmListView.swift:53`: asymmetric insert/remove transitions.
- See it on the **Favorites** tab: un-heart a film and the card shrinks away.

### Carousel (`PageView` + `Transform`)
- `GhibliSwiftUIApp/Views/HeroCarousel.swift:41`: `.scrollTransition` maps scroll position (−1…0…1) to a scale and opacity.
- `GhibliSwiftUIApp/Views/HeroCarousel.swift:102`: the same tool used for a subtle parallax on the artwork.
- `GhibliSwiftUIApp/Views/HeroCarousel.swift:55`: `.scrollPosition(id:)` two-way binds the current page (like a `PageController`).
- `GhibliSwiftUIApp/Views/HeroCarousel.swift:65`: `.task` loop auto-advances every 5s (a `Timer.periodic` that cancels itself).
- **Try:** change the parallax offset from `-20` to `-80` and the auto-advance curve from `.snappy(duration: 0.45)` to `.smooth(duration: 1.2)`, and feel how quickly motion starts to look forced. Subtle usually wins.

### Heart burst (`TweenSequence` × several properties)
- `GhibliSwiftUIApp/Views/FavoriteButton.swift:39`: SF Symbols morph from outline to filled.
- `GhibliSwiftUIApp/Views/FavoriteButton.swift:41`: `.symbolEffect(.bounce)`.
- `GhibliSwiftUIApp/Views/FavoriteButton.swift:77`: `KeyframeAnimator`, one track per property (radius, scale, opacity).
- `GhibliSwiftUIApp/Views/FavoriteButton.swift:53`: haptics with `.sensoryFeedback`.

### Looping idle motion (`TweenSequence` on repeat)
- `GhibliSwiftUIApp/Views/StateViews.swift:38`: `.phaseAnimator([false, true])` floats the icon forever.

### Stretchy, parallax header (`SliverAppBar(stretch: true)`)
- `GhibliSwiftUIApp/Views/FilmDetailScreen.swift:46`: `onScrollGeometryChange` is your `ScrollController` listener.
- `GhibliSwiftUIApp/Views/FilmDetailScreen.swift:75`: `StretchyBanner` grows when you pull down, and lags and blurs when you scroll up.
- `GhibliSwiftUIApp/Views/FilmDetailScreen.swift:97`: `.mask` with a gradient (Flutter: `ShaderMask`) fades the banner into the animated background, so there's no hard edge.

### Liquid Glass (`BackdropFilter`)
- `GhibliSwiftUIApp/Views/FilmDetailScreen.swift:153`: `GlassEffectContainer` groups glass shapes so they blend.
- `GhibliSwiftUIApp/Views/FilmDetailScreen.swift:188`: `.glassEffect(.regular, in: shape)`.

### Expand/collapse (`AnimatedSize`)
- `GhibliSwiftUIApp/Views/FilmDetailScreen.swift:231`: toggling `lineLimit`…
- `GhibliSwiftUIApp/Views/FilmDetailScreen.swift:237`: …inside `withAnimation` animates the height and the chevron together.

### Sliding selector pill (`AnimatedAlign` / in-screen `Hero`)
- `GhibliSwiftUIApp/Views/SettingsScreen.swift:123`: `matchedGeometryEffect`. Only the selected item draws the pill, and the shared ID makes it slide between items.
- `GhibliSwiftUIApp/Views/SettingsScreen.swift:61`: the stepper's number rolls with `numericText`.

---

## 3. Habits worth copying
- **Read tokens from the theme** (`@Environment(\.theme)`), never hard-code colors.
- **Respect Reduce Motion** (`@Environment(\.accessibilityReduceMotion)`). The background, shimmer, stagger and carousel all check it.
- **Modifier order matters.** `.padding().background()` ≠ `.background().padding()`, just as nesting order matters in Flutter.
- **Use `#Preview` like hot reload.** Every redesigned view has one, so you can tweak numbers and see the result instantly.
