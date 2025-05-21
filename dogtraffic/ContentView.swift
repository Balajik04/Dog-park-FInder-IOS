//
//  ContentView.swift
//  dogtraffic
//
//  Created by Balaji on 5/15/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ParksListView()
                    .onAppear {
                        let appearance = UINavigationBarAppearance()
                        appearance.configureWithOpaqueBackground()
                        appearance.backgroundColor = UIColor(AppColors.appBackground)
                        appearance.titleTextAttributes = [.foregroundColor: UIColor(AppColors.textPrimary)]
                        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(AppColors.textPrimary)]
                        
                        UINavigationBar.appearance().standardAppearance = appearance
                        UINavigationBar.appearance().scrollEdgeAppearance = appearance
                        UINavigationBar.appearance().compactAppearance = appearance
                    }
    }
}

#Preview {
    ContentView()
}
