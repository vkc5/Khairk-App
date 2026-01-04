IT8108 Group Project Implementation 
Community-Based Food Donation App: Khairk – خيرك
Section 1, Group 2
---------------------------------------------------
Group Members
---------------------------------------------------
1. Batool AlBonni - 202301567
2. Maryam Sarhan - 202200553
3. Noora Thabet - 202202341
4. Mohammed Alhalal - 202200670
5. Ali Hani Aljassas - 202202536
6. Yusuf Qasim - 202201329

-----------------------------------------------------------------
GitHub Link
-----------------------------------------------------------------
GitHub Link for the app: 
https://github.com/vkc5/Khairk-App.git

-----------------------------------------------------------------
Main Features
-----------------------------------------------------------------
User Registration & Role-Based Authentication 
- Developer: Mohammed Alhalal 
- Tester: Noora Thabet

Profile Management & Settings 
- Developer: Mohammed Alhalal 
- Tester: Noora Thabet

Food Donation Creation & Submission 
- Developer: Maryam Sarhan 
- Tester: Batool Albonni

Donation Tracking & Monitoring  
- Developer: Maryam Sarhan 
- Tester: Batool Albonni

Pickup Management & Collection Tracking  
- Developer: Ali Aljassas 
- Tester: Yusuf Qasim

NGO Case Creation & Management 
- Developer: Ali Aljassas 
- Tester: Yusuf Qasim

Interactive Map with NGO Locations 
- Developer: Mohammed Alhalal 
- Tester: Noora Thabet

NGO Discovery & Exploration 
- Developer: Noora Thabet 
- Tester: Maryam Sarhan

NGO Verification and User Account Management 
- Developer: Batool AlBonni  
- Tester: Maryam Sarhan

User Management Dashboard 
- Developer: Noora Thabet 
- Tester: Maryam Sarhan

Notification System and Communication 
- Developer: Batool AlBonni 
- Tester: Mohamed Alhalal

Rewards System 
- Developer: Yusuf Qasim 
- Tester: Batool Albonni

History Tracking 
- Developer: Batool Albonni 
- Tester: Mohamed Alhalal

NGOs Case Discovery & Exploration 
- Developer: Yusuf Qasim 
- Tester: Noora Thabet

Leaderboard & Ranking System 
- Developer: Noora Thabet 
- Tester: Ali Hani Aljassas 

Donation Group / Recurring Donation Schedules 
- Developer: Maryam Sarhan 
- Tester: Ali Aljassas

Community Impact Dashboard 
- Developer: Yusuf Qasim 
- Tester: Noora Thabet

Advanced Search with Multiple Filters 
- Developer: All members 
- Tester: All members

-----------------------------------------------------------------
Design changes
-----------------------------------------------------------------
- Replaced custom-designed alert with Apple’s alert (UIAlertController), becomes custom alert implementations caused layout issues across different screen sizes and iOS versions

-----------------------------------------------------------------
Libraries, Packages, External code implementations Referenced
-----------------------------------------------------------------
- UIKit: used for designing the frontend of the app using storyboards in addition to view controllers and UI component

- MapKit: used To display maps, user locations, pins, and location-based features within the app such as view detailed in the map

- Firebase Firestore: used as cloud-based NoSQL database for application data storage

- Firebase Authentication: used for user registration, login, and authentication management.

- Firebase Storage: used to upload, store data

- UserNotifications Framework: used to schedule, and manage local and push notifications

- Firebase App check: used to protect backend resources by ensuring requests originate from authentic

- Firebase Anylytis: used to collect usage data and analyze user behavior to improve application performance and user experience

-----------------------------------------------------------------
Setup the project 
-----------------------------------------------------------------
1. Install Xcode (Xcode 16.4 or later)
2. Clone the project repository from GitHub: https://github.com/vkc5/Khairk-App.git
```
git clone https://github.com/vkc5/Khairk-App.git
```
3. Open to the project folder (.xcodeproj file using Xcode)
4. Choose a simulator or device
5. Run the application so the application will build and launch automatically
6. Permissions:
	- Allow location access for MapKit features
	- Allow notification permissions for User Notifications when prompted

-----------------------------------------------------------------
Simulators
-----------------------------------------------------------------
iPhone 16 is the simulators used for testing the application 

-----------------------------------------------------------------
Simulators
-----------------------------------------------------------------
Donor
- email:Ali@gmail.com
- password:asdasd

NGO
- email:foodbank@gmail.com
- password:123123

Admin
- email:Sara@gmail.com
- password:asdasd
