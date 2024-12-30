//
//  TermineViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 06.11.2024.
//

import SwiftUI

@MainActor
class TermineViewModel: ObservableObject {
    
    var type: TermineViewInputType
    
    private let calendarNetworkManager = CalendarNetworkManager.shared
    
    @Published var events: [TransformedCalendarEventResponse]
    @Published var calendarLastUpdated: String
    @Published var nextPageToken: String?
    private let numberOfEventsPerPage: Int = 10
    
    @Published var initialEventsLoadingState: SeesturmLoadingState<Void, PfadiSeesturmAppError>
    @Published var moreEventsLoadingState: SeesturmLoadingState<Void, PfadiSeesturmAppError>
    
    init(
        type: TermineViewInputType,
        events: [TransformedCalendarEventResponse] = [],
        calendarLastUpdated: String = "",
        nextPageToken: String? = nil,
        initialEventsLoadingState: SeesturmLoadingState<Void, PfadiSeesturmAppError> = .none,
        moreEventsLoadingState: SeesturmLoadingState<Void, PfadiSeesturmAppError> = .none
    ) {
        self.type = type
        self.events = events
        self.calendarLastUpdated = calendarLastUpdated
        self.nextPageToken = nextPageToken
        self.initialEventsLoadingState = initialEventsLoadingState
        self.moreEventsLoadingState = moreEventsLoadingState
    }
    
    private var calendarId: String {
        switch type {
        case .mainTab:
            return CalendarType.termine.info.calendarId
        case .leiterbereich:
            return CalendarType.termineLeitungsteam.info.calendarId
        }
    }
    
    // function to fetch the initial set of posts
    func loadInitialSetOfEvents(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.initialEventsLoadingState = isPullToRefresh ? initialEventsLoadingState : .loading
        }
        
        do {
            let response = try await calendarNetworkManager.fetchEvents(calendarId: calendarId, includePast: false, maxResults: numberOfEventsPerPage)
            let transformedEvents = try response.items.compactMap { item in
                return try item.toTransformedEvent(calendarTimeZoneIdentifier: response.timeZone)
            }
            let calendarLastUpdatedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: response.updated)
            let calendarLastUpdatedDateString = DateTimeUtil.shared.formatDate(date: calendarLastUpdatedDate, format: "dd. MMMM yyyy", withRelativeDateFormatting: true, timeZone: .current)
            withAnimation {
                self.nextPageToken = response.nextPageToken
                self.events = transformedEvents
                self.calendarLastUpdated = calendarLastUpdatedDateString
                self.initialEventsLoadingState = .result(.success(()))
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
                    self.initialEventsLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.initialEventsLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        
    }
    
    // function to fetch more posts
    func loadMoreEvents(pageToken: String) async {
        
        withAnimation {
            self.moreEventsLoadingState = .loading
        }
        
        do {
            let moreLoadedEvents = try await calendarNetworkManager.fetchEvents(by: pageToken, calendarId: calendarId, maxResults: numberOfEventsPerPage)
            let transformedEvents = try moreLoadedEvents.items.compactMap { item in
                return try item.toTransformedEvent(calendarTimeZoneIdentifier: moreLoadedEvents.timeZone)
            }
            let calendarLastUpdatedDate = try DateTimeUtil.shared.parseISO8601DateWithTimeZoneAndFractionalSeconds(iso8601DateString: moreLoadedEvents.updated)
            let calendarLastUpdatedDateString = DateTimeUtil.shared.formatDate(date: calendarLastUpdatedDate, format: "dd. MMMM yyyy", withRelativeDateFormatting: true, timeZone: .current)
            withAnimation {
                self.nextPageToken = moreLoadedEvents.nextPageToken
                self.events.append(contentsOf: transformedEvents)
                self.calendarLastUpdated = calendarLastUpdatedDateString
                self.moreEventsLoadingState = .result(.success(()))
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
                    self.moreEventsLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.moreEventsLoadingState = .result(.failure(pfadiSeesturmError))
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
