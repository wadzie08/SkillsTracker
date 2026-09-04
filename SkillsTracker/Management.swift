//
//  Management.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import SwiftUI

struct ManagementDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 0
    @State private var showingAddStudent = false
    @State private var showingAddStaff = false
    @State private var showingAddManagement = false
    @State private var showingAddCompany = false
    
    var body: some View {
        if let manager = viewModel.currentUser as? Management {
            TabView(selection: $selectedTab) {
                ManagementOverviewView(manager: manager)
                    .tabItem {
                        Image(systemName: "chart.bar.fill")
                        Text("Overview")
                    }
                    .tag(0)
                
                ManagementStudentsView(manager: manager)
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Students")
                    }
                    .tag(1)
                
                ManagementStaffView(manager: manager)
                    .tabItem {
                        Image(systemName: "person.3")
                        Text("Staff")
                    }
                    .tag(2)
                
                ManagementCompaniesView(manager: manager)
                    .tabItem {
                        Image(systemName: "building.2")
                        Text("Companies")
                    }
                    .tag(3)
                
                ManagementPlacementsView(manager: manager)
                    .tabItem {
                        Image(systemName: "briefcase.fill")
                        Text("Placements")
                    }
                    .tag(4)
            }
            .accentColor(.red)
            .navigationTitle("Management Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
            .sheet(isPresented: $showingAddStudent) {
                AddStudentSheet(isPresented: $showingAddStudent)
            }
            .sheet(isPresented: $showingAddStaff) {
                AddStaffSheet(isPresented: $showingAddStaff)
            }
            .sheet(isPresented: $showingAddManagement) {
                AddManagementSheet(isPresented: $showingAddManagement)
            }
            .sheet(isPresented: $showingAddCompany) {
                AddCompanySheet(isPresented: $showingAddCompany)
            }
        }
    }
}

struct ManagementOverviewView: View {
    let manager: Management
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Welcome, \(manager.firstName)!")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Management Dashboard")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    StatCard(title: "Total Students", value: "\(viewModel.students.count)", icon: "person.2", color: .blue)
                    StatCard(title: "Active Interns", value: "\(activeInternsCount)", icon: "briefcase.fill", color: .green)
                    StatCard(title: "Total Staff", value: "\(viewModel.staff.count)", icon: "person.3", color: .purple)
                    StatCard(title: "Hiring Companies", value: "\(viewModel.hiringCompanies.count)", icon: "building.2", color: .orange)
                    StatCard(title: "Permanent Hires", value: "\(permanentHiresCount)", icon: "checkmark.seal.fill", color: .mint)
                    StatCard(title: "Pending Offers", value: "\(pendingOffersCount)", icon: "clock.fill", color: .yellow)
                }
                .padding(.horizontal)
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Activity")
                        .font(.headline)
                    
                    if viewModel.students.isEmpty {
                        Text("No recent activity")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.students.prefix(5)) { student in
                            ActivityRow(student: student)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private var activeInternsCount: Int {
        viewModel.students.filter { $0.internshipStatus == .active }.count
    }
    
    private var permanentHiresCount: Int {
        viewModel.students.filter { $0.hiredPermanently }.count
    }
    
    private var pendingOffersCount: Int {
        viewModel.students.filter { $0.internshipStatus == .offered }.count
    }
}

struct ActivityRow: View {
    let student: Student
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .font(.caption)
                )
            
            VStack(alignment: .leading, spacing: 3) {
                Text(student.fullName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(student.internshipStatus.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            StatusBadge(status: student.internshipStatus)
        }
        .padding(.vertical, 5)
    }
}

struct ManagementStudentsView: View {
    let manager: Management
    @EnvironmentObject var viewModel: AppViewModel
    @State private var searchText = ""
    @State private var showingAddStudent = false
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return viewModel.students
        } else {
            return viewModel.students.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.studentID.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Students (\(viewModel.students.count))")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingAddStudent = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search students...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Students List
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(filteredStudents) { student in
                        ManagementStudentCard(student: student)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddStudent) {
            AddStudentSheet(isPresented: $showingAddStudent)
        }
    }
}

