![image](https://github.com/user-attachments/assets/60e95958-1e7c-4853-b203-1ffc249e3991)

MDH CAS is a mod, created by Moerderhoschi for Arma 3. You are able to call in an CAS Strike.

HOW THE ADDON WORKS?
The addon automatically add an Actionmenu entry to call in the CAS Strike.

IS THE ADDON MP COMPATIBLE?
Yes, call it and use it like in SP.

CAS call in action menue only with specific item:
- mdhCASModNeededItemToCall= "B_UavTerminal"

CAS call in action menue entry only on specific object(use unit variable name or unit init):
- mdhCASModCallerObj1
- mdhCASModCallerObj2
- mdhCASModCallerObj3
- mdhCASModCallerObj4
- mdhCASModCallerObj5
(or if you want that only one specific player with the variable name p1 get the action)
- if(!isNil"p1" and {player == p1}) then {mdhCASModCallerObj1= player} else {mdhCASModCallerObj1= "logic" createVehicleLocal [0,0,-50]}

Dowload on Steam: https://steamcommunity.com/sharedfiles/filedetails/?id=3473212949

CREDITS
Armed-Assault.de Crew - For many great ArmA moments in many years
BIS - For ArmA3

You like my mod? Check out my other Mods: [Arma 3 Mods created by Moerderhoschi](https://steamcommunity.com/sharedfiles/filedetails/?id=3408421250)
