//
//  ViewModels.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import Foundation
import SwiftUI
internal import Combine

class AppViewModel: ObservableObject {
    let objectWillChange: ObservableObjectPublisher
    
    @Published var currentUser: Any?
    @Published var currentRole: UserRole?
    @Published var selectedCompany: HiringCompany?
    @Published var isLoggedIn = false
    @Published var showCongratulationAlert = false
    @Published var congratulationMessage = ""
    
    // Data stores
    @Published var students: [Student] = []
    @Published var staff: [Staff] = []
    @Published var management: [Management] = []
    @Published var hiringCompanies: [HiringCompanyUser] = []
    @Published var managers: [Manager] = []
    @Published var employers: [Employer] = []
    @Published var externalViewers: [ExternalViewer] = []
    
    private let persistenceManager = PersistenceManager.shared
    
    init() {
        objectWillChange = ObservableObjectPublisher()
        loadData()
        if students.isEmpty {
            loadSampleData()
            saveData()
        }
    }
    
    // MARK: - Session Sync
    func refreshCurrentUser() {
        switch currentRole {
        case .student:
            if let student = currentUser as? Student,
               let updated = students.first(where: { $0.id == student.id }) {
                currentUser = updated
                currentRole = roleForStudent(updated)
            }
        case .facilitator:
            if let manager = currentUser as? Management,
               let updated = management.first(where: { $0.id == manager.id }) {
                currentUser = updated
            }
        case .programManager:
            if let managerUser = currentUser as? Manager,
               let updated = managers.first(where: { $0.id == managerUser.id }) {
                currentUser = updated
            }
        case .employer:
            if let employer = currentUser as? Employer,
               let updated = employers.first(where: { $0.id == employer.id }) {
                currentUser = updated
            }
        case .externalViewer:
            if let viewer = currentUser as? ExternalViewer,
               let updated = externalViewers.first(where: { $0.id == viewer.id }) {
                currentUser = updated
            }
        case .none:
            break
        }
    }
    
    private func roleForStudent(_ student: Student) -> UserRole {
        return .student
    }
    
    func student(withID id: UUID) -> Student? {
        students.first(where: { $0.id == id })
    }
    
    func internship(forStudentID id: UUID) -> Internship? {
        students.first(where: { $0.id == id })?.currentInternship
    }
    
    func isStudentAvailableForInternship(_ student: Student, company: HiringCompany) -> Bool {
        guard student.isActive else { return false }
        if student.internshipStatus == .active {
            return student.currentInternship?.company == company
        }
        if student.internshipStatus == .offered || student.internshipStatus == .accepted {
            return student.currentInternship?.company == company
        }
        return student.internshipStatus != .hired
    }
    
    // MARK: - Data Persistence
    private func loadData() {
        students = persistenceManager.loadStudents()
        staff = persistenceManager.loadStaff()
        management = persistenceManager.loadManagement()
        hiringCompanies = persistenceManager.loadHiringCompanies()
        managers = persistenceManager.loadManagers()
        employers = persistenceManager.loadEmployers()
        externalViewers = persistenceManager.loadExternalViewers()
    }
    
    private func saveData() {
        persistenceManager.saveAllData(
            students: students,
            staff: staff,
            management: management,
            hiringCompanies: hiringCompanies,
            managers: managers,
            employers: employers,
            externalViewers: externalViewers
        )
    }
    
    // MARK: - Authentication
    func loginStudent(studentID: String, password: String) -> Bool {
        guard let student = students.first(where: { $0.studentID == studentID && $0.password == password }) else {
            return false
        }
        
        if !student.isActive {
            return false
        }
        
        currentUser = student
        currentRole = roleForStudent(student)
        isLoggedIn = true
        return true
    }
    
    func loginStaff(staffID: String, password: String) -> Bool {
        guard let staffMember = staff.first(where: { $0.staffID == staffID && $0.password == password }) else {
            return false
        }
        
        if !staffMember.isActive {
            return false
        }
        
        currentUser = staffMember
        currentRole = .facilitator
        isLoggedIn = true
        return true
    }
    
    func loginManagement(username: String, password: String) -> Bool {
        guard let manager = management.first(where: { $0.username == username && $0.password == password }) else {
            return false
        }
        
        if !manager.isActive {
            return false
        }
        
        currentUser = manager
        currentRole = .programManager
        isLoggedIn = true
        return true
    }
    
