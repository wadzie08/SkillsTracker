//
//  Models.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import Foundation

// MARK: - User Roles
enum UserRole: String, Codable, CaseIterable {
    case student = "Student"
    case facilitator = "Facilitator"
    case programManager = "Program Manager"
    case employer = "Employer"
    case externalViewer = "External Viewer"
}

// MARK: - Staff Departments
enum StaffDepartment: String, Codable, CaseIterable {
    case facilitator = "Facilitator"
    case technical = "Technical"
    case maintenance = "Maintenance"
    case generalHelp = "General Help"
    case administration = "Administration"
}

// MARK: - Hiring Companies
enum HiringCompany: String, Codable, CaseIterable {
    case jamf = "Jamf"
    case mainsl = "Mainsl"
    case tradition = "Tradition"
    case apple = "Apple"
}

// MARK: - Ticket Status
enum TicketStatus: String, Codable, CaseIterable {
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
}

// MARK: - Internship Status
enum InternshipStatus: String, Codable, CaseIterable {
    case offered = "Offered"
    case accepted = "Accepted"
    case declined = "Declined"
    case active = "Active"
    case completed = "Completed"
    case hired = "Hired"
}

// MARK: - Base User Model
struct User: Identifiable, Codable {
    var id: UUID
    var role: UserRole
    var isActive: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), role: UserRole, isActive: Bool = true, createdAt: Date = Date()) {
        self.id = id
        self.role = role
        self.isActive = isActive
        self.createdAt = createdAt
    }
}

// MARK: - Student Model
struct Student: Identifiable, Codable, Hashable {
    var id: UUID
    var studentID: String
    var password: String
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var profileImage: String?
    var bio: String
    var skills: [String]
    var academicProgress: Double
    var internshipStatus: InternshipStatus
    var currentInternship: Internship?
    var facilitatorAcceptedOffer: Bool
    var reviews: [Review]
    var achievements: [Achievement]
    var isActive: Bool
    var archivedAt: Date?
    var hiredPermanently: Bool
    var permanentHireCompany: String?
    
