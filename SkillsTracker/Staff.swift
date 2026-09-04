//
//  Staff.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import SwiftUI

struct StaffDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 0
    @State private var showingAddReview = false
    @State private var selectedStudent: Student?
    
    var body: some View {
        if let staffMember = viewModel.currentUser as? Staff {
            TabView(selection: $selectedTab) {
                StaffProfileView(staff: staffMember)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(0)
                
                StaffStudentsView(staff: staffMember)
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Students")
                    }
                    .tag(1)
                
                StaffReviewsView(staff: staffMember)
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Reviews")
                    }
                    .tag(2)
                
                if staffMember.department == .facilitator {
                    StaffInternshipView(staff: staffMember)
                        .tabItem {
                            Image(systemName: "briefcase")
                            Text("Internships")
                        }
                        .tag(3)
                }
            }
            .accentColor(.green)
            .navigationTitle("Staff Dashboard")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        viewModel.logout()
                    }
                }
            }
            .sheet(item: $selectedStudent) { student in
                AddReviewSheet(student: student, staff: staffMember, isPresented: .constant(true))
            }
        }
    }
}

struct StaffProfileView: View {
    let staff: Staff
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                    }
                    
                    Text(staff.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(staff.staffID)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Staff Details
                VStack(alignment: .leading, spacing: 15) {
                    Section(header: Text("Staff Information").font(.headline)) {
                        InfoRow(label: "Department", value: staff.department.rawValue)
                        InfoRow(label: "Email", value: staff.email)
                    }
                    
                    Section(header: Text("Permissions").font(.headline)) {
                        if staff.permissions.isEmpty {
                            Text("No special permissions assigned")
                                .font(.body)
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(staff.permissions, id: \.self) { permission in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(permission.capitalized)
                                        .font(.body)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Department Description").font(.headline)) {
                        Text(departmentDescription(for: staff.department))
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
            }
            .padding()
        }
    }
    
    private func departmentDescription(for department: StaffDepartment) -> String {
        switch department {
        case .facilitator:
            return "Facilitators guide students through their career readiness journey, review student progress, and can accept internship offers on behalf of students."
        case .technical:
            return "Technical staff provide technical support and guidance to students, assist with technical projects, and review technical skills."
        case .maintenance:
            return "Maintenance staff ensure facilities and equipment are properly maintained for student use."
        case .generalHelp:
            return "General Help staff provide day-to-day support to students and staff, assist with inquiries, and help with general operations."
        case .administration:
            return "Administration staff handle administrative tasks, record keeping, and support the overall operations of the institute."
        }
    }
}

struct StaffStudentsView: View {
    let staff: Staff
    @EnvironmentObject var viewModel: AppViewModel
    @State private var searchText = ""
    @State private var selectedStudent: Student?
    
    var filteredStudents: [Student] {
        if searchText.isEmpty {
            return viewModel.students.filter { $0.isActive }
        } else {
            return viewModel.students.filter {
                $0.isActive &&
                ($0.fullName.localizedCaseInsensitiveContains(searchText) ||
                 $0.studentID.localizedCaseInsensitiveContains(searchText))
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
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
            .padding()
            
            // Students List
            ScrollView {
                VStack(spacing: 15) {
                    if filteredStudents.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "person.2")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Students Found")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Try a different search term")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        ForEach(filteredStudents) { student in
                            StaffStudentCard(student: student, staff: staff)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct StaffStudentCard: View {
    let student: Student
    let staff: Staff
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingAddReview = false
    @State private var showingProfile = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading) {
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
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Academic Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ProgressView(value: student.academicProgress)
                        .frame(width: 100)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Skills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(student.skills.count) skills")
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Reviews")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(student.reviews.count) reviews")
                        .font(.subheadline)
                }
            }
            
            HStack(spacing: 10) {
                Button("View Profile") {
                    showingProfile = true
                }
                .buttonStyle(.bordered)
                
                Button("Add Review") {
                    showingAddReview = true
                }
                .buttonStyle(.borderedProminent)
                
                if staff.department == .facilitator && student.internshipStatus == .offered && !student.facilitatorAcceptedOffer {
                    Button("Accept Offer") {
                        viewModel.facilitatorAcceptInternship(student: student)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .sheet(isPresented: $showingProfile) {
            StudentProfileDetailView(student: student)
        }
        .sheet(isPresented: $showingAddReview) {
            AddReviewSheet(student: student, staff: staff, isPresented: $showingAddReview)
        }
    }
}

struct StaffReviewsView: View {
    let staff: Staff
    @EnvironmentObject var viewModel: AppViewModel
    
    var myReviews: [Review] {
        viewModel.students.flatMap { $0.reviews }.filter { $0.reviewerID == staff.id }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats
                HStack(spacing: 20) {
                    StatCard(title: "Reviews Given", value: "\(myReviews.count)", icon: "star.fill", color: .yellow)
                    StatCard(title: "Average Rating", value: String(format: "%.1f", averageRating), icon: "chart.bar.fill", color: .blue)
                }
                .padding(.horizontal)
                
                // Reviews List
                VStack(alignment: .leading, spacing: 15) {
                    Text("My Reviews")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if myReviews.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "star")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Reviews Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Your reviews will appear here")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        ForEach(myReviews.sorted(by: { $0.date > $1.date })) { review in
                            ReviewCard(review: review)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var averageRating: Double {
        guard !myReviews.isEmpty else { return 0.0 }
        let total = myReviews.reduce(0.0) { $0 + $1.rating }
        return total / Double(myReviews.count)
    }
}

struct StaffInternshipView: View {
    let staff: Staff
    @EnvironmentObject var viewModel: AppViewModel
    
    var studentsWithOffers: [Student] {
        viewModel.students.filter { $0.internshipStatus == .offered && !$0.facilitatorAcceptedOffer }
    }
    
    var activeInterns: [Student] {
        viewModel.students.filter { $0.internshipStatus == .active }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Pending Offers
                VStack(alignment: .leading, spacing: 15) {
                    Text("Pending Offers")
                        .font(.headline)
                    
                    if studentsWithOffers.isEmpty {
                        Text("No pending internship offers")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(studentsWithOffers) { student in
                            PendingOfferCard(student: student)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                
                // Active Interns
                VStack(alignment: .leading, spacing: 15) {
                    Text("Active Interns")
                        .font(.headline)
                    
                    if activeInterns.isEmpty {
                        Text("No active interns")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(activeInterns) { student in
                            ActiveInternCard(student: student)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
            }
            .padding()
        }
    }
}

struct PendingOfferCard: View {
    let student: Student
    @EnvironmentObject var viewModel: AppViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(student.fullName)
                    .font(.headline)
                
                Spacer()
                
                Text(student.studentID)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if let internship = student.currentInternship {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Company", value: internship.company.rawValue)
                    InfoRow(label: "Role", value: internship.role)
                    InfoRow(label: "Department", value: internship.department)
                }
            }
            
            HStack(spacing: 10) {
                Button("Accept on Behalf") {
                    viewModel.facilitatorAcceptInternship(student: student)
                }
                .buttonStyle(.borderedProminent)
                
                Button("View Details") {
                    // Show details
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ActiveInternCard: View {
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(student.fullName)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: student.internshipStatus)
            }
            
            if let internship = student.currentInternship {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(label: "Company", value: internship.company.rawValue)
                    InfoRow(label: "Role", value: internship.role)
                    InfoRow(label: "Manager", value: internship.managerName)
                }
            }
            
            Button("View Progress") {
                // Navigate to intern progress
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(10)
    }
}

struct AddReviewSheet: View {
    let student: Student
    let staff: Staff
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    @State private var rating = 3.0
    @State private var comments = ""
    @State private var category = "General"
    
    let categories = ["General", "Technical", "Communication", "Teamwork", "Leadership", "Attendance"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Review Details")) {
                    VStack {
                        HStack {
                            Text("Rating")
                            Spacer()
                            Text(String(format: "%.1f", rating))
                                .foregroundColor(.blue)
                        }
                        
                        Slider(value: $rating, in: 1...5, step: 0.5)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    TextField("Comments", text: $comments, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Student Information")) {
                    HStack {
                        Text("Student")
                        Spacer()
                        Text(student.fullName)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Student ID")
                        Spacer()
                        Text(student.studentID)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Review")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        let review = Review(
                            reviewerID: staff.id,
                            reviewerName: staff.fullName,
                            reviewerRole: staff.department.rawValue,
                            studentID: student.id,
                            rating: rating,
                            comments: comments,
                            category: category
                        )
                        viewModel.addReview(to: student, review: review)
                        isPresented = false
                    }
                    .disabled(comments.isEmpty)
                }
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
}

struct StudentProfileDetailView: View {
    let student: Student
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.blue)
                        }
                        
                        Text(student.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(student.studentID)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    // Student Details
                    VStack(alignment: .leading, spacing: 15) {
                        Section(header: Text("Personal Information").font(.headline)) {
                            InfoRow(label: "Email", value: student.email)
                            InfoRow(label: "Phone", value: student.phoneNumber)
                        }
                        
                        Section(header: Text("Bio").font(.headline)) {
                            Text(student.bio)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Section(header: Text("Skills").font(.headline)) {
                            FlowLayout(spacing: 10) {
                                ForEach(student.skills, id: \.self) { skill in
                                    Text(skill)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        
                        Section(header: Text("Academic Progress").font(.headline)) {
                            VStack(alignment: .leading, spacing: 8) {
                                ProgressView(value: student.academicProgress)
                                Text(String(format: "%.0f%%", student.academicProgress * 100))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section(header: Text("Internship Status").font(.headline)) {
                            StatusBadge(status: student.internshipStatus)
                        }
                        
                        if let internship = student.currentInternship {
                            Section(header: Text("Current Internship").font(.headline)) {
                                InfoRow(label: "Company", value: internship.company.rawValue)
                                InfoRow(label: "Role", value: internship.role)
                                InfoRow(label: "Department", value: internship.department)
                                InfoRow(label: "Manager", value: internship.managerName)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                }
                .padding()
            }
            .navigationTitle("Student Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    StaffDashboardView()
        .environmentObject(AppViewModel())
}

