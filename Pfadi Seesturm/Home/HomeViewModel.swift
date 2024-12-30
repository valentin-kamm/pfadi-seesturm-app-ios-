//
//  HomeViewModel.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 17.10.2024.
//

import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    
    // network managers
    private let aktuellNetworkManager = AktuellNetworkManager.shared
    private let calendarNetworkManager = CalendarNetworkManager.shared
    private let weatherNetworkManager = WeatherNetworkManager.shared
    
    // loading states
    @Published var aktuellLoadingState: SeesturmLoadingState<TransformedAktuellPostResponse, PfadiSeesturmAppError> = .none
    @Published var termineLoadingState: SeesturmLoadingState<[TransformedCalendarEventResponse], PfadiSeesturmAppError> = .none
    @Published var weatherLoadingState: SeesturmLoadingState<TransformedWeatherResponse, PfadiSeesturmAppError> = .none
    @Published var naechsteAktivitaetLoadingStates: [SeesturmStufe : SeesturmLoadingState<TransformedCalendarEventResponse?, PfadiSeesturmAppError>] = [
        .biber: .none,
        .wolf: .none,
        .pfadi: .none,
        .pio: .none
    ]
        
    // selected stufen (save if changed)
    private var userDefaultsKeySelectedStufen = "selectedStufen_V2"
    @Published var selectedStufen: Set<SeesturmStufe> = [SeesturmStufe.biber, SeesturmStufe.wolf, SeesturmStufe.pfadi, SeesturmStufe.pio] {
        didSet {
            saveSelectedStufen()
            Task {
                await fetchNaechsteAktivitaeten(isPullToRefresh: false)
            }
        }
    }
    
    // initialize selected stufen
    init() {
        withAnimation {
            self.selectedStufen = getSelectedStufen()
        }
    }
    
    // function to fetch the desired data
    func fetchData(isPullToRefresh: Bool) async {
        
        var tasks: [() async -> Void] = []
        
        if aktuellLoadingState.taskShouldRun || isPullToRefresh {
            tasks.append {
                await self.fetchPost(isPullToRefresh: isPullToRefresh)
            }
        }
        if termineLoadingState.taskShouldRun || isPullToRefresh {
            tasks.append {
                await self.fetchNext3Events(isPullToRefresh: isPullToRefresh)
            }
        }
        if weatherLoadingState.taskShouldRun || isPullToRefresh {
            tasks.append {
                await self.fetchForecast(isPullToRefresh: isPullToRefresh)
            }
        }
        tasks.append {
            await self.fetchNaechsteAktivitaeten(isPullToRefresh: isPullToRefresh)
        }
        
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
        
    }
    
    // function that loads the next activity for multiple stufen
    private func fetchNaechsteAktivitaeten(isPullToRefresh: Bool) async {
        var tasks: [() async -> Void] = []
        for stufe in selectedStufen {
            if naechsteAktivitaetLoadingStates[stufe]?.taskShouldRun == true || isPullToRefresh {
                tasks.append {
                    await self.fetchNaechsteAktivitaet(for: stufe, isPullToRefresh: isPullToRefresh)
                }
            }
        }
        await withTaskGroup(of: Void.self) { group in
            for task in tasks {
                group.addTask {
                    await task()
                }
            }
        }
    }
    
    // function to load data for nächste aktivität of one stufe
    func fetchNaechsteAktivitaet(for stufe: SeesturmStufe, isPullToRefresh: Bool) async {
        
        withAnimation {
            self.naechsteAktivitaetLoadingStates[stufe] = isPullToRefresh ? naechsteAktivitaetLoadingStates[stufe] : .loading
        }
        
        do {
            let response = try await calendarNetworkManager.fetchEvents(calendarId: stufe.calendar.info.calendarId, includePast: false, maxResults: 1)
            let nextActivity = try response.items.first?.toTransformedEvent(calendarTimeZoneIdentifier: response.timeZone)
            withAnimation {
                self.naechsteAktivitaetLoadingStates[stufe] = .result(.success(nextActivity))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.naechsteAktivitaetLoadingStates[stufe] = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.naechsteAktivitaetLoadingStates[stufe] = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.naechsteAktivitaetLoadingStates[stufe] = .result(.failure(pfadiSeesturmError))
            }
        }
    }
    
    // fetch weather
    func fetchForecast(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.weatherLoadingState = isPullToRefresh ? weatherLoadingState : .loading
        }
        
        do {
            let forecast = try await weatherNetworkManager.fetchForecast()
            withAnimation {
                self.weatherLoadingState = .result(.success(forecast.toTransformedWeatherResponse()))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.weatherLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.weatherLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.weatherLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        
    }
    
    // function to fetch the latest post
    func fetchPost(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.aktuellLoadingState = isPullToRefresh ? aktuellLoadingState : .loading
        }
        
        do {
            let post = try await aktuellNetworkManager.fetchLatestPost()
            withAnimation {
                self.aktuellLoadingState = .result(.success(post.posts[0].toTransformedPost()))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.aktuellLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.aktuellLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.aktuellLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        
    }
    
    // function to fetch the next 3 events
    func fetchNext3Events(isPullToRefresh: Bool) async {
        
        withAnimation {
            self.termineLoadingState = isPullToRefresh ? termineLoadingState : .loading
        }
        
        do {
            let response = try await calendarNetworkManager.fetchEvents(calendarId: CalendarType.termine.info.calendarId, includePast: false, maxResults: 3)
            let transformedEvents = try response.items.compactMap { item in
                return try item.toTransformedEvent(calendarTimeZoneIdentifier: response.timeZone)
            }
            withAnimation {
                self.termineLoadingState = .result(.success(transformedEvents))
            }
        }
        catch let pfadiSeesturmError as PfadiSeesturmAppError {
            if case .cancellationError(_) = pfadiSeesturmError {
                withAnimation {
                    self.termineLoadingState = .errorWithReload(error: pfadiSeesturmError)
                }
            }
            else {
                withAnimation {
                    self.termineLoadingState = .result(.failure(pfadiSeesturmError))
                }
            }
        }
        catch {
            let pfadiSeesturmError = PfadiSeesturmAppError.unknownError(message: "Ein unbekannter Fehler ist aufgetreten: \(error.localizedDescription)")
            withAnimation {
                self.termineLoadingState = .result(.failure(pfadiSeesturmError))
            }
        }
        
    }
    
    // function to get the selected stufen
    private func getSelectedStufen() -> Set<SeesturmStufe> {
        let data = UserDefaults().data(forKey: userDefaultsKeySelectedStufen) ?? Data()
        guard !data.isEmpty else {
            return [SeesturmStufe.biber, SeesturmStufe.wolf, SeesturmStufe.pfadi, SeesturmStufe.pio]
        }
        let set = try? JSONDecoder().decode(Set<SeesturmStufe>.self, from: data)
        return set ?? [SeesturmStufe.biber, SeesturmStufe.wolf, SeesturmStufe.pfadi, SeesturmStufe.pio]
    }
    
    // function to save selected stufen to user defaults
    private func saveSelectedStufen() {
        let data = try? JSONEncoder().encode(selectedStufen)
        UserDefaults().set(data, forKey: userDefaultsKeySelectedStufen)
    }
    
}
