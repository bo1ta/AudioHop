//
//  OnboardingVIew.swift
//  AudioHop
//
//  Created by Solomon Alexandru on 14.11.2024.
//

import SwiftUI

// MARK: - OnboardingView

struct OnboardingView: View {
  @Environment(\.dismissWindow) private var dismissWindow
  @State private var currentPage = 0

  var body: some View {
    VStack {
      TabView(selection: $currentPage) {
        // Page 1: Welcome
        OnboardingPageView(
          imageName: "logo-icon",
          title: "Welcome to Quick Audio Switcher",
          description: "Quickly switch your audio outputs with a single click. Manage favorites and set shortcuts for quick access.",
          isAnimated: false)
          .tag(0)

        // Page 2: Left Click to Switch
        OnboardingPageView(
          imageName: "left-clicking-tip",
          title: "Switch Outputs with a Click",
          description: "Left-click the menu bar icon to instantly switch between your favorite audio devices.")
          .tag(1)

        // Page 3: Right Click for Options
        OnboardingPageView(
          imageName: "right-clicking-tip",
          title: "Manage Options and Shortcuts",
          description: "Right-click the icon to access settings, manage favorites, and set up custom keyboard shortcuts.")
          .tag(2)

        // Page 4: Favorites
        OnboardingPageView(
          imageName: "preferences-screenshot",
          title: "Add Favorites",
          description: "Mark frequently used audio outputs as favorites for easy access.",
          isAnimated: false)
          .tag(3)
      }
      .tabViewStyle(DefaultTabViewStyle())
      .frame(width: 400, height: 400)

      HStack {
        Button(action: backHandler, label: {
          Text("Back")
        })
        .disabled(currentPage == 0)

        Spacer()

        Button(action: nextHandler, label: {
          Text(currentPage == 3 ? "Done" : "Next")
        })
      }
      .padding(.horizontal)
    }
    .padding()
  }

  private func backHandler() {
    guard currentPage > 0 else {
      return
    }
    currentPage -= 1
  }

  private func nextHandler() {
    if currentPage < 3 {
      currentPage += 1
    } else {
      dismissWindow()
    }
  }
}

// MARK: - OnboardingPageView

struct OnboardingPageView: View {
  var imageName: String
  var title: String
  var description: String
  var isAnimated = true

  var body: some View {
    VStack(spacing: 20) {
      if isAnimated {
        GIFImageView(imageName: imageName)
      } else {
        Image(imageName)
          .resizable()
          .scaledToFit()
          .shadow(radius: 1.0)
          .clipShape(RoundedRectangle(cornerRadius: 4))
      }

      Text(title)
        .font(.title)
        .fontWeight(.bold)
        .multilineTextAlignment(.center)

      Text(description)
        .font(.body)
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
  }
}

#Preview {
    OnboardingView()
}
