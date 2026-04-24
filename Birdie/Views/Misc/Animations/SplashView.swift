//
//  SplashView.swift
//  Birdie
//
//  Created by dmu mac 33 on 17/05/2025.
//

import SwiftUI

struct SplashView: View {
    @State private var animate = false
    @State private var fade = false
    @State private var textDisappear = false
    @State private var gradientPhase: Double = 0.0
    @State private var sunOffset: CGFloat = 100

    let onFinish: () -> Void

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hue: 0.1, saturation: 0.8, brightness: 1.0 - gradientPhase * 0.4),
                    Color(hue: 0.6, saturation: 0.5, brightness: 0.4 + gradientPhase * 0.5)
                ]),
                startPoint: .bottom,
                endPoint: .top
            )
            .animation(.easeInOut(duration: 3), value: gradientPhase)
            .ignoresSafeArea(.all)
            
            Circle()
                .fill(Color.yellow)
                .frame(width: 80, height: 80)
                .offset(y: animate ? -400 : 200)
                .opacity(0.9)
                .blur(radius: 6) //A gaussian blur? Why the heck haven't I used this before?
                .animation(.easeInOut(duration: 5), value: sunOffset)
            
            VStack {
                ZStack {
                    birdImage()
                    birdImage()
                        .scaleEffect(x: -1, y: 1)
                }
                logo()
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3).delay(0.5)
            ) {
                animate = true
                textDisappear = true
                gradientPhase = 1.0
                sunOffset = -400
            }

            Task {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    withAnimation(.easeInOut(duration: 1)) {
                        fade = true
                    }
                }

                try? await Task.sleep(nanoseconds: 1_500_000_000)
                await MainActor.run {
                    onFinish()
                }
            }
        }
    }

    private func birdImage() -> some View {
        Image(systemName: "bird.fill")
            .foregroundStyle(Color.green)
            .font(.system(size: 64))
            .scaleEffect(animate ? 0.6 : 1.4)
            .rotation3DEffect(.degrees(animate ? 40 : 0), axis: (x: 1, y: 0, z: 0))
            .rotation3DEffect(.degrees(animate ? 20 : 0), axis: (x: 0, y: 1, z: 0))
            .rotation3DEffect(.degrees(animate ? -15 : 20), axis: (x: 0, y: 0, z: 1))
            .opacity(fade ? 0.2 : 1)
            .offset(x: animate ? 200 : -100, y: animate ? -450 : -10)
    }

    private func logo() -> some View {
        Text("Welcome to Birdie!")
            .font(.largeTitle)
            .bold()
            .scaleEffect(textDisappear ? 0.5 : 1)
            .opacity(textDisappear ? 0 : 1)
            .offset(y: textDisappear ? 200 : 0)
    }
}

#Preview {
    SplashView(onFinish: {})
}
