# 🚨 AidLink - Disaster Response App

**AidLink** is a real-time disaster response application developed using **Flutter (Frontend)**, **Flask (Backend)**, and **Firebase Authentication**. It helps users find nearby emergency services and share their location during disasters like floods, earthquakes, or accidents.

---

## 🌟 Features

- 🔒 Secure login via **Firebase Authentication**  
- 📍 Real-time location tracking (Google Maps API)  
- 🏥 Nearby hospitals & police stations display  
- 🆘 SOS functionality (Call and Email alerts)  
- ✉️ SMTP integration for emergency communication  
- 📰 **Region-based news feed** *(can be implemented)*  
- 📲 Cross-platform: Works on **Web** and **Android**

---

## 🧑‍💻 Tech Stack

| Layer         | Technology         |
|---------------|--------------------|
| Frontend      | Flutter            |
| Backend       | Flask (Python)     |
| Authentication| Firebase Auth      |
| Database      | Firebase / MySQL   |
| APIs Used     | Google Maps API, SMTP |

---

## ⚠️ Important: API Keys and Configurations Required

To run AidLink successfully, you **must add your own API keys and configuration files** before running the app. The app depends on these keys for authentication, maps, and email features.

- **Google Maps API Key:** Required for location and maps.  
- **Firebase Config Files:** Required for Firebase Authentication (e.g., `google-services.json`, `GoogleService-Info.plist`).  
- **SMTP Credentials:** Required for sending emails via the backend.  

Without these keys and configs, the app will **not function correctly**.

---

## 🚀 How to Run Locally

1. **Clone the Repository**  
```bash
git clone https://github.com/karthik-h-tech/Aidlink.git
cd Aidlink
