//
//  ContentView.swift
//  LTL MD
//
//  Created on [Date]
//

import SwiftUI

struct ContentView: View {
    @State private var greeting = "Welkom bij LTL MD!"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(greeting)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Je iOS app is klaar om te beginnen!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    greeting = "Laten we beginnen met ontwikkelen! 🚀"
                }) {
                    Text("Klik hier")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("LTL MD")
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

