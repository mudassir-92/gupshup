# WhatsApp-Like Messaging App (Flutter)

A full-featured WhatsApp-like messaging application built with Flutter.  

It supports:  
- Email & Google authentication via **Supabase**  
- Real-time messaging  
- Audio and video calls via **ZegoCloud**  
- Profile editing, image editing, and username search  

# See Working
[![Watch Demo](https://img.youtube.com/vi/JLUglOqVsIM/0.jpg)](https://youtu.be/JLUglOqVsIM)

Click the image to watch the demo video.


## Features

- **Secure Login:** Email/password and Google authentication  
- **User Profiles:** Create unique usernames, edit profiles, and upload profile pictures  
- **Real-Time Chat:** Send and receive instant messages with media support  
- **Audio & Video Calls:** Smooth, low-latency calls powered by ZegoCloud  
- **Image Editing:** Built-in image editor before sending or saving profile pictures  
- **Backend:** Node.js + Express with Supabase & PostgreSQL for data storage  

---

## Setup Instructions

### 1️⃣ Clone the Repo

```bash
git clone https://github.com/mudassir-92/gupshup.git
cd gupshup
flutter pub get
````

---

### 2️⃣ Configure Environment Variables

Create a file at `main/.env`:

```env
SUPABASE_URL=XXXXXXXXXX
SUPABASE_ANON_KEY=XXXXXXXXXXXXXXX
ANDROID_CLIENT=XXXXXXXXXXXXXXXXXX
WEB_CLIENT=xxxxxxxxxxxxxxxxxxxxxx
```

Replace the `XXXXXXXX` values with your Supabase project credentials.

---

### 3️⃣ Configure ZegoCloud Credentials

In `main/lib/utils.dart`:

```dart
class Utils {
  // ZegoCloud App credentials
  static int get appId => 123456; // Replace with your Zego App ID
  static String get appSign =>
      "fXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"; // Replace with your Zego App Sign
}
```

---

### 4️⃣ Run the App

* **Android:**

```bash
flutter run
```

* **Web:**

```bash
flutter run -d chrome
```

---

### 5️⃣ Notes

* Supabase handles **auth and real-time messaging**
* ZegoCloud handles **all audio and video calls**
* Unique usernames are used to **search and connect users**
* Profile and image editing are handled **locally and stored in Supabase**

---

### 6️⃣ Recommended Packages

* `supabase_flutter` → Auth & real-time database
* `zego_uikit_prebuilt_call` → Audio & Video calls
* `image_editor_plus` → Image editing
* `flutter_dotenv` → Load environment variables

---

### 7️⃣ Folder Structure (High Level)

```
main/
├─ lib/
│  ├─ main.dart
│  ├─ assets/            # all images and fonts
│  ├─ utils.dart          # Zego credentials
│  ├─ screens/           # All app screens
│  ├─ Controller/         # All RiverPod related things are here 
│  └─ models/          # API calls, Supabase integration
├─ .env                  # Environment variables
└─ pubspec.yaml
```

---

### 8️⃣ Contributing

Contributions are welcome! Please fork the repo and create a pull request for any features, bug fixes, or improvements.