struct ManagementStudentCard: View {
    let student: Student
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingDeleteAlert = false
    
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
                
                VStack(alignment: .trailing, spacing: 3) {
                    StatusBadge(status: student.internshipStatus)
                    if student.hiredPermanently {
                        Text("Permanently Hired")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(student.email)
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Academic Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ProgressView(value: student.academicProgress)
                        .frame(width: 80)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Status")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(student.isActive ? "Active" : "Archived")
                        .font(.caption)
                        .foregroundColor(student.isActive ? .green : .red)
                }
            }
            
            HStack(spacing: 10) {
                Button("View Details") {
                    // Navigate to details
                }
                .buttonStyle(.bordered)
                
                Button("Edit") {
                    // Edit student
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .alert("Delete Student", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.removeStudent(student)
            }
        } message: {
            Text("Are you sure you want to delete \(student.fullName)? This action cannot be undone.")
        }
    }
}

struct ManagementStaffView: View {
    let manager: Management
    @EnvironmentObject var viewModel: AppViewModel
    @State private var searchText = ""
    @State private var showingAddStaff = false
    
    var filteredStaff: [Staff] {
        if searchText.isEmpty {
            return viewModel.staff
        } else {
            return viewModel.staff.filter {
                $0.fullName.localizedCaseInsensitiveContains(searchText) ||
                $0.staffID.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Staff (\(viewModel.staff.count))")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingAddStaff = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search staff...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Staff List
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(filteredStaff) { staffMember in
                        ManagementStaffCard(staff: staffMember)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddStaff) {
            AddStaffSheet(isPresented: $showingAddStaff)
        }
    }
}

struct ManagementStaffCard: View {
    let staff: Staff
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(staff.fullName)
                        .font(.headline)
                    Text(staff.staffID)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text(staff.department.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Text(staff.isActive ? "Active" : "Inactive")
                        .font(.caption2)
                        .foregroundColor(staff.isActive ? .green : .red)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(staff.email)
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Permissions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(staff.permissions.count) assigned")
                        .font(.caption)
                }
            }
            
            HStack(spacing: 10) {
                Button("View Details") {
                    // Navigate to details
                }
                .buttonStyle(.bordered)
                
                Button("Edit") {
                    // Edit staff
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .alert("Delete Staff", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.removeStaff(staff)
            }
        } message: {
            Text("Are you sure you want to delete \(staff.fullName)? This action cannot be undone.")
        }
    }
}

struct ManagementCompaniesView: View {
    let manager: Management
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingAddCompany = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Hiring Companies (\(viewModel.hiringCompanies.count))")
                    .font(.headline)
                
                Spacer()
                
                Button(action: {
                    showingAddCompany = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Companies List
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(viewModel.hiringCompanies) { company in
                        ManagementCompanyCard(company: company)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingAddCompany) {
            AddCompanySheet(isPresented: $showingAddCompany)
        }
    }
}

struct ManagementCompanyCard: View {
    let company: HiringCompanyUser
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingDeleteAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(company.company.rawValue)
                        .font(.headline)
                    Text(company.contactName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 3) {
                    Text(company.department)
                        .font(.caption)
                        .foregroundColor(.blue)
                    Text(company.isActive ? "Active" : "Inactive")
                        .font(.caption2)
                        .foregroundColor(company.isActive ? .green : .red)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(company.email)
                        .font(.caption)
                }
                
                Spacer()
            }
            
            HStack(spacing: 10) {
                Button("View Details") {
                    // Navigate to details
                }
                .buttonStyle(.bordered)
                
                Button("Edit") {
                    // Edit company
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    Image(systemName: "trash")
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .alert("Delete Company", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.removeHiringCompany(company)
            }
        } message: {
            Text("Are you sure you want to delete \(company.company.rawValue)? This action cannot be undone.")
        }
    }
}

struct ManagementPlacementsView: View {
    let manager: Management
    @EnvironmentObject var viewModel: AppViewModel
    
