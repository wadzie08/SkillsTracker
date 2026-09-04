//
//  MatterApp.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import SwiftUI

@main
struct MatterCareerReadinessApp: App {
    @StateObject private var viewModel = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}

struct LoginView: View {
    @EnvironmentObject private var viewModel: AppViewModel
    @State private var selectedRole: UserRole = .student
    @State private var identifier = ""
    @State private var password = ""
    @State private var showLoginError = false
    
    var body: some View {
        Form {
            Section {
                Picker("Role", selection: $selectedRole) {
                    ForEach(UserRole.allCases, id: \.self) { role in
                        Text(role.rawValue).tag(role)
                    }
                }
                .pickerStyle(.menu)

            }
            
            Section {
                TextField(identifierPlaceholder, text: $identifier)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $password)
            }
            
            Section {
                Button(action: login) {
                    Label("Log In", systemImage: "person.crop.circle.badge.checkmark")
                        .frame(maxWidth: .infinity)
                }
                .disabled(identifier.isEmpty || password.isEmpty)
            }
        }
        .navigationTitle("MCRI Login")
        .alert("Login Failed", isPresented: $showLoginError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Check your credentials and try again.")
        }
    }
    
    private var identifierPlaceholder: String {
        switch selectedRole {
        case .student:
            return "Student ID"
        case .facilitator:
            return "Username"
        case .programManager:
            return "Program Manager ID"
        case .employer:
            return "Employer ID"
        case .externalViewer:
            return "Viewer ID"
        }
    }
    
    private func login() {
        let loginSucceeded: Bool
        
        switch selectedRole {
        case .student:
            loginSucceeded = viewModel.loginStudent(studentID: identifier, password: password)
        case .facilitator:
            loginSucceeded = viewModel.loginManagement(username: identifier, password: password)
        case .programManager:
            loginSucceeded = viewModel.loginManager(managerID: identifier, password: password)
        case .employer:
            loginSucceeded = viewModel.loginEmployer(employerID: identifier, password: password)
        case .externalViewer:
            loginSucceeded = viewModel.loginExternalViewer(viewerID: identifier, password: password)
        }
        
        showLoginError = !loginSucceeded
    }
}


