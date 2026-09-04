//
//  ContentView.swift
//  SkillsTracker
//
//  Created by wadzie on 4/9/2026.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoggedIn {
                    switch viewModel.currentRole {
                    case .student:
                        StudentDashboardView()
                    case .facilitator:
                        ManagementDashboardView()
                    case .programManager:
                        ManagerDashboardView()
                    case .employer:
                        EmployerDashboardView()
                    case .externalViewer:
                        ExternalViewerDashboardView()
                    case .none:
                        LoginView()
                    }
                } else {
                    welcome()
                }
            }
            .alert("Congratulations!", isPresented: $viewModel.showCongratulationAlert) {
                Button("OK", role: .cancel) {
                    viewModel.logout()
                }
            } message: {
                Text(viewModel.congratulationMessage)
            }
        }
    }
}

struct EmployerDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    private var employer: Employer? {
        viewModel.currentUser as? Employer
    }
    
    var body: some View {
        if let employer {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 80))
                            .foregroundColor(.indigo)
                        Text(employer.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(employer.position.isEmpty ? employer.company.rawValue : employer.position)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Employer Information")
                            .font(.headline)
                        InfoRow(label: "Employer ID", value: employer.employerID)
                        InfoRow(label: "Company", value: employer.company.rawValue)
                        InfoRow(label: "Department", value: employer.department.isEmpty ? "Not set" : employer.department)
                        InfoRow(label: "Email", value: employer.email)
                        InfoRow(label: "Status", value: employer.isActive ? "Active" : "Inactive")
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("Employer Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
        }
    }
}

struct ExternalViewerDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    
    private var viewer: ExternalViewer? {
        viewModel.currentUser as? ExternalViewer
    }
    
    var body: some View {
        if let viewer {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Image(systemName: "eye.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.teal)
                        Text(viewer.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(viewer.organization.isEmpty ? viewer.accessLevel : viewer.organization)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Viewer Information")
                            .font(.headline)
                        InfoRow(label: "Viewer ID", value: viewer.viewerID)
                        InfoRow(label: "Organization", value: viewer.organization.isEmpty ? "Not set" : viewer.organization)
                        InfoRow(label: "Access Level", value: viewer.accessLevel)
                        InfoRow(label: "Email", value: viewer.email)
                        InfoRow(label: "Status", value: viewer.isActive ? "Active" : "Inactive")
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("External Viewer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
        }
    }
}

struct HiringCompanyDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 0
    
    private var companyUser: HiringCompanyUser? {
        viewModel.currentUser as? HiringCompanyUser
    }
    
    private var companyStudents: [Student] {
        guard let company = companyUser?.company else { return [] }
        return viewModel.students.filter { student in
            student.currentInternship?.company == company || student.permanentHireCompany == company.rawValue
        }
    }
    
    private var activeInterns: [Student] {
        companyStudents.filter { $0.internshipStatus == .active }
    }
    
    private var hiredStudents: [Student] {
        companyStudents.filter { $0.hiredPermanently }
    }
    
    var body: some View {
        if let companyUser {
            TabView(selection: $selectedTab) {
                HiringCompanyOverviewView(
                    companyUser: companyUser,
                    companyStudents: companyStudents,
                    activeInterns: activeInterns,
                    hiredStudents: hiredStudents
                )
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Overview")
                }
                .tag(0)
                
                HiringCompanyStudentsView(students: companyStudents)
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Students")
                    }
                    .tag(1)
            }
            .accentColor(.orange)
            .navigationTitle("Hiring Company")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
        }
    }
}

struct HiringCompanyOverviewView: View {
    let companyUser: HiringCompanyUser
    let companyStudents: [Student]
    let activeInterns: [Student]
    let hiredStudents: [Student]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(companyUser.company.rawValue)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(companyUser.contactName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    StatCard(title: "Students", value: "\(companyStudents.count)", icon: "person.2", color: .orange)
                    StatCard(title: "Active", value: "\(activeInterns.count)", icon: "briefcase.fill", color: .green)
                    StatCard(title: "Hired", value: "\(hiredStudents.count)", icon: "checkmark.seal.fill", color: .mint)
                    StatCard(title: "Department", value: companyUser.department.isEmpty ? "Any" : companyUser.department, icon: "building.2", color: .blue)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Company Information")
                        .font(.headline)
                    InfoRow(label: "Contact", value: companyUser.contactName)
                    InfoRow(label: "Email", value: companyUser.email)
                    InfoRow(label: "Status", value: companyUser.isActive ? "Active" : "Inactive")
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct HiringCompanyStudentsView: View {
    let students: [Student]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if students.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "person.2")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Students")
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text("Students connected to this company will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ForEach(students) { student in
                        HiringCompanyStudentCard(student: student)
                    }
                }
            }
            .padding()
        }
    }
}

struct HiringCompanyStudentCard: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(student.fullName)
                        .font(.headline)
                    Text(student.studentID)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: student.internshipStatus)
            }
            
            Divider()
            
            InfoRow(label: "Email", value: student.email)
            InfoRow(label: "Skills", value: student.skills.isEmpty ? "None listed" : student.skills.joined(separator: ", "))
            InfoRow(label: "Academic Progress", value: "\(Int(student.academicProgress * 100))%")
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
}

struct welcome: View {
    @EnvironmentObject var viewModel: AppViewModel
    var body: some View {
        NavigationStack {
            ZStack {
                Image("Welcome page")
                    .resizable()
                    .ignoresSafeArea(edges: .all)
                    .frame(width: 440, height: 1000)
                    .opacity(150)
                Text("Welcome To MCRI")
                    .offset(x:7 ,y: -50)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.white)
                    .opacity(0.9)
                    .padding()
                
                
                VStack{
                    
                    Spacer()
                    
                    NavigationLink(destination: LoginView().environmentObject(viewModel)) {
                        HStack{
                            Text("Get Started")
                                .font(.system(size: 20))
                                .fontWeight(.heavy)
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.white)
                                .padding(10)
                            
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.white)
                                .padding(10)
                                .opacity(0.9)
                            
                            
                        }
                        
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(style: StrokeStyle(lineWidth: 1.5))
                                .foregroundStyle(Color.white)
                            
                            
                        )
                    }
                    .offset(x: 0, y: -20)
                    .padding(.bottom, 100)
                }.padding(24)
                
            }
        }
    }
}

#Preview {
    welcome()
        .environmentObject(AppViewModel())
}
