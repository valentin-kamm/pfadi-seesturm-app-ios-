//
//  MehrView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 08.10.2024.
//

import SwiftUI

struct MehrView: View {
    
    var footerText = """
        Pfadi Seesturm \(String(Calendar.current.component(.year, from: Date())))
        app@seesturm\u{200B}.ch
        
        \((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String != nil && Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String != nil) ? ("App-Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String) (\(Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String)) \(Constants.IS_DEBUG ? "(Debug)" : "")") : "")
        """
    
    @EnvironmentObject var appState: AppState
    @StateObject var pfadijahreViewModel = PfadijahreViewModel()
    
    // url's
    var belegungsplanUrl = URL(string: "https://api.belegungskalender-kostenlos.de/kalender.php?kid=24446")!
    var pfadiheimInfoUrl = URL(string: "https://seesturm.ch/pfadiheim/")!
    var pfadiheimMailUrl = URL(string: "mailto:pfadiheim@seesturm.ch")!
    
    // Auswahlmöglichkeiten für dark / light mode
    @AppStorage("theme") var selectedTheme: String = "system"
    
    var body: some View {
        NavigationStack(path: $appState.tabNavigationPaths[AppMainTab.mehr.id]) {
            Form {
                Section(header: Text("Infos und Medien")) {
                    NavigationLink(value: MehrNavigationDestination.fotos(forceImageLoading: false)) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Fotos")
                        }
                    }
                    // show a preview of the photos if no error occurs
                    .listRowSeparator(pfadijahreViewModel.loadingState.isError ? .hidden : .automatic)
                    MehrHorizontalPhotoScrollView(viewModel: pfadijahreViewModel)
                    
                    NavigationLink(value: MehrNavigationDestination.dokumente) {
                        HStack {
                            Image(systemName: "doc.text")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Dokumente")
                        }
                    }
                    NavigationLink(value: MehrNavigationDestination.lüüchtturm) {
                        HStack {
                            Image(systemName: "magazine")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Lüüchtturm")
                        }
                    }
                    NavigationLink(value: MehrNavigationDestination.leitungsteam(stufe: "Abteilungsleitung")) {
                        HStack {
                            Image(systemName: "person.crop.square.filled.and.at.rectangle")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Leitungsteam")
                        }
                    }
                }
                Section(header: Text("Pfadiheim")) {
                    Link(destination: belegungsplanUrl) {
                        HStack {
                            Image(systemName: "calendar")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Belegungsplan")
                        }
                    }
                    Link(destination: pfadiheimInfoUrl) {
                        HStack {
                            Image(systemName: "info.square")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Weitere Informationen")
                        }
                    }
                    Link(destination: pfadiheimMailUrl) {
                        HStack {
                            Image(systemName: "ellipsis.message")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Anfrage und Reservation")
                        }
                    }
                }
                Section(header: Text("Einstellungen")) {
                    NavigationLink(value: MehrNavigationDestination.pushNotifications) {
                        HStack {
                            Image(systemName: "bell.badge")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Push-Nachrichten")
                        }
                    }
                    NavigationLink(value: MehrNavigationDestination.gespeichertePersonen) {
                        HStack {
                            Image(systemName: "person.2")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Gespeicherte Personen")
                        }
                    }
                    // there is a bug with preferredColorScheme in iOS 18.0
                    // -> Do not include this feature when running this version
                    if !(ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 18 && ProcessInfo.processInfo.operatingSystemVersion.minorVersion == 0) {
                        HStack {
                            Image(systemName: "circle.lefthalf.filled")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Picker("Erscheinungsbild", selection: $selectedTheme) {
                                Text("Hell")
                                    .tag("hell")
                                Text("Dunkel")
                                    .tag("dunkel")
                                Text("System")
                                    .tag("system")
                            }
                            .pickerStyle(.menu)
                            .tint(Color.SEESTURM_GREEN)
                        }
                    }
                }
                Section {
                    Link(destination: URL(string: Constants.FEEDBACK_FORM_URL)!) {
                        HStack {
                            Image(systemName: "text.bubble")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Feedback zur App geben")
                        }
                    }
                    Link(destination: URL(string: Constants.DATENSCHUTZERKLAERUNG_URL)!) {
                        HStack {
                            Image(systemName: "doc.questionmark")
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.SEESTURM_GREEN)
                            Text("Datenschutzerklärung")
                        }
                    }
                }
                // display a footer
                Text(footerText)
                    .multilineTextAlignment(.center)
                    .font(.footnote)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
            }
            .task {
                if pfadijahreViewModel.loadingState.taskShouldRun {
                    await pfadijahreViewModel.fetchPfadijahre(isPullToRefresh: false)
                }
            }
            .navigationTitle("Mehr")
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: MehrNavigationDestination.self) { destination in
                switch destination {
                case .fotos(let forceImageLoading):
                    PfadijahreView(viewModel: pfadijahreViewModel, forceImageLoading: forceImageLoading)
                case .dokumente:
                    DokumenteView()
                case .lüüchtturm:
                    LuuchtturmView()
                case .leitungsteam(let stufe):
                    LeitungsteamView(passedStufe: stufe)
                case .pushNotifications:
                    PushNotificationVerwaltenView()
                case .gespeichertePersonen:
                    GespeichertePersonenView()
                }
            }
            .navigationDestination(for: PfadijahreAlbumResponse.self) { pfadijahr in
                GalleriesView(pfadijahr: pfadijahr)
            }
        }
        .tint(Color.SEESTURM_GREEN)
    }
}

// separate view for scroll view of photos
struct MehrHorizontalPhotoScrollView: View {
    
    @ObservedObject var viewModel: PfadijahreViewModel
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        switch viewModel.loadingState {
        case .none, .loading, .errorWithReload(_):
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(1..<10) { _ in
                        PhotoGalleryLoadingCell(
                            width: 120,
                            height: 120,
                            withText: true
                        )
                    }
                }
            }
            .scrollDisabled(true)
        case .result(.failure(_)):
            EmptyView()
        case .result(.success(let pfadijahre)):
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(pfadijahre, id: \.id) { pfadijahr in
                        NavigationLink(value: pfadijahr) {
                            PhotoGalleryCell(
                                width: 120,
                                height: 120,
                                thumbnailUrl: pfadijahr.thumbnail,
                                title: pfadijahr.title
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    
    }
    
}

enum MehrNavigationDestination: Hashable {
    case fotos(forceImageLoading: Bool)
    case dokumente
    case lüüchtturm
    case leitungsteam(stufe: String)
    case pushNotifications
    case gespeichertePersonen
}

#Preview {
    MehrView()
        .environmentObject(AppState())
}
