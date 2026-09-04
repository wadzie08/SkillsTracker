//
//  Themes.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import SwiftUI

struct AppTheme {
    let primaryColor: Color
    let secondaryColor: Color
    let backgroundColor: Color
    let cardColor: Color
    let iconName: String
    
    static let student = AppTheme(
        primaryColor: .blue,
        secondaryColor: Color(red: 0.2, green: 0.5, blue: 0.9),
        backgroundColor: Color(red: 0.94, green: 0.96, blue: 1.0),
        cardColor: Color(UIColor.secondarySystemGroupedBackground),
        iconName: "graduationcap.fill"
    )
    
    static let intern = AppTheme(
        primaryColor: .green,
        secondaryColor: Color(red: 0.2, green: 0.7, blue: 0.4),
        backgroundColor: Color(red: 0.94, green: 0.98, blue: 0.95),
        cardColor: Color(UIColor.secondarySystemGroupedBackground),
        iconName: "briefcase.fill"
    )
    
    static let staff = AppTheme(
        primaryColor: .green,
        secondaryColor: Color(red: 0.15, green: 0.6, blue: 0.35),
        backgroundColor: Color(red: 0.94, green: 0.98, blue: 0.95),
        cardColor: Color(UIColor.secondarySystemGroupedBackground),
        iconName: "person.3.fill"
    )
    
    static let management = AppTheme(
        primaryColor: .purple,
        secondaryColor: Color(red: 0.55, green: 0.25, blue: 0.75),
        backgroundColor: Color(red: 0.97, green: 0.94, blue: 1.0),
        cardColor: Color(UIColor.secondarySystemGroupedBackground),
        iconName: "chart.bar.fill"
    )
    
    static let hiringCompany = AppTheme(
        primaryColor: .orange,
        secondaryColor: Color(red: 0.9, green: 0.5, blue: 0.1),
        backgroundColor: Color(red: 1.0, green: 0.97, blue: 0.93),
        cardColor: Color(UIColor.secondarySystemGroupedBackground),
        iconName: "building.2.fill"
    )
    
    static let manager = AppTheme(
        primaryColor: .cyan,
        secondaryColor: Color(red: 0.1, green: 0.6, blue: 0.75),
        backgroundColor: Color(red: 0.93, green: 0.98, blue: 1.0),
        cardColor: Color(UIColor.secondarySystemGroupedBackground),
        iconName: "person.badge.shield.checkmark.fill"
    )
    
    static let login = AppTheme(
        primaryColor: .blue,
        secondaryColor: Color(red: 0.2, green: 0.5, blue: 0.9),
        backgroundColor: Color(UIColor.systemGroupedBackground),
        cardColor: Color(UIColor.secondarySystemGroupedBackground),
        iconName: "building.columns.fill"
    )
    
    static func forRole(_ role: UserRole?) -> AppTheme {
        switch role {
        case .student: return .student
        case .intern: return .intern
        case .staff: return .staff
        case .management: return .management
        case .hiringCompany, .employer: return .hiringCompany
        case .manager: return .manager
        case .externalViewer: return .login
        case .none: return .login
        }
    }
}

struct ThemedBackground: ViewModifier {
    let theme: AppTheme
    
    func body(content: Content) -> some View {
        content
            .background(theme.backgroundColor.ignoresSafeArea())
    }
}

extension View {
    func themedBackground(_ theme: AppTheme) -> some View {
        modifier(ThemedBackground(theme: theme))
    }
    
    func dashboardToolbar(title: String, theme: AppTheme, onBackToLogin: @escaping () -> Void) -> some View {
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbarBackground(theme.primaryColor.opacity(0.12), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(theme.primaryColor)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBackToLogin) {
                        Label("Login", systemImage: "chevron.left")
                    }
                }
            }
    }
}
