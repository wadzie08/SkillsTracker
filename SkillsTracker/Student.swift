//
//  StudentView.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import SwiftUI

struct StudentDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        if let student = viewModel.currentUser as? Student {
            TabView(selection: $selectedTab) {
                StudentProfileView(student: student)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(0)
                
                StudentInternshipView(student: student)
                    .tabItem {
                        Image(systemName: "briefcase")
                        Text("Internships")
                    }
                    .tag(1)
                
                StudentProgressView(student: student)
                    .tabItem {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Progress")
                    }
                    .tag(2)
                
                StudentReviewsView(student: student)
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Reviews")
                    }
                    .tag(3)
            }
            .accentColor(.blue)
            .navigationTitle("Student Dashboard")
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

struct StudentProfileView: View {
    let student: Student
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingEditProfile = false
    
    var body: some View {
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

                // Profile Details
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
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEditProfile = true
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileSheet(student: student, isPresented: $showingEditProfile)
        }
    }
}

struct StudentInternshipView: View {
    let student: Student
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingOfferDetails = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let internship = student.currentInternship {
                    InternshipCard(internship: internship, student: student)
                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "briefcase")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Active Internship")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Wait for hiring companies to offer you an internship")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
            }
            .padding()
        }
    }
}

struct InternshipCard: View {
    let internship: Internship
    let student: Student
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingDetails = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "building.2")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(internship.company.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(internship.role)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: internship.status)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(label: "Department", value: internship.department)
                InfoRow(label: "Team", value: internship.team)
                InfoRow(label: "Manager", value: internship.managerName)
                InfoRow(label: "Start Date", value: formatDate(internship.startDate))
                InfoRow(label: "End Date", value: formatDate(internship.endDate))
            }
            
            if internship.status == .offered {
                Divider()
                
                if student.facilitatorAcceptedOffer {
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Facilitator has accepted this offer on your behalf")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("View Internship") {
                            // Navigate to intern view
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    HStack(spacing: 15) {
                        Button("Decline") {
                            viewModel.declineInternship(student: student)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Accept") {
                            viewModel.acceptInternship(student: student)
                        }
                        .buttonStyle(.borderedProminent)
                    }
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

struct StatusBadge: View {
    let status: InternshipStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(colorForStatus)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    private var colorForStatus: Color {
        switch status {
        case .offered:
            return .orange
        case .accepted:
            return .blue
        case .declined:
            return .red
        case .active:
            return .green
        case .completed:
            return .purple
        case .hired:
            return .mint
        }
    }
}

struct StudentProgressView: View {
    let student: Student
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Academic Progress
                VStack(alignment: .leading, spacing: 15) {
                    Text("Academic Progress")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        ProgressView(value: student.academicProgress)
                            .tint(.blue)
                        
                        Text("\(Int(student.academicProgress * 100))% Complete")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                
                // Internship Status
                VStack(alignment: .leading, spacing: 15) {
                    Text("Internship Status")
                        .font(.headline)
                    
                    HStack {
                        StatusBadge(status: student.internshipStatus)
                        
                        Spacer()
                        
                        if student.hiredPermanently {
                            HStack {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(.green)
                                Text("Permanently Hired")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(15)
                
                // Achievements
                VStack(alignment: .leading, spacing: 15) {
                    Text("Achievements")
                        .font(.headline)
                    
                    if student.achievements.isEmpty {
                        Text("No achievements yet")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(student.achievements) { achievement in
                            AchievementRow(achievement: achievement)
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

struct StudentReviewsView: View {
    let student: Student
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if student.reviews.isEmpty {
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
                    ForEach(student.reviews) { review in
                        ReviewCard(review: review)
                    }
                }
            }
            .padding()
        }
    }
}

struct ReviewCard: View {
    let review: Review
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(review.reviewerName)
                        .font(.headline)
                    Text(review.reviewerRole)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 3) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(review.rating) ? "star.fill" : "star")
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Text(review.comments)
                .font(.body)
            
            HStack {
                Text(review.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(8)
                
                Spacer()
                
                Text(formatDate(review.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatDate(achievement.date))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 5)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
        }
    }
}

struct EditProfileSheet: View {
    let student: Student
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var bio = ""
    @State private var skillsText = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Bio")) {
                    TextField("Tell us about yourself", text: $bio, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Skills")) {
                    TextField("Skills (comma separated)", text: $skillsText, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Profile")
            .onAppear {
                firstName = student.firstName
                lastName = student.lastName
                email = student.email
                phoneNumber = student.phoneNumber
                bio = student.bio
                skillsText = student.skills.joined(separator: ", ")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        var updatedStudent = student
                        updatedStudent.firstName = firstName
                        updatedStudent.lastName = lastName
                        updatedStudent.email = email
                        updatedStudent.phoneNumber = phoneNumber
                        updatedStudent.bio = bio
                        updatedStudent.skills = skillsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                        viewModel.updateStudent(updatedStudent)
                        isPresented = false
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

// Simple FlowLayout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return CGSize(width: proposal.width ?? 0, height: result.height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var positions: [CGPoint] = []
        var height: CGFloat = 0
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > width && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            
            height = currentY + lineHeight
        }
    }
}

#Preview {
    StudentDashboardView()
        .environmentObject(AppViewModel())
}

