//
//  MainTabView.swift
//  Birdie
//
//  Created by dmu mac 33 on 13/05/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tabs = LaunchOptions.initialTab().flatMap(Tabs.init(rawValue:)) ?? .home
    @State private var showAddSpotting = false
    @State private var isButtonPressed = false
    @State private var animateFloating = false

    @Environment(BirdSpotController.self) private var spotController

    enum Tabs: String {
        case home, list, empty, map, profile
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                NavigationStack{
                    HomeView()
                }
                    .tabItem {
                        Label {
                            Text("Home")
                        } icon: {
                            Image(systemName: "house")
                                .font(.system(size: 16))
                        }
                    }
                    .tag(Tabs.home)

                NavigationStack{
                    SpottingListView()
                }
                    .tabItem {
                        Label {
                            Text("Sightings")
                        } icon: {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 16))
                        }
                    }
                    .tag(Tabs.list)

                Color.clear
                    .frame(height: 1)
                    .tabItem {
                        Label("", systemImage: "")
                    }
                    .tag(Tabs.empty)
                    .disabled(true)
                
                NavigationStack{
                    SpotMapView()
                }
                .tabItem {
                        Label {
                            Text("Map")
                        } icon: {
                            Image(systemName: "map")
                                .font(.system(size: 16))
                        }
                    }
                    .tag(Tabs.map)
                
                NavigationStack{
                    ProfileView()
                }
                    .tabItem {
                        Label {
                            Text("Profile")
                        } icon: {
                            Image(systemName: "person")
                                .font(.system(size: 16))
                        }
                    }
                    .tag(Tabs.profile)
            }


            .errorAlert(
                Binding(
                    get: { spotController.errorMessage },
                    set: { spotController.errorMessage = $0 }
                )
            )
            .onChange(of: selectedTab) { oldValue, newValue in
                if newValue == .empty {
                    selectedTab = oldValue
                }
            }
            .background(
                VisualEffectBlur(blurStyle: .systemThinMaterial)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.1)
            )

            VStack {
                Spacer()
                HStack {
                    Spacer()

                    Button(action: {
                        withAnimation(
                            .spring(response: 0.3, dampingFraction: 0.5)
                        ) {
                            isButtonPressed = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            showAddSpotting = true
                            withAnimation(.spring()) {
                                isButtonPressed = false
                            }
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .padding(24)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color.blue.opacity(0.8), Color.blue,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.blue.opacity(0.7), radius: 10)
                            .scaleEffect(isButtonPressed ? 1.2 : 1.0)
                            .rotationEffect(.degrees(isButtonPressed ? 45 : 0))
                            .offset(y: animateFloating ? -6 : 6)
                            .animation(
                                .easeInOut(duration: 2).repeatForever(
                                    autoreverses: true
                                ),
                                value: animateFloating
                            )
                    }
                    .offset(y: 5)
                    .sheet(isPresented: $showAddSpotting) {
                        AddSpottingView()
                    }

                    Spacer()
                }
            }
            .onAppear {
                animateFloating = true
            }
        }
    }
}

struct VisualEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    MainTabView().withDemoEnvironment()
}
