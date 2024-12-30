//
//  TermineContentView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 28.12.2024.
//

import SwiftUI

struct TermineContentView: View {
    
    var type: TermineViewInputType
    @StateObject private var viewModel: TermineViewModel
    
    init(type: TermineViewInputType) {
        self.type = type
        _viewModel = StateObject(wrappedValue: TermineViewModel(type: type))
    }
    
    var body: some View {
        ScrollView {
            switch viewModel.initialEventsLoadingState {
            case .loading, .none, .errorWithReload(_):
                LazyVStack(spacing: 0) {
                    Section(header:
                                BasicStickyHeader(title: "August")
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    ) {
                        ForEach(0..<2) { index in
                            TermineLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                        }
                    }
                    Section(header:
                                BasicStickyHeader(title: "September")
                        .redacted(reason: .placeholder)
                        .customLoadingBlinking()
                    ) {
                        ForEach(0..<5) { index in
                            TermineLoadingCardView()
                                .padding(.top, index == 0 ? 16 : 0)
                        }
                    }
                }
            case .result(.failure(let error)):
                CardErrorView(
                    errorTitle: "Ein Fehler ist aufgetreten",
                    errorDescription: error.localizedDescription,
                    asyncRetryAction: {
                        await viewModel.loadInitialSetOfEvents(isPullToRefresh: false)
                    }
                )
                .padding(.vertical)
            case .result(.success(_)):
                if viewModel.events.isEmpty {
                    Text("Keine bevorstehenden Anlässe")
                        .padding(.horizontal)
                        .padding(.vertical, 75)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundStyle(Color.secondary)
                }
                else {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(Array(viewModel.groupedEvents().enumerated()), id: \.element.start) { index, section in
                            let title = DateTimeUtil.shared.formatDate(date: section.start, format: "MMMM yyyy", withRelativeDateFormatting: false, timeZone: .current)
                            Section {
                                ForEach(Array(section.events.enumerated()), id: \.element.id) { index, event in
                                    NavigationLink(value: event) {
                                        TermineCardView(
                                            event: event,
                                            isLeitungsteam: type == .leiterbereich
                                        )
                                            .padding(.top, index == 0 ? 16 : 0)
                                    }
                                    .foregroundStyle(Color.primary)
                                }
                            } header: {
                                BasicStickyHeader(title: title)
                                    .background(Color.customBackground)
                            }
                        }
                        if let nextPage = viewModel.nextPageToken {
                            switch viewModel.moreEventsLoadingState {
                            case .result(.failure(let error)):
                                CardErrorView(
                                    errorTitle: "Es konnten keine weiteren Termine geladen werden",
                                    errorDescription: error.localizedDescription,
                                    asyncRetryAction: {
                                        await viewModel.loadMoreEvents(pageToken: nextPage)
                                    }
                                )
                                .padding(.bottom)
                            default:
                                TermineLoadingCardView()
                                    .onAppear {
                                        if viewModel.moreEventsLoadingState.infiniteScrollTaskShouldRun {
                                            Task {
                                                await viewModel.loadMoreEvents(pageToken: nextPage)
                                            }
                                        }
                                    }
                            }
                        }
                        Text("Stand Kalender: \(viewModel.calendarLastUpdated)\n(Alle gezeigten Zeiten in MEZ/MESZ)")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundStyle(Color.secondary)
                            .padding()
                            .padding(.bottom)
                    }
                }
            }
        }
        .background(Color.customBackground)
        .scrollDisabled(viewModel.initialEventsLoadingState.scrollingDisabled)
        .navigationTitle(type == .leiterbereich ? "Termine Leitungsteam" : "Anlässe")
        .navigationBarTitleDisplayMode(.large)
        // kalendar abonnieren link
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    UIApplication.shared.open(type == .leiterbereich ? CalendarType.termineLeitungsteam.info.subscriptionURL : CalendarType.termine.info.subscriptionURL)
                }) {
                    Image(systemName: "calendar.badge.plus")
                }
                .foregroundStyle(type == .leiterbereich ? Color.SEESTURM_RED : Color.SEESTURM_GREEN)
            }
        }
        .task {
            if viewModel.initialEventsLoadingState.taskShouldRun {
                await viewModel.loadInitialSetOfEvents(isPullToRefresh: false)
            }
        }
        .refreshable {
            await Task {
                await viewModel.loadInitialSetOfEvents(isPullToRefresh: true)
            }.value
        }
        .navigationDestination(for: TransformedCalendarEventResponse.self) { event in
            TermineDetailView(
                event: event,
                calendarInfo: type == .leiterbereich ? CalendarType.termineLeitungsteam.info : CalendarType.termine.info,
                isLeitungsteam: type == .leiterbereich
            )
        }
    }
}

#Preview {
    TermineContentView(type: .mainTab)
}
