//
//  CustomerRootView.swift
//  LTLL – Klanten-app hoofdscherm
//
//  Deze view is alleen voor de KLANTEN-APP bedoeld (LTLLApp).
//  De bezorger-app gebruikt `DriverLoginView` / `DriverDashboardView`.
//

import SwiftUI
import SwiftData

struct CustomerRootView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("LTLL – Klanten-app")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Dit is het startpunt voor de klanten-app.\nHier komen de schermen om zendingen aan te maken en orders te beheren.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Deze app gebruikt dezelfde database als de bezorger-app.", systemImage: "database")
                    Label("Orders die je hier aanmaakt, verschijnen bij de bezorger.", systemImage: "arrow.right.arrow.left")
                    Label("De admin-app kan op dezelfde data rapporteren.", systemImage: "chart.bar.xaxis")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Klant-portaal")
        }
    }
}

#Preview {
    CustomerRootView()
}


