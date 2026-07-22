# MedGuardian
<img width="528" height="528" alt="MedGLogo" src="https://github.com/user-attachments/assets/2ef991c6-da50-4f78-9f5c-8c5bd7d504d0" />
Introduction

✨ Features
AI Cancer Detection: Multi-class automated detection and classification for Brain Tumors (Glioma, Meningioma, Pituitary, Normal), Breast Cancer (Benign, Malignant), and Lung Cancer (Malignant, Benign, Normal) directly within the mobile application.

Medical Report Summarizer: AI-driven text extraction from uploaded PDF reports (via Syncfusion PDF and Llama 3.1 8B via Groq API) that translates complex clinical terms into simplified summaries.

AI Medical Assistant: Conversational health guidance interface powered by Google Gemini 2.5 Flash Lite using google_generative_ai.

Medication Reminder: Scheduled dose tracking, type selection (pills, syrups, injections), and progress monitoring powered by real-time Firebase Firestore streams.

Doctor Portal: Supplementary React-based dashboard enabling verified medical professionals to review scans, confirm/modify AI diagnostic predictions, and push action plans directly to patient devices.

Patient-Doctor Chat: Real-time synchronized messaging connecting patients with assigned specialists.

Scan History: Persistent historical tracking of previous scans, model confidence scores, and specialist verification statuses.

Nearby Hospitals: Geolocation-based facility search using the geolocator and url_launcher packages with one-tap SOS emergency dialing.

Authentication: Secure account management and social sign-in via Firebase Authentication.

🏗️ System Architecture
MedGuardian operates across a hybrid architecture connecting the patient mobile frontend, backend cloud infrastructure, deep learning inference models, and the physician web portal:

[ Patient (Mobile App) ] <---> [ Firebase Auth & Firestore ] <---> [ Doctor (Web Portal) ]
          |                                                                   |
          +---> [ Local TFLite / Cloud ML Models ] <--------------------------+
          |
          +---> [ Gemini API / Groq LLM ]
          
📱 Mobile Application
Built using Flutter and the BLoC pattern for reactive state management. Supports local TFLite execution, camera/gallery image picking, real-time Firestore stream subscriptions, and background notification scheduling.

💻 Doctor Web Portal

Developed using React, TypeScript, and Tailwind CSS. Allows specialists to:

Authenticate and manage active clinical availability.

Review pending AI predictions alongside uploaded MRI/CT/Mammography images.

Confirm or modify diagnoses and sign off on verification tickets.

Issue personalized medication treatment plans synchronized to the patient's mobile device.

🧠 AI Models
- Brain Tumor
- Breast Cancer
- Lung Cancer
- YOLOv8
- EfficientNetV2B0
- VGG16

📂 Project Structure

🛠️ Tech Stack

📊 Datasets

🚀 Installation

📷 Screenshots

🔮 Future Work

👥 Authors

📄 License
