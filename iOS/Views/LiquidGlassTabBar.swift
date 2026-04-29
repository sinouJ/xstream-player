//
//  LiquidGlassTabBar.swift
//  xstream-player
//

import SwiftUI

struct LiquidGlassTabBar: View {
    @Binding var selection: AppTab
    @Namespace private var namespace

    private struct TabItem {
        let tab: AppTab
        let id: String
        let icon: String
        let iconFill: String
        let label: String
    }

    private let items: [TabItem] = [
        TabItem(tab: .home,      id: "home",      icon: "house",            iconFill: "house.fill",            label: "Accueil"),
        TabItem(tab: .library,   id: "library",   icon: "square.grid.2x2",  iconFill: "square.grid.2x2.fill",  label: "Librairie"),
        TabItem(tab: .downloads, id: "downloads", icon: "arrow.down.circle", iconFill: "arrow.down.circle.fill", label: "Téléchargés"),
        TabItem(tab: .search,    id: "search",    icon: "magnifyingglass",  iconFill: "magnifyingglass",        label: "Recherche"),
    ]

    private enum TabShape {
        case active
        case isolated
        case grouped(String)
    }

    private func tabShape(at index: Int) -> TabShape {
        let activeIndex = items.firstIndex(where: { $0.tab == selection }) ?? 0
        guard index != activeIndex else { return .active }

        let leftCount  = activeIndex
        let rightCount = items.count - activeIndex - 1

        if index < activeIndex {
            return leftCount == 1 ? .isolated : .grouped("left")
        } else {
            return rightCount == 1 ? .isolated : .grouped("right")
        }
    }

    var body: some View {
        GlassEffectContainer(spacing: 6) {
            HStack(spacing: 8) {
                ForEach(items.indices, id: \.self) { i in
                    tabButton(item: items[i], shape: tabShape(at: i))
                }
            }
            .padding(6)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.bottom, AppTheme.Spacing.xs)
    }

    @ViewBuilder
    private func tabButton(item: TabItem, shape: TabShape) -> some View {
        switch shape {
        case .active:
            // Cercle accentué — icône colorée, fond verre neutre (pas de tint sur le glass)
            Button {} label: {
                circleContent(icon: item.iconFill, label: item.label, isAccent: true)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: Circle())
            .glassEffectID(item.id, in: namespace)

        case .isolated:
            // Cercle neutre — seul de son côté, non accentué
            Button {
                withAnimation(.smooth(duration: 1.2)) { selection = item.tab }
            } label: {
                circleContent(icon: item.icon, label: item.label, isAccent: false)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: Circle())
            .glassEffectID(item.id, in: namespace)

        case .grouped(let groupID):
            // Pill groupée — plusieurs inactifs fusionnés côte à côte
            Button {
                withAnimation(.smooth(duration: 1.2)) { selection = item.tab }
            } label: {
                pillContent(icon: item.icon, label: item.label)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive())
            .glassEffectUnion(id: groupID, namespace: namespace)
            .glassEffectID(item.id, in: namespace)
        }
    }

    private func circleContent(icon: String, label: String, isAccent: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isAccent ? AppTheme.Colors.accent : Color.primary.opacity(0.6))
                .frame(width: 44, height: 44)
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
    }

    private func pillContent(icon: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(Color.primary.opacity(0.6))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
