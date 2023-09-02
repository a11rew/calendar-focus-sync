//
//  HomeView.swift
//  Calendar Focus Sync
//
//  Created by Andrew Glago on 02/09/2023.
//

import SwiftUI

struct HomeView: View {
    @State private var launchOnLogin = true;
    @State private var selectedPriorTimeBuffer: TimeBefore = TimeBefore.one_minute
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Automatically enter focus modes when a calendar event begins")
            
            generalConfig
        }
        .padding(16)
    }
    
    @ViewBuilder
    private var generalConfig: some View {
        VStack(alignment: .leading) {
            Text("Preferences")
            
            VStack {
                HStack {
                    Text("Launch at login")
                    Spacer()
                    Toggle("", isOn: $launchOnLogin)
                        .toggleStyle(.switch)
                }
                
                Divider()
                
                HStack {
                    Text("Enter Focus Mode how long before")
                    Spacer()
                    Picker("", selection: $selectedPriorTimeBuffer) {
                        Text("1 minute").tag(TimeBefore.one_minute)
                        Text("2 minutes").tag(TimeBefore.two_minutes)
                        Text("5 minutes").tag(TimeBefore.five_minutes)
                        Text("10 minutes").tag(TimeBefore.ten_minutes)
                    }.frame(maxWidth: 140)
                }
            }
            .padding(8)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.white, lineWidth: 0.5)
                    .opacity(0.3)
            )
        }
        
    }
}

enum TimeBefore {
    case one_minute
    case two_minutes
    case five_minutes
    case ten_minutes
}

struct HomeViewPreview: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
