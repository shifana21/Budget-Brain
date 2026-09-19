# 💰 BudgetBrain

> An AI-powered personal expense analytics application that helps users track spending, understand financial behavior, detect unusual expenses, and make smarter budgeting decisions.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
[![Python](https://img.shields.io/badge/Python-3.x-blue?logo=python)](https://www.python.org/)
[![AI/ML](https://img.shields.io/badge/AI%2FML-Powered-orange)](https://www.python.org/)
[![Hive](https://img.shields.io/badge/Hive-Local%20Storage-yellow)](https://pub.dev/packages/hive)
[![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-5C6BC0)](https://riverpod.dev/)

---

## 📌 Overview

**BudgetBrain** is a smart expense management application designed to go beyond simple expense tracking.

Traditional expense applications mainly record transactions. BudgetBrain focuses on understanding the user's spending behavior and transforming transaction data into useful insights.

### 🎯 Goal

Turn:

```text
Expenses
   ↓
Data
   ↓
Analysis
   ↓
Insights
   ↓
Better Financial Decisions
```

---

## ✨ Key Features

### 💸 Expense Tracking

Users can record multiple transactions with information such as:

* Amount
* Category
* Date
* Description
* Transaction type

### 📊 Expense Analytics

Visualize spending patterns through:

* Category-wise spending
* Monthly expenses
* Spending trends
* Budget utilization
* Transaction summaries

### 🤖 AI-Powered Insights

BudgetBrain is designed to analyze spending behavior and provide personalized insights.

Examples include:

* High-spending categories
* Changes in spending patterns
* Potential savings opportunities
* Unusual transactions
* Budget-related recommendations

### 🔮 Expense Prediction

Historical spending data can be used to estimate future expenses and help users plan their budgets.

### 🚨 Anomaly Detection

The application can identify unusual spending behavior using statistical techniques such as **Z-score based anomaly detection**.

Example:

```text
Normal spending:
₹100 → ₹250 → ₹180 → ₹220

Unusual spending:
₹4,500
      ↑
Potential anomaly
```

### 🧠 Financial Health Score

Generate an overall financial health indicator based on spending-related behavior.

The score can consider factors such as:

* Spending consistency
* Budget utilization
* Savings behavior
* Unusual spending
* Category distribution

### 🎙️ Voice Expense Entry

Users can enter expenses using voice input instead of manually typing every transaction.

Example:

```text
"Spent 250 rupees for groceries"
             ↓
        Expense Entry
             ↓
       ₹250 - Groceries
```

### 📷 Receipt Scanner

A planned receipt-scanning feature can help extract transaction information from receipts.

### 💬 AI Financial Assistant

A conversational interface can help users understand their spending data and ask questions about their expenses.

---

## 🏗️ Architecture

BudgetBrain follows an offline-first approach with a structured application architecture.

```text
                 ┌──────────────────────┐
                 │      Flutter UI      │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │     Riverpod         │
                 │  State Management    │
                 └──────────┬───────────┘
                            │
                            ▼
                 ┌──────────────────────┐
                 │   Clean Architecture │
                 └──────────┬───────────┘
                            │
             ┌──────────────┼──────────────┐
             ▼              ▼              ▼
        ┌─────────┐   ┌───────────┐   ┌─────────┐
        │  Hive   │   │ AI / ML    │   │ Charts  │
        │ Storage │   │ Analytics  │   │ FL Chart│
        └─────────┘   └───────────┘   └─────────┘
```

---

## 🛠️ Tech Stack

### Mobile Application

* Flutter
* Dart
* Material 3

### State Management

* Riverpod

### Local Storage

* Hive

### Data Visualization

* FL Chart

### AI / Machine Learning

* Python
* Statistical analysis
* Prediction models
* Anomaly detection
* Behavioral analysis

### Architecture

* Clean Architecture
* Offline-first design

---

## 📱 Application Flow

```text
Add Expense
     ↓
Store Transaction
     ↓
Categorize Expense
     ↓
Analyze Spending
     ↓
Detect Patterns
     ↓
Generate Insights
     ↓
Recommend Actions
```

---

## 📂 Project Structure

```text
BudgetBrain/
│
├── lib/
│   ├── core/
│   ├── data/
│   ├── domain/
│   ├── presentation/
│   └── main.dart
│
├── assets/
├── test/
├── pubspec.yaml
└── README.md
```

> Project structure may evolve as new features are integrated.

---

## 🚀 Getting Started

### 1. Clone the repository

```bash
git clone <YOUR_BUDGETBRAIN_REPOSITORY_URL>
cd BudgetBrain
```

### 2. Check Flutter installation

```bash
flutter doctor
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the application

```bash
flutter run
```

For Android:

```bash
flutter devices
flutter run
```

---

## 📊 Development Roadmap

* [x] Flutter project setup
* [x] Material 3 UI
* [x] Expense tracking foundation
* [x] Local storage
* [x] Riverpod integration
* [x] Expense analytics foundation
* [x] Multiple transaction support
* [x] Voice expense feature foundation
* [ ] Advanced AI insights
* [ ] Expense prediction
* [ ] Advanced anomaly detection
* [ ] Financial health score
* [ ] AI financial assistant
* [ ] Receipt scanner
* [ ] Advanced budgeting
* [ ] Android production build

---

## 🔮 Future Enhancements

* ☁️ Optional cloud synchronization
* 🔐 Secure user accounts
* 📈 Advanced financial forecasting
* 🧠 Personalized financial recommendations
* 📷 OCR-powered receipt extraction
* 🎙️ Improved voice expense recognition
* 📊 Advanced financial dashboards
* 🔔 Smart budget alerts

---

## 🎯 Why BudgetBrain?

BudgetBrain is designed around the idea that expense management should not stop at:

> **"How much did I spend?"**

It should also help answer:

> **"Where am I spending?"**
> **"What changed?"**
> **"Is this unusual?"**
> **"What might happen next?"**
> **"How can I improve?"**

---

## 👩‍💻 Author

### Shifana Barveen S

Computer Science and Engineering Student
Interested in Software Engineering, AI/ML, mobile applications, and intelligent systems.

**BUILD • LEARN • INNOVATE**

---

## ⭐ Support

If you find BudgetBrain interesting, consider giving the repository a ⭐ on GitHub.
