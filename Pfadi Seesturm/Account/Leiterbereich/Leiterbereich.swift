//
//  Leiterbereich.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 14.12.2024.
//

import SwiftUI

struct Leiterbereich: View {
    
    @EnvironmentObject var appState: AppState
    let user: FirebaseHitobitoUser
    @StateObject var viewModel: LeiterbereichViewModel
    
    init(user: FirebaseHitobitoUser) {
        self.user = user
        _viewModel = StateObject(wrappedValue: LeiterbereichViewModel(currentUser: user))
    }
    
    var body: some View {
        let welcomeImageSize: CGFloat = 60
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            List {
                VStack(alignment: .center, spacing: 0) {
                    ZStack {
                        Circle()
                            .fill(Color.customCardViewBackground)
                            .frame(width: welcomeImageSize, height: welcomeImageSize)
                            .shadow(color: Color.seesturmGreenCardViewShadowColor.opacity(0.3), radius: 5, x: 0, y: 0)
                        Image("SeesturmLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 0.9 * welcomeImageSize, height: 0.9 * welcomeImageSize)
                            .clipShape(Circle())
                            .padding(.vertical, 16)
                    }
                    Text("Willkommen, \(user.displayName)!")
                        .multilineTextAlignment(.center)
                        .font(.callout)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                    Text(user.email)
                        .multilineTextAlignment(.center)
                        .font(.caption)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .frame(maxWidth: .infinity, alignment: .center)
                //.padding()
                Section(header: ListSectionHeaderWithButton(
                    headerType: .blank,
                    sectionTitle: "Schöpflialarm",
                    iconName: "iphone.homebutton.radiowaves.left.and.right.circle.fill"
                )
                    .padding(0)
                ) {
                    SchöpflialarmCardView(viewModel: viewModel)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding()
                }
                Section(header: HStack(alignment: .center) {
                    Image(systemName: "person.2.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
                        .foregroundStyle(Color.SEESTURM_RED)
                    Spacer(minLength: 16)
                    Text("Stufen")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer(minLength: 16)
                    CustomStufenSelectMenuButton(selectedStufen: $viewModel.selectedStufen)
                }
                    .padding(.vertical, 8)
                ) {
                    ScrollView(.horizontal) {
                        HStack(alignment: .top, spacing: 16) {
                            ForEach(Array(viewModel.selectedStufen.sorted { $0.id < $1.id }.enumerated()), id: \.element.id) { index, stufe in
                                NavigationLink(value: stufe) {
                                    LeiterbereichStufeCardView(
                                        width: viewModel.selectedStufen.count == 1 ? screenWidth - 32 : (viewModel.selectedStufen.count == 2 ? (screenWidth - 48) / 2 : 0.85 * (screenWidth - 48) / 2),
                                        stufe: stufe,
                                        contentMode: viewModel.selectedStufen.count == 1 ? .expanded(navigateTo: { destination in
                                            appState.tabNavigationPaths[AppMainTab.leiterbereich.id].append(destination)
                                        }) : .simple
                                    )
                                    .foregroundStyle(Color.primary)
                                }
                                .padding(.leading, index == 0 ? 16 : 0)
                                .padding(.trailing, index == viewModel.selectedStufen.count - 1 ? 16 : 0)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                Section(header: ListSectionHeaderWithButton(
                    headerType: .button(
                        buttonTitle: "Alle",
                        buttonIconName: "chevron.right",
                        buttonAction: {
                            appState.tabNavigationPaths[AppMainTab.leiterbereich.id].append(LeiterbereichNavigationDestination.termineLeitungsteam)
                        }
                    ),
                    sectionTitle: "Termine",
                    iconName: "calendar.circle.fill"
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
                    case .result(.failure(let error)):
                        CardErrorView(
                            errorTitle: "Ein Fehler ist aufgetreten",
                            errorDescription: error.localizedDescription,
                            asyncRetryAction: {
                                await viewModel.fetchNext3LeiterbereichEvents(isPullToRefresh: false)
                            }
                        )
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.top)
                    case .result(.success(let events)):
                        if events.isEmpty {
                            Text("Keine bevorstehenden Anlässe")
                                .padding(.horizontal)
                                .padding(.vertical, 75)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(Color.secondary)
                        }
                        else {
                            ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                TermineCardView(event: event, isLeitungsteam: true)
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
                Section {
                    CustomButton(
                        buttonStyle: .primary,
                        buttonTitle: "Abmelden"
                    )
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .padding(.top, 16)
                }
            }
            .listStyle(PlainListStyle())
        }
        .background(Color.customBackground)
        .navigationTitle("Schöpfli")
        .navigationBarTitleDisplayMode(.large)
        .task {
            do {
                try await FCMManager.shared.requestOrCheckNotificationPermission()
            }
            catch {
                print("Notification permission not granted")
            }
        }
        .task {
            if viewModel.termineLoadingState.taskShouldRun {
                await viewModel.fetchNext3LeiterbereichEvents(isPullToRefresh: false)
            }
        }
        .navigationDestination(for: TransformedCalendarEventResponse.self) { event in
            TermineDetailView(
                event: event,
                calendarInfo: CalendarType.termineLeitungsteam.info,
                isLeitungsteam: true
            )
        }
        .navigationDestination(for: LeiterbereichNavigationDestination.self) { destination in
            switch destination {
            case .termineLeitungsteam:
                TermineView(type: .leiterbereich)
            }
        }
        .navigationDestination(for: SeesturmStufe.self, destination: { stufe in
            StufenbereichView(stufe: stufe)
        })
        .navigationDestination(for: StufenbereichNavigationDestination.self, destination: { destination in
            switch destination {
            case .abmeldungen(let stufe):
                StufenbereichView(stufe: stufe)
            case .neueAktivität(stufe: let stufe):
                AktivitaetBearbeitenView(stufe: stufe, contentMode: .new)
            }
        })
        .alert("Push-Nachrichten nicht aktiviert", isPresented: $viewModel.showNotificationsSettingsAlert) {
            Button("Einstellungen") {
                FCMManager.shared.goToNotificationSettings()
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Um diese Funktion nutzen zu können, musst du Push-Nachrichten in den Einstellungen aktivieren.")
        }
        .alert("Ortungsdienste nicht aktiviert", isPresented: $viewModel.showLocationSettingsAlert) {
            Button("Einstellungen") {
                FCMManager.shared.goToNotificationSettings()
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Um diese Funktion nutzen zu können, musst du die Ortungsdienste in den Einstellungen aktivieren.")
        }
        .alert("Genauer Standort nicht aktiviert", isPresented: $viewModel.showLocationAccuracySettingsAlert) {
            Button("Einstellungen") {
                FCMManager.shared.goToNotificationSettings()
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("Um diese Funktion nutzen zu können, wird dein genauer Standort benötigt.")
        }
        .confirmationDialog("Möchtest du den Schöpflialarm wirklich senden?", isPresented: $viewModel.showWirklichSendenAlert, titleVisibility: .visible, actions: {
            Button("Abbrechen", role: .cancel) {
                viewModel.wirklichSendenContinuation?.resume(throwing: PfadiSeesturmAppError.cancellationError(message: "Operation wurde durch den Benutzer abgebrochen."))
            }
            Button("Senden") {
                viewModel.wirklichSendenContinuation?.resume()
            }
        }, message: {
            Text("Der Schöpflialarm wird ohne Nachricht gesendet.")
        })
        .snackbar(
            show: viewModel.sendSchöpflialarmLoadingState.failureBinding(from: viewModel.$sendSchöpflialarmLoadingState, reset: {
                viewModel.sendSchöpflialarmLoadingState = .none
            }),
            type: .error,
            message: viewModel.sendSchöpflialarmLoadingState.errorMessage,
            dismissAutomatically: true,
            allowManualDismiss: true,
            onDismiss: {}
        )
        .snackbar(
            show: viewModel.sendSchöpflialarmLoadingState.successBinding(from: viewModel.$sendSchöpflialarmLoadingState, reset: {
                viewModel.sendSchöpflialarmLoadingState = .none
            }),
            type: .success,
            message: viewModel.sendSchöpflialarmLoadingState.successMessage,
            dismissAutomatically: true,
            allowManualDismiss: true,
            onDismiss: {}
        )
    }
}

enum LeiterbereichNavigationDestination: Hashable {
    case termineLeitungsteam
}

#Preview {
    Leiterbereich(
        user: FirebaseHitobitoUser(
            userId: 123,
            vorname: "Vorname",
            nachname: "Nachname",
            pfadiname: "Pfadiname",
            email: "xxx@yyy.ch"
        )
    )
}