    func loginHiringCompany(company: HiringCompany, email: String, password: String) -> Bool {
        guard let companyUser = hiringCompanies.first(where: { $0.company == company && $0.email == email && $0.password == password }) else {
            return false
        }
        
        if !companyUser.isActive {
            return false
        }
        
        currentUser = companyUser
        currentRole = .employer
        selectedCompany = company
        isLoggedIn = true
        return true
    }
    
    func loginManager(managerID: String, password: String) -> Bool {
        guard let manager = managers.first(where: { $0.managerID == managerID && $0.password == password }) else {
            return false
        }
        
        if !manager.isActive {
            return false
        }
        
        currentUser = manager
        currentRole = .externalViewer
        isLoggedIn = true
        return true
    }
    
    func loginEmployer(employerID: String, password: String) -> Bool {
        guard let employer = employers.first(where: { $0.employerID == employerID && $0.password == password }) else {
            return false
        }
        
        if !employer.isActive {
            return false
        }
        
        currentUser = employer
        currentRole = .employer
        isLoggedIn = true
        return true
    }
    
    func loginExternalViewer(viewerID: String, password: String) -> Bool {
        guard let viewer = externalViewers.first(where: { $0.viewerID == viewerID && $0.password == password }) else {
            return false
        }
        
        if !viewer.isActive {
            return false
        }
        
        currentUser = viewer
        currentRole = .externalViewer
        isLoggedIn = true
        return true
    }
    
    func logout() {
        currentUser = nil
        currentRole = nil
        selectedCompany = nil
        isLoggedIn = false
    }
    
    // MARK: - Student Management
    func addStudent(_ student: Student) {
        students.append(student)
        saveData()
    }
    
    func removeStudent(_ student: Student) {
        students.removeAll { $0.id == student.id }
        saveData()
    }
    
