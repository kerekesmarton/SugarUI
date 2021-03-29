//
//  Coordinator.swift
//  RouterWithModifiers
//
//  Created by Ihor Vovk on 02.09.2020.
//

import SwiftUI


/**
```
class PresentingRouter: Router, PresentingRouterProtocol {

    func pushDetails(text: String) {
         navigateTo (
             PresentedView(text: text, router: Router(isPresented: isNavigating))
         )
    }

    func presentDetails(text: String) {
         presentSheet (
             PresentedView(text: text, router: Router(isPresented: isPresentingSheet))
         )
    }
 }

struct PresentingView: View {

    @StateObject private var router: PresentingRouter

    var body: some View {
        NavigationView {
        Button(action: {
            router.presentDetails(text: "Details")
        }) {
            Text("Present Details").padding()
        }.sheet(router)

        Button(action: {
             router.showDetails(text: "Details")
        }) {
             Text("Present Details").padding()
        }.navigation(router)
    }
}
```
 */
open class Router {
    
    struct State {
        var navigating: AnyView? = nil
        var presentingSheet: AnyView? = nil
        var isPresented: Binding<Bool>
    }
    
    @Published private(set) var state: State
    
    public init(isPresented: Binding<Bool>) {
        state = State(isPresented: isPresented)
    }
}

public extension Router {
    
    func navigateTo<V: View>(_ view: V) {
        state.navigating = AnyView(view)
    }
    
    func presentSheet<V: View>(_ view: V) {
        state.presentingSheet = AnyView(view)
    }
    
    func dismiss() {
        state.isPresented.wrappedValue = false
    }
}

public extension Router {
    
    var isNavigating: Binding<Bool> {
        boolBinding(keyPath: \.navigating)
    }
    
    var isPresentingSheet: Binding<Bool> {
        boolBinding(keyPath: \.presentingSheet)
    }
    
    var isPresented: Binding<Bool> {
        state.isPresented
    }
}

private extension Router {
    
    func binding<T>(keyPath: WritableKeyPath<State, T>) -> Binding<T> {
        Binding(
            get: { self.state[keyPath: keyPath] },
            set: { self.state[keyPath: keyPath] = $0 }
        )
    }
    
    func boolBinding<T>(keyPath: WritableKeyPath<State, T?>) -> Binding<Bool> {
        Binding(
            get: { self.state[keyPath: keyPath] != nil },
            set: {
                if !$0 {
                    self.state[keyPath: keyPath] = nil
                }
            }
        )
    }
}

public extension View {
    
    func navigation(_ router: Router) -> some View {
        self.modifier(NavigationModifier(presentingView: router.binding(keyPath: \.navigating)))
    }
    
    func sheet(_ router: Router) -> some View {
        self.modifier(SheetModifier(presentingView: router.binding(keyPath: \.presentingSheet)))
    }
}

struct SheetModifier: ViewModifier {

    @Binding var presentingView: AnyView?

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: Binding(
                get: { self.presentingView != nil },
                set: { if !$0 {
                    self.presentingView = nil
                }})
            ) {
                self.presentingView
            }
    }
}

struct NavigationModifier: ViewModifier {

    @Binding var presentingView: AnyView?

    func body(content: Content) -> some View {
        content
            .background(
                NavigationLink(destination: self.presentingView, isActive: Binding(
                    get: { self.presentingView != nil },
                    set: { if !$0 {
                        self.presentingView = nil
                    }})
                ) {
                    EmptyView()
                }
            )
    }
}