    var placedStudents: [Student] {
        viewModel.students.filter { $0.currentInternship != nil }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if placedStudents.isEmpty {
                    VStack(spacing: 15) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Placements Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Student internship placements will appear here")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    ForEach(placedStudents) { student in
                        if let internship = student.currentInternship {
                            PlacementCard(student: student, internship: internship)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct PlacementCard: View {
    let student: Student
    let internship: Internship
    
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
                
                StatusBadge(status: internship.status)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                InfoRow(label: "Company", value: internship.company.rawValue)
                InfoRow(label: "Role", value: internship.role)
                InfoRow(label: "Department", value: internship.department)
                InfoRow(label: "Manager", value: internship.managerName)
                InfoRow(label: "Start Date", value: formatDate(internship.startDate))
                InfoRow(label: "End Date", value: formatDate(internship.endDate))
            }
            
            if student.hiredPermanently {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Permanently Hired at \(student.permanentHireCompany ?? "")")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Add Sheets

struct AddStudentSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    @State private var studentID = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var bio = ""
    @State private var skills = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Student Information")) {
                    TextField("Student ID", text: $studentID)
                    TextField("Password", text: $password)
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                    TextField("Phone Number", text: $phoneNumber)
                }
                
                Section(header: Text("Additional Details")) {
                    TextField("Bio", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Skills (comma separated)", text: $skills)
                }
            }
            .navigationTitle("Add Student")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newStudent = Student(
                            studentID: studentID,
                            password: password,
                            firstName: firstName,
                            lastName: lastName,
                            email: email,
                            phoneNumber: phoneNumber,
                            bio: bio,
                            skills: skills.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        )
                        viewModel.addStudent(newStudent)
                        isPresented = false
                    }
                    .disabled(studentID.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

struct AddStaffSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    @State private var staffID = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var department: StaffDepartment = .generalHelp
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Staff Information")) {
                    TextField("Staff ID", text: $staffID)
                    TextField("Password", text: $password)
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                    
                    Picker("Department", selection: $department) {
                        ForEach(StaffDepartment.allCases, id: \.self) { dept in
                            Text(dept.rawValue).tag(dept)
                        }
                    }
                }
            }
            .navigationTitle("Add Staff")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newStaff = Staff(
                            staffID: staffID,
                            password: password,
                            firstName: firstName,
                            lastName: lastName,
                            email: email,
                            department: department
                        )
                        viewModel.addStaff(newStaff)
                        isPresented = false
                    }
                    .disabled(staffID.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

struct AddManagementSheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Management Information")) {
                    TextField("Username", text: $username)
                    TextField("Password", text: $password)
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                }
            }
            .navigationTitle("Add Management")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newManager = Management(
                            username: username,
                            password: password,
                            firstName: firstName,
                            lastName: lastName,
                            email: email
                        )
                        viewModel.addManagement(newManager)
                        isPresented = false
                    }
                    .disabled(username.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

struct AddCompanySheet: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    @State private var company: HiringCompany = .jamf
    @State private var contactName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var department = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Company Information")) {
                    Picker("Company", selection: $company) {
                        ForEach(HiringCompany.allCases, id: \.self) { comp in
                            Text(comp.rawValue).tag(comp)
                        }
                    }
                    TextField("Contact Name", text: $contactName)
                    TextField("Email", text: $email)
                    TextField("Password", text: $password)
                    TextField("Department", text: $department)
                }
            }
            .navigationTitle("Add Company")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newCompany = HiringCompanyUser(
                            company: company,
                            contactName: contactName,
                            email: email,
                            password: password,
                            department: department
                        )
                        viewModel.addHiringCompany(newCompany)
                        isPresented = false
                    }
                    .disabled(contactName.isEmpty || email.isEmpty || password.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ManagementDashboardView()
        .environmentObject(AppViewModel())
}

