 -------------------------------------------
| It's A Trap! for iOS                      |
| Jiatao Cheng, Carlton Keedy, Quinn Radich
| Adam Canady

| CS 342: Mobile App Development            |
| Wednesday, June 4, 2014                   |
 -------------------------------------------

About This Project (A brief description of the project.)
------------------

The end-goal for this project was to have an app with which users can plant/remove/activate traps in a map-based game. A user 
plants traps on a map that are hidden from other users, and whenever another user activates the trap by "stepping on it", the 
user that placed the trap gets a certain number of points. All user/trap information is stored in a server. 


Project Status     (Current bugs and future work)
------------------


Current Bugs:
- None that we know of

Future Work: 
- User tutorial upon first time log-in 
- Push notifications from back-end 



Getting Started
------------------ (Make it as easy as possible for me to build and use your app.)
The app should build straight from the project, EXCEPT if it cannot find the GooglePlus files. To fix this problem, simply
remove the references under Frameworks in the left most panel, and then drag and drop the files in the GoogleSDK 
folder (My-Face-iOS/It's A Trap/GoogleSDK) into the project and re-build the project. Then log-in with Facebook and continue. 


TO-DO
-----
- test on an iPhone, if possible (meh)
- implement death
- more interesting countdown to renewed sweep availability
- all we can show is that score has gone up due to trapping an enemy

DONE
------
- display user's score at top of screen
- make sweep button look better
- fix crash-on-removing-trap-loaded-from-backend
- clarify that the count is your mines
- cool down for sweep
- Facebook Login 


DELIVERY
Make sure Jeff has access to the repo, and that the main branch's latest commit is the version you want to submit. I want to do "git clone your-url", read readme.txt, open the project in Xcode, and run it.

Repo should include:
- All source code, data, and project files required to run and test the app.
- I don't want to install any new tools, so include any external libraries you use in your repo.

