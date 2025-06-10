//
//  ParksListContainerView.swift
//  dogtraffic
//
//  Created by Balaji on 6/9/25.
//


import SwiftUI

struct ParksListContainerView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @StateObject private var parkSearchViewModel: ParkSearchViewModel

    init(authViewModel: AuthViewModel) {
        _parkSearchViewModel = StateObject(wrappedValue: ParkSearchViewModel(authViewModel: authViewModel))
    }

    var body: some View {
        ParksListView(viewModel: parkSearchViewModel)
    }
}
