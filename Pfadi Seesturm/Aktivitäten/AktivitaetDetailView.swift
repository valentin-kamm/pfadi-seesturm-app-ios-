//
//  AktivitaetDetailView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 30.11.2024.
//

import SwiftUI
import RichText

struct AktivitaetDetailView: View {
    
    @StateObject var viewModel = AktivitaetDetailViewModel()
    @Environment(\.scenePhase) private var scenePhase
    var stufe: SeesturmStufe
    var input: AktivitaetDetailViewInputType
        
    var body: some View {
        ScrollView {
            switch(input) {
            case .id(let aktivitaetID):
                switch viewModel.loadingState {
                case .none, .loading, .errorWithReload(_):
                    CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top, spacing: 16) {
                                Text(Constants.PLACEHOLDER_TEXT)
                                    .lineLimit(1)
                                    .multilineTextAlignment(.leading)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .redacted(reason: .placeholder)
                                    .customLoadingBlinking()
                                Circle()
                                    .fill(Color.skeletonPlaceholderColor)
                                    .frame(width: 40, height: 40)
                                    .customLoadingBlinking()
                            }
                            Text(Constants.PLACEHOLDER_TEXT)
                                .lineLimit(6)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .multilineTextAlignment(.center)
                                .redacted(reason: .placeholder)
                                .customLoadingBlinking()
                        }
                        .padding()
                    }
                    .padding()
                case .error(let error):
                    CardErrorView(
                        errorTitle: "Ein Fehler ist aufgetreten",
                        errorDescription: error.localizedDescription,
                        asyncRetryAction: {
                            await viewModel.fetchEvent(by: aktivitaetID, calendarId: stufe.calendar.info.calendarId, isPullToRefresh: false)
                        }
                    )
                    .padding(.vertical)
                case .success:
                    AktivitaetDetailContentView(
                        stufe: stufe,
                        aktivitaet: viewModel.event
                    )
                
                }
            case .object(let aktivitaet):
                AktivitaetDetailContentView(
                    stufe: stufe,
                    aktivitaet: aktivitaet
                )
            }
        }
        .background(Color.customBackground)
        .navigationTitle("Aktivitäten \(stufe.description)")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if case .id(let aktivitaetID) = input, viewModel.loadingState.taskShouldRun || aktivitaetID != viewModel.currentEventId {
                    Task {
                        await viewModel.fetchEvent(by: aktivitaetID, calendarId: stufe.calendar.info.calendarId, isPullToRefresh: false)
                    }
                }
            }
        }
        .onAppear {
            if case .id(let aktivitaetID) = input, viewModel.loadingState.taskShouldRun || aktivitaetID != viewModel.currentEventId {
                Task {
                    await viewModel.fetchEvent(by: aktivitaetID, calendarId: stufe.calendar.info.calendarId, isPullToRefresh: false)
                }
            }
        }
    }
}

