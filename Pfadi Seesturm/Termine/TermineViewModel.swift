//
//  TermineViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.11.2024.
//

import SwiftUI

@MainActor
class TermineViewModel: ObservableObject {
    
    private let calendarNetworkManager = CalendarNetworkManager.shared
    
    @Published var events: [TransformedCalendarEventResponse] = []
    @Published var calendarLastUpdated: String = ""
    @Published var nextPageToken: String? = nil
    private let numberOfEventsPerPage: Int = 10
    
    @Published var initialEventsLoadingState: SeesturmLoadingState = .none
    @Published var moreEventsLoadingState: SeesturmLoadingState = .none
    
    // function to fetch the initial set of posts
    func loadInitialSetOfEvents(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.initialEventsLoadingState = isPullToRefresh ? initialEventsLoadingState : .loading
        }
        
        do {
            let response = try await calendarNetworkManager.fetchEvents(calendarId: CalendarType.termine.info.calendarId, includePast: false, maxResults: numberOfEventsPerPage)
            let transformedEvents = try response.items.compactMap { item in
                return try item.toTransformedEvent(calendarTimeZoneIdentifier: response.timeZone)
            }
            let calendarLastUpdatedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: response.updated)
            let calendarLastUpdatedDateString = DateTimeUtil.shared.formatDate(date: calendarLastUpdatedDate, format: "dd. MMMM yyyy", withRelativeDateFormatting: true, timeZone: .current)
            withAnimation {
                self.nextPageToken = response.nextPageToken
                self.events = transformedEvents
                self.calendarLastUpdated = calendarLastUpdatedDateString
                self.initialEventsLoadingState = .success
            }
            
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.initialEventsLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.initialEventsLoadingState = .error(error: pfadiSeesturmError)
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.initialEventsLoadingState = .error(error: pfadiSeesturmError)
            }
        }
        
    }
    
    // function to fetch more posts
    func loadMoreEvents(pageToken: String) async {
        
        withAnimation {
            self.moreEventsLoadingState = .loading
        }
        
        do {
            let moreLoadedEvents = try await calendarNetworkManager.fetchEvents(by: pageToken, calendarId: CalendarType.termine.info.calendarId, maxResults: numberOfEventsPerPage)
            let transformedEvents = try moreLoadedEvents.items.compactMap { item in
                return try item.toTransformedEvent(calendarTimeZoneIdentifier: moreLoadedEvents.timeZone)
            }
            let calendarLastUpdatedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: moreLoadedEvents.updated)
            let calendarLastUpdatedDateString = DateTimeUtil.shared.formatDate(date: calendarLastUpdatedDate, format: "dd. MMMM yyyy", withRelativeDateFormatting: true, timeZone: .current)
            withAnimation {
                self.nextPageToken = moreLoadedEvents.nextPageToken
                self.events.append(contentsOf: transformedEvents)
                self.calendarLastUpdated = calendarLastUpdatedDateString
                self.moreEventsLoadingState = .success
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.moreEventsLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.moreEventsLoadingState = .error(error: pfadiSeesturmError)
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.moreEventsLoadingState = .error(error: pfadiSeesturmError)
            }
        }
        
    }
    
    // function to get the events grouped by start year and month
    func groupedEvents() -> [(start: Date, events: [TransformedCalendarEventResponse])] {
        let groupedDictionary = Dictionary(grouping: events, by: { $0.monthStartDate })
        return groupedDictionary
            .sorted { $0.key < $1.key }
            .map { (start: $0.key, events: $0.value) }
    }
    
}
