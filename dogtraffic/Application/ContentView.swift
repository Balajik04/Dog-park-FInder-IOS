//
//  ContentView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.user != nil {
                // If a user is logged in, show the main part of the app
                ParksListContainerView(authViewModel: authViewModel)
            } else {
                // If no user is logged in, show the sign-in screen
               // trialView()
                AuthenticationView()
            }
        }
        .environmentObject(authViewModel) // Make AuthViewModel available to all child views
    }
}

#Preview {
    ContentView()
}
