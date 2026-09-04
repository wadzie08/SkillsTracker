//
//  Manager.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import SwiftUI

struct ManagerDashboardView: View {
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        if let manager = viewModel.currentUser as? Manager {
            TabView(selection: $selectedTab) {
                ManagerProfileView(manager: manager)
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }
                    .tag(0)
                
                ManagerInternsView(manager: manager)
                    .tabItem {
                        Image(systemName: "person.2")
                        Text("Interns")
                    }
                    .tag(1)
                
                ManagerChatView(manager: manager)
                    .tabItem {
                        Image(systemName: "message")
                        Text("Chat")
                    }
                    .tag(2)
                
                ManagerTicketsView(manager: manager)
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Tickets")
                    }
                    .tag(3)
                
                ManagerReviewsView(manager: manager)
                    .tabItem {
                        Image(systemName: "star.fill")
                        Text("Reviews")
                    }
                    .tag(4)
            }
            .accentColor(.cyan)
            .navigationTitle("Manager Dashboard")
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

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 40)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(message.content)
                    .font(.body)
                    .padding(10)
                    .background(isCurrentUser ? Color.cyan.opacity(0.18) : Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if !isCurrentUser {
                Spacer(minLength: 40)
            }
        }
    }
}

struct TicketCard: View {
    let ticket: Ticket
    let internship: Internship
    let student: Student
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(ticket.title)
                        .font(.headline)
                    Text(student.fullName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(ticket.status.rawValue)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            Text(ticket.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label(ticket.priority, systemImage: "flag.fill")
                Spacer()
                Label(internship.role, systemImage: "briefcase.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .padding(.horizontal)
    }
    
    private var statusColor: Color {
        switch ticket.status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

struct WeeklyReviewCard: View {
    let review: WeeklyReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Week \(review.weekNumber)")
                    .font(.headline)
                Spacer()
                Label(String(format: "%.1f", review.performanceRating), systemImage: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            Text(review.reviewerName)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(review.comments)
                .font(.subheadline)
            
            if !review.goalsForNextWeek.isEmpty {
                InfoRow(label: "Next Goals", value: review.goalsForNextWeek)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct ManagerProfileView: View {
    let manager: Manager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile Header
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(Color.cyan.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.cyan)
                    }
                    
                    Text(manager.fullName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(manager.managerID)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Manager Details
                VStack(alignment: .leading, spacing: 15) {
                    Section(header: Text("Manager Information").font(.headline)) {
                        InfoRow(label: "Company", value: manager.company.rawValue)
                        InfoRow(label: "Department", value: manager.department)
                        InfoRow(label: "Team", value: manager.team)
                        InfoRow(label: "Email", value: manager.email)
                    }
                    
                    Section(header: Text("Assigned Interns").font(.headline)) {
                        Text("\(manager.assignedInterns.count) interns assigned")
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
}

struct ManagerInternsView: View {
    let manager: Manager
    @EnvironmentObject var viewModel: AppViewModel
    
    var myInterns: [Student] {
        viewModel.students.filter { manager.assignedInterns.contains($0.id) }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats
                HStack(spacing: 20) {
                    StatCard(title: "Total Interns", value: "\(myInterns.count)", icon: "person.2", color: .cyan)
                    StatCard(title: "Active", value: "\(activeInternsCount)", icon: "briefcase.fill", color: .green)
                }
                .padding(.horizontal)
                
                // Interns List
                VStack(alignment: .leading, spacing: 15) {
                    Text("My Interns")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if myInterns.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "person.2")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Interns Assigned")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Interns will appear here when assigned to you")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        ForEach(myInterns) { intern in
                            ManagerInternCard(intern: intern, manager: manager)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var activeInternsCount: Int {
        myInterns.filter { $0.internshipStatus == .active }.count
    }
}

struct ManagerInternCard: View {
    let intern: Student
    let manager: Manager
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingProfile = false
    @State private var showingTicketSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(intern.fullName)
                        .font(.headline)
                    Text(intern.studentID)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusBadge(status: intern.internshipStatus)
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Email")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(intern.email)
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Academic Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ProgressView(value: intern.academicProgress)
                        .frame(width: 80)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Skills")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(intern.skills.count)")
                        .font(.caption)
                }
            }
            
            HStack(spacing: 10) {
                Button("View Profile") {
                    showingProfile = true
                }
                .buttonStyle(.bordered)
                
                Button("Send Ticket") {
                    showingTicketSheet = true
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .sheet(isPresented: $showingProfile) {
            StudentProfileDetailView(student: intern)
        }
        .sheet(isPresented: $showingTicketSheet) {
            ManagerTicketSheet(intern: intern, manager: manager, isPresented: $showingTicketSheet)
        }
    }
}

struct ManagerChatView: View {
    let manager: Manager
    @EnvironmentObject var viewModel: AppViewModel
    @State private var selectedIntern: Student?
    
    var myInterns: [Student] {
        viewModel.students.filter { manager.assignedInterns.contains($0.id) }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let intern = selectedIntern {
                    ManagerChatDetailView(manager: manager, intern: intern)
                } else {
                    VStack(spacing: 15) {
                        Image(systemName: "message")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Select an Intern to Chat")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Choose an intern from your assigned list to start a conversation")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    
                    List {
                        ForEach(myInterns) { intern in
                            Button(action: {
                                selectedIntern = intern
                            }) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(intern.fullName)
                                            .font(.headline)
                                        Text(intern.studentID)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    if let internship = intern.currentInternship {
                                        if let lastMessage = internship.messages.last {
                                            Text(formatTime(lastMessage.timestamp))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Chat")
            .toolbar {
                if selectedIntern != nil {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            selectedIntern = nil
                        }
                    }
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ManagerChatDetailView: View {
    let manager: Manager
    let intern: Student
    @EnvironmentObject var viewModel: AppViewModel
    @State private var newMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat Header
            HStack {
                VStack(alignment: .leading) {
                    Text(intern.fullName)
                        .font(.headline)
                    Text("Intern")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            
            // Messages
            ScrollView {
                VStack(spacing: 10) {
                    if let internship = intern.currentInternship {
                        if internship.messages.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "message")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No Messages Yet")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text("Start a conversation with your intern")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        } else {
                            ForEach(internship.messages) { message in
                                MessageBubble(message: message, isCurrentUser: message.senderID == manager.id)
                            }
                        }
                    }
                }
                .padding()
            }
            
            // Message Input
            HStack(spacing: 10) {
                TextField("Type a message...", text: $newMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if !newMessage.isEmpty, let internship = intern.currentInternship {
                        let message = Message(
                            senderID: manager.id,
                            senderName: manager.fullName,
                            senderRole: "Manager",
                            content: newMessage
                        )
                        viewModel.addMessage(to: internship, message: message)
                        newMessage = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.cyan)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
    }
}

struct ManagerTicketsView: View {
    let manager: Manager
    @EnvironmentObject var viewModel: AppViewModel
    
    var myInterns: [Student] {
        viewModel.students.filter { manager.assignedInterns.contains($0.id) }
    }
    
    // Pair each ticket with the internship and student it belongs to
    var allTicketEntries: [(ticket: Ticket, internship: Internship, student: Student)] {
        myInterns.compactMap { student -> [(Ticket, Internship, Student)]? in
            guard let internship = student.currentInternship else { return nil }
            return internship.tickets.map { ($0, internship, student) }
        }
        .flatMap { $0 }
    }
    
    var allTickets: [Ticket] {
        allTicketEntries.map { $0.ticket }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats
                HStack(spacing: 20) {
                    StatCard(title: "Total Tickets", value: "\(allTickets.count)", icon: "list.bullet", color: .cyan)
                    StatCard(title: "Pending", value: "\(pendingCount)", icon: "clock", color: .orange)
                }
                .padding(.horizontal)
                
                // Tickets List
                VStack(alignment: .leading, spacing: 15) {
                    Text("All Tickets")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if allTicketEntries.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "list.bullet")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Tickets")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Tickets from your interns will appear here")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        ForEach(allTicketEntries.sorted(by: { $0.ticket.assignedDate > $1.ticket.assignedDate }), id: \.ticket.id) { entry in
                            TicketCard(ticket: entry.ticket, internship: entry.internship, student: entry.student)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private var pendingCount: Int {
        allTickets.filter { $0.status == .pending }.count
    }
}

struct ManagerReviewsView: View {
    let manager: Manager
    @EnvironmentObject var viewModel: AppViewModel
    @State private var showingAddReview = false
    
    var myInterns: [Student] {
        viewModel.students.filter { manager.assignedInterns.contains($0.id) }
    }
    
    var allReviews: [WeeklyReview] {
        myInterns.flatMap { $0.currentInternship?.weeklyReviews ?? [] }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats
                HStack(spacing: 20) {
                    StatCard(title: "Reviews Given", value: "\(allReviews.count)", icon: "star.fill", color: .cyan)
                    StatCard(title: "Avg Rating", value: String(format: "%.1f", averageRating), icon: "chart.bar.fill", color: .blue)
                }
                .padding(.horizontal)
                
                Button(action: {
                    showingAddReview = true
                }) {
                    Label("Add Weekly Review", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
                .padding(.horizontal)
                .disabled(myInterns.isEmpty)
                
                // Reviews List
                VStack(alignment: .leading, spacing: 15) {
                    Text("Weekly Reviews")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if allReviews.isEmpty {
                        VStack(spacing: 15) {
                            Image(systemName: "star")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("No Reviews Yet")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Your weekly reviews will appear here")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        ForEach(allReviews.sorted(by: { $0.weekNumber > $1.weekNumber })) { review in
                            WeeklyReviewCard(review: review)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingAddReview) {
            ManagerAddWeeklyReviewSheet(manager: manager, interns: myInterns, isPresented: $showingAddReview)
        }
    }
    
    private var averageRating: Double {
        guard !allReviews.isEmpty else { return 0.0 }
        let total = allReviews.reduce(0.0) { $0 + $1.performanceRating }
        return total / Double(allReviews.count)
    }
}

struct ManagerAddWeeklyReviewSheet: View {
    let manager: Manager
    let interns: [Student]
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    
    @State private var selectedIntern: Student?
    @State private var weekNumber = 1
    @State private var performanceRating = 3.0
    @State private var attendanceRating = 3.0
    @State private var communicationRating = 3.0
    @State private var teamworkRating = 3.0
    @State private var technicalSkillsRating = 3.0
    @State private var comments = ""
    @State private var goalsForNextWeek = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Intern")) {
                    Picker("Intern", selection: $selectedIntern) {
                        Text("Select an intern").tag(nil as Student?)
                        ForEach(interns) { intern in
                            Text(intern.fullName).tag(intern as Student?)
                        }
                    }
                    
                    Stepper("Week \(weekNumber)", value: $weekNumber, in: 1...52)
                }
                
                Section(header: Text("Ratings")) {
                    RatingSliderRow(label: "Performance", value: $performanceRating)
                    RatingSliderRow(label: "Attendance", value: $attendanceRating)
                    RatingSliderRow(label: "Communication", value: $communicationRating)
                    RatingSliderRow(label: "Teamwork", value: $teamworkRating)
                    RatingSliderRow(label: "Technical Skills", value: $technicalSkillsRating)
                }
                
                Section(header: Text("Comments")) {
                    TextField("Comments about this week", text: $comments, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section(header: Text("Goals for Next Week")) {
                    TextField("Goals for next week", text: $goalsForNextWeek, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Weekly Review")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Submit") {
                        if let intern = selectedIntern, let internship = intern.currentInternship {
                            let review = WeeklyReview(
                                weekNumber: weekNumber,
                                reviewerName: manager.fullName,
                                performanceRating: performanceRating,
                                attendanceRating: attendanceRating,
                                communicationRating: communicationRating,
                                teamworkRating: teamworkRating,
                                technicalSkillsRating: technicalSkillsRating,
                                comments: comments,
                                goalsForNextWeek: goalsForNextWeek
                            )
                            viewModel.addWeeklyReview(to: internship, review: review)
                            isPresented = false
                        }
                    }
                    .disabled(selectedIntern == nil)
                }
            }
        }
    }
}

struct RatingSliderRow: View {
    let label: String
    @Binding var value: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                Spacer()
                Text(String(format: "%.1f", value))
                    .foregroundColor(.cyan)
            }
            Slider(value: $value, in: 1...5, step: 0.5)
        }
    }
}

struct ManagerTicketSheet: View {
    let intern: Student
    let manager: Manager
    @Binding var isPresented: Bool
    @EnvironmentObject var viewModel: AppViewModel
    @State private var title = ""
    @State private var description = ""
    @State private var priority = "Medium"
    
    let priorities = ["Low", "Medium", "High"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Ticket Details")) {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(priorities, id: \.self) { priority in
                            Text(priority).tag(priority)
                        }
                    }
                }
                
                Section(header: Text("Intern Information")) {
                    HStack {
                        Text("Intern")
                        Spacer()
                        Text(intern.fullName)
                            .foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Intern ID")
                        Spacer()
                        Text(intern.studentID)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Send Ticket")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Send") {
                        if let internship = intern.currentInternship {
                            let ticket = Ticket(
                                title: title,
                                description: description,
                                status: .pending,
                                priority: priority,
                                assignedBy: manager.fullName,
                                assignedDate: Date()
                            )
                            viewModel.addTicket(to: internship, ticket: ticket)
                            isPresented = false
                        }
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
        }
    }
}

#Preview {
    ManagerDashboardView()
        .environmentObject(AppViewModel())
}

