# BIM493 - Mobile Programming I - Assignment #4

This repository contains the fourth assignment for the BIM493 Mobile Programming I course at Eskişehir Technical University, Department of Computer Engineering.

## Project Description

A store inventory management application developed with Flutter and Sqflite, featuring:
* **Product Management:** Users can view product name, price, and stock information in a clean grid layout (DataTable/Card).
* **Local Database:** Uses **sqflite** to store data locally, ensuring persistence even after the app is closed.
* **Barcode Query:** Products can be quickly searched using their barcode numbers.
* **CRUD Operations:** Implements full Create, Read, Update, and Delete functionality for managing store inventory.
* **Input Validation:** Validates form inputs and provides user-friendly error messages (e.g., checks for empty fields or duplicate barcodes).
* **Smart Dialogs:** Detects non-existent barcodes during search and prompts the user to add them immediately.

## Group Members

* **Name:** `Çağdaş Kaplan`
  **Student ID:** `41615046366`
* **Name:** `Özgün Saz`
  **Student ID:** `12125201262`
* **Name:** `Ali Görkem Sali`
  **Student ID:** `12245973452`

## How to Run

1.  Ensure you have the Flutter SDK installed.
2.  Clone this repository or extract the project zip file.
3.  Navigate to the project directory.
4.  Run `flutter pub get` to install the required dependencies (`sqflite`, `path`).
5.  Run `flutter run` on a connected device or emulator.