    func updateStudent(_ student: Student) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index] = student
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - Staff Management
    func addStaff(_ staffMember: Staff) {
        staff.append(staffMember)
        saveData()
    }
    
    func removeStaff(_ staffMember: Staff) {
        staff.removeAll { $0.id == staffMember.id }
        saveData()
    }
    
    func updateStaff(_ staffMember: Staff) {
        if let index = staff.firstIndex(where: { $0.id == staffMember.id }) {
            staff[index] = staffMember
            saveData()
            refreshCurrentUser()
        }
    }
    
    func updateManagement(_ manager: Management) {
        if let index = management.firstIndex(where: { $0.id == manager.id }) {
            management[index] = manager
            saveData()
            refreshCurrentUser()
        }
    }
    
    func updateHiringCompany(_ companyUser: HiringCompanyUser) {
        if let index = hiringCompanies.firstIndex(where: { $0.id == companyUser.id }) {
            hiringCompanies[index] = companyUser
            saveData()
            refreshCurrentUser()
        }
    }
    
    func updateManager(_ manager: Manager) {
        if let index = managers.firstIndex(where: { $0.id == manager.id }) {
            managers[index] = manager
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - Employer Management
    func addEmployer(_ employer: Employer) {
        employers.append(employer)
        saveData()
    }
    
    func removeEmployer(_ employer: Employer) {
        employers.removeAll { $0.id == employer.id }
        saveData()
    }
    
    func updateEmployer(_ employer: Employer) {
        if let index = employers.firstIndex(where: { $0.id == employer.id }) {
            employers[index] = employer
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - External Viewer Management
    func addExternalViewer(_ viewer: ExternalViewer) {
        externalViewers.append(viewer)
        saveData()
    }
    
    func removeExternalViewer(_ viewer: ExternalViewer) {
        externalViewers.removeAll { $0.id == viewer.id }
        saveData()
    }
    
    func updateExternalViewer(_ viewer: ExternalViewer) {
        if let index = externalViewers.firstIndex(where: { $0.id == viewer.id }) {
            externalViewers[index] = viewer
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - Manager Management
    func addManager(_ manager: Manager) {
        managers.append(manager)
        saveData()
    }
    
    func removeManager(_ manager: Manager) {
        managers.removeAll { $0.id == manager.id }
        saveData()
    }
    
    func changeInternManager(student: Student, newManager: Manager) {
        // Remove student from old manager's assignedInterns
        for index in managers.indices {
            if managers[index].assignedInterns.contains(student.id) {
                managers[index].assignedInterns.removeAll { $0 == student.id }
            }
        }
        
        // Add student to new manager's assignedInterns
        if let managerIndex = managers.firstIndex(where: { $0.id == newManager.id }) {
            if !managers[managerIndex].assignedInterns.contains(student.id) {
                managers[managerIndex].assignedInterns.append(student.id)
            }
        }
        
        // Update student's internship manager info
        if let studentIndex = students.firstIndex(where: { $0.id == student.id }),
           var internship = students[studentIndex].currentInternship {
            internship.managerName = newManager.fullName
            internship.managerEmail = newManager.email
            students[studentIndex].currentInternship = internship
        }
        
        saveData()
    }
    
    // MARK: - Management Management
    func addManagement(_ manager: Management) {
        management.append(manager)
        saveData()
    }
    
    func removeManagement(_ manager: Management) {
        management.removeAll { $0.id == manager.id }
        saveData()
    }
    
    // MARK: - Hiring Company Management
    func addHiringCompany(_ companyUser: HiringCompanyUser) {
        hiringCompanies.append(companyUser)
        saveData()
    }
    
    func removeHiringCompany(_ companyUser: HiringCompanyUser) {
        hiringCompanies.removeAll { $0.id == companyUser.id }
        saveData()
    }
    
    // MARK: - Internship Management
    func offerInternship(to student: Student, company: HiringCompany, role: String, department: String, managerName: String, managerEmail: String, team: String, startDate: Date, endDate: Date) {
        let internship = Internship(
            studentID: student.id,
            company: company,
            department: department,
            role: role,
            managerName: managerName,
            managerEmail: managerEmail,
            team: team,
            startDate: startDate,
            endDate: endDate,
            status: .offered
        )
        
        // Create or update manager
        let managerID = "MGR-\(UUID().uuidString.prefix(8).uppercased())"
        let managerPassword = "Manager123" // Default password
        let nameComponents = managerName.split(separator: " ")
        let managerFirstName = nameComponents.count > 0 ? String(nameComponents[0]) : managerName
        let managerLastName = nameComponents.count > 1 ? nameComponents[1...].joined(separator: " ") : ""
        
        let newManager = Manager(
            managerID: managerID,
            password: managerPassword,
            firstName: managerFirstName,
            lastName: managerLastName,
            email: managerEmail,
            company: company,
            department: department,
            team: team,
            assignedInterns: [student.id]
        )
        
        // Check if manager already exists by email
        if let existingManagerIndex = managers.firstIndex(where: { $0.email == managerEmail }) {
            // Update existing manager with new intern
            if !managers[existingManagerIndex].assignedInterns.contains(student.id) {
                managers[existingManagerIndex].assignedInterns.append(student.id)
            }
        } else {
            // Create new manager
            managers.append(newManager)
        }
        
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].currentInternship = internship
            students[index].internshipStatus = .offered
            saveData()
            refreshCurrentUser()
        }
    }
    
    func assignInternDirectly(to student: Student, company: HiringCompany, role: String, department: String, managerName: String, managerEmail: String, team: String, startDate: Date, endDate: Date) {
        let internship = Internship(
            studentID: student.id,
            company: company,
            department: department,
            role: role,
            managerName: managerName,
            managerEmail: managerEmail,
            team: team,
            startDate: startDate,
            endDate: endDate,
            status: .active
        )
        
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].currentInternship = internship
            students[index].internshipStatus = .active
            students[index].facilitatorAcceptedOffer = true
            saveData()
            refreshCurrentUser()
        }
    }
    
    func acceptInternship(student: Student) {
        guard let currentStudent = students.first(where: { $0.id == student.id }),
              !currentStudent.facilitatorAcceptedOffer else {
            return
        }
        
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].internshipStatus = .active
            if var internship = students[index].currentInternship {
                internship.status = .active
                students[index].currentInternship = internship
            }
            saveData()
            refreshCurrentUser()
        }
    }
    
    func declineInternship(student: Student) {
        guard let currentStudent = students.first(where: { $0.id == student.id }),
              !currentStudent.facilitatorAcceptedOffer else {
            return
        }
        
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].internshipStatus = .declined
            students[index].currentInternship = nil
            saveData()
            refreshCurrentUser()
        }
    }
    
    func facilitatorAcceptInternship(student: Student) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].facilitatorAcceptedOffer = true
            students[index].internshipStatus = .active
            if var internship = students[index].currentInternship {
                internship.status = .active
                students[index].currentInternship = internship
            }
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - Permanent Hiring
    func offerPermanentPosition(to student: Student, company: HiringCompany) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].hiredPermanently = true
            students[index].permanentHireCompany = company.rawValue
            students[index].isActive = false
            students[index].archivedAt = Date()
            
            congratulationMessage = "Congratulations! You have been offered a permanent position at \(company.rawValue). Your account has been archived."
            showCongratulationAlert = true
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - Ticket Management
    func addTicket(to internship: Internship, ticket: Ticket) {
        if let studentIndex = students.firstIndex(where: { $0.currentInternship?.id == internship.id }) {
            students[studentIndex].currentInternship?.tickets.append(ticket)
            saveData()
            refreshCurrentUser()
        }
    }
    
    func updateTicket(ticket: Ticket, in internship: Internship) {
        if let studentIndex = students.firstIndex(where: { $0.currentInternship?.id == internship.id }),
           let ticketIndex = students[studentIndex].currentInternship?.tickets.firstIndex(where: { $0.id == ticket.id }) {
            students[studentIndex].currentInternship?.tickets[ticketIndex] = ticket
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - Review Management
    func addReview(to student: Student, review: Review) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].reviews.append(review)
            saveData()
            refreshCurrentUser()
        }
    }
    
    func addWeeklyReview(to internship: Internship, review: WeeklyReview) {
        if let studentIndex = students.firstIndex(where: { $0.currentInternship?.id == internship.id }) {
            students[studentIndex].currentInternship?.weeklyReviews.append(review)
            saveData()
            refreshCurrentUser()
        }
    }
    
    // MARK: - Achievement Management
    func addAchievement(to student: Student, achievement: Achievement) {
        if let index = students.firstIndex(where: { $0.id == student.id }) {
            students[index].achievements.append(achievement)
            saveData()
        }
    }
    
    // MARK: - Message Management
    func addMessage(to internship: Internship, message: Message) {
        if let studentIndex = students.firstIndex(where: { $0.currentInternship?.id == internship.id }) {
            students[studentIndex].currentInternship?.messages.append(message)
            saveData()
        }
    }
    
    // MARK: - Meeting Management
    func addMeeting(to internship: Internship, meeting: Meeting) {
        if let studentIndex = students.firstIndex(where: { $0.currentInternship?.id == internship.id }) {
            students[studentIndex].currentInternship?.meetings.append(meeting)
            saveData()
        }
    }
    
    // MARK: - Sample Data
    private func loadSampleData() {
        // Sample Students
        students = [
            Student(
                studentID: "STU001",
                password: "password123",
                firstName: "John",
                lastName: "Doe",
                email: "john.doe@email.com",
                phoneNumber: "555-0101",
                bio: "Computer Science student passionate about iOS development",
                skills: ["Swift", "iOS Development", "Python", "SQL"],
                academicProgress: 0.85
            ),
            Student(
                studentID: "STU002",
                password: "password123",
                firstName: "Jane",
                lastName: "Smith",
                email: "jane.smith@email.com",
                phoneNumber: "555-0102",
                bio: "Information Technology student with focus on cybersecurity",
                skills: ["Cybersecurity", "Network Administration", "Linux", "Python"],
                academicProgress: 0.92
            )
        ]
        
        // Sample Staff
        staff = [
            Staff(
                staffID: "STA001",
                password: "password123",
                firstName: "Dr. Robert",
                lastName: "Johnson",
                email: "r.johnson@matter.edu",
                department: .facilitator,
                permissions: ["review_students", "accept_offers", "view_all"]
            ),
            Staff(
                staffID: "STA002",
                password: "password123",
                firstName: "Sarah",
                lastName: "Williams",
                email: "s.williams@matter.edu",
                department: .technical,
                permissions: ["review_students", "technical_support"]
            )
        ]
        
        // Sample Management
        management = [
            Management(
                username: "admin",
                password: "admin123",
                firstName: "Michael",
                lastName: "Brown",
                email: "m.brown@matter.edu"
            )
        ]
        
        // Sample Hiring Companies
        hiringCompanies = [
            HiringCompanyUser(
                company: .jamf,
                contactName: "Jamf HR",
                email: "hr@jamf.com",
                password: "jamf123",
                department: "Human Resources"
            ),
            HiringCompanyUser(
                company: .apple,
                contactName: "Apple Recruiting",
                email: "recruiting@apple.com",
                password: "apple123",
                department: "Recruiting"
            )
        ]
    }
}

