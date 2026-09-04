//
//  PersistenceManager.swift
//  SkillsTracker
//
//  Created by BONGANI    on 9/4/26.
//

import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    
    private let userDefaults = UserDefaults.standard
    
    // Keys
    private let studentsKey = "students"
    private let staffKey = "ProgramManager"
    private let managementKey = "Facilitator"
    private let hiringCompaniesKey = "Employers"
    private let managersKey = "ExternalViewers"
    private let employersKey = "employers"
    private let externalViewersKey = "externalViewers"
    
    private init() {}
    
    // MARK: - Save Methods
    func saveStudents(_ students: [Student]) {
        if let encoded = try? JSONEncoder().encode(students) {
            userDefaults.set(encoded, forKey: studentsKey)
        }
    }
    
    func saveStaff(_ staff: [Staff]) {
        if let encoded = try? JSONEncoder().encode(staff) {
            userDefaults.set(encoded, forKey: staffKey)
        }
    }
    
    func saveManagement(_ management: [Management]) {
        if let encoded = try? JSONEncoder().encode(management) {
            userDefaults.set(encoded, forKey: managementKey)
        }
    }
    
    func saveHiringCompanies(_ companies: [HiringCompanyUser]) {
        if let encoded = try? JSONEncoder().encode(companies) {
            userDefaults.set(encoded, forKey: hiringCompaniesKey)
        }
    }
    
    func saveManagers(_ managers: [Manager]) {
        if let encoded = try? JSONEncoder().encode(managers) {
            userDefaults.set(encoded, forKey: managersKey)
        }
    }
    
    func saveEmployers(_ employers: [Employer]) {
        if let encoded = try? JSONEncoder().encode(employers) {
            userDefaults.set(encoded, forKey: employersKey)
        }
    }
    
    func saveExternalViewers(_ viewers: [ExternalViewer]) {
        if let encoded = try? JSONEncoder().encode(viewers) {
            userDefaults.set(encoded, forKey: externalViewersKey)
        }
    }
    
    // MARK: - Load Methods
    func loadStudents() -> [Student] {
        guard let data = userDefaults.data(forKey: studentsKey),
              let decoded = try? JSONDecoder().decode([Student].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func loadStaff() -> [Staff] {
        guard let data = userDefaults.data(forKey: staffKey),
              let decoded = try? JSONDecoder().decode([Staff].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func loadManagement() -> [Management] {
        guard let data = userDefaults.data(forKey: managementKey),
              let decoded = try? JSONDecoder().decode([Management].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func loadHiringCompanies() -> [HiringCompanyUser] {
        guard let data = userDefaults.data(forKey: hiringCompaniesKey),
              let decoded = try? JSONDecoder().decode([HiringCompanyUser].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func loadManagers() -> [Manager] {
        guard let data = userDefaults.data(forKey: managersKey),
              let decoded = try? JSONDecoder().decode([Manager].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func loadEmployers() -> [Employer] {
        guard let data = userDefaults.data(forKey: employersKey),
              let decoded = try? JSONDecoder().decode([Employer].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func loadExternalViewers() -> [ExternalViewer] {
        guard let data = userDefaults.data(forKey: externalViewersKey),
              let decoded = try? JSONDecoder().decode([ExternalViewer].self, from: data) else {
            return []
        }
        return decoded
    }
    
    // MARK: - Clear Methods
    func clearAllData() {
        userDefaults.removeObject(forKey: studentsKey)
        userDefaults.removeObject(forKey: staffKey)
        userDefaults.removeObject(forKey: managementKey)
        userDefaults.removeObject(forKey: hiringCompaniesKey)
        userDefaults.removeObject(forKey: managersKey)
        userDefaults.removeObject(forKey: employersKey)
        userDefaults.removeObject(forKey: externalViewersKey)
    }
    
    // MARK: - Save All
    func saveAllData(students: [Student], staff: [Staff], management: [Management], hiringCompanies: [HiringCompanyUser], managers: [Manager], employers: [Employer], externalViewers: [ExternalViewer]) {
        saveStudents(students)
        saveStaff(staff)
        saveManagement(management)
        saveHiringCompanies(hiringCompanies)
        saveManagers(managers)
        saveEmployers(employers)
        saveExternalViewers(externalViewers)
    }
}
