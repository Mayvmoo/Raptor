# Database Setup - Raptor & Raptor Driver

## Overzicht

Beide apps (Raptor en Raptor Driver) gebruiken nu dezelfde gedeelde database via **CloudKit**. Dit betekent dat:

- ✅ Orders die in de Raptor app (klant-app) worden aangemaakt, verschijnen automatisch in de Raptor Driver app
- ✅ Beide apps synchroniseren data via iCloud/CloudKit
- ✅ Data is beschikbaar op alle devices waarop de apps zijn geïnstalleerd

## CloudKit Container

**Container Identifier:** `iCloud.com.lettertoletter.LTLL`

Deze identifier is geconfigureerd in:
- `Raptor/Raptor.entitlements`
- `Raptor Driver/Raptor_Driver.entitlements`
- `Services/DatabaseService.swift`

## Database Models

De volgende models worden gedeeld tussen beide apps:

1. **DriverAccount** - Bezorger accounts
   - Email, wachtwoord hash, naam, telefoon, voertuigtype
   - Wordt gebruikt voor authenticatie in de Driver app

2. **DeliveryOrder** - Bezorgopdrachten
   - Alle order informatie (afzender, bestemming, status, etc.)
   - Wordt gebruikt in beide apps

3. **DriverSession** - Actieve bezorger sessies
   - Lokaal model (niet gesynchroniseerd via CloudKit)
   - Wordt alleen gebruikt in de Driver app voor de huidige login

## Database Services

### DatabaseService
- `createSharedContainer()` - Maakt de gedeelde CloudKit container aan
- `checkCloudKitStatus()` - Controleert CloudKit beschikbaarheid
- Seed data bij eerste opstarten (test account)

### OrderService
- `createOrder()` - Maakt nieuwe orders aan (klant-app)
- `fetchAllOrders()` - Haalt alle orders op
- `fetchOrdersForDriver()` - Haalt orders op voor specifieke bezorger
- `fetchAvailableOrders()` - Haalt beschikbare (pending) orders op
- `updateOrderStatus()` - Update order status
- `assignOrder()` - Wijs order toe aan bezorger
- `completeOrder()` - Markeer order als voltooid

### DriverAuthService
- `authenticate()` - Authenticeert bezorger
- `ensureSeeded()` - Zorgt voor test data

### DatabaseSyncService
- `observeChanges()` - Observeert database wijzigingen
- `forceSync()` - Forceert synchronisatie met CloudKit

## App Configuratie

### Raptor App (Klant-app)
- **Entry Point:** `Raptor/RaptorApp.swift`
- **Main View:** `CustomerRootView`
- Gebruikt `DatabaseService.createSharedContainer()` voor database setup

### Raptor Driver App (Bezorger-app)
- **Entry Point:** `Raptor Driver/DriverApp.swift`
- **Main View:** `DriverLoginView` → `DriverDashboardView`
- Gebruikt `DatabaseService.createSharedContainer()` voor database setup

## Test Account

Bij eerste opstarten wordt automatisch een test account aangemaakt:

- **Email:** `bezorger@lettertoletter.nl`
- **Wachtwoord:** `test123`
- **Naam:** Test Bezorger
- **Voertuig:** Bike

⚠️ **BELANGRIJK:** In productie moet je:
- Echte password hashing implementeren (BCrypt, Argon2, etc.)
- De seed data verwijderen of via een admin interface beheren
- Proper authenticatie en autorisatie implementeren

## CloudKit Setup in Xcode

Om CloudKit te gebruiken in productie:

1. **Apple Developer Account:**
   - Zorg dat je een Apple Developer account hebt
   - Configureer de App ID met CloudKit capabilities

2. **CloudKit Dashboard:**
   - Ga naar https://icloud.developer.apple.com/dashboard
   - Selecteer je container: `iCloud.com.lettertoletter.LTLL`
   - Configureer de database schema's

3. **Entitlements:**
   - Zorg dat beide apps de juiste entitlements hebben
   - CloudKit service moet zijn ingeschakeld
   - Container identifier moet correct zijn

## Synchronisatie

CloudKit synchroniseert automatisch:
- Wanneer de app wordt geopend
- Wanneer er wijzigingen zijn
- In de achtergrond (met iCloud account)

Voor handmatige synchronisatie:
```swift
await DatabaseSyncService.forceSync()
```

## Troubleshooting

### CloudKit werkt niet
1. Controleer of je ingelogd bent op iCloud op het device
2. Controleer de CloudKit status in de console logs
3. Zorg dat beide apps dezelfde container identifier gebruiken
4. Controleer de entitlements in Xcode

### Data verschijnt niet in beide apps
1. Wacht even - CloudKit synchroniseert in de achtergrond
2. Check de CloudKit status: `await DatabaseService.checkCloudKitStatus()`
3. Zorg dat beide apps dezelfde container identifier gebruiken
4. Controleer of de models correct zijn geconfigureerd

### Test account werkt niet
1. Check of de seed data is aangemaakt (zie console logs)
2. Gebruik de juiste credentials: `bezorger@lettertoletter.nl` / `test123`
3. Controleer of `DriverAuthService.ensureSeeded()` is aangeroepen

## Volgende Stappen

1. ✅ Database is verbonden met beide apps
2. ✅ CloudKit synchronisatie is geconfigureerd
3. ⏭️ Implementeer order creation in CustomerRootView
4. ⏭️ Implementeer order listing in DriverDashboardView
5. ⏭️ Implementeer order assignment functionaliteit
6. ⏭️ Voeg push notifications toe voor nieuwe orders
7. ⏭️ Implementeer proper password hashing
8. ⏭️ Voeg error handling en retry logic toe

