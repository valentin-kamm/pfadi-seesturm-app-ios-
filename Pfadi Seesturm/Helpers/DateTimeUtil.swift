//
//  DateTimeUtil.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 16.10.2024.
//

import SwiftUI

class DateTimeUtil {
    
    static let shared = DateTimeUtil()
    
    // function to get the start of the month of the provided date
    func getFirstDayOfMonthOfADate(date: Date) throws -> Date {
        let calendar = Calendar.current
        if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) {
            return startOfMonth
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Fehler bei der Datumsverarbeitung.")
        }
    }
    
    // function to parse a floating date string in the format yyyy-MM-dd
    func parseFloatingDateString(floatingDateString: String, timeZone: TimeZone) throws -> Date {
        let df = DateFormatter()
        df.timeZone = timeZone
        df.dateFormat = "yyyy-MM-dd"
        if let date = df.date(from: floatingDateString) {
            return date
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Datumsformat ungültig.")
        }
    }
    
    // functions to parse a ISO 8601 datetime string
    func parseISO8601DateWithTimeZone(iso8601DateString: String) throws -> Date {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone]
        if let date = df.date(from: iso8601DateString) {
            return date
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Datumsformat ungültig.")
        }
    }
    func parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: String) throws -> Date {
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withInternetDateTime, .withColonSeparatorInTimeZone, .withFractionalSeconds]
        if let date = df.date(from: iso8601DateString) {
            return date
        }
        else {
            throw PfadiSeesturmAppError.dateDecodingError(message: "Datumsformat ungültig.")
        }
    }
    
    // function to format a date range
    func formatDateRange(startDate: Date, endDate: Date, timeZone: TimeZone, withTime: Bool) -> String {
        let formatter = DateIntervalFormatter()
        formatter.locale = Locale(identifier: "de_CH")
        formatter.timeZone = timeZone
        formatter.dateStyle = .full
        formatter.timeStyle = withTime ? .short : .none
        return formatter.string(from: startDate, to: endDate)
    }
    
    // function to format a date into the desired string format
    // if a relative date format is desired and available, return it instead
    func formatDate(date: Date, format: String, withRelativeDateFormatting: Bool, includeTimeInRelativeFormatting: Bool? = nil, timeZone: TimeZone) -> String {
        
        // custom date formatter
        let customDf = DateFormatter()
        customDf.timeZone = timeZone
        customDf.locale = Locale(identifier: "de_CH")
        customDf.dateFormat = format
        
        // relative date formatter
        let relDf = DateFormatter()
        relDf.timeZone = timeZone
        relDf.locale = Locale(identifier: "de_CH")
        relDf.doesRelativeDateFormatting = true
        relDf.dateStyle = .long
        relDf.timeStyle = (includeTimeInRelativeFormatting ?? true ? .short : .none)
        
        // non-relative formatter with same style
        let nonRelDf = DateFormatter()
        nonRelDf.timeZone = timeZone
        nonRelDf.locale = Locale(identifier: "de_CH")
        nonRelDf.dateStyle = .long
        nonRelDf.timeStyle = (includeTimeInRelativeFormatting ?? true ? .short : .none)
        
        // get result from both formatters
        let rel = relDf.string(from: date)
        let nonRel = nonRelDf.string(from: date)
        
        // if no relative date formatting is desired
        if !withRelativeDateFormatting {
            return customDf.string(from: date)
        }
        // if the results are the same, it's not a relative date -> use custom date formatter
        else if rel == nonRel {
            return customDf.string(from: date)
        }
        // else, return relative date
        else {
            return rel + (includeTimeInRelativeFormatting ?? true ? " Uhr" : "")
        }
        
    }
    
}