    init(id: UUID = UUID(), studentID: String, password: String, firstName: String, lastName: String, email: String, phoneNumber: String, profileImage: String? = nil, bio: String = "", skills: [String] = [], academicProgress: Double = 0.0, internshipStatus: InternshipStatus = .offered, currentInternship: Internship? = nil, facilitatorAcceptedOffer: Bool = false, reviews: [Review] = [], achievements: [Achievement] = [], isActive: Bool = true, archivedAt: Date? = nil, hiredPermanently: Bool = false, permanentHireCompany: String? = nil) {
        self.id = id
        self.studentID = studentID
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImage = profileImage
        self.bio = bio
        self.skills = skills
        self.academicProgress = academicProgress
        self.internshipStatus = internshipStatus
        self.currentInternship = currentInternship
        self.facilitatorAcceptedOffer = facilitatorAcceptedOffer
        self.reviews = reviews
        self.achievements = achievements
        self.isActive = isActive
        self.archivedAt = archivedAt
        self.hiredPermanently = hiredPermanently
        self.permanentHireCompany = permanentHireCompany
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Staff Model
struct Staff: Identifiable, Codable {
    var id: UUID
    var staffID: String
    var password: String
    var firstName: String
    var lastName: String
    var email: String
    var department: StaffDepartment
    var permissions: [String]
    var isActive: Bool
    
    init(id: UUID = UUID(), staffID: String, password: String, firstName: String, lastName: String, email: String, department: StaffDepartment, permissions: [String] = [], isActive: Bool = true) {
        self.id = id
        self.staffID = staffID
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.department = department
        self.permissions = permissions
        self.isActive = isActive
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Management Model
struct Management: Identifiable, Codable {
    var id: UUID
    var username: String
    var password: String
    var firstName: String
    var lastName: String
    var email: String
    var isActive: Bool
    
    init(id: UUID = UUID(), username: String, password: String, firstName: String, lastName: String, email: String, isActive: Bool = true) {
        self.id = id
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.isActive = isActive
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Hiring Company User Model
struct HiringCompanyUser: Identifiable, Codable {
    var id: UUID
    var company: HiringCompany
    var contactName: String
    var email: String
    var password: String
    var department: String
    var isActive: Bool
    
    init(id: UUID = UUID(), company: HiringCompany, contactName: String, email: String, password: String, department: String = "", isActive: Bool = true) {
        self.id = id
        self.company = company
        self.contactName = contactName
        self.email = email
        self.password = password
        self.department = department
        self.isActive = isActive
    }
}

// MARK: - Manager Model
struct Manager: Identifiable, Codable, Hashable {
    var id: UUID
    var managerID: String
    var password: String
    var firstName: String
    var lastName: String
    var email: String
    var company: HiringCompany
    var department: String
    var team: String
    var assignedInterns: [UUID]
    var isActive: Bool
    
    init(id: UUID = UUID(), managerID: String, password: String, firstName: String, lastName: String, email: String, company: HiringCompany, department: String = "", team: String = "", assignedInterns: [UUID] = [], isActive: Bool = true) {
        self.id = id
        self.managerID = managerID
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.company = company
        self.department = department
        self.team = team
        self.assignedInterns = assignedInterns
        self.isActive = isActive
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Employer Model
struct Employer: Identifiable, Codable {
    var id: UUID
    var employerID: String
    var password: String
    var firstName: String
    var lastName: String
    var email: String
    var company: HiringCompany
    var department: String
    var position: String
    var permissions: [String]
    var isActive: Bool
    
    init(id: UUID = UUID(), employerID: String, password: String, firstName: String, lastName: String, email: String, company: HiringCompany, department: String = "", position: String = "", permissions: [String] = [], isActive: Bool = true) {
        self.id = id
        self.employerID = employerID
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.company = company
        self.department = department
        self.position = position
        self.permissions = permissions
        self.isActive = isActive
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - External Viewer Model
struct ExternalViewer: Identifiable, Codable {
    var id: UUID
    var viewerID: String
    var password: String
    var firstName: String
    var lastName: String
    var email: String
    var organization: String
    var accessLevel: String
    var permissions: [String]
    var isActive: Bool
    
    init(id: UUID = UUID(), viewerID: String, password: String, firstName: String, lastName: String, email: String, organization: String = "", accessLevel: String = "Read Only", permissions: [String] = [], isActive: Bool = true) {
        self.id = id
        self.viewerID = viewerID
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.organization = organization
        self.accessLevel = accessLevel
        self.permissions = permissions
        self.isActive = isActive
    }
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
}

// MARK: - Internship Model
struct Internship: Identifiable, Codable, Hashable {
    var id: UUID
    var studentID: UUID
    var company: HiringCompany
    var department: String
    var role: String
    var managerName: String
    var managerEmail: String
    var team: String
    var startDate: Date
    var endDate: Date
    var status: InternshipStatus
    var tickets: [Ticket]
    var meetings: [Meeting]
    var weeklyReviews: [WeeklyReview]
    var messages: [Message]
    
    init(id: UUID = UUID(), studentID: UUID, company: HiringCompany, department: String, role: String, managerName: String, managerEmail: String, team: String, startDate: Date, endDate: Date, status: InternshipStatus = .offered, tickets: [Ticket] = [], meetings: [Meeting] = [], weeklyReviews: [WeeklyReview] = [], messages: [Message] = []) {
        self.id = id
        self.studentID = studentID
        self.company = company
        self.department = department
        self.role = role
        self.managerName = managerName
        self.managerEmail = managerEmail
        self.team = team
        self.startDate = startDate
        self.endDate = endDate
        self.status = status
        self.tickets = tickets
        self.meetings = meetings
        self.weeklyReviews = weeklyReviews
        self.messages = messages
    }
}

// MARK: - Ticket Model
struct Ticket: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var status: TicketStatus
    var priority: String
    var assignedBy: String
    var assignedDate: Date
    var dueDate: Date?
    var completedDate: Date?
    
    init(id: UUID = UUID(), title: String, description: String, status: TicketStatus = .pending, priority: String = "Medium", assignedBy: String, assignedDate: Date = Date(), dueDate: Date? = nil, completedDate: Date? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.priority = priority
        self.assignedBy = assignedBy
        self.assignedDate = assignedDate
        self.dueDate = dueDate
        self.completedDate = completedDate
    }
}

// MARK: - Meeting Model
struct Meeting: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var date: Date
    var duration: Int
    var location: String
    var attendees: [String]
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, description: String, date: Date, duration: Int = 60, location: String = "", attendees: [String] = [], isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.duration = duration
        self.location = location
        self.attendees = attendees
        self.isCompleted = isCompleted
    }
}

// MARK: - Review Model
struct Review: Identifiable, Codable, Hashable {
    var id: UUID
    var reviewerID: UUID
    var reviewerName: String
    var reviewerRole: String
    var studentID: UUID
    var rating: Double
    var comments: String
    var date: Date
    var category: String
    
    init(id: UUID = UUID(), reviewerID: UUID, reviewerName: String, reviewerRole: String, studentID: UUID, rating: Double, comments: String, date: Date = Date(), category: String = "General") {
        self.id = id
        self.reviewerID = reviewerID
        self.reviewerName = reviewerName
        self.reviewerRole = reviewerRole
        self.studentID = studentID
        self.rating = rating
        self.comments = comments
        self.date = date
        self.category = category
    }
}

// MARK: - Weekly Review Model
struct WeeklyReview: Identifiable, Codable, Hashable {
    var id: UUID
    var weekNumber: Int
    var reviewerName: String
    var performanceRating: Double
    var attendanceRating: Double
    var communicationRating: Double
    var teamworkRating: Double
    var technicalSkillsRating: Double
    var comments: String
    var goalsForNextWeek: String
    var date: Date
    
    init(id: UUID = UUID(), weekNumber: Int, reviewerName: String, performanceRating: Double, attendanceRating: Double, communicationRating: Double, teamworkRating: Double, technicalSkillsRating: Double, comments: String, goalsForNextWeek: String, date: Date = Date()) {
        self.id = id
        self.weekNumber = weekNumber
        self.reviewerName = reviewerName
        self.performanceRating = performanceRating
        self.attendanceRating = attendanceRating
        self.communicationRating = communicationRating
        self.teamworkRating = teamworkRating
        self.technicalSkillsRating = technicalSkillsRating
        self.comments = comments
        self.goalsForNextWeek = goalsForNextWeek
        self.date = date
    }
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var description: String
    var date: Date
    var category: String
    var attachmentURL: String?
    
    init(id: UUID = UUID(), title: String, description: String, date: Date = Date(), category: String = "General", attachmentURL: String? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.category = category
        self.attachmentURL = attachmentURL
    }
}

// MARK: - Message Model
struct Message: Identifiable, Codable, Hashable {
    var id: UUID
    var senderID: UUID
    var senderName: String
    var senderRole: String
    var content: String
    var timestamp: Date
    var isRead: Bool
    
    init(id: UUID = UUID(), senderID: UUID, senderName: String, senderRole: String, content: String, timestamp: Date = Date(), isRead: Bool = false) {
        self.id = id
        self.senderID = senderID
        self.senderName = senderName
        self.senderRole = senderRole
        self.content = content
        self.timestamp = timestamp
        self.isRead = isRead
    }
}
