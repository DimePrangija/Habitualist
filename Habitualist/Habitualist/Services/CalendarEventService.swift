import Foundation
import EventKit
import UIKit

@MainActor
class CalendarEventService {
    static let shared = CalendarEventService()
    
    private let eventStore = EKEventStore()
    
    private init() {}
    
    func requestAccessIfNeeded() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await eventStore.requestAccess(to: .event)
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
    
    func upsertDailySummaryEvent(date: Date, title: String, notes: String) async throws {
        guard await requestAccessIfNeeded() else {
            throw CalendarEventError.permissionDenied
        }
        
        let calendar = try await getOrCreateHabitualistCalendar()
        
        var calendarInstance = Calendar(identifier: .iso8601)
        calendarInstance.timeZone = TimeZone.current
        
        let startOfDay = calendarInstance.startOfDay(for: date)
        guard let startOfNextDay = calendarInstance.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw CalendarEventError.dateCalculationError
        }
        
        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: startOfNextDay, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate)
        
        if let existingEvent = existingEvents.first(where: { $0.title == "Habitualist Summary" && $0.calendar == calendar }) {
            existingEvent.notes = notes
            try eventStore.save(existingEvent, span: .thisEvent)
        } else {
            let event = EKEvent(eventStore: eventStore)
            event.calendar = calendar
            event.title = "Habitualist Summary"
            event.notes = notes
            event.isAllDay = true
            event.startDate = startOfDay
            event.endDate = startOfNextDay
            
            try eventStore.save(event, span: .thisEvent)
        }
    }
    
    private func getOrCreateHabitualistCalendar() async throws -> EKCalendar {
        let calendars = eventStore.calendars(for: .event)
        
        if let existingCalendar = calendars.first(where: { $0.title == "Habitualist" && $0.allowsContentModifications }) {
            return existingCalendar
        }
        
        guard let newCalendar = EKCalendar(for: .event, eventStore: eventStore) else {
            throw CalendarEventError.calendarCreationFailed
        }
        
        newCalendar.title = "Habitualist"
        newCalendar.cgColor = UIColor.purple.cgColor
        
        if let defaultCalendar = eventStore.defaultCalendarForNewEvents {
            newCalendar.source = defaultCalendar.source
        } else {
            guard let localSource = eventStore.sources.first(where: { $0.sourceType == .local }) else {
                throw CalendarEventError.calendarCreationFailed
            }
            newCalendar.source = localSource
        }
        
        try eventStore.saveCalendar(newCalendar, commit: true)
        
        guard let savedCalendar = eventStore.calendar(withIdentifier: newCalendar.calendarIdentifier) else {
            throw CalendarEventError.calendarCreationFailed
        }
        
        return savedCalendar
    }
}

enum CalendarEventError: LocalizedError {
    case permissionDenied
    case dateCalculationError
    case calendarCreationFailed
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Calendar access is required to save daily summaries. Please enable it in Settings."
        case .dateCalculationError:
            return "Unable to calculate date range for calendar event."
        case .calendarCreationFailed:
            return "Unable to create Habitualist calendar. Please check your calendar permissions."
        }
    }
}
