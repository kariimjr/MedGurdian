# MedGuardian
<img width="227" height="227" alt="MedGLogo" src="https://github.com/user-attachments/assets/2ef991c6-da50-4f78-9f5c-8c5bd7d504d0" />


Introduction

An integrated deep learning-based healthcare platform for automated multi-class cancer detection (Brain, Breast, and Lung) using medical imaging (MRI, Mammography, and CT scans), paired with a Flutter mobile application and a React doctor portal.

✨ Features

- AI Cancer Detection: Multi-class automated detection and classification for Brain Tumors (Glioma, Meningioma, Pituitary, Normal), Breast Cancer (Benign, Malignant), and Lung Cancer (Malignant, Benign, Normal) directly within the mobile application.
- Medical Report Summarizer: AI-driven text extraction from uploaded PDF reports (via Syncfusion PDF and Llama 3.1 8B via Groq API) that translates complex clinical terms into simplified summaries.
- AI Medical Assistant: Conversational health guidance interface powered by Google Gemini 2.5 Flash Lite using google_generative_ai.
- Medication Reminder: Scheduled dose tracking, type selection (pills, syrups, injections), and progress monitoring powered by real-time Firebase Firestore streams.
- Doctor Portal: Supplementary React-based dashboard enabling verified medical professionals to review scans, confirm/modify AI diagnostic predictions, and push action plans directly to patient devices.
- Patient-Doctor Chat: Real-time synchronized messaging connecting patients with assigned specialists.
- Scan History: Persistent historical tracking of previous scans, model confidence scores, and specialist verification statuses.
- Nearby Hospitals: Geolocation-based facility search using the geolocator and url_launcher packages with one-tap SOS emergency dialing.
- Authentication: Secure account management and social sign-in via Firebase Authentication.

🏗️ System Architecture

MedGuardian operates across a hybrid architecture connecting the patient mobile frontend, backend cloud infrastructure, deep learning inference models, and the physician web portal:

<img width="1235" height="629" alt="image" src="https://github.com/user-attachments/assets/d4679a46-a71d-41a2-ac7a-22bee8641d1b" />
     
📱 Mobile Application

Built using Flutter and the BLoC pattern for reactive state management. Supports local TFLite execution, camera/gallery image picking, real-time Firestore stream subscriptions, and background notification scheduling.

💻 Doctor Web Portal

1) Developed using React, TypeScript, and Tailwind CSS. Allows specialists to:
2) Authenticate and manage active clinical availability.
3) Review pending AI predictions alongside uploaded MRI/CT/Mammography images.
4) Confirm or modify diagnoses and sign off on verification tickets.
5) Issue personalized medication treatment plans synchronized to the patient's mobile device.

🧠 AI Models

1) Brain Tumor:
- EfficientNetV2B0: Fine-tuned on 7,200 MRI images for 4-class classification (Glioma, Meningioma, Pituitary, No Tumor). Accuracy: 93.06%.
- YOLOv8m: Trained on Roboflow MRI bounding-box dataset. Accuracy: 81.10%.

2) Breast Cancer:
- VGG16: Transfer learning on 3,383 mammograms for binary classification (Benign vs. Malignant). Accuracy: 82.72%.
- YOLOv8m: Trained on 1,642 mammography scans. Accuracy: 92.70%.

3) Lung Cancer:
- EfficientNetV2B0: Trained on 1,053 CT scans for 3-class classification (Malignant, Benign, Normal). Accuracy: 86.92%.
- YOLOv8m: Object detection pipeline on CT scans. Accuracy: 80.60%.

🛠️ Tech Stack

- Mobile: Flutter, Dart, BLoC Pattern
- Web Portal: React, TypeScript, Tailwind CSS
- Backend Services: Firebase (Auth, Cloud Firestore, Storage)
- AI & ML Frameworks: TensorFlow, Keras, PyTorch, Ultralytics YOLOv8, TensorFlow Lite
- LLMs & APIs: Google Gemini 2.5 Flash Lite, Groq API (Llama 3.1 8B)

📊 Datasets

Brain MRI Dataset: Masoud Nickparvar (Kaggle, 7,200 images) & Roboflow (brain-tumor-aeizh, 3,063 images).
Breast Mammogram Dataset: Hayder17 (Kaggle, 3,383 images) & Roboflow (breastcancer-yolov8, 1,642 images).
Lung CT Dataset: Roboflow Universe (lung-cancer-mz4fj, 1,053 CT scan images).

📷 Screenshots
<img width="293" height="593" alt="image" src="https://github.com/user-attachments/assets/f8580142-d774-4715-9b78-242dad2599d7" />
<img width="294" height="595" alt="image" src="https://github.com/user-attachments/assets/374a6dee-4d42-47d1-bc64-52786ec4a834" />
<img width="284" height="609" alt="image" src="https://github.com/user-attachments/assets/21de4cea-fb02-4a08-8ced-70dc0c438076" />
<img width="277" height="595" alt="image" src="https://github.com/user-attachments/assets/52782a9f-754f-41ba-b081-b1c1622c2605" />
<img width="1598" height="900" alt="image" src="https://github.com/user-attachments/assets/7ac9677a-b3e2-4747-8a18-40f354bd53b6" />

🔮 Future Work

- Integration of 3D volumetric MRI/CT scan models to capture tumor depth and surrounding tissue relations.
- Integration of Explainable AI (XAI) heatmaps (such as Grad-CAM or Eigen-CAM) directly into the UI to increase model transparency for clinicians.
- Deployment of lightweight Vision Transformer (ViT) edge architectures for on-device inference.
- Large-scale clinical validation trials and hospital system integrations.

👥 Authors
1) Ahmed Samir - Computer Engineering, The British University in Egypt
2) Karim Mohamed - Computer Engineering, The British University in Egypt
3) Mohamed Ali - Computer Engineering, The British University in Egypt
4) Steve Safwat - Computer Engineering, The British University in Egypt
5) Zeyad Ahmed - Computer Engineering, The British University in Egypt
