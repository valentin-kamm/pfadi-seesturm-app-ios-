//
//  HomeView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var appState: AppState
            
    var body: some View {
        NavigationStack(path: $appState.tabNavigationPaths[AppMainTab.home.id]) {
            GeometryReader { geometry in
                List {
                    // nächste aktivität
                    Section(header:
                                HStack(alignment: .center) {
                        Image(systemName: "person.2.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 45, height: 45)
                            .foregroundStyle(Color.SEESTURM_RED)
                        Spacer(minLength: 16)
                        Text("Nächste Aktivität")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer(minLength: 16)
                        CustomStufenSelectMenuButton(selectedStufen: $viewModel.selectedStufen)
                    }
                        .padding(.vertical, 8)
                            
                    ) {
                        
                        if viewModel.selectedStufen.count < 1 {
                            Text("Wähle eine Stufe aus, um die Angaben zur nächsten Aktivität anzuschauen")
                                .padding(.horizontal)
                                .padding(.vertical, 75)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .multilineTextAlignment(.center)
                        }
                        else {
                            ScrollView(.horizontal) {
                                HStack(alignment: .top, spacing: 16) {
                                    ForEach(Array(viewModel.selectedStufen.sorted { $0.id < $1.id }.enumerated()), id: \.element.id) { index, stufe in
                                        
                                        if let result = viewModel.naechsteAktivitaetLoadingStates[stufe] {
                                            switch result {
                                            case .loading, .none, .errorWithReload(_):
                                                AktivitaetHomeLoadingView(
                                                    width: (viewModel.selectedStufen.count == 1 ? geometry.size.width - 32 : 0.85 * geometry.size.width)
                                                )
                                                .padding(.leading, index == 0 ? 16 : 0)
                                                .padding(.trailing, index == viewModel.selectedStufen.count - 1 ? 16 : 0)
                                            case .error(let error):
                                                CardErrorView(
                                                    errorTitle: "Ein Fehler ist aufgetreten",
                                                    errorDescription: error.localizedDescription,
                                                    asyncRetryAction: {
                                                        await viewModel.fetchNaechsteAktivitaet(for: stufe, isPullToRefresh: false)
                                                    })
                                                .padding(.horizontal, -16)
                                                .frame(width: (viewModel.selectedStufen.count == 1 ? geometry.size.width - 32 : 0.85 * geometry.size.width))
                                                .padding(.vertical)
                                                .padding(.leading, index == 0 ? 16 : 0)
                                                .padding(.trailing, index == viewModel.selectedStufen.count - 1 ? 16 : 0)
                                            case .success(let aktivitaet):
                                                NavigationLink(
                                                    value: AktivitaetDetailNavigationData(
                                                        stufe: stufe,
                                                        aktivitaet: .object(aktivitaet)
                                                    )
                                                ) {
                                                    AktivitaetHomeCardView(
                                                        width: (viewModel.selectedStufen.count == 1 ? geometry.size.width - 32 : 0.85 * geometry.size.width),
                                                        stufe: stufe,
                                                        aktivitaet: aktivitaet
                                                    )
                                                }
                                                .padding(.leading, index == 0 ? 16 : 0)
                                                .padding(.trailing, index == viewModel.selectedStufen.count - 1 ? 16 : 0)
                                                .foregroundStyle(Color.primary)
                                            }
                                        }
                                        else {
                                            CardErrorView(
                                                errorTitle: "Ein Fehler ist aufgetreten",
                                                errorDescription: "Unbekannter Fehler",
                                                asyncRetryAction: {
                                                await viewModel.fetchNaechsteAktivitaet(for: stufe, isPullToRefresh: false)
                                            })
                                            .padding(.horizontal, -16)
                                            .frame(width: (viewModel.selectedStufen.count == 1 ? geometry.size.width - 32 : 0.85 * geometry.size.width))
                                            .padding(.vertical)
                                            .padding(.leading, index == 0 ? 16 : 0)
                                            .padding(.trailing, index == viewModel.selectedStufen.count - 1 ? 16 : 0)
                                        }
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                        
                    }
                    // Aktuell
                    Section(header: ListSectionHeaderWithButton(
                        iconName: "newspaper.circle.fill",
                        sectionTitle: "Aktuell",
                        showButton: true,
                        buttonTitle: "Mehr",
                        buttonIconName: "chevron.right",
                        buttonAction: {appState.selectedTab = .aktuell}
                    )
                        .padding(0)
                    ) {
                        switch viewModel.aktuellLoadingState {
                        case .loading, .none, .errorWithReload(_):
                            AktuellSkeletonCardView()
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .padding(.top)
                        case .error(let error):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: error.localizedDescription,
                                asyncRetryAction: {
                                    await viewModel.fetchPost(isPullToRefresh: false)
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                        case .success:
                            AktuellCardView(
                                post: viewModel.aktuellPost,
                                width: geometry.size.width
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                            .background(
                                NavigationLink(value: AktuellDetailViewInputType.object(viewModel.aktuellPost)) {
                                    EmptyView()
                                }
                                    .opacity(0)
                            )
                        }
                    }
                    
                    // Anlässe
                    Section(header: ListSectionHeaderWithButton(
                        iconName: "calendar.circle.fill",
                        sectionTitle: "Anlässe",
                        showButton: true,
                        buttonTitle: "Mehr",
                        buttonIconName: "chevron.right",
                        buttonAction: {appState.selectedTab = .anlässe}
                    )
                        .padding(0)
                    ) {
                        switch viewModel.termineLoadingState {
                        case .loading, .none, .errorWithReload(_):
                            ForEach(0..<3) { index in
                                TermineLoadingCardView()
                                    .padding(.top, index == 0 ? 16 : 0)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                            }
                        case .error(let error):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: error.localizedDescription,
                                asyncRetryAction: {
                                    await viewModel.fetchNext3Events(isPullToRefresh: false)
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.top)
                        case .success:
                            if viewModel.events.isEmpty {
                                Text("Keine bevorstehenden Anlässe")
                                    .padding(.horizontal)
                                    .padding(.vertical, 75)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets())
                                    .listRowBackground(Color.clear)
                                    .multilineTextAlignment(.center)
                            }
                            else {
                                ForEach(Array(viewModel.events.enumerated()), id: \.element.id) { index, event in
                                    TermineCardView(event: event)
                                        .padding(.top, index == 0 ? 16 : 0)
                                        .listRowSeparator(.hidden)
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.clear)
                                        .background(
                                            NavigationLink(value: event, label: {
                                                EmptyView()
                                            })
                                            .opacity(0)
                                        )
                                }
                            }
                        }
                    }
                    
                    // Wetter
                    Section(header: ListSectionHeaderWithButton(
                        iconName: "sun.max.circle.fill",
                        sectionTitle: "Wetter",
                        showButton: false
                    )
                        .padding(0)
                    ) {
                        switch viewModel.weatherLoadingState {
                        case .loading, .none, .errorWithReload(_):
                            WeatherLoadingView()
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        case .error(let error):
                            CardErrorView(
                                errorTitle: "Ein Fehler ist aufgetreten",
                                errorDescription: error.localizedDescription,
                                asyncRetryAction: {
                                    await viewModel.fetchForecast(isPullToRefresh: false)
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .padding(.vertical)
                        case .success:
                            WeatherCardView(weather: viewModel.weather)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.customBackground)
                .task {
                    await viewModel.fetchData(isPullToRefresh: false)
                }
                .refreshable {
                    await viewModel.fetchData(isPullToRefresh: true)
                }
                .navigationTitle("Pfadi Seesturm")
                .navigationBarTitleDisplayMode(.large)
                .navigationDestination(for: AktivitaetDetailNavigationData.self) { destination in
                    AktivitaetDetailView(stufe: destination.stufe, input: destination.aktivitaet)
                }
                .navigationDestination(for: AktuellDetailViewInputType.self) { input in
                    AktuellDetailView(input: input)
                }
                .navigationDestination(for: TransformedCalendarEventResponse.self) { event in
                    TermineDetailView(event: event, calendarInfo: CalendarType.termine.info)
                }
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

struct AktivitaetDetailNavigationData: Hashable {
    let stufe: SeesturmStufe
    let aktivitaet: AktivitaetDetailViewInputType
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}
