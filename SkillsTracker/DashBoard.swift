//
//  DashBoard.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import SwiftUI

struct DashboardContainer<Content: View>: View {
    @EnvironmentObject var viewModel: AppViewModel
    let title: String
    let theme: AppTheme
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        NavigationStack {
            content()
                .themedBackground(theme)
                .dashboardToolbar(title: title, theme: theme) {
                    viewModel.logout()
                }
        }
    }
}
