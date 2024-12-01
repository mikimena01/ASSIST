![Logo](logo.png)

<p align="center">
  <strong>A</strong>utomated 
  <strong>S</strong>upport 
  <strong>S</strong>ystem for 
  <strong>I</strong>ntegrated 
  <strong>S</strong>mart 
  <strong>T</strong>riage
</p>

## Overview
The Automated Support System for Integrated Smart Triage is designed to provide an easy-to-use mobile application (available on Android and iOS) that simplifies the triage process.

## Features
- **Barcode Scanning**: Users can scan the barcode on the back of their health card to begin the triage process.
- **Chatbot Assistance**: Initiate a chat with our chatbot, RAG. By recognizing the provided tax code, RAG can answer all questions related to the patient's medical history.
- **Chat Management**: All chats can be saved, archived, and consulted within the app for future reference.

## How It Works
1. **Scan Health Card**: Use the app to scan the barcode on the back of your health card.
2. **Start Chat**: Begin a conversation with RAG, our intelligent chatbot.
3. **Get Information**: RAG will use the scanned tax code to access and provide relevant medical history information.
4. **Save and Archive**: Save and archive all chat sessions for later review and consultation.

## Usage
1. Open the Colab project and upload the PDFs files in the content section.
2. Run notebook from the start, using a CUDA enabled GPU with at least 10 GB of Memory and substituiting your API keys in the first cell.
3. Open the flutter project and navigate to /lib/chat_page.dart at line 41.
4. Substitute the generated link by Fast API inside the variable "baseUrl".
5. Connect your phone to the pc and run "flutter run" command on your project terminal; the app will display on your mobile device in debug mode.
6. Scan the barcode on the health card.
7. Start chatting with RAG and ask any questions regarding patient medical history.
8. Save and archive the chat sessions as needed.


