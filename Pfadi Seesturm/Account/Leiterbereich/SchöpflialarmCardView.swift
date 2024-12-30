//
//  SchöpflialarmCardView.swift
//  Pfadi Seesturm
//
//  Created by Valentin Kamm on 27.12.2024.
//

import SwiftUI

struct SchöpflialarmCardView: View {
    
    @ObservedObject var viewModel: LeiterbereichViewModel
    
    var body: some View {
        CustomCardView(shadowColor: .seesturmGreenCardViewShadowColor) {
            VStack(alignment: .center, spacing: 16) {
                Text("Letzter Schöpflialarm")
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                CustomCardView(shadowColor: .clear, backgroundColor: Color(UIColor.systemGray5)) {
                    switch viewModel.lastSchöpflialarmLoadingState {
                    case .none, .loading, .errorWithReload(_):
                        Text(Constants.PLACEHOLDER_TEXT)
                            .lineLimit(3)
                            .font(.caption)
                            .redacted(reason: .placeholder)
                            .padding(8)
                            .customLoadingBlinking()
                    case .result(.failure(let error)):
                        HStack(alignment: .center, spacing: 16) {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "exclamationmark.bubble")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(Color.SEESTURM_GREEN)
                                    Text("Ein Fehler ist aufgetreten")
                                        .font(.callout)
                                        .fontWeight(.bold)
                                        .multilineTextAlignment(.leading)
                                }
                                Text(error.localizedDescription)
                                    .font(.caption)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            CustomButton(
                                buttonStyle: .tertiary(),
                                buttonTitle: nil,
                                buttonSystemIconName: "arrow.trianglehead.clockwise",
                                asyncButtonAction: {
                                    viewModel.startObservingLeiterbereichData()
                                }
                            )
                            .layoutPriority(1)
                        }
                        .padding()
                    case .result(.success(let data)):
                        if let schöpflialarm = data {
                            
                        }
                        else {
                            Text("Es wurde noch kein Schöpflialarm gesendet.")
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(32)
                        }
                    }
                }
                Divider()
                Text("Neuer Schöpflialarm")
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Image(systemName: "text.bubble.fill")
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.SEESTURM_GREEN)
                    TextField("Nachricht", text: $viewModel.schöpflialarmMessage)
                        .textFieldStyle(.roundedBorder)
                        .disabled(
                            viewModel.sendSchöpflialarmLoadingState.isError ||
                            viewModel.sendSchöpflialarmLoadingState.isSuccess ||
                            viewModel.sendSchöpflialarmLoadingState.isLoading
                        )
                }
                CustomButton(
                    buttonStyle: .primary,
                    buttonTitle: "Schöpflialarm senden",
                    isLoading: viewModel.sendSchöpflialarmLoadingState.loadingBinding(from: viewModel.$sendSchöpflialarmLoadingState),
                    asyncButtonAction: {
                        await viewModel.sendSchöpflialarm()
                    }
                )
            }
            .padding()
                
        }
    }
}

#Preview {
    Leiterbereich(
        user: FirebaseHitobitoUser(
            userId: 123,
            vorname: "Valentin",
            nachname: "Kamm",
            pfadiname: "Pancho",
            email: "xxx@yyy.ch"
        )
    )
}
