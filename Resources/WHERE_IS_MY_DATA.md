# Waar is mijn data opgeslagen?

## 📱 In de Apps Zelf

### Raptor Driver App (Bezorger-app)
- **DriverDashboardView** toont alle orders:
  - Tab "Beschikbaar": Orders met status "pending"
  - Tab "Mijn Orders": Orders toegewezen aan de ingelogde bezorger
- **DriverProfileView**: Bezorger profiel informatie
- **DriverOrderDetailView**: Details van een specifieke order

### Raptor App (Klant-app)
- **CustomerRootView**: Hoofdscherm (moet nog worden uitgebreid met order lijst)
- Je kunt een debug view toevoegen om alle data te bekijken

## 💾 Lokaal op je Device

SwiftData slaat de database lokaal op in de app's container directory:

**Locatie op macOS Simulator:**
```
~/Library/Developer/CoreSimulator/Devices/[DEVICE_ID]/data/Containers/Data/Application/[APP_ID]/Library/Application Support/default.store
```

**Locatie op echt iOS Device:**
- In de app's sandbox directory (niet direct toegankelijk zonder jailbreak)
- Path: `App Container/Library/Application Support/default.store`

**Om de lokale database te vinden:**
1. Open Xcode
2. Ga naar Window → Devices and Simulators
3. Selecteer je device/simulator
4. Selecteer je app
5. Klik op "Download Container..."
6. Open de gedownloade container
7. Navigeer naar: `AppData/Library/Application Support/default.store`

## ☁️ In CloudKit (iCloud)

Alle data wordt automatisch gesynchroniseerd naar CloudKit. Je kunt dit bekijken via:

### CloudKit Dashboard
1. Ga naar: https://icloud.developer.apple.com/dashboard
2. Log in met je Apple Developer account
3. Selecteer je container: `iCloud.com.lettertoletter.LTLL`
4. Klik op "Data" in de sidebar
5. Selecteer de database (Development of Production)
6. Je ziet alle records:
   - **DriverAccount** records
   - **DeliveryOrder** records

### CloudKit Database Types
- **Development Database**: Voor testen tijdens ontwikkeling
- **Production Database**: Voor live apps in de App Store

## 🔍 Data Bekijken via Code

### In de App (SwiftUI Views)

**Alle orders ophalen:**
```swift
@Query private var allOrders: [DeliveryOrder]

// Of met een FetchDescriptor:
let descriptor = FetchDescriptor<DeliveryOrder>(
    sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
)
let orders = try modelContext.fetch(descriptor)
```

**Bezorger accounts ophalen:**
```swift
let descriptor = FetchDescriptor<DriverAccount>()
let accounts = try modelContext.fetch(descriptor)
```

### Via Console Logs

De app print automatisch informatie naar de console:
- Database initialisatie status
- CloudKit status
- Seed data confirmatie
- Error messages

**Om logs te zien:**
1. Run de app in Xcode
2. Open de Console (View → Debug Area → Activate Console)
3. Filter op "Database" of "CloudKit"

## 🛠️ Debug Tools

### 1. Xcode Database Inspector
- Open Xcode
- Run je app
- Ga naar Debug → View Debugging → Capture View Hierarchy
- Of gebruik de SwiftData debugger (als beschikbaar)

### 2. CloudKit Console
- Zie hierboven bij "In CloudKit (iCloud)"

### 3. Terminal Commands (voor lokale database)

**Op macOS Simulator:**
```bash
# Vind je simulator device
xcrun simctl list devices

# Vind de app container
xcrun simctl get_app_container booted com.yourapp.bundleid data

# Database staat in:
# [CONTAINER]/Library/Application Support/default.store
```

## 📊 Data Structure

### DriverAccount
- `email` (unique)
- `passwordHash`
- `driverName`
- `phoneNumber`
- `vehicleType`
- `isActive`
- `createdAt`

### DeliveryOrder
- `orderId` (unique)
- `senderName`
- `senderAddress`
- `destinationName`
- `destinationAddress`
- `deliveryMode`
- `status` (pending, assigned, inProgress, completed, cancelled)
- `assignedDriverEmail`
- `isUrgent`
- `notes`
- `attachmentImageData`
- `paymentStatus`
- `createdAt`
- `updatedAt`

## 🔄 Synchronisatie

Data wordt automatisch gesynchroniseerd:
- **Lokaal → CloudKit**: Wanneer je data aanmaakt/wijzigt
- **CloudKit → Lokaal**: Wanneer de app opstart of wanneer er wijzigingen zijn
- **Tussen Devices**: Via iCloud account

**Handmatige synchronisatie forceren:**
```swift
await DatabaseSyncService.forceSync()
```

## ⚠️ Belangrijk

1. **Development vs Production**: 
   - Tijdens ontwikkeling gebruik je de Development database
   - Voor productie moet je de Production database gebruiken

2. **iCloud Account Vereist**:
   - CloudKit synchronisatie werkt alleen met een ingelogd iCloud account
   - Check de status: `await DatabaseService.checkCloudKitStatus()`

3. **Data Privacy**:
   - Lokale database is versleuteld
   - CloudKit data is privé en alleen toegankelijk voor jouw app
   - Gebruikers moeten ingelogd zijn op iCloud

## 🚀 Quick Check: Is mijn data er?

1. **In de app**: Open DriverDashboardView en kijk of orders verschijnen
2. **In console**: Check voor "✅ Seeded initial driver account" message
3. **CloudKit Dashboard**: Log in en check de Data tab
4. **Lokaal**: Download app container via Xcode en check de store file

