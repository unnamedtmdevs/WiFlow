import SwiftUI

extension View {
    /// Limits maximum content width for iPad adaptability
    func adaptiveMaxWidth() -> some View {
        self.frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
    }
    
    /// Adaptive padding for screens
    func adaptivePadding() -> some View {
        GeometryReader { geometry in
            self.padding(.horizontal, geometry.size.width > 600 ? 40 : AppTheme.screenPadding)
        }
    }
    
    /// Adaptive container with width constraint
    func adaptiveContainer() -> some View {
        self
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
    }
    
    /// Configure NavigationView for proper iPad operation
    func adaptiveNavigationView() -> some View {
        if #available(iOS 16.0, *) {
            return AnyView(self.navigationViewStyle(.stack))
        } else {
            return AnyView(self.navigationViewStyle(StackNavigationViewStyle()))
        }
    }
    
    /// Configure sheet presentation for iPad
    func adaptiveSheet<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return AnyView(
                self.sheet(isPresented: isPresented) {
                    NavigationView {
                        content()
                            .adaptiveMaxWidth()
                            .frame(maxWidth: .infinity)
                    }
                    .navigationViewStyle(.stack)
                }
            )
        } else {
            return AnyView(
                self.sheet(isPresented: isPresented) {
                    content()
                }
            )
        }
    }
    
    /// Configure sheet with item for iPad
    func adaptiveSheet<Item: Identifiable, Content: View>(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Content) -> some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return AnyView(
                self.sheet(item: item) { item in
                    NavigationView {
                        content(item)
                            .adaptiveMaxWidth()
                            .frame(maxWidth: .infinity)
                    }
                    .navigationViewStyle(.stack)
                }
            )
        } else {
            return AnyView(
                self.sheet(item: item) { item in
                    content(item)
                }
            )
        }
    }
}

