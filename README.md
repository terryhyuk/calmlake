# CalmLake

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://python.org/)
[![Figma](https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white)](https://figma.com/)
[![Miro](https://img.shields.io/badge/Miro-050038?style=for-the-badge&logo=miro&logoColor=white)](https://miro.com/)
[![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white)](https://firebase.google.com/)
[![VS Code](https://img.shields.io/badge/VS%20Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com/)
[![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white)](https://github.com/)
[![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com/)

---

## Table of Contents

- [Overview](#overview)
- [Demo Video](#demo-video)
- [Features](#features)
- [My Roles & Responsibilities](#my-roles--responsibilities)
- [Tech Stack](#tech-stack)
- [Main Packages](#main-packages)
- [System Architecture](#system-architecture)
- [Database](#database)
- [Screen Flow Diagram](#screen-flow-diagram)
- [Screenshots](#screenshots)
- [How to Run](#how-to-run)
- [Contact](#contact)

---

## Overview

CalmLake is a Flutter-based mobile app that provides a space for users to relieve stress by enjoying healing music and communicating with others.  
Key features include music appreciation, social interaction, real-time chat, and friend management.

- **Team Size:** 4 members  
- **Project Duration:** October 2, 2024 – October 17, 2024

---

## Demo Video

**Links:**  
- [Demo Video](https://youtu.be/zySfBs3fqRo)

---

## Features

- Real-time private chat and open chat rooms
- User search and friend management (add/delete/search)
- Music appreciation and sharing
- Backend powered by FastAPI & MySQL, with Firebase for chat and storage

---

## My Roles & Responsibilities

- Implemented real-time private chat functionality
- Developed open chat rooms for multiple users
- Built user search and friend management system (add/delete features)
- Integrated backend routing and APIs using FastAPI
- Designed and implemented UI/UX for friend and chat features
- Managed real-time state with GetX and Observer pattern

---

## Tech Stack

**Frameworks:**  
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
<img src="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white"/>

**Languages:**  
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
<img src="https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white"/>

**Database:**  
<img src="https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white"/>
<img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=white"/>
- **EER Diagram only is provided for MySQL.**

**Design/Planning:**  
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=figma&logoColor=white"/>
<img src="https://img.shields.io/badge/Miro-050038?style=for-the-badge&logo=miro&logoColor=white"/>

**Tools:**  
<img src="https://img.shields.io/badge/VS%20Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white"/>
<img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white"/>

---

## Main Packages

- `get`: State management
- `http`: HTTP requests
- `get_storage`: Local storage
- `flutter_slidable`: Swipeable list items
- `image_picker`: Image selection from gallery/camera
- `firebase_core`, `cloud_firestore`, `firebase_storage`: Firebase integration
- `audioplayers`: Audio playback
- `intl`: Date/time formatting
- `flutter_rating_bar`: Rating bar widget
- `lottie`: Lottie animation
- `chat_bubbles`: Chat UI widgets
- `volume_controller`: System volume control
- `file_picker`: File selection widget
- `gif`: GIF image handling
- `expandable_text`: Expandable text widget

---

## System Architecture

![System Configuration](image/system_configuration.png)

---

## Database

### MySQL EER Diagram  
_Only the EER diagram is provided; actual database dump is not included._

![MySQL EER Diagram](image/MySQL_EER.png)

### Firebase Structure  
![Firebase Structure](image/Firebase.png)

---

## Screen Flow Diagram

![Screen Flow Diagram](image/SFD.png)

---

## Screenshots

### Main Screenshots (Features I Developed)

![Page 1](image/page1.png)
![Page 2](image/page2.png)

---

## How to Run

1. Clone the repository  
   `git clone https://github.com/terryhyuk/calmlake.git`
2. Install dependencies  
   `flutter pub get`
3. Run the app  
   `flutter run`
4. Backend setup required for full functionality:
   - The backend (FastAPI) source code is in the `/pythonSpace` directory.
   - To run the backend:
     1. Open a terminal and go to the `pythonSpace` folder.
     2. (Optional) Create a virtual environment:
        `python3 -m venv venv`
        `source venv/bin/activate`
     3. Install dependencies:
        `pip install -r requirements.txt`
     4. Start the FastAPI server:
        `uvicorn calmlake:app --reload`
   - The Flutter app uses Firebase directly; there is **no separate Firebase folder**.  
     Make sure your Firebase project is set up and configured in your Flutter app as described in the Flutter/Firebase documentation.

---

## Contact

For questions, contact:  
**Terry Yoon**  
yonghyuk.terry.yoon@gmail.com
