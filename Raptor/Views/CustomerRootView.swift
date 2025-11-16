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
    @Query(sort: \DeliveryOrder.createdAt, order: .reverse) private var allOrders: [DeliveryOrder]
    @Query private var allAccounts: [DriverAccount]
    @State private var showDebugView = false
    
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
                
                // Database Info Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text("Database Status")
                            .font(.headline)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("\(allOrders.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Orders")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            Text("\(allAccounts.count)")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Bezorgers")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Button {
                        showDebugView = true
                    } label: {
                        Label("Bekijk alle data", systemImage: "eye.fill")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            .foregroundStyle(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Klant-portaal")
            .sheet(isPresented: $showDebugView) {
                DatabaseDebugView()
            }
        }
    }
}

// Debug View om alle data te bekijken
struct DatabaseDebugView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DeliveryOrder.createdAt, order: .reverse) private var allOrders: [DeliveryOrder]
    @Query private var allAccounts: [DriverAccount]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Database Overzicht") {
                    HStack {
                        Text("Totaal Orders:")
                        Spacer()
                        Text("\(allOrders.count)")
                            .fontWeight(.semibold)
                    }
                    HStack {
                        Text("Totaal Bezorgers:")
                        Spacer()
                        Text("\(allAccounts.count)")
                            .fontWeight(.semibold)
                    }
                }
                
                Section("Orders (\(allOrders.count))") {
                    if allOrders.isEmpty {
                        Text("Geen orders gevonden")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(allOrders) { order in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Order #\(String(order.orderId.prefix(8)))")
                                    .font(.headline)
                                Text("Status: \(order.status)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Van: \(order.senderAddress)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Naar: \(order.destinationAddress)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let driver = order.assignedDriverEmail {
                                    Text("Bezorger: \(driver)")
                                        .font(.caption)
                                        .foregroundStyle(.blue)
                                }
                                Text("Aangemaakt: \(order.createdAt.formatted())")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Section("Bezorger Accounts (\(allAccounts.count))") {
                    if allAccounts.isEmpty {
                        Text("Geen accounts gevonden")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(allAccounts) { account in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(account.driverName)
                                    .font(.headline)
                                Text(account.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Voertuig: \(account.vehicleType)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                HStack {
                                    Text("Actief:")
                                    Spacer()
                                    Image(systemName: account.isActive ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundStyle(account.isActive ? .green : .red)
                                }
                                .font(.caption)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("Database Debug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sluiten") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CustomerRootView()
}


