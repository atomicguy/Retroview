//
//  Untitled.swift
//  Retroview
//
//  Created by Adam Schuster on 3/24/25.
//

import SwiftUI

struct VisibilityAwareScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let onScroll: ((ScrollVisibility) -> Void)?
    let content: () -> Content
    
    init(
        axes: Axis.Set = .vertical,
        showsIndicators: Bool = true,
        onScroll: ((ScrollVisibility) -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.onScroll = onScroll
        self.content = content
    }
    
    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: ScrollVisibility(
                                contentHeight: proxy.size.height,
                                offset: proxy.frame(in: .global).minY
                            )
                        )
                    }
                )
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { visibility in
            onScroll?(visibility)
        }
    }
}

struct ScrollVisibility: Equatable {  // Added Equatable conformance here
    let contentHeight: CGFloat
    let offset: CGFloat
    
    var topVisible: CGFloat {
        -offset
    }
    
    var bottomVisible: CGFloat {
        topVisible + contentHeight
    }
    
    // Swift automatically synthesizes the == function since all properties
    // are already Equatable
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: ScrollVisibility = ScrollVisibility(contentHeight: 0, offset: 0)
    
    static func reduce(value: inout ScrollVisibility, nextValue: () -> ScrollVisibility) {
        value = nextValue()
    }
}
