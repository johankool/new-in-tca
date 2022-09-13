import SwiftUI
import DeckUI

extension ContentView {
  var deck: Deck {
    Deck(title: "What's New in TCA?", theme: .egeniq) {
      
      // MARK: Title
      Slide(alignment: .center) {
        Title("""
        What's New in
        The Composable Architecture?
        """)
        Words("Lunch lecture")
        Words("13 september 2022")
      }
      
      // MARK: Intro
      Slide {
        Title("What is TCA?")
        Columns {
          Column {
            Words("App architecture based on:")
            Bullets(style: .bullet) {
              Words("Reducer")
              Words("State")
              Words("Action")
              Words("Effect")
            }
            Words(" ")
            Words("Created by Brandon Williams and Stephen Celis at PointFree.co")
          }
          Column {
            Media(.assetImage("pointfree"))
          }
        }
      }
      
      Slide {
        Title("New Features", subtitle: "Exciting New Techniques!")
        // As announced at https://github.com/pointfreeco/swift-composable-architecture/discussions/1282
        
        Bullets(style: .bullet) {
          Words("async/await support")
          Words("protocol for reducers")
          Words("simplified composition of reducers")
          Words("improved dependency injection")
        }
      }
      
      // MARK: Concurrency
      Slide {
        Title("Concurrency", subtitle: "Creating Effect")
        
        Words("There are 2 distinct ways to create an Effect:")
        Bullets(style: .bullet) {
          Words("using Apple's Combine framework, and")
          Words("using Swift's native concurrency tools.")
        }
      }
      
      Slide {
        Title("Async/Await Support")
        
        Words("If using Swift's native structured concurrency tools\nthen there are 3 main ways to create an effect:")
        
        // <!-- depending on if you want to emit one single action back into the system, or any number of actions, or just execute some work without emitting any actions:-->
        Bullets(style: .bullet) {
          Words(".task")
          Words(".run")
          Words(".fireAndForget")
        }
      }

      Slide {
        Title("Effect.task", subtitle: "Emit one single action")
        
        Code(#"""
          struct Feature: ReducerProtocol {
            struct State { … }
            enum Action {
              case factButtonTapped
              case factResponse(TaskResult<String>)
            }
            @Dependency(\.numberFact) var numberFact

            func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
              switch action {
                case .factButtonTapped:
                  return .task { [number = state.number] in
                    await .factResponse(TaskResult { try await self.numberFact.fetch(number) })
                  }

                case let .factResponse(.success(fact)):
                  // do something with fact

                case let .factResponse(.failure(error)):
                  // handle error
              }
            }
          }
          """#)
      }

      Slide {
        Title("Effect.run", subtitle: "Emit any number of actions")
        
        Code(#"""
          struct LongLivingEffects: ReducerProtocol {
            struct State {
              var screenshotCount = 0
            }
            enum Action {
              case task
              case userDidTakeScreenshotNotification
            }

            @Dependency(\.screenshots) var screenshots
            func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
              switch action {
              case .task:
                // When the view appears, start the effect that emits when screenshots are taken.
                return .run { send in
                  for await _ in self.screenshots() {
                    send(.userDidTakeScreenshotNotification)
                  }
                }
              case .userDidTakeScreenshotNotification:
                state.screenshotCount += 1
                return .none
              }
            }
          }

          struct LongLivingEffectsView: View {
            let store: StoreOf<LongLivingEffects>

            var body: some View {
              WithViewStore(self.store) { viewStore in
                Text("Screenshots: \(viewStore.screenshotCount)")
                  .task { await viewStore.send(.task).finish() }
              }
            }
          }
          """#)
        // Cancelled when LongLivingEffectsView is not visible anymore.
      }

      Slide {
        Title("Effect.fireAndForget", subtitle: "Emit no actions")
        
        Code(#"""
          @Dependency(\.analytics) var analytics
          
          func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
            switch action {
            case .buttonTapped:
              return .fireAndForget {
                try await self.analytics.track("Button Tapped")
              }
            }
          }
          """#)
        
        // This effect is handy for executing some asynchronous work that your feature doesn't need to react to. One such example is analytics.
      }

      // MARK: Reducer Protocol
      Slide {
        Title("Introducing Reducer Protocol")
        
        Columns {
          Column {
            Words("Old")
            Code(#"""
              struct FeatureState { … }
               
              enum FeatureAction { … }
               
              struct FeatureEnvironment {
                var client: Client
                …
              }
               
              let featureReducer = Reducer<FeatureState, FeatureAction, FeatureEnvironment> { state, action, environment in
                …
              }
              """#)
          }
          
          Column {
            Words("New")
            Code(#"""
              struct Feature: ReducerProtocol {
                struct State { … }
                
                enum Action { … }
              
                let client: Client
              
                // either:
                func reduce(into state: inout State, action: Action) -> Effect<Action, Never> {
                  …
                }
              
                // or:
                var body: some ReducerProtocol<State, Action> {
                  …
                }
              }
              """#)
          }
        }
      }
      
//      Slide {
//        Title("Introducing Reducer Protocol")
//
//        Words("Benefits for new style:")
//        Bullets(style: .bullet) {
//          Words("Natural namespace for state and action types, no prefix needed.")
//          Words("Dedicated environment type is no longer needed.")
//          Words("Far less strain on the compiler.")
//        }
//      }
      
      // MARK: Composing Reducers
      Slide {
        Title("Composing Reducers", subtitle: "Merging and Scoping")
        
        Columns {
          Column {
            Words("Old")
            Code(#"""
              struct AppState {
                var activity: Activity.State
                var profile: Profile.State
                var settings: Settings.State
              }
              
              enum AppAction {
                case activity(Activity.Action)
                case profile(Profile.Action)
                case settings(Settings.Action)
              }
              
              struct AppEnvironment {
                …
              }
              
              let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
                activityReducer
                  .pullback(
                    state: \.activity,
                    action: /AppAction.activity,
                    environment: { … }),
                profileReducer
                  .pullback(
                    state: \.profile,
                    action: /AppAction.profile,
                    environment: { … }),
                settingsReducer
                  .pullback(
                    state: \.settings,
                    action: /AppAction.settings,
                    environment: { … })
              )
              """#)
          }
          
          Column {
            Words("New")
            Code(#"""
              struct App: ReducerProtocol {
                struct State {
                  var activity: Activity.State
                  var profile: Profile.State
                  var settings: Settings.State
                }
              