struct AktivitaetDetailContentView: View {
    var stufe: SeesturmStufe
    var aktivitaet: TransformedCalendarEventResponse?
    @State var sheetMode: AktivitaetAktionen? = nil
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            if let aktivitaet = aktivitaet {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(aktivitaet.title)
                                .multilineTextAlignment(.leading)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Label {
                                Text("Veröffentlicht: ")
                                    .font(.caption2)
                                    .fontWeight(.bold) +
                                Text(aktivitaet.created)
                                    .font(.caption2)
                            } icon: {
                                Image(systemName: "calendar.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 15, height: 15)
                                    .aspectRatio(contentMode: .fit)
                            }
                            .foregroundStyle(Color.secondary)
                            if aktivitaet.showUpdated {
                                Label {
                                    Text("Aktualisiert: ")
                                        .font(.caption2)
                                        .fontWeight(.bold) +
                                    Text(aktivitaet.updated)
                                        .font(.caption2)
                                } icon: {
                                    Image(systemName: "arrow.trianglehead.2.clockwise")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 15, height: 15)
                                        .aspectRatio(contentMode: .fit)
                                }
                                .foregroundStyle(Color.secondary)
                            }
                        }
                        stufe.icon
                            .resizable()
                            .frame(width: 40, height: 40)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    }
                    Divider()
                    Label {
                        if #available(iOS 17.0, *) {
                            Text("Zeit: ")
                                .foregroundStyle(stufe.color)
                                .font(.subheadline)
                                .fontWeight(.bold) +
                            Text(aktivitaet.fullDateTimeString)
                                .foregroundStyle(Color.secondary)
                                .font(.subheadline)
                        } else {
                            Text("Zeit: ")
                                .foregroundColor(stufe.color)
                                .font(.subheadline)
                                .fontWeight(.bold) +
                            Text(aktivitaet.fullDateTimeString)
                                .foregroundColor(Color.secondary)
                                .font(.subheadline)
                        }
                        
                    } icon: {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundStyle(stufe.color)
                    }
                    if let ort = aktivitaet.location {
                        Label {
                            if #available(iOS 17.0, *) {
                                Text("Treffpunkt: ")
                                    .foregroundStyle(stufe.color)
                                    .font(.subheadline)
                                    .fontWeight(.bold) +
                                Text(ort)
                                    .foregroundStyle(Color.secondary)
                                    .font(.subheadline)
                            } else {
                                Text("Treffpunkt: ")
                                    .foregroundColor(stufe.color)
                                    .font(.subheadline)
                                    .fontWeight(.bold) +
                                Text(ort)
                                    .foregroundColor(Color.secondary)
                                    .font(.subheadline)
                            }
                            
                        } icon: {
                            Image(systemName: "location")
                                .foregroundStyle(stufe.color)
                        }
                    }
                    if let beschreibung = aktivitaet.description {
                        Divider()
                        Label {
                            Text("Infos")
                                .foregroundStyle(stufe.color)
                                .font(.subheadline)
                                .fontWeight(.bold)
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(stufe.color)
                        }
                        RichText(html: beschreibung)
                            .transition(.none)
                            .linkOpenType(.SFSafariView())
                            .placeholder(content: {
                                Text(Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT + Constants.PLACEHOLDER_TEXT)
                                    .lineLimit(2)
                                    .font(.body)
                                    .redacted(reason: .placeholder)
                                    .customLoadingBlinking()
                                    .padding(.top, -16)
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(minHeight: 16)
                    }
                    Divider()
                    HStack(alignment: .top, spacing: 16) {
                        if stufe.allowedActionActivities.contains(.abmelden) {
                            CustomButton(buttonStyle: .primary, buttonTitle: "Abmelden", buttonAction: {
                                sheetMode = .abmelden
                            })
                        }
                        if stufe.allowedActionActivities.contains(.anmelden) {
                            CustomButton(buttonStyle: .secondary, buttonTitle: "Anmelden", buttonAction: {
                                sheetMode = .anmelden
                            })
                        }
                    }
                }
                .padding()
            }
            else {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top, spacing: 16) {
                        Text(stufe.description)
                            .multilineTextAlignment(.leading)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        stufe.icon
                            .resizable()
                            .frame(width: 40, height: 40)
                            .scaledToFit()
                            .aspectRatio(contentMode: .fit)
                    }
                    Text("Die nächste Aktivität ist noch in Planung.")
                        .foregroundStyle(Color.secondary)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, 64)
                        .lineLimit(2)
                }
                .padding()
            }
        }
        .padding()
        .sheet(item: $sheetMode, content: { mode in
            if let aktivitaet = aktivitaet {
                AktivitaetAnAbmeldenView(aktivitaet: aktivitaet, stufe: stufe, selectedContentMode: mode)
            }
        })
        // kalendar abonnieren link
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    UIApplication.shared.open(stufe.calendar.info.subscriptionURL)
                }) {
                    Image(systemName: "calendar.badge.plus")
                }
            }
        }
    }
}


// to define which input is provided
enum AktivitaetDetailViewInputType: Hashable {
    case id(String)
    case object(TransformedCalendarEventResponse?)
}

#Preview("Aktivität übergeben") {
    AktivitaetDetailView(
        stufe: .biber,
        input: .object(
            TermineCardViewPreviewExtension().oneDayEventData()
        )
    )
}

#Preview("Aktivität noch nicht fertig geplant") {
    AktivitaetDetailView(
        stufe: .pio,
        input: .object(nil)
    )
}

#Preview("ID übergeben") {
    AktivitaetDetailView(
        stufe: .pio,
        input: .id("2337fuo04n6lv5lju4kgflrqmq")
    )
}
