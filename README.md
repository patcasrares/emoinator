# Emoinator

Aplicație Flutter pentru detectarea emoțiilor.

## Introducere

Succesul sau eșecul unei aplicații interactive este determinat de utilizabilitatea produsului. Una din componentele utilizabilității este satisfacția utilizatorului. Evaluarea satisfacției pentru utilizatorii adulți se realizează prin observație, interviuri post-interacțiune sau metode cantitative (chestionare) care însă nu pot fi aplicate copiilor preșcolari, care au capacitate limitată de autoanaliză și de comunicare, nu pot citi și nu pot scrie. Astfel, pe lângă observație (care poate fi subiectivă, depinzând de modul de interpretare a reacțiilor preșcolarului de către expertul care realizează aplicația), se dorește o măsurare obiectivă a emoțiilor pe care le trăiesc copiii în timpul interacțiunii. Pentru aceasta este nevoie de dezvoltarea unei aplicații care să permită identificarea stărilor emoționale ale unui preșcolar în timpul derulării unei activități.

Pentru o analiză cât mai completă, identificarea stărilor emoționale trebuie făcută într-o manieră cât mai obiectivă, bazată pe numere și calcule rezultate dintr-un proces de învățare elaborat; în același timp, această identificare trebuie făcută in timp real. Ca aceste două aspecte să fie îndeplinite, conceperea analizei ar implica supravegherea constantă de către un specialist cu experiență, care să monitorizeze stările emoționale ale preșcolarilor, implicație care aduce cu sine costuri foarte mari atât financiare, cât și din punctul de vedere al resurselor umane. Aceste costuri și resurse pot fi reduse prin folosirea unei aplicații care să înglobeze un proces automat de monitorizare a stărilor emoționale prin utilizarea metodologiilor inteligenței artificiale.

Ceea ce își propune Emoinator este livrarea unei aplicații pe dispozitivele mobile care să identifice preșcolarul, să îi identifice stările emoționale din diferite surse (audio, video) care ne pot sugera care sunt emoțiile lui la un moment dat iar apoi să salveze aceste date pentru a fi ușor de analizat de către profesorul care coordonează grupul de preșcolari. Pe baza analizei, persoana responsabilă poate decide care a fost impactul activității asupra copiilor și îmbunătăți modul de organizare a viitoarelor activități pentru a maximiza impactul pozitiv si a face experiența cât mai plăcută pentru participanți.

## Setup

### _Aplicația Flutter_

Pentru a rula aplicația, în afară de o versiune
de [Flutter](https://flutter.dev/docs/get-started/install) instalată, este nevoie
de [OpenCV pentru Android](https://sourceforge.net/projects/opencvlibrary/files/4.4.0/opencv-4.4.0-android-sdk.zip/download)
(momentan, aplicația nu suportă IOS) și Android NDK (instalat din SDK Manager). După extragerea arhivei de OpenCV, setați
în [android/CmakeLists.txt](./FlutterApp/Emoinator/android/CmakeLists.txt) variabila `OPENCV_BASE_DIR`
cu locația absolută a folderului extras (separatorul trebuie să fie `/`). 

Aplicația folosește o bază de date Firebase Cloud Firestore, pentru care fișierul de
configurație (`google-services.json`) trebuie amplasat în proiect conform instrucțiunilor
din [Firebase Console](https://console.firebase.google.com/project/_/overview).

Aplicația poate apoi fi pornită pe un dispozitiv Android ARM, folosind Flutter CLI /
Android Studio / VS Code.

### _Serverul Flask pentru recunoașterea emoțiilor din voce_
Pachete necesare în Python:
- flask
- keras
- pandas
- librosa
- numpy
- sklearn
- pickle
- wave

Pentru a putea face apeluri din aplicația Flutter, modificați în aplicație, în [app.config.dart](./FlutterApp/Emoinatorlib/config/app.config.dart), `serverUrl` cu adresa și portul de la care se poate accesa serverul.
## [Mai multe detalii](./Raport/RAPORT.pdf)