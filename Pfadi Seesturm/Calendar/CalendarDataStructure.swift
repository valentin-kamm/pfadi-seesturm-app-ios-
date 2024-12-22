//
//  CalendarDataStructure.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.11.2024.
//

import SwiftUI

// struct that is used to store information about each calendar
struct CalendarInfo {
    let calendarId: String
    let subscriptionURL: URL
}

// response when fetching events
struct CalendarResponse: Codable {
    var updated: String
    var timeZone: String
    var nextPageToken: String?
    var items: [CalendarEventResponse]
    
    init(
        updated: String = "",
        timeZone: String = "",
        nextPageToken: String? = nil,
        items: [CalendarEventResponse] = []
    ) {
        self.updated = updated
        self.timeZone = timeZone
        self.nextPageToken = nextPageToken
        self.items = items
    }
}
struct CalendarEventResponse: Identifiable, Codable {
    
    var id: String
    var summary: String?
    var description: String?
    var location: String?
    var created: String
    var updated: String
    var start: CalendarEventStartEndResponse
    var end: CalendarEventStartEndResponse
    
    init(
        id: String = "",
        summary: String? = "",
        description: String? = "",
        location: String? = "",
        created: String = "",
        updated: String = "",
        start: CalendarEventStartEndResponse = CalendarEventStartEndResponse(),
        end: CalendarEventStartEndResponse = CalendarEventStartEndResponse()
    ) {
        self.id = id
        self.summary = summary
        self.description = description
        self.location = location
        self.created = created
        self.updated = updated
        self.start = start
        self.end = end
    }
    
}
struct CalendarEventStartEndResponse: Codable {
    var dateTime: String?
    var date: String?
    
    init(
        dateTime: String? = "",
        date: String? = ""
    ) {
        self.dateTime = dateTime
        self.date = date
    }
}
struct TransformedCalendarEventResponse: Identifiable, Hashable {
    var id: String
    var title: String
    var description: String?
    var location: String?
    var created: String
    var updated: String
    var showUpdated: Bool
    var monthStartDate: Date
    var startDay: String
    var startMonth: String
    var endDate: String?
    var time: String
    var fullDateTimeString: String
    
    init(
        id: String = "",
        title: String = "",
        description: String? = nil,
        location: String? = nil,
        created: String = "",
        updated: String = "",
        showUpdated: Bool = false,
        monthStartDate: Date = Date(),
        startDay: String = "",
        startMonth: String = "",
        endDate: String? = nil,
        time: String = "",
        fullDateTimeString: String = ""
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.location = location
        self.created = created
        self.updated = updated
        self.showUpdated = showUpdated
        self.monthStartDate = monthStartDate
        self.startDay = startDay
        self.startMonth = startMonth
        self.endDate = endDate
        self.time = time
        self.fullDateTimeString = fullDateTimeString
    }
    
}

// functions to convert raw event to transformed event that can be displayed
extension CalendarEventResponse {
    
