import SwiftUI

struct AllBadgesView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var showRedeemAlert = false
    @State private var redeemTargetId: Int?
    @State private var redeemResult = false

    private var badges: [BadgeDefinition] { AppState.allBadges }
    private var unlockedIds: Set<Int> { appState.userStats.unlockedBadgeIds }

    // 成就徽章（非积分兑换）
    private var achievementBadges: [BadgeDefinition] {
        badges.filter { $0.conditionType != .redeemPoints }
    }
    // 积分兑换徽章
    private var redeemBadges: [BadgeDefinition] {
        badges.filter { $0.conditionType == .redeemPoints }
    }

    private let columns = [
        GridItem(.flexible(), spacing: DS.Spacing.md),
        GridItem(.flexible(), spacing: DS.Spacing.md),
        GridItem(.flexible(), spacing: DS.Spacing.md),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: DS.Spacing.xl) {
                summaryHeader
                pointsBanner

                // 成就徽章
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DS.Colors.tertiary)
                        Text("成就徽章")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DS.Colors.onBackground)
                    }
                    .padding(.horizontal, DS.Spacing.lg)

                    LazyVGrid(columns: columns, spacing: DS.Spacing.lg) {
                        ForEach(achievementBadges) { badge in
                            badgeCard(badge)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                }

                // 积分兑换
                VStack(alignment: .leading, spacing: DS.Spacing.md) {
                    HStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(DS.Colors.secondary)
                        Text("积分兑换")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DS.Colors.onBackground)
                        Spacer()
                        Text("当前 \(appState.userStats.points) 积分")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(DS.Colors.onSurfaceVariant)
                    }
                    .padding(.horizontal, DS.Spacing.lg)

                    LazyVGrid(columns: columns, spacing: DS.Spacing.lg) {
                        ForEach(redeemBadges) { badge in
                            badgeCard(badge)
                        }
                    }
                    .padding(.horizontal, DS.Spacing.lg)
                }
            }
            .padding(.bottom, 40)
        }
        .background(DS.Colors.surface.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(DS.Colors.onBackground)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("我的徽章")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(DS.Colors.onBackground)
            }
        }
        .alert("兑换徽章", isPresented: $showRedeemAlert) {
            Button("取消", role: .cancel) {}
            Button("确认兑换") {
                if let id = redeemTargetId {
                    redeemResult = appState.redeemBadge(id)
                }
            }
        } message: {
            if let id = redeemTargetId, let badge = badges.first(where: { $0.id == id }) {
                Text("花费 \(badge.threshold) 积分兑换「\(badge.title)」？\n当前积分：\(appState.userStats.points)")
            }
        }
    }

    // MARK: - Summary
    private var summaryHeader: some View {
        VStack(spacing: DS.Spacing.sm) {
            let total = badges.count
            let unlocked = unlockedIds.count
            Text("\(unlocked)/\(total)")
                .font(.system(size: 36, weight: .heavy))
                .foregroundColor(DS.Colors.primary)
            Text("已解锁徽章")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(DS.Colors.onSurfaceVariant)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DS.Colors.surfaceContainer)
                        .frame(height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DS.Colors.primary)
                        .frame(width: geo.size.width * CGFloat(unlocked) / CGFloat(max(total, 1)), height: 10)
                }
            }
            .frame(height: 10)
            .padding(.horizontal, 60)
        }
        .padding(.top, DS.Spacing.lg)
    }

    // MARK: - Points Banner
    private var pointsBanner: some View {
        HStack {
            Image(systemName: "star.fill")
                .font(.system(size: 18))
                .foregroundColor(DS.Colors.secondary)
            Text("我的积分")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(DS.Colors.onBackground)
            Spacer()
            Text("\(appState.userStats.points)")
                .font(.system(size: 24, weight: .heavy))
                .foregroundColor(DS.Colors.primary)
        }
        .padding(DS.Spacing.md)
        .background(DS.Colors.primaryContainer.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .padding(.horizontal, DS.Spacing.lg)
    }

    // MARK: - Badge Card
    private func badgeCard(_ badge: BadgeDefinition) -> some View {
        let unlocked = unlockedIds.contains(badge.id)
        let isRedeemable = badge.conditionType == .redeemPoints && !unlocked

        return VStack(spacing: DS.Spacing.sm) {
            Image(badge.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(
                        unlocked ? DS.Colors.primary.opacity(0.3) : DS.Colors.outlineVariant.opacity(0.2),
                        lineWidth: 2
                    )
                )
                .grayscale(unlocked ? 0 : 1)
                .opacity(unlocked ? 1 : 0.4)

            Text(badge.title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(unlocked ? DS.Colors.onBackground : DS.Colors.onSurfaceVariant)
                .lineLimit(1)

            Text(badge.description)
                .font(.system(size: 10))
                .foregroundColor(DS.Colors.onSurfaceVariant)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 28)

            if isRedeemable {
                Button {
                    redeemTargetId = badge.id
                    showRedeemAlert = true
                } label: {
                    Text("\(badge.threshold) 积分兑换")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(appState.userStats.points >= badge.threshold ? DS.Colors.primary : DS.Colors.outlineVariant)
                        .clipShape(Capsule())
                }
                .disabled(appState.userStats.points < badge.threshold)
            }
        }
        .padding(.vertical, DS.Spacing.md)
        .padding(.horizontal, DS.Spacing.xs)
        .frame(maxWidth: .infinity)
        .background(DS.Colors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.md))
        .shadow(color: DS.Colors.onBackground.opacity(unlocked ? 0.06 : 0.02), radius: 10, y: 5)
    }
}

