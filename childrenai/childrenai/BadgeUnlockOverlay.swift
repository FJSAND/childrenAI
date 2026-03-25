import SwiftUI

struct BadgeUnlockOverlay: View {
    let badge: BadgeDefinition
    let onDismiss: () -> Void

    @State private var badgeOffset: CGFloat = -500
    @State private var badgeScale: CGFloat = 0.5
    @State private var showContent = false
    @State private var overlayOpacity: Double = 0
    @State private var glowOpacity: Double = 0
    @State private var starRotation: Double = 0

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.55 * overlayOpacity)
                .ignoresSafeArea()
                .onTapGesture { }  // block tap-through

            // Radial glow behind badge
            Circle()
                .fill(
                    RadialGradient(
                        colors: [DS.Colors.primaryContainer.opacity(0.5), Color.clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .opacity(glowOpacity)
                .scaleEffect(showContent ? 1.0 : 0.3)

            // Spinning star particles behind badge
            Image(systemName: "sparkle")
                .font(.system(size: 80))
                .foregroundColor(DS.Colors.tertiary.opacity(0.3 * glowOpacity))
                .rotationEffect(.degrees(starRotation))

            VStack(spacing: 24) {
                Spacer()

                // Title
                Text("🎉 恭喜获得新勋章！")
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                // Badge image — bouncing ball
                Image(badge.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: DS.Colors.primary.opacity(0.4), radius: 20, y: 8)
                    .scaleEffect(badgeScale)
                    .offset(y: badgeOffset)

                // Badge name
                Text(badge.title)
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)

                // Badge description
                Text(badge.description)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .opacity(showContent ? 1 : 0)

                Spacer()

                // Dismiss button
                Button(action: onDismiss) {
                    Text("继续加油")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(DS.Colors.primary)
                        .padding(.horizontal, 48)
                        .padding(.vertical, 16)
                        .background(.white)
                        .clipShape(Capsule())
                        .shadow(color: .white.opacity(0.3), radius: 12)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.7)
                .padding(.bottom, 60)
            }
        }
        .onAppear { startAnimation() }
    }

    private func startAnimation() {
        // 1. Fade in background
        withAnimation(.easeOut(duration: 0.3)) {
            overlayOpacity = 1
        }

        // 2. Badge bouncy ball drop — spring with high bounce
        withAnimation(
            .interpolatingSpring(
                mass: 1.0,
                stiffness: 200,
                damping: 10,
                initialVelocity: 0
            ).delay(0.2)
        ) {
            badgeOffset = 0
            badgeScale = 1.0
        }

        // 3. Show text & button after badge settles
        withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
            showContent = true
        }

        // 4. Glow effect
        withAnimation(.easeInOut(duration: 0.6).delay(0.6)) {
            glowOpacity = 1
        }

        // 5. Spinning star
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            starRotation = 360
        }
    }
}