    // function to transform the raw response
    func toTransformedEvent(calendarTimeZoneIdentifier: String) throws -> TransformedCalendarEventResponse {
        
        if let calendarTimeZone = TimeZone(identifier: calendarTimeZoneIdentifier) {
            return TransformedCalendarEventResponse(
                id: id,
                title: summary ?? "Unbenannter Anlass",
                description: description,
                location: location,
                created: DateTimeUtil.shared.formatDate(date: try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: created), format: "d. MMMM, HH:mm 'Uhr'", withRelativeDateFormatting: true, timeZone: .current),
                updated: DateTimeUtil.shared.formatDate(date: try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: updated), format: "d. MMMM, HH:mm 'Uhr'", withRelativeDateFormatting: true, timeZone: .current),
                showUpdated: getCreatedUpdatedDifference(calendarTimeZone: calendarTimeZone),
                monthStartDate: try getFirstDayOfMonthFromEventStart(calendarTimeZone: calendarTimeZone),
                startDay: try getEventStartDayString(calendarTimeZone: calendarTimeZone),
                startMonth: try getEventStartMonthString(calendarTimeZone: calendarTimeZone),
                endDate: try getEndDateString(calendarTimeZone: calendarTimeZone),
                time: try getTimeString(calendarTimeZone: calendarTimeZone),
                fullDateTimeString: try getFullDateTimeString(calendarTimeZone: calendarTimeZone)
            )
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Unbekannte Zeitzone.")
        }
        
    }
    
    // function to calculate date difference between created and updated date
    private func getCreatedUpdatedDifference(calendarTimeZone: TimeZone) -> Bool {
        do {
            let createdDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: created)
            let updatedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: updated)
            let components = Calendar.current.dateComponents([.minute], from: createdDate, to: updatedDate)
            if let minutes = components.minute {
                return abs(minutes) > 1
            }
            else {
                return false
            }
        }
        catch {
            return false
        }
    }
    
    // function to get the full dateTime string for the detail view
    private func getFullDateTimeString(calendarTimeZone: TimeZone) throws -> String {
        let startDate = try getStartDate(calendarTimeZone: calendarTimeZone)
        let endDate = try getEndDate(calendarTimeZone: calendarTimeZone)
        let calendar = Calendar.current
        // all day events
        if let correctedEndDate = calendar.date(byAdding: .day, value: -1, to: endDate), isAllDay() {
            return "\(DateTimeUtil.shared.formatDateRange(startDate: startDate, endDate: correctedEndDate, timeZone: calendarTimeZone, withTime: false)), ganztägig"
        }
        // normal events: do it using dateintervalformatter
        else {
            return DateTimeUtil.shared.formatDateRange(startDate: startDate, endDate: endDate, timeZone: calendarTimeZone, withTime: true)
        }
    }
    
    // function to get time of event
    private func getTimeString(calendarTimeZone: TimeZone) throws -> String {
        if isAllDay() {
            return "Ganztägig"
        }
        else {
            let startDate = try getStartDate(calendarTimeZone: calendarTimeZone)
            let endDate = try getEndDate(calendarTimeZone: calendarTimeZone)
            let startTimeString = DateTimeUtil.shared.formatDate(date: startDate, format: "HH:mm", withRelativeDateFormatting: false, timeZone: calendarTimeZone)
            let endTimeString = DateTimeUtil.shared.formatDate(date: endDate, format: "HH:mm", withRelativeDateFormatting: false, timeZone: calendarTimeZone)
            return "\(startTimeString) bis \(endTimeString) Uhr"
        }
    }
    
    // function to get the end date of an event
    private func getEndDateString(calendarTimeZone: TimeZone) throws -> String? {
        let startDate = try getStartDate(calendarTimeZone: calendarTimeZone)
        let endDate = try getEndDate(calendarTimeZone: calendarTimeZone)
        let calendar = Calendar.current
        if let correctedEndDate = calendar.date(byAdding: .day, value: -1, to: endDate) {
            let endDateToUse: Date = isAllDay() ? correctedEndDate : endDate
            if calendar.isDate(startDate, inSameDayAs: endDateToUse) {
                return nil
            }
            else {
                return "bis \(DateTimeUtil.shared.formatDate(date: endDateToUse, format: "dd. MMM", withRelativeDateFormatting: false, timeZone: calendarTimeZone))"
            }
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Enddatum eines Anlasses konnte nicht ermittelt werden.")
        }
    }
    
    // function to get the start month of an event
    private func getEventStartMonthString(calendarTimeZone: TimeZone) throws -> String {
        let startDate = try getStartDate(calendarTimeZone: calendarTimeZone)
        return DateTimeUtil.shared.formatDate(date: startDate, format: "MMM", withRelativeDateFormatting: false, timeZone: calendarTimeZone)
    }
    
    // function to get the start day of an event
    private func getEventStartDayString(calendarTimeZone: TimeZone) throws -> String {
        let startDate = try getStartDate(calendarTimeZone: calendarTimeZone)
        return DateTimeUtil.shared.formatDate(date: startDate, format: "dd.", withRelativeDateFormatting: false, timeZone: calendarTimeZone)
    }
    
    // function to check whether an even is all day
    private func isAllDay() -> Bool {
        return start.dateTime == nil
    }
    
    // function to get the date of the first day of the month when an event starts
    private func getFirstDayOfMonthFromEventStart(calendarTimeZone: TimeZone) throws -> Date {
        let startDate = try getStartDate(calendarTimeZone: calendarTimeZone)
        return try DateTimeUtil.shared.getFirstDayOfMonthOfADate(date: startDate)
    }
    
    // function to get end date of an event
    private func getEndDate(calendarTimeZone: TimeZone) throws -> Date {
        if let endDateTimeString = end.dateTime {
            return try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: endDateTimeString)
        }
        else if let endDateString = end.date {
            return try DateTimeUtil.shared.parseFloatingDateString(floatingDateString: endDateString, timeZone: calendarTimeZone)
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Anlass ohne Enddatum vorhanden.")
        }
    }
    
    // function to get start date of an event
    private func getStartDate(calendarTimeZone: TimeZone) throws -> Date {
        if let startDateTimeString = start.dateTime {
            return try DateTimeUtil.shared.parseISO8601DateWithTimeZone(iso8601DateString: startDateTimeString)
        }
        else if let startDateString = start.date {
            return try DateTimeUtil.shared.parseFloatingDateString(floatingDateString: startDateString, timeZone: calendarTimeZone)
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Anlass ohne Startdatum vorhanden.")
        }
    }
    
}
