# 🚨 SafePulse – AI Emergency Shouter App

SafePulse is an **AI-powered emergency safety application** designed to help users quickly send alerts, share their location, and trigger emergency assistance during dangerous situations.

The app combines **Flutter (mobile UI), Python FastAPI (AI backend), and Supabase (authentication & database)** to create a modern real-time emergency response system.

---

# 📱 Features

### 🚨 Emergency Alert System

* One-tap **Emergency Button**
* Sends **real-time location**
* Triggers emergency alert

### 🎤 AI Voice Detection

* Records voice input
* Detects emergency keywords like:

  * "help"
  * "danger"
  * "save me"
  * "emergency"

### 📍 Live Location Sharing

* Automatically shares user GPS location during emergencies.

### 👥 Emergency Contacts

* Add trusted contacts
* Send alerts to contacts during emergencies.

### 📊 Emergency History

* View previous emergency alerts and logs.

### 🔐 Secure Authentication

* Powered by **Supabase Authentication**.

---

# 🧱 Tech Stack

| Technology                          | Purpose                               |
| ----------------------------------- | ------------------------------------- |
| Flutter                             | Mobile App UI                         |
| Python FastAPI                      | Backend API                           |
| Supabase                            | Authentication + Database             |
| OpenAI Whisper / Speech Recognition | Voice detection                       |
| REST API                            | Communication between app and backend |

---

# 🏗 Project Architecture

```
Flutter Mobile App
        ↓
     FastAPI
        ↓
     Supabase
(Database + Auth)
```

---

# 📂 Project Structure

```
safe-pulse/
│
├── flutter_app/
│   ├── main.dart
│   └── lib/
│       ├── pages/
│       │   ├── splash_page.dart
│       │   ├── login_page.dart
│       │   ├── signup_page.dart
│       │   ├── home_page.dart
│       │   ├── emergency_page.dart
│       │   ├── add_contact_page.dart
│       │   ├── contact_list_page.dart
│       │   └── emergency_history_page.dart
│       │
│       ├── services/
│       │   ├── auth_service.dart
│       │   ├── location_service.dart
│       │   ├── voice_service.dart
│       │   └── emergency_service.dart
│       │
│       ├── models/
│       │   ├── user_model.dart
│       │   ├── contact_model.dart
│       │   └── emergency_model.dart
│       │
│       └── widgets/
│           └── emergency_button_widget.dart
│
├── python_backend/
│   ├── main.py
│   ├── requirements.txt
│   │
│   ├── routes/
│   │   ├── auth_routes.py
│   │   ├── emergency_routes.py
│   │   └── contact_routes.py
│   │
│   ├── services/
│   │   └── ai_service.py
│   │
│   └── utils/
│       └── keyword_detector.py
│
└── README.md
```

---

# 🗄 Database Schema (Supabase)

### Users

```
id
name
email
phone
created_at
```

### Emergency Contacts

```
id
user_id
contact_name
contact_phone
relationship
```

### Emergency Logs

```
id
user_id
latitude
longitude
audio_url
status
timestamp
```

---

# 🚀 Installation

## 1️⃣ Clone the Repository

```
git clone https://github.com/YOUR_USERNAME/safe-pulse.git
```

```
cd safe-pulse
```

---

# 📱 Run Flutter App

Install dependencies:

```
flutter pub get
```

Run app:

```
flutter run
```

---

# 🐍 Run Python Backend

Install dependencies:

```
pip install -r requirements.txt
```

Start server:

```
uvicorn main:app --reload
```

Backend will run on:

```
http://localhost:8000
```

---

# 🔑 Environment Variables

Create a `.env` file in the backend folder.

```
SUPABASE_URL=your_supabase_url
SUPABASE_KEY=your_supabase_key
```

---

# 🧠 AI Keyword Detection Example

Example logic used by backend:

```python
keywords = ["help", "danger", "save me", "emergency"]

def detect_emergency(text):
    for word in keywords:
        if word in text.lower():
            return True
    return False
```

---

# 🔮 Future Improvements

* AI emotion detection
* Shake-to-trigger emergency
* Real-time map tracking
* Smartwatch integration
* Automatic video recording
* Push notifications

---

# 🛡 Safety Goal

SafePulse aims to improve **personal safety and rapid emergency response**, especially for:

* Women safety
* Elderly monitoring
* Student safety
* Personal security situations

---

# 👨‍💻 Author

**Suriya Prakash**

Computer Science Student
AI Enthusiast | Mobile Developer | Cloud Learner

---

# ⭐ Support

If you like this project, consider giving it a ⭐ on GitHub.

It helps others discover the project and motivates further development.

