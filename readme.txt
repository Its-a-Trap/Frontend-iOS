 -------------------------------------------
| It's A Trap! for iOS                      |
| Adam Canady    Jiatao Cheng               |
| Carlton Keedy  Quinn Radich               |
| CS 342: Mobile App Development            |
| Wednesday, June 4, 2014                   |
 -------------------------------------------

About This Project
------------------
The end-goal for this project was to have an app with which users can plant/remove/activate traps in a map-based game. A user 
plants traps on a map that are hidden from other users, and whenever another user activates the trap by "stepping on it", the 
user that placed the trap gets a certain number of points. All user/trap information is stored in a server. 


Project Status
--------------
Current Bugs:
  - None that we know of, but we haven't tested on-to-move location updating as much as we would have liked

Future Work: 
  - User tutorial upon first time log-in
  - Push notifications from back-end
  - Make everything prettier, more engaging


Getting Started
---------------
The app should build straight from the project, EXCEPT if it cannot find the GooglePlus files. To fix this problem, simply
remove the references under Frameworks in the left most panel, and then drag and drop the files in the GoogleSDK 
folder (My-Face-iOS/It's A Trap/GoogleSDK) into the project and re-build the project. Then log-in with Facebook and continue. 