                enum Action {
                  case activity(Activity.Action)
                  case profile(Profile.Action)
                  case settings(Settings.Action)
                }
              
                var body: some ReducerProtocol<State, Action> {
                  Scope(state: \.activity, action: /Action.activity) {
                    Activity()
                  }
                  Scope(state: \.profile, action: /Action.profile) {
                    Profile()
                  }
                  Scope(state: \.settings, action: /Action.settings) {
                    Settings()
                  }
                }
              }
              """#)
            
            //      ^ Things to note:
            //      - builder context of body automatically combines reducers together
            //      - pullback operator has been reimagined as a Scope reducer
            //      - composing reducers has also improved: `ifLet`, `ifCaseLet`, and `forEach`.
            //      - drastically reduces stack size
          }
        }
      }
      
      Slide {
        Title("Composing Reducers", subtitle: "Optional State")
        Code(#"""
          struct App: ReducerProtocol {
            struct State {
              var activity: Activity.State
              var profile: Profile.State?
            }
            enum Action {
              case activity(Activity.Action)
              case profile(Profile.Action)
            }
            var body: some ReducerProtocol<State, Action> {
              Scope(state: \.activity, action: /Action.activity) {
                Activity()
              }
              .ifLet(\.profile, action: /Action.profile) {
                Profile()
              }
            }
          }
          """#)
      
      //      ^ Order used to be important. Now impossible to have wrong order.
      }
      
      // MARK: Injecting Dependencies
      Slide {
        Title("Injecting Dependencies")
        
        Columns {
          Column {
            Words("Old")
            Code(#"""
              struct FeatureEnvironment {
                var apiClient: APIClient
                var date: () -> Date
                var mainQueue: AnySchedulerOf<DispatchQueue>
              }
              
              struct ParentEnvironment {
                var apiClient: APIClient
                var date: () -> Date
                var mainQueue: AnySchedulerOf<DispatchQueue>
                var uuid: () -> UUID
              }
              
              featureReducer
                .pullback(
                  state: \.feature,
                  action: /ParentAction.feature,
                  environment: {
                    FeatureEnvironment(
                      apiClient: $0.apiClient,
                      date: $0.date,
                      mainQueue: $0.mainQueue
                    )
                  }
                )
              """#)
          }
          
          Column {
            Words("New")
            Code(#"""
              struct Feature: ReducerProtocol {
                @Dependency(\.apiClient) var apiClient
                @Dependency(\.date) var date
                @Dependency(\.mainQueue) var mainQueue
              }
              """#)
          }
        }
      }
      
      Slide {
        Title("Injecting Custom Dependencies")
        Words("Domain specific dependencies need to define key:")
        
        Code(#"""
          private enum APIClientKey: LiveDependencyKey {
            static let liveValue = APIClient.live
            static let testValue = APIClient.unimplemented
          }
          
          extension DependencyValues {
            var apiClient: APIClient {
              get { self[APIClientKey.self] }
              set { self[APIClientKey.self] = newValue }
            }
          }
          """#)
      }
    
      // MARK: Outro
//      Slide {
//        Title("Testability")
//      }
//
//      Slide {
//        Title("Downsides")
//
//        Words("In Unidirectional Data Flow architectures, the State should be the source of truth. Actions should be treated like functions in regular OOP programming. The problem is Enums in Swift doesn't have any access control.")
//
//        Words("When we observe our modules' actions in the higher order reducers, we look at the implementation detail of those features, which many would consider an anti-pattern.")
//
//        Words("https://www.merowing.info/boundries-in-tca/")
//
//
//        Words("Exhaustive testing in TCA")
//
//        Words("https://www.merowing.info/exhaustive-testing-in-tca/")
//
//      }
      
      Slide {
        Title("Requirements")
        
        Words("Runtime")
        Bullets(style: .bullet) {
          Words("iOS/iPadOS/tvOS 13")
          Words("macOS 10.15")
          Words("watchOS 6")
        }
        Words("")
        
        Words("Development*")
        Bullets(style: .bullet) {
          Words("Xcode 14")
          Words("Swift 5.7")
        }
        Words("* for all fancy features")
      }
      
      Slide {
        Title("Did you know?")
        Bullets(style: .bullet) {
          Words("fully backwards compatible")
          Words("step-by-step migration possible")
          Words("great with SwiftUI and UIKit")
          Words("introduced in PointFree podcast episode 201 (free)")
          Words("neat shortcut for Store<MyFeature.State, MyFeature.Action> is StoreOf<MyFeature>")
          Words("frequently mistyping State as Sate makes me hungry")
        }
      }
      
      Slide(alignment: .center) {
        Title("Questions?")
      }
      
      Slide {
        Title("Relevant Links")
        
        Words("Library:")
        Words("github.com/pointfreeco/swift-composable-architecture\n")
        
        Words("Video series:")
        Words("www.pointfree.co\n")
        
        Words("This presentation:")
        Words("github.com/johankool/new-in-tca\n")
        
        Words("Presentation created with:")
        Words("github.com/joshdholtz/DeckUI")
      }
    }
  }
}
