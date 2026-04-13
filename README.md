# AppruvQR 
## Overview

AppruvQR is an iOS application built with SwiftUI and SwiftData designed to facilitate offline accountability and task management through secure QR code scanning. It allows users to manage tasks, track streaks, and verify task completion using locally generated, time-sensitive cryptographic QR codes.

## Features

* **Task Management:** Create, track, and manage daily tasks and routines.
* **Offline Accountability:** Verify task completion securely without relying on an active internet connection.
* **Dynamic Secure QR Codes:** Uses `CryptoKit` to generate time-sensitive (expiring) QR codes with HMAC-SHA256 signatures to prevent spoofing.
* **Built-in QR Scanner:** A custom camera view using `AVFoundation` to scan and validate approval codes instantly.
* **Streak Tracking:** Gamified tracking of consistent task completion to build habits.
* **Local Notifications:** Get instant feedback via system banners upon successful task verification using the `UserNotifications` framework.
* **History & Logging:** Uses `SwiftData` to store user profiles, task history, and a log of system notifications locally on the device.

## Architecture & Technologies

* **UI Framework:** SwiftUI
* **Local Storage:** SwiftData (Modern replacement for Core Data)
* **Cryptography:** CryptoKit (HMAC-SHA256)
* **Camera Integration:** AVFoundation (Custom `UIViewControllerRepresentable` for scanning)
* **Notifications:** UserNotifications framework
* **Architecture Pattern:** Model-View (Apple's recommended approach for SwiftData applications)

## Core Components

* **`TaskSheetView`**: The primary interface for creating and editing tasks, including selecting a "Reviewer" for accountability.
* **`ProfileView`**: Manages the user's profile and displays their dynamic, auto-refreshing Secure QR Code.
* **`QRCameraScanner`**: Handles the physical scanning of QR codes and processes the resulting payload.
* **`ScannerValidator`**: Ensures the scanned QR code is valid, not expired, and matches the required signature.
* **`NotificationView`**: Displays a history log of important events (like tasks due or completed) pulled directly from SwiftData.

## Requirements

* iOS 17.0+
* Xcode 15.0+
* Swift 5.9+

## Installation & Setup

1.  Clone the repository to your local machine.
2.  Open the `.xcodeproj` or `.xcworkspace` file in Xcode.
3.  Ensure your app's target has the **Privacy - Camera Usage Description** (`NSCameraUsageDescription`) set in the `Info.plist` to allow QR scanning.
4.  Build and run on the iOS Simulator or a physical device.

## How the Offline Verification Works

1.  **The Reviewer (Approver):** Opens their `ProfileView`. The app generates a JSON payload containing their ID, Name, a current UNIX timestamp, and a cryptographic signature. This payload is rendered as a QR code that refreshes every 10 seconds.
2.  **The User (Requester):** Opens the scanner via `TaskSheetView` to prove they finished a task.
3.  **Validation:** The app scans the code, checks that the timestamp is less than 10 seconds old, and verifies the signature using a shared secret key. If valid, the task is marked complete, the streak increases, and a local notification is fired.
