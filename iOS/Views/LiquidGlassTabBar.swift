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

    // Règle :
    //   - Onglet actif         → capsule seule, contenu accentué
    //   - Groupe de 1 inactif  → capsule seule, contenu neutre
    //   - Groupe de 2+ inactifs → pill fusionnée (glassEffectUnion "left" / "right")
    private enum TabShape {
        case active
        case isolated
        case grouped(String) // "left" ou "right"
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
            // Capsule seule, contenu violet — fond glass neutre (pas de tint sur le glass)
            Button {} label: {
                itemContent(icon: item.iconFill, label: item.label, isAccent: true)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive())
            .glassEffectID(item.id, in: namespace)

        case .isolated:
            // Capsule seule, contenu neutre — même taille que les items dans la pill
            Button {
                withAnimation(.smooth(duration: 0.55)) { selection = item.tab }
            } label: {
                itemContent(icon: item.icon, label: item.label, isAccent: false)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive())
            .glassEffectID(item.id, in: namespace)

        case .grouped(let groupID):
            // Pill groupée — plusieurs inactifs fusionnés dans une même capsule
            Button {
                withAnimation(.smooth(duration: 0.55)) { selection = item.tab }
            } label: {
                itemContent(icon: item.icon, label: item.label, isAccent: false)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive())
            .glassEffectUnion(id: groupID, namespace: namespace)
            .glassEffectID(item.id, in: namespace)
        }
    }

    // Contenu identique pour tous les états → hauteur toujours cohérente
    private func itemContent(icon: String, label: String, isAccent: Bool) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
            Text(label)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundStyle(isAccent ? AppTheme.Colors.accent : Color.primary.opacity(0.6))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }
}
