///////////////////////////////////////////////////////////////////////////////////////////////////
// MDH CAS MOD(by Moerderhoschi) - v2025-08-20
// github: https://github.com/Moerderhoschi/arma3_mdhCAS
// steam mod version: https://steamcommunity.com/sharedfiles/filedetails/?id=3473212949
///////////////////////////////////////////////////////////////////////////////////////////////////
if (missionNameSpace getVariable ["pMdhCAS",99] == 99) then
{
	0 spawn
	{
		_valueCheck = 99;
		_defaultValue = 99;
		_path = 'mdhCAS';
		_env  = hasInterface;

		_diary   = 0;
		_mdhFnc  = 0;
		call compile preprocessFileLineNumbers "mdhCAS\mdhBlackfishAI.sqf";

		missionNameSpace setVariable ["mdhFncCASweapons",
		{
			_weaponTypes = ["machinegun","bomblauncher","missilelauncher","rocketlauncher","vehicleweapon","horn","cannon"];
			_weapons = [];
			_missilelauncherAT = [];
			_missilelauncherAA = [];
			_weaponsSorted = [0,0,0,0]; // MG,BOMB,ROCKET,NAPALM
			_weaponsFiltered = [];
			{
				if (configname(configfile >> "CfgWeapons" >> _x) == "") then {systemChat (_x + " not found in current loaded mods!")};
				_type = toLowerANSI((_x call bis_fnc_itemType) select 1);
				if !(_type in _weaponTypes) then {_weaponsFiltered pushBackUnique _x};
				if(_type in _weaponTypes) then
				{
					if (_x in ["rhs_weap_DummyLauncher","vn_fuel_mig19_launcher"]) exitWith {_weaponsFiltered pushBackUnique _x};
					_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
					if (count _modes == 0) then {_weaponsFiltered pushBackUnique _x};
					if (count _modes > 0) then
					{
						_mode = _modes select 0;
						if (_mode == "this") then {_mode = _x};
						_w = _x;
						{
							if (configname(configfile >> "CfgMagazines" >> _x) == "" && {!("flare" in toLowerANSI(_x))} && {!("chaff" in toLowerANSI(_x))}) then {systemChat (_x + " not found in current loaded mods!")};
							if (_x in compatibleMagazines _w) then
							{
								_ammo = gettext(configfile >> "CfgMagazines" >> _x >> "ammo");
								_irLock = getNumber(configFile >> "CfgAmmo" >> _ammo >> "irLock");
								_canLock = getNumber(configFile >> "CfgWeapons" >> _w >> "canLock");
								_airLock  = getNumber(configFile >> "CfgAmmo" >> _ammo >> "airLock");
								_lockType = getNumber(configFile >> "CfgAmmo" >> _ammo >> "lockType");
								_laserLock = getNumber(configFile >> "CfgAmmo" >> _ammo >> "laserLock");
								_newSensors = configName(configfile >> "CfgAmmo" >> _ammo >> "Components" >> "SensorsManagerComponent" >> "Components");
								_autoSeekTarget = getNumber(configFile >> "CfgAmmo" >> _ammo >> "autoSeekTarget");

								if (_ammo isKindOf "BulletBase" OR _ammo isKindOf "SubmunitionBase" && {_type == "machinegun"}) exitWith
								{
									_weapons set [count _weapons,[_w,_mode]];
									if (typename(_weaponsSorted#0)=="SCALAR") then
									{
										_weaponsSorted set [0,[[_w,_mode]]];
									}
									else
									{
										(_weaponsSorted#0) pushBackUnique [_w,_mode];
									};
								};

								if (_ammo isKindOf "BombCore") exitWith
								{
									_weapons set [count _weapons,[_w,_mode]];
									if (_w in ["vn_bomb_blu1b_500_fb_launcher","vn_bomb_blu1b_750_fb_launcher"]) exitWith
									{
										if (typename(_weaponsSorted#3)=="SCALAR") then
										{
											_weaponsSorted set [3,[[_w,_mode]]];
										}
										else
										{
											(_weaponsSorted#3) pushBackUnique [_w,_mode];
										};															
									};

									if (typename(_weaponsSorted#1)=="SCALAR") then
									{
										_weaponsSorted set [1,[[_w,_mode]]];
									}
									else
									{
										(_weaponsSorted#1) pushBackUnique [_w,_mode];
									};
								};

								if (_ammo isKindOf "MissileBase" && {_canLock == 0 OR _canLock == 2 && {_newSensors == ""}} && {_airLock == 0} && {_autoSeekTarget == 0} && {_laserLock == 0} && {_irLock == 0}) exitWith
								{
									_weapons set [count _weapons,[_w,_mode]];
									if (typename(_weaponsSorted#2)=="SCALAR") then
									{
										_weaponsSorted set [2,[[_w,_mode]]];
									}
									else
									{
										(_weaponsSorted#2) pushBackUnique [_w,_mode];
									};
								};

								if (_ammo isKindOf "MissileBase" && {_canLock == 2} && {_airLock < 2} && {_autoSeekTarget == 1 OR _laserLock == 1 OR _irLock == 1 OR _newSensors != ""}) exitWith
								{
									_weapons set [count _weapons,[_w,_mode]];
									_missilelauncherAT pushBackUnique _w;
								};

								if (_ammo isKindOf "MissileBase" && {_airLock > 0} && {_autoSeekTarget == 1 OR _laserLock == 1 OR _irLock == 1 OR _newSensors != ""}) exitWith
								{
									_weapons set [count _weapons,[_w,_mode]];
									_missilelauncherAA pushBackUnique _w;
								};

								if (_ammo isKindOf "RocketBase") exitWith
								{
									_weapons set [count _weapons,[_w,_mode]];
									if (typename(_weaponsSorted#2)=="SCALAR") then
									{
										_weaponsSorted set [2,[[_w,_mode]]];
									}
									else
									{
										(_weaponsSorted#2) pushBackUnique [_w,_mode];
									};
								};
								_weaponsFiltered pushBackUnique _w;
							};
						} foreach (if (count _planeMagazines == 0) then {(_planeClass call BIS_fnc_magazinesEntityType)} else {_planeMagazines});
					};
				};
			} foreach (if (count _planeWeapons == 0) then {(_planeClass call bis_fnc_weaponsEntityType)} else {_planeWeapons});
			if (profileNameSpace getVariable ["mdhCASModDebug",false]) then 
			{
				hintSilent
				(
					"MDH CAS DEBUGINFO"
					+"\n\nPlane:"+(getText(configfile >> "CfgVehicles" >> _planeClass >> "displayName"))
					+"\n\nMG:"+(if(typename(_weaponsSorted#0)=="ARRAY")then{_tx=[];{_tx pushBackUnique(_x#0)}forEach(_weaponsSorted#0);str(_tx)}else{""})
					+"\n\nBOMB:"+(if(typename(_weaponsSorted#1)=="ARRAY")then{_tx=[];{_tx pushBackUnique(_x#0)}forEach(_weaponsSorted#1);str(_tx)}else{""})
					+"\n\nROCKET:"+(if(typename(_weaponsSorted#2)=="ARRAY")then{_tx=[];{_tx pushBackUnique(_x#0)}forEach(_weaponsSorted#2);str(_tx)}else{""})
					+"\n\nMissileAT:"+str(_missilelauncherAT)
					+"\n\nMissileAA:"+str(_missilelauncherAA)
					+"\n\nNAPALM:"+(if(typename(_weaponsSorted#3)=="ARRAY")then{_tx=[];{_tx pushBackUnique(_x#0)}forEach(_weaponsSorted#3);str(_tx)}else{""})
					+"\n\nFILTER:"+str(_weaponsFiltered)
				);
			};
		}];

		if (hasInterface) then
		{
			_diary =
			{
				waitUntil {!(isNull player)};
				_c = true;
				_t = "MDH CAS";
				if (player diarySubjectExists "MDH Mods") then
				{
					{
						if (_x#1 == _t) then {_c = false}
					} forEach (player allDiaryRecords "MDH Mods");
				}
				else
				{
					player createDiarySubject ["MDH Mods","MDH Mods"];
				};
		
				if(_c) then
				{
					mdhCASBriefingFnc =
					{
						if (_this#0 == "mdhCASModCallOverModTab") exitWith
						{
							_code = 0;
							if (profileNameSpace getVariable["mdhCASModBlackfishSelected",0] == 0) then
							{
								_code = missionNameSpace getVariable["mdhCASCode",0];
							}
							else
							{
								_code = missionNameSpace getVariable["mdhCASCodeBlackfish",0];
							};

							if (typename _code == "SCALAR") exitWith {systemChat "mdhCASCode not found"};
							if !(player in (missionNameSpace getVariable ["mdhCASAllowedCaller",[]])) exitWith {systemChat "player not in allowed MDH CAS caller"};
							_f = if (!isNil'mdhCASModNeededItemToCall')then
							{
								mdhCASModNeededItemToCall in
								(
									itemsWithMagazines player 
									+ assignedItems [player, true, true] 
									+ weapons player 
									+ primaryWeaponItems player 
									+ secondaryWeaponItems player 
									+ handgunItems player
								)
							}
							else
							{
								true
							};
							if !(_f) exitWith {systemChat ('player has not needed item for MDH CAS call "'+mdhCASModNeededItemToCall+'"')};
							_t = missionNameSpace getVariable['mdhCASModCallTime',time - 1];
							if (_t > time) exitWith
							{
								_t = round(_t - time);
								systemChat ("MDH CAS cooldown " + str(_t) + " sec" + (if (_t > 180) then {" / " + str(round((_t/60) * 100) / 100) + " min"} else {""}));
							};

							[player] call _code;
						};

						if ((_this#0) == "mdhCASModCallMode" && {(_this#1) in [4,5]}) then
						{
							profileNameSpace setVariable["mdhCASModBlackfishSelected",0];
						};

						profileNameSpace setVariable[_this#0,_this#1];
						systemChat (_this#2);
						
						if (_this#0 == "mdhCASModTimeout") then
						{
							_t = missionNameSpace getVariable['mdhCASModCallTime',time - 1];
							if (_t > time && {(time + (_this#1)) < _t}) then
							{
								_t = time + (_this#1);
								missionNameSpace setVariable['mdhCASModCallTime', _t];
								_t = round(_t - time);
								systemChat ("MDH CAS cooldown " + str(_t) + " sec" + (if (_t > 180) then {" / " + str(round((_t/60) * 100) / 100) + " min"} else {""}));
							};
						};

						if ((_this#0) == "mdhCASModPlaneType") then
						{
							if ((_this#1) == 9) then
							{
								profileNameSpace setVariable["mdhCASModBlackfishSelected",1];
								if (profileNameSpace getVariable["mdhCASModCallMode",0] in [4,5]) then
								{
									profileNameSpace setVariable["mdhCASModCallMode",0];
								};
							}
							else
							{
								profileNameSpace setVariable["mdhCASModBlackfishSelected",0];
								_a = (profileNameSpace getVariable [("mdhCASPlane" + str(side group player) + str(_this#1)),0]);
								if (typename _a == "SCALAR") exitWith {systemChat "no saved planeconfig found!"; systemChat "using Arma 3 standard plane!"};
	
								_t = getText(configfile >> "CfgVehicles" >> (_a#0) >> "displayName");
								if (_t == "") exitWith {systemChat ((_a#0)+" not found in current loaded mods!"); systemChat "using Arma 3 standard plane!"};
	
								_planeClass = _a#0;
								_planeWeapons = _a#3;
								_planeMagazines = _a#4;
								_weapons = 0;
								call (missionNameSpace getVariable["mdhFncCASweapons",{systemChat "mdhFncCASweapons not found!"}]);
	
								_w = [];
								{
									_tx = getText(configfile >> "CfgWeapons" >> (_x#0) >> "displayName");							
									_w pushBackUnique _tx;
								} forEach _weapons;
	
								{
									if (_x != "") then {_t = _t + " /// " + _x};
								} forEach _w;
							};
							systemChat _t;
						};
					};

					player createDiaryRecord
					[
						"MDH Mods",
						[
							_t,
							(
								'<br/>MDH CAS is a mod created by Moerderhoschi for Arma 3. (v2025-08-20)<br/>'
							+ '<br/>'
							+ 'you are able to call in an CAS Strike.<br/>'
							+ '<br/>'
							+ 'MDH CAS Modoptions:'
							+ '<br/><br/>'
							+ 'Set language for CAS Strike: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModVoicelanguage'',1,''MDH CAS Voicelanguage always BLUFOR english activated''] call mdhCASBriefingFnc">BLUFOR english</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModVoicelanguage'',2,''MDH CAS Voicelanguage Arma 3 side standard activated''] call mdhCASBriefingFnc">Arma 3 side standard</execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModVoicelanguage'',0,''MDH CAS Voicelanguage deactivated''] call mdhCASBriefingFnc">deact</execute></font color>'
							//+ '<br/><br/>'
							//+ 'Use MapMarker with CAS in name for next CAS Strike: '
							//+    '<font color="#33CC33"><execute expression = "[''mdhCASModMapLocation'',1,''MDH CAS for MapMarker activated''] call mdhCASBriefingFnc">activate</execute></font color>'
							//+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMapLocation'',0,''MDH CAS for MapMarker deactivated''] call mdhCASBriefingFnc">deactivate</execute></font color>'
							//+ '<br/><br/>'
							//+ 'Use RedSmoke near player for next CAS Strike: '
							//+    '<font color="#33CC33"><execute expression = "[''mdhCASModSmoke'',1,''MDH CAS RedSmoke activated''] call mdhCASBriefingFnc">activate</execute></font color>'
							//+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModSmoke'',0,''MDH CAS RedSmoke deactivated''] call mdhCASBriefingFnc">deactivate</execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS debug mode: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModDebug'',true,''MDH CAS Debug mode activated''] call mdhCASBriefingFnc">activate</execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModDebug'',false,''MDH CAS Debug mode deactivated''] call mdhCASBriefingFnc">deactivate</execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS actionmenu entry for call: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModActionmenu'',true,''MDH CAS Actionmenu entry for call activated''] call mdhCASBriefingFnc">activate</execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModActionmenu'',false,''MDH CAS Actionmenu entry for call deactivated''] call mdhCASBriefingFnc">deactivate</execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS actionmenu entry for save plane: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModActionmenu2'',true,''MDH CAS Actionmenu entry for save plane activated''] call mdhCASBriefingFnc">activate</execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModActionmenu2'',false,''MDH CAS Actionmenu entry for save plane deactivated''] call mdhCASBriefingFnc">deactivate</execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS timeout minutes: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',30,''MDH CAS Timeout set to 30 sec''] call mdhCASBriefingFnc"> 0.5 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',60,''MDH CAS Timeout set to 1 min''] call mdhCASBriefingFnc"> 1 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',180,''MDH CAS Timeout set to 3 min''] call mdhCASBriefingFnc"> 3 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',300,''MDH CAS Timeout set to 5 min''] call mdhCASBriefingFnc"> 5 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',600,''MDH CAS Timeout set to 10 min''] call mdhCASBriefingFnc"> 10 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',900,''MDH CAS Timeout set to 15 min''] call mdhCASBriefingFnc"> 15 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',1200,''MDH CAS Timeout set to 20 min''] call mdhCASBriefingFnc"> 20 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',1800,''MDH CAS Timeout set to 30 min''] call mdhCASBriefingFnc"> 30</execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS arrival time in sec: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',3,''MDH CAS arrival time set to 3 sec''] call mdhCASBriefingFnc"> 3 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',15,''MDH CAS arrival time set to 15 sec''] call mdhCASBriefingFnc"> 15 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',30,''MDH CAS arrival time set to 30 sec''] call mdhCASBriefingFnc"> 30 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',45,''MDH CAS arrival time set to 45 sec''] call mdhCASBriefingFnc"> 45 </execute></font color>'
							+ ' in min: '
							+ '<font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',60,''MDH CAS arrival time set to 1 min''] call mdhCASBriefingFnc"> 1 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',120,''MDH CAS arrival time set to 2 min''] call mdhCASBriefingFnc"> 2 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',180,''MDH CAS arrival time set to 3 min''] call mdhCASBriefingFnc"> 3 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',240,''MDH CAS arrival time set to 4 min''] call mdhCASBriefingFnc"> 4 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',300,''MDH CAS arrival time set to 5 min''] call mdhCASBriefingFnc"> 5 </execute></font color>'
							+ '<br/><br/>'
							+ 'Set minDistance to friendly players for CAS target in meter: '
							+    '<font color="#CC0000"><execute expression = "[''mdhCASModMinDistance'',25,''MDH CAS min distance set to 25 meter''] call mdhCASBriefingFnc"> 25 </execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModMinDistance'',50,''MDH CAS min distance set to 50 meter''] call mdhCASBriefingFnc"> 50 </execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModMinDistance'',75,''MDH CAS min distance set to 75 meter''] call mdhCASBriefingFnc"> 75 </execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModMinDistance'',100,''MDH CAS min distance set to 100 meter''] call mdhCASBriefingFnc"> 100 </execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModMinDistance'',125,''MDH CAS min distance set to 125 meter''] call mdhCASBriefingFnc"> 125 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',150,''MDH CAS min distance set to 150 meter''] call mdhCASBriefingFnc"> 150 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',200,''MDH CAS min distance set to 200 meter''] call mdhCASBriefingFnc"> 200</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',250,''MDH CAS min distance set to 250 meter''] call mdhCASBriefingFnc"> 250</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',300,''MDH CAS min distance set to 300 meter''] call mdhCASBriefingFnc"> 300</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',350,''MDH CAS min distance set to 350 meter''] call mdhCASBriefingFnc"> 350</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',400,''MDH CAS min distance set to 400 meter''] call mdhCASBriefingFnc"> 400</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',450,''MDH CAS min distance set to 450 meter''] call mdhCASBriefingFnc"> 450</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',500,''MDH CAS min distance set to 500 meter''] call mdhCASBriefingFnc"> 500</execute></font color>'
							+ '<br/><br/>'
							+ 'Set behaviour when no red smoke found: '
							+    '<font color="#CC0000"><execute expression = "[''mdhCASModNoRedSmokeThenAbort'',1,''MDH CAS no red smoke abort CAS activated''] call mdhCASBriefingFnc"> abort CAS </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModNoRedSmokeThenAbort'',0,''MDH CAS no red smoke attack nearest taget activated''] call mdhCASBriefingFnc"> attack near target </execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS planetype: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModPlaneType'',1,''MDH CAS planeType 1 activated''] call mdhCASBriefingFnc"> PLANE 1 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModPlaneType'',2,''MDH CAS planeType 2 activated''] call mdhCASBriefingFnc"> PLANE 2 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModPlaneType'',3,''MDH CAS planeType 3 activated''] call mdhCASBriefingFnc"> PLANE 3 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModPlaneType'',9,''MDH CAS Gunship activated''] call mdhCASBriefingFnc"> Gunship </execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS call mode: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',0,''MDH CAS callmode near caller activated''] call mdhCASBriefingFnc">near caller</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',4,''MDH CAS callmode Rolling CAS activated''] call mdhCASBriefingFnc">rolling CAS</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',5,''MDH CAS callmode BROKEN ARROW activated''] call mdhCASBriefingFnc">BROKEN ARROW</execute></font color>'
							+ ' /<br/>'
							+ '<font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',1,''MDH CAS callmode CAS mapMarker activated''] call mdhCASBriefingFnc">CAS mapMarker</execute></font color>'
							+ ' / red smoke: '
							+ '<font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',2,''MDH CAS callmode near red smoke near activated''] call mdhCASBriefingFnc">near </execute></font color>'
							+ '<font color="#CC0000"><execute expression = "[''mdhCASModCallMode'',3,''MDH CAS callmode direct at red smoke activated''] call mdhCASBriefingFnc">direct</execute></font color>'
							+ ' / cursortarget: '
							+ '<font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',6,''MDH CAS callmode near cursortarget activated''] call mdhCASBriefingFnc">near </execute></font color>'
							+ '<font color="#CC0000"><execute expression = "[''mdhCASModCallMode'',7,''MDH CAS callmode direct at cursortarget activated''] call mdhCASBriefingFnc">direct</execute></font color>'
							//+ '<br/><br/>'
							//+ 'Set CAS item for call: '
							//+    '<font color="#33CC33"><execute expression = "[''mdhCASModCallitem'',0,''MDH CAS item to call set none''] call mdhCASBriefingFnc">none</execute></font color>'
							//+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModCallitem'',1,''MDH CAS item to call set UAV Terminal''] call mdhCASBriefingFnc">UAV Terminal</execute></font color>'
							+ '<br/>'
							+ '<br/>'
							+ '-----------------------------------------------------------------------------------------------------'
							+ '<br/>'
							+ '<font color="#CC0000" size="40"><execute expression = "[''mdhCASModCallOverModTab'',true,''''] call mdhCASBriefingFnc">&gt;&gt;&gt; CALL MDH CAS &lt;&lt;&lt;</execute></font color>'
							+ '<br/>'
							+ '-----------------------------------------------------------------------------------------------------'
							+ '<br/>CAS call mode description:'
							+ '<br/><font color="#33CC33">near caller:</font color> target nearest threat to CAS caller(player) outside of minDistance'
							+ '<br/><font color="#33CC33">rolling CAS:</font color> same as near caller but with automatic call after timeout'
							+ '<br/><font color="#33CC33">BROKEN ARROW:</font color> CAS Plane every 30 seconds near caller with 10 planes'
							+ '<br/><font color="#33CC33">CAS mapMarker:</font color> target nearest threat at mapmarker with CAS in name'
							+ '<br/><font color="#33CC33">redSmoke near:</font color> target nearest threat to red smoke shell'
							+ '<br/><font color="#CC0000">redSmoke direct:</font color> target red smoke shell(<font color="#CC0000">minDistance ignored</font color>)'
							+ '<br/><font color="#33CC33">cursortarget near:</font color> target nearest threat to cursortarget'
							+ '<br/><font color="#CC0000">cursortarget direct:</font color> target position of cursortarget(<font color="#CC0000">minDistance ignored</font color>)'
							+ '<br/>'
							+ '<br/>If you have any question you can contact me at the steam workshop page.'
							+ '<br/>'
							+ '<img image="'+(if(isNil"_path")then{""}else{_path})+'\mdhCAS.paa"/>'
							+ '<br/>'
							+ 'Credits and Thanks:<br/>'
							+ 'Armed-Assault.de Crew  for many great ArmA moments in many years<br/>'
							+ 'BIS For Arma 3<br/>'
							+ '<br/>'
							+ 'Mod options with global variables at missionstart.<br/>'
							+ '<br/>'
							+ 'CAS call in action menue only with specific item:<br/>'
							+ '- mdhCASModNeededItemToCall = "B_UavTerminal"<br/>'
							+ '<br/>'
							+ 'CAS call in action menue entry only on specific object<br/>'
							+ '(use unit variable name or unit init)<br/>'
							+ '- mdhCASModCallerObj1<br/>'
							+ '- mdhCASModCallerObj2<br/>'
							+ '- mdhCASModCallerObj3<br/>'
							+ '- mdhCASModCallerObj4<br/>'
							+ '- mdhCASModCallerObj5<br/>'
							+ '(or if you want that only one specific player<br/>'
							+ 'with the variable name p1 get the action)<br/>'
							+ '- if(!isNil"p1" and {player == p1}) then {mdhCASModCallerObj1 = player}<br/>'
							+ 'else {mdhCASModCallerObj1 = "logic" createVehicleLocal [0,0,-50]}'
							)
						]
					]
				};
				true
			};
		};

		if (_env) then
		{
			_mdhFnc =
			{
				if !(localNameSpace getVariable ['mdhModsSelectDiarySubjectEh',false]) then
				{
					localNameSpace setVariable ['mdhModsSelectDiarySubjectEh',true];
					(findDisplay 12) displayAddEventHandler ['KeyDown',{if (_this#1 == 35 && {_this#2} && {_this#3}) then {player selectDiarySubject 'MDH Mods'};false}];
				};

				_t = "call MDH CAS Plane";
				_a = [];
				if (!isNil"mdhCASModCallerObj1" && {alive mdhCASModCallerObj1}) then {_a pushBackUnique mdhCASModCallerObj1};
				if (!isNil"mdhCASModCallerObj2" && {alive mdhCASModCallerObj2}) then {_a pushBackUnique mdhCASModCallerObj2};
				if (!isNil"mdhCASModCallerObj3" && {alive mdhCASModCallerObj3}) then {_a pushBackUnique mdhCASModCallerObj3};
				if (!isNil"mdhCASModCallerObj4" && {alive mdhCASModCallerObj4}) then {_a pushBackUnique mdhCASModCallerObj4};
				if (!isNil"mdhCASModCallerObj5" && {alive mdhCASModCallerObj5}) then {_a pushBackUnique mdhCASModCallerObj5};
		
				_f = false;
				if (count _a == 0) then {_a = [player]};
				{
					missionNameSpace setVariable ["mdhCASAllowedCaller",_a];
					if !(player in _a) then {profileNameSpace setVariable["mdhCASModActionmenu",true]};

					_f = false;
					_b = _x;
					{
						if (_t in (_b actionParams _x select 0)) then
						{
							_f = true;
						};																
					} forEach (actionIDs _b);
		
					if (!_f) then
					{
						_hoschisCASCode =
						{
							params ["_target"];
							_target spawn 
							{
								scriptName "mdhSpawnCAS";
								params ["_target"];
								if (time < 3) exitWith {systemChat "try again in 3 sek"};

								_debug = profileNameSpace getVariable ["mdhCASModDebug",false];
								_callMode = profileNameSpace getVariable ["mdhCASModCallMode",0];
								if (_callMode != 5) then {missionNameSpace setVariable["mdhCASBrokenArrow",0]};

								_strikePos = getPos vehicle player;
								if (_callMode in [6,7]) then
								{
									_strikePos = [];
									if !(isNull cursorTarget) then {_strikePos = getPos cursorTarget};
									if (count _strikepos == 0 && {!isNull cursorObject}) then {_strikePos = getPos cursorObject};
									if (count _strikepos == 0 && {vehicle player == player}) then
									{
										_strikePos = lineIntersectsSurfaces
										[
											AGLToASL positionCameraToWorld [0,0,0],
											(AGLToASL positionCameraToWorld [0,0,0]) vectorAdd ((getCameraViewDirection player) vectorMultiply 5000), 
											player
										];
										if (count _strikepos == 1) then
										{
											_strikePos = _strikePos#0#0;
											_strikePos set [2, 0];
										}
										else
										{
											_strikePos = [];
										};
									};
								};
								if (count _strikePos == 0) exitWith {systemChat "MDH CAS no cursortarget found"};

								_brokenArrow = (missionNameSpace getVariable["mdhCASBrokenArrow",0]);
								if (_debug && {_brokenArrow == 0}) then {systemChat "MDH CAS Debug mode active"};
								
								_timeout = profileNameSpace getVariable['mdhCASModTimeout',60];
								if (profileNameSpace getVariable ["mdhCASModCallMode",0] in [4,5] && {_timeout < 60}) then {_timeout = 60};
								
								_arrival = profileNameSpace getVariable['mdhCASModTimeArrival',15];
								if (_brokenArrow != 0) then {_arrival = 3};
								missionNameSpace setVariable['mdhCASModCallTime',time + _timeout + _arrival];
								
								_r = selectRandom [0,1,2];
								_r = str(_r);
								_l = "B";
								if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] == 2) then
								{
									if (side group player == east) then {_l = "O"};
									if (side group player == resistance) then {_l = "I"};
								};

								if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] != 0 && {_brokenArrow == 0}) then
								{
									playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\01_CasRequested\mp_groundsupport_01_casrequested_"+_l+"HQ_"+_r+".ogg"];
								};

								_counter = 99;
								for "_i" from 0 to _arrival do
								{
									if (_brokenArrow == 0) then
									{
										_arrival = profileNameSpace getVariable['mdhCASModTimeArrival',15]
									};

									_limit = if (_arrival > 60 && {_arrival - _i > 60}) then {60} else {15};
									if (_counter >= _limit && {_arrival - _i > 0}) then
									{
										if (_brokenArrow == 0) then
										{
											systemChat ("Close Air Support called ETA " + (if (_arrival - _i > 59) then {str((_arrival - _i)/60) + " min"} else {str(_arrival - _i) + " sec"}));
										};
										_counter = 0;
									};
									if (_i > _arrival) exitWith {};
									_counter = _counter + 1;
									sleep 1;
								};

								if !(_callMode in [6,7]) then {_strikePos = getPos vehicle player};
								if (_callMode in [5]) then {_strikePos = _strikePos VectorAdd [random 300 * - 1 + random 300, random 300 * - 1 + random 300, 0]};

								_t = player;
								_tM1 = player;
								_tM2 = player;
								_tAA = player;
								_enemySides = [];
								{if ((side group player) getFriend _x < 0.6) then {_enemySides pushBack _x}} forEach [east,west,resistance];
								_v = [];
								for "_i" from 4 to 30 do {_v pushBack (_i*50)};
								_safeDistance = profileNameSpace getVariable ["mdhCASModMinDistance",25];
								//if (_debug && {name player == "Moerderhoschi"}) then {_safeDistance = 1};
								_AA = [];
								_mbt = [];
								_cars = [];
								_tanks = [];
								_AAmoving = [];
								_mbtMoving = [];
								_carsMoving = [];
								_tanksMoving = [];
								_heli = [];
								_plane = [];

								_MapLocation = 0;
								_markerText = "";
								if (_callMode == 1) then
								{
									_MapLocation = 1;
									_s = "_USER_DEFINED #" + getPlayerID player;
									{
										if (_s in _x) then
										{
											if ("cas" in toLowerANSI(markerText _x)) exitWith
											{
												_MapLocation = 2;
												_markerText = markerText _x;
												_strikePos = getmarkerPos _x;
												_safeDistance = 0;
											};
										};
									} forEach allMapMarkers;

									if (_safeDistance != 0) then
									{
										{
											if ("cas" in toLowerANSI(markerText _x)) exitWith
											{
												_MapLocation = 2;
												_markerText = markerText _x;
												_strikePos = getmarkerPos _x;
												_safeDistance = 0;
											};
										} forEach allMapMarkers;
									};									
								};

								_redSmoke = 0;
								_redSmokeShell = player;
								if (_callMode in [2,3]) then
								{
									_redSmoke = 1;
									_n = nearestObjects [vehicle player,["SmokeShell"],1000];
									{
										_m = toLowerANSI(typeOf _x);
										if ("red" in _m) exitWith
										{
											_redSmoke = 2;
											_strikePos = getPos _x;
											_redSmokeShell = _x;
											_safeDistance = 0;
										};
									} forEach _n;
								};

								_dist = _v;
								_distMax = 1500;
								_targetFound = false;
								{
									_v = _x;
									if !(_targetFound) then
									{
										_AA = [];
										_mbt = [];
										_cars = [];
										_tanks = [];
										_AAmoving = [];
										_mbtMoving = [];
										_carsMoving = [];
										_tanksMoving = [];
										_heli = [];
										_plane = [];
										_v2 = _v;
										if (_t != player) then
										{
											_v2 = _distMax;
											_targetFound = true;
										};

										{
											if
											(
												alive _x 
												&& {side _x in _enemySides} 
											)
											then
											{
												if
												(
													(getPos _x)#2 < 3
													&& {_x distance _strikePos < _v2 }
												)
												then 
												{
													_isAA = (getnumber(configFile >> "cfgVehicles" >> (typeOf _x) >> "irScanRangeMin") > 600);
													_isArty = (getnumber(configFile >> "cfgVehicles" >> (typeOf _x) >> "artilleryScanner") > 0);
													_isMBT = "mbt" in toLowerANSI(typeOf _x);
					
													if (_x isKindOf "LAND" && {_isAA} && {speed _x == 0}) exitWith {_AA pushBack [_x distance _strikePos, _x]};
													if (_x isKindOf "LAND" && {_isAA} && {speed _x !=  0}) exitWith {_AAmoving pushBack [_x distance _strikePos, _x]};
					
													if (_x isKindOf "TANK" && {!_isArty} && {_isMBT} && {speed _x == 0}) exitWith {_mbt pushBack [_x distance _strikePos, _x]};
													if (_x isKindOf "TANK" && {!_isArty} && {_isMBT} && {speed _x != 0}) exitWith {_mbtMoving pushBack [_x distance _strikePos, _x]};
					
													if (_x isKindOf "TANK" && {speed _x == 0} && {!_isMBT}) exitWith {_tanks pushBack [_x distance _strikePos, _x]};
													if (_x isKindOf "TANK" && {speed _x != 0} && {!_isMBT}) exitWith {_tanksMoving pushBack [_x distance _strikePos, _x]};
					
													if (_x isKindOf "CAR" && {speed _x == 0}) exitWith {_cars pushBack [_x distance _strikePos, _x]};
													if (_x isKindOf "CAR" && {speed _x != 0}) exitWith {_carsMoving pushBack [_x distance _strikePos, _x]};
												};
	
												if (_x distance _strikePos < (_distMax * 2)) then 
												{
													_isIrTarget = (getnumber(configFile >> "cfgVehicles" >> (typeOf _x) >> "irTarget") > 0);
													_isRadarTarget = (getnumber(configFile >> "cfgVehicles" >> (typeOf _x) >> "radarTarget") > 0);
													if (_x isKindOf "Helicopter" && {_isIrTarget || _isRadarTarget}) exitWith {_heli pushBack [_x distance _strikePos, _x]};
													if (_x isKindOf "Plane" && {_isIrTarget || _isRadarTarget}) exitWith {_plane pushBack [_x distance _strikePos, _x]};
												};
											};
										} forEach vehicles;
									};

									{
										if (_t == player && {count _x > 0}) then
										{
											_x sort true;
											{
												_t1 = _x#1;
												if (allPlayers findIf {side group _x getFriend side group player > 0.5 && {vehicle _x distance _t1 < _safeDistance}} == -1) then {_t = _t1};
											} forEach _x;
										};
									} forEach [_mbt, _AA, _tanks, _cars, _mbtMoving, _AAmoving, _tanksMoving, _carsMoving];

									if (_t == player && {_v >= 300 && _redSmoke == 2 or _v >= 500}) then
									{
										_units = [];
										{
											if
											(
												alive _x
												&& {side _x in _enemySides} 
												&& {(getPos vehicle _x)#2 < 3} 
												&& {_x distance _strikePos < _v } 
												&& {_t1 = _x; allPlayers findIf {side group _x getFriend side group player > 0.5 && {vehicle _x distance _t1 < _safeDistance}} == -1} 
											)
											then
											{
												_units pushBackUnique [_x distance _strikePos, _x];
											}
										} forEach allUnits;
			
										if (count _units > 0) then
										{
											_units sort true;
											_t = _units#0#1;
										};
									};
								} forEach _dist;

								_dist = 500;
								{
									_f = 1;
									if (_forEachIndex == 0) then {_f = 2};
									_x sort true;
									while{_tM1 == player && {count _x > 0}} do {if ((_x#0#1) distance _t < (_dist * _f) && {(_x#0#1) != _t}) then {_tM1 = _x#0#1}; _x deleteAt 0};
								} forEach [_AAmoving, _AA, _mbtMoving, _mbt, _tanksMoving, _tanks, _carsMoving, _cars];
								if (_tM1 == player && {_t isKindOf "TANK" OR _t isKindOf "CAR"}) then {_tM1 = _t};

								{
									_f = 1;
									if (_forEachIndex == 0) then {_f = 2};
									_x sort true;
									while{_tM2 == player && {count _x > 0}} do {if ((_x#0#1) distance _t < (_dist * _f) && {(_x#0#1) != _t}) then {_tM2 = _x#0#1}; _x deleteAt 0};
								} forEach [_AAmoving, _AA, _mbtMoving, _mbt, _tanksMoving, _tanks, _carsMoving, _cars];
								if (_tM2 == player && {_t isKindOf "TANK" OR _t isKindOf "CAR"}) then {_tM2 = _t};
								
								_dist = 3000;
								{
									_f = 1;
									_x sort true;
									while{_tAA == player && {count _x > 0}} do {if ((_x#0#1) distance _t < (_dist * _f) && {(_x#0#1) != _t}) then {_tAA = _x#0#1}; _x deleteAt 0};
								} forEach [_heli, _plane];

								if ((_callMode == 3 or _callMode == 2 && _t == player) && {_redSmoke == 2} && {_redSmokeShell != player}) then
								{
									_redSmokeLogic = "logic" createVehicleLocal getPos _redSmokeShell;
									_redSmokeLogic setPos getPos _redSmokeShell;
									_t = _redSmokeLogic;
									[_redSmokeShell,_redSmokeLogic] spawn
									{
										params["_redSmokeShell","_redSmokeLogic"];
										for "_i" from 1 to 60 do
										{
											if !(isNull _redSmokeShell) then
											{
												_redSmokeLogic setPos getPos _redSmokeShell;
											};
											sleep 1;
										};
										deleteVehicle _redSmokeLogic;
									};
								};

								if (_callMode == 7) then
								{
									_t = "logic" createVehicleLocal _strikepos;
									_t spawn {sleep 90; deleteVehicle _this};
								};

								_onlyAA = 0;
								if (_tAA != player && {_t == player}) then
								{
									_onlyAA = 1;
									_tP = getPos _tAA;
									_t = "logic" createVehicleLocal [_tp#0, _tp#1, 0];
									_t spawn {sleep 90; deleteVehicle _this};
								};

								if (_t == player or (_redSmoke == 1 && (profileNameSpace getVariable ["mdhCASModNoRedSmokeThenAbort",0] == 1)) or _MapLocation == 1) exitWith
								{
									if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] != 0) then
									{
										playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\05_CasAborted\mp_groundsupport_05_casaborted_"+_l+"HQ_"+_r+".ogg"];
									};
									systemChat "Close Air Support canceled no valid targets found";
									_s = "(to close or to far from caller)";
									if (_MapLocation == 1) then {_s = ("(no map marker with CAS in name found)")};
									if (_MapLocation == 2) then {_s = ('(no targets found at map marker "' + _markerText + '")')};
									if (_redSmoke == 1) then {_s = "(no red smoke around 1000 meter of caller found)"};
									systemChat _s;
									missionNameSpace setVariable['mdhCASModCallTime',time + 5];
									missionNameSpace setVariable["mdhCASBrokenArrow",0];
								};

								if (_redSmoke == 1) then {systemChat "no red smoke around 1000 meter of caller found"; systemChat "(Attacking nearest Target)"};

								_logic = "logic" createVehicleLocal getPos _t;
								_logic setPos getPos _t;
								_logic attachTo [_t,[0,0,0]];

								_side = "West";
								if (side group player == east) then {_side = "East"};
								if (side group player == resistance) then {_side = "Guer"};
								_n = profileNameSpace getVariable ["mdhCASModPlaneType",1];

								_planeClass = profileNameSpace getVariable [("mdhCASPlane"+_side+str(_n)),["mdhNothing",[],[],[],[]]];
								_planeCamo = _planeClass#1;
								_planePylon = _planeClass#2;
								_planeWeapons = _planeClass#3;
								_planeMagazines = _planeClass#4;
								_planeClass = _planeClass#0;

								if !(isclass(configfile >> "cfgvehicles" >> _planeClass)) then
								{
									_planeCamo = [];
									_planeClass = "B_Plane_CAS_01_dynamicLoadout_F";
									_planePylon = [[1,"Pylons1",[-1],"PylonRack_1Rnd_AAA_missiles",1,"0:10001561",[[6.53854,0.566696,-0.277049],[-0,-1,0],[-0,-0,1]]],[2,"Pylons2",[-1],"PylonMissile_1Rnd_Bomb_04_F",1,"0:10001562",[[5.35845,0.665939,-0.45968],[-0,-1,0],[-0,-0,1]]],[3,"Pylons3",[-1],"PylonRack_3Rnd_Missile_AGM_02_F",3,"0:10001563",[[4.14074,0.654476,-0.615896],[-0,-1,0],[-0,-0,1]]],[4,"Pylons4",[-1],"PylonRack_7Rnd_Rocket_04_AP_F",7,"0:10001564",[[1.78969,0.670163,-0.789496],[-0,-1,0],[-0,-0,1]]],[5,"Pylons5",[-1],"PylonRack_7Rnd_Rocket_04_HE_F",7,"0:10001565",[[0.65753,0.670163,-0.80346],[-0,-1,0],[-0,-0,1]]],[6,"Pylons6",[-1],"PylonRack_7Rnd_Rocket_04_HE_F",7,"0:10001566",[[-0.641189,0.670163,-0.806879],[-0,-1,0],[-0,-0,1]]],[7,"Pylons7",[-1],"PylonRack_7Rnd_Rocket_04_AP_F",7,"0:10001567",[[-1.76817,0.670163,-0.787626],[-0,-1,0],[-0,-0,1]]],[8,"Pylons8",[-1],"PylonRack_7Rnd_Rocket_04_HE_F",7,"0:10001568",[[-4.12668,0.654476,-0.611977],[-0,-1,0],[-0,-0,1]]],[9,"Pylons9",[-1],"PylonMissile_1Rnd_BombCluster_01_F",1,"0:10001570",[[-5.33928,0.665939,-0.46261],[-0,-1,0],[-0,-0,1]]],[10,"Pylons10",[-1],"PylonRack_1Rnd_AAA_missiles",1,"0:10001571",[[-6.52269,0.566696,-0.278784],[-0,-1,0],[-0,-0,1]]]];
									_planeWeapons = ["Gatling_30mm_Plane_CAS_01_F","Laserdesignator_pilotCamera","CMFlareLauncher","Rocket_04_HE_Plane_CAS_01_F","Missile_AGM_02_Plane_CAS_01_F","Bomb_04_Plane_CAS_01_F","Rocket_04_AP_Plane_CAS_01_F","missiles_ASRAAM","BombCluster_01_F"];
									_planeMagazines = ["1000Rnd_Gatling_30mm_Plane_CAS_01_F","Laserbatteries","120Rnd_CMFlare_Chaff_Magazine","PylonRack_1Rnd_AAA_missiles","PylonMissile_1Rnd_Bomb_04_F","PylonRack_3Rnd_Missile_AGM_02_F","PylonRack_7Rnd_Rocket_04_AP_F","PylonRack_7Rnd_Rocket_04_HE_F","PylonRack_7Rnd_Rocket_04_HE_F","PylonRack_7Rnd_Rocket_04_AP_F","PylonRack_7Rnd_Rocket_04_HE_F","PylonMissile_1Rnd_BombCluster_01_F","PylonRack_1Rnd_AAA_missiles"];
									
									if (side group player == east) then
									{
										_planeClass = "O_Plane_CAS_02_dynamicLoadout_F";
										_planePylon = [[1,"Pylons1",[-1],"PylonRack_1Rnd_Missile_AA_03_F",1,"0:10001486",[[6.37092,-2.62643,-1.36961],[-0,-1,0],[-0,-0,1]]],[2,"Pylons2",[-1],"PylonRack_3Rnd_LG_scalpel",3,"0:10001488",[[5.34636,-2.37923,-1.66239],[-0,-1,0],[-0,-0,1]]],[3,"Pylons3",[-1],"PylonMissile_1Rnd_Bomb_03_F",1,"0:10001489",[[4.30098,-1.63516,-1.60637],[-0,-1,0],[-0,-0,1]]],[4,"Pylons4",[-1],"PylonRack_20Rnd_Rocket_03_HE_F",20,"0:10001490",[[3.2575,-1.16712,-1.60761],[-0,-1,0],[-0,-0,1]]],[5,"Pylons5",[-1],"PylonRack_20Rnd_Rocket_03_AP_F",20,"0:10001491",[[2.23013,-0.662919,-1.57773],[-0,-1,0],[-0,-0,1]]],[6,"Pylons6",[-1],"PylonRack_20Rnd_Rocket_03_AP_F",20,"0:10001492",[[-2.22577,-0.662919,-1.57773],[-0,-1,0],[-0,-0,1]]],[7,"Pylons7",[-1],"PylonRack_20Rnd_Rocket_03_HE_F",20,"0:10001493",[[-3.25315,-1.16712,-1.60761],[-0,-1,0],[-0,-0,1]]],[8,"Pylons8",[-1],"PylonMissile_1Rnd_BombCluster_02_cap_F",1,"0:10001495",[[-4.29663,-1.63516,-1.60637],[-0,-1,0],[-0,-0,1]]],[9,"Pylons9",[-1],"PylonRack_20Rnd_Rocket_03_HE_F",20,"0:10001496",[[-5.34201,-2.37923,-1.66239],[-0,-1,0],[-0,-0,1]]],[10,"Pylons10",[-1],"PylonRack_1Rnd_Missile_AA_03_F",1,"0:10001497",[[-6.36657,-2.62643,-1.36961],[-0,-1,0],[-0,-0,1]]]];
										_planeWeapons = ["Cannon_30mm_Plane_CAS_02_F","Laserdesignator_pilotCamera","CMFlareLauncher","Missile_AA_03_Plane_CAS_02_F","Rocket_03_HE_Plane_CAS_02_F","Bomb_03_Plane_CAS_02_F","Rocket_03_AP_Plane_CAS_02_F","missiles_SCALPEL","BombCluster_02_F"];
										_planeMagazines = ["500Rnd_Cannon_30mm_Plane_CAS_02_F","Laserbatteries","120Rnd_CMFlare_Chaff_Magazine","PylonRack_1Rnd_Missile_AA_03_F","PylonRack_3Rnd_LG_scalpel","PylonMissile_1Rnd_Bomb_03_F","PylonRack_20Rnd_Rocket_03_HE_F","PylonRack_20Rnd_Rocket_03_AP_F","PylonRack_20Rnd_Rocket_03_AP_F","PylonRack_20Rnd_Rocket_03_HE_F","PylonMissile_1Rnd_BombCluster_02_cap_F","PylonRack_20Rnd_Rocket_03_HE_F","PylonRack_1Rnd_Missile_AA_03_F"];
									};

									if (side group player == resistance) then 
									{
										_planeClass = "I_Plane_Fighter_03_dynamicLoadout_F";
										_planePylon = [[1,"Pylons1",[-1],"PylonRack_1Rnd_Missile_AA_04_F",1,"0:10000678",[[3.5543,-0.618341,-1.4382],[-0,-0.99863,0.052336],[-0,0.052336,0.99863]]],[2,"Pylons2",[-1],"PylonRack_3Rnd_LG_scalpel",3,"0:10000679",[[2.80474,-0.546924,-1.59068],[-0,-0.99863,0.052336],[-0,0.052336,0.99863]]],[3,"Pylons3",[-1],"PylonMissile_1Rnd_BombCluster_01_F",1,"0:10000681",[[2.06158,-0.546924,-1.59068],[-0,-0.99863,0.052336],[-0,0.052336,0.99863]]],[4,"Pylons4",[-1],"PylonWeapon_300Rnd_20mm_shells",300,"0:10000682",[[0.0391688,0.83876,-1.56742],[3.72529e-09,-0.999967,-0.00818288],[-6.62664e-16,-0.00818288,0.999967]]],[5,"Pylons5",[-1],"PylonMissile_1Rnd_Bomb_04_F",1,"0:10000683",[[-2.01977,-0.546924,-1.59068],[-0,-0.99863,0.052336],[-0,0.052336,0.99863]]],[6,"Pylons6",[-1],"PylonRack_12Rnd_missiles",12,"0:10000685",[[-2.76284,-0.546924,-1.59068],[-0,-0.99863,0.052336],[-0,0.052336,0.99863]]],[7,"Pylons7",[-1],"PylonRack_1Rnd_Missile_AA_04_F",1,"0:10000686",[[-3.50268,-0.618341,-1.4382],[-0,-0.99863,0.052336],[-0,0.052336,0.99863]]]];
										_planeWeapons = ["CMFlareLauncher","missiles_SCALPEL","Bomb_04_Plane_CAS_01_F","Twin_Cannon_20mm_gunpod","Missile_AA_04_Plane_CAS_01_F","BombCluster_01_F","missiles_DAR"];
										_planeMagazines = ["120Rnd_CMFlare_Chaff_Magazine","PylonRack_1Rnd_Missile_AA_04_F","PylonRack_3Rnd_LG_scalpel","PylonMissile_1Rnd_BombCluster_01_F","PylonWeapon_300Rnd_20mm_shells","PylonMissile_1Rnd_Bomb_04_F","PylonRack_12Rnd_missiles","PylonRack_1Rnd_Missile_AA_04_F"];
									};
								};

								_planeCfg = configfile >> "cfgvehicles" >> _planeClass;
								if !(isclass _planeCfg) exitwith {["Vehicle class '%1' not found",_planeClass] call bis_fnc_error; false};

								_weaponTypes = 0;
								_weapons = 0;
								_missilelauncherAT = [];
								_missilelauncherAA = [];
								_weaponsSorted = 0;
								call (missionNameSpace getVariable["mdhFncCASweapons",{systemChat "mdhFncCASweapons not found!"}]);
								if (count _weapons == 0) exitwith {["No weapon of types %2 found on '%1'",_planeClass,_weaponTypes] call bis_fnc_error; false};
								if (_onlyAA == 1 && {count _missilelauncherAA == 0}) exitwith
								{
									systemChat "Close Air Support canceled no valid targets found";
									missionNameSpace setVariable["mdhCASBrokenArrow",0];
									missionNameSpace setVariable['mdhCASModCallTime',time + 5];
								};

								//systemChat str(_weapons);
								_weapons = _weaponsSorted;
								//systemChat str(_weapons + _missilelauncherAT);
								//systemChat str(_missilelauncherAT);

								_posATL = getposATL _logic;
								_pos = +_posATL;
								_pos set [2,(getPosASL _t)#2];
								_dir = direction _logic;
								_dis = 3000 + 1000;
								_alt = _dis / 3;
					
								_pitch = atan (_alt / _dis);
								_speed = 400 / 3.6;
								_duration = ([0,0] distance [_dis,_alt]) / _speed;
							
								_h = 1;
								_planePos = [_pos,_dis,_dir + 180] call bis_fnc_relpos;
								_h = 0;
								if (true) then
								{
									_a = 1;
									_c = 0;
									for "_i" from 1 to 10000 do
									{
										_a = _i;
										_h = _i/10;
										_h = _h + _alt * 0.5;
										if (_h > 999) then {_h = 999};
										_dir = if (typename(_weaponsSorted#3)=="ARRAY" && {_i < 5000}) then {(vehicle player getDir _t) + 80 + random 30 + selectRandom[0,180]} else {random 360};
										_planePos = [eyePos _t,_dis,_dir + 180] call bis_fnc_relpos;
										_planePos set [2, _h];
										_tmpPos = eyePos _t;
										_tmpPos set [2,(_tmpPos#2)+1];
										_c = [_t,"VIEW"] checkVisibility [_planePos, _tmpPos];
										if (_c > 0) exitWith {};
									};
									//if (_debug) then {systemChat ("randomDirCounter: "+str(_a)+", checkVisibility: "+str(_c))};
								};

								_planePos set [2,(_pos#2) + _alt];
								_logic setDir _dir;
		
								if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] != 0 && {_brokenArrow == 0}) then
								{
									playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\50_Cas\mp_groundsupport_50_cas_"+_l+"HQ_"+_r+".ogg"];
								};
								_s = "Close Air Support incomming";
								if (_MapLocation == 2) then {_s = ('Close Air Support incomming on map marker "' + _markerText + '"')};
								if (_redSmoke == 2) then {_s = "Close Air Support incomming on red smoke"};
								if (_brokenArrow == 0) then {systemChat _s};
		
								_z="--- Create plane";
								_planeSide = side group player;
								_planeArray = [_planePos,_dir,_planeClass,_planeSide] call bis_fnc_spawnVehicle;
								_plane = _planeArray select 0;
								
								{_plane setObjectTextureGlobal [_forEachIndex, _x]} forEach _planeCamo;
								if (count _planeMagazines != 0) then
								{
									{_plane setPylonLoadout [_x#0, _x#3, false, _x#2]} forEach _planePylon;
									{if !(_x in _planeMagazines) then {_plane removeMagazineGlobal _x}} forEach (magazines _plane);
									{if !(_x in magazines _plane) then {_plane addMagazineGlobal _x}} forEach _planeMagazines;
									{if !(_x in _planeWeapons) then {_plane removeWeaponGlobal _x}} forEach (weapons _plane);
									{if !(_x in weapons _plane) then {_plane addWeaponGlobal _x}} forEach _planeWeapons;
								};
								_planeDriver = driver _plane;
								_plane setposasl _planePos;
								_plane move ([_pos,_dis,_dir] call bis_fnc_relpos);
								_plane disableai "move";
								_plane disableai "target";
								_plane disableai "autotarget";
								_plane setcombatmode "blue";
								_plane setVariable ["onlyAA",_onlyAA];
								//player setDir (player getDir _plane);
		
								if (profileNameSpace getVariable ["mdhCASModDebug",false]) then
								{
									_eh = addMissionEventHandler[ 'Draw3D',
									{
										_t = _thisArgs#0;
										_tM1 = _thisArgs#1;
										_tM2 = _thisArgs#2;
										_plane = _thisArgs#3;
										_planePos = _thisArgs#4;
										_logic = _thisArgs#5;
										_h = _thisArgs#6;
										_w = _thisArgs#7;
										_m = _thisArgs#8;
										_tAA = _thisArgs#9;
										
										drawLine3D [getPos _plane, getPos _logic, [1,0,0,1],10];
										_tmpPos = +_planePos;
										_tmpPos set [2, _h];
										if (name player == "Moerderhoschi") then {drawLine3D [_tmpPos, getPos _logic, [0,1,0,1],10]};
										{
											if (alive _x) then
											{
												if (_x == player) exitWith {};
												_color = [1,0,0,1];
												_tSize = 0.032;
												_pos = unitAimPositionVisual _x;
												_s = "";
												if (_x == _t &&{typename(_w#0)=="SCALAR"}&&{typename(_w#1)=="SCALAR"}&&{typename(_w#2)=="SCALAR"}&&{typename(_w#3)=="SCALAR"}) exitWith {};
												if (_x == _t) then {_s = _s + "Target"};
												if (_x == _tM1 &&{count _m==0}) exitWith {};
												if (_x == _tM1) then {_s = _s + " AGM1"};
												if (_x == _tM2 && {count _m==0}) exitWith {};
												if (_x == _tM2) then {_s = _s + " AGM2"};
												if (_x == _tAA && {count _m==0}) exitWith {};
												if (_x == _tAA) then {_s = _s + " AA"};
												if (_x == _plane) then {_s = "CAS Plane"; _color = [0,0,0.5,1]};
												drawIcon3D ["\a3\ui_f\data\Map\VehicleIcons\iconExplosiveGP_ca.paa", _color, _pos, 1, 1, 0,_s, 1, _tSize];
											}
										} forEach [_t,_tM1,_tM2,_plane,_tAA];
									},[_t,_tM1,_tM2,_plane,_planePos,_logic,_h,_weaponsSorted,_missilelauncherAT,_tAA,_missilelauncherAA]];
									[_eh,_plane,_dis]spawn
									{
										params["_eh","_plane","_dis"];
										_time = time + (_dis/100) + 5;
										waitUntil{sleep 1; time > _time or !alive _plane or _plane getVariable ["fireProgressDone",false]};
										removeMissionEventHandler["Draw3D",_eh]
									};
								};
		
								_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
								_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
								_plane setvectordir _vectorDir;
								[_plane,-90 + atan (_dis / _alt),0] call bis_fnc_setpitchbank;
								_vectorUp = vectorup _plane;
							
								_z="--- Remove all other weapons";
								_currentWeapons = weapons _plane;
								{
									if !(toLowerANSI ((_x call bis_fnc_itemType) select 1) in (_weaponTypes + ["countermeasureslauncher"])) then {
										_plane removeweapon _x;
									};
								} foreach _currentWeapons;
		
								_z="--- Approach";
								_fire = [] spawn {waituntil {false}};
								_fireNull = true;
								_time = time;

								0 spawn
								{
									if (profileNameSpace getVariable['mdhCASModCallMode',0] == 5) then
									{
										0 spawn
										{
											sleep (14 + random 4);
											if !(profileNameSpace getVariable['mdhCASModCallMode',0] == 5) exitWith {};
											_brokenArrow = (missionNameSpace getVariable["mdhCASBrokenArrow",0]);
											missionNameSpace setVariable["mdhCASBrokenArrow",(_brokenArrow + 1)];
											_brokenArrow = (missionNameSpace getVariable["mdhCASBrokenArrow",0]);
											if (_brokenArrow < 10) then
											{
												call (missionNameSpace getVariable["mdhCASCode",{systemChat "mdhCASCode not found!"}]);
											}
											else
											{
												missionNameSpace setVariable["mdhCASBrokenArrow",0];
											};
										};
									};
								};

								waituntil
								{
									_fireProgress = _plane getvariable ["fireProgress",0];
									if (damage _plane > 0.2) then {_planeDriver setDamage 1};

									_z="--- Update plane position when module was moved / rotated";
									if ((getposatl _logic distance _posATL > 0 || direction _logic != _dir) && _fireProgress == 0) then
									{
										_posATL = getposatl _logic;
										_pos = +_posATL;
										_pos set [2,((_pos select 2)-0) + getterrainheightasl _pos];
										_dir = direction _logic;

										//_planePos = [_pos,_dis,_dir + 180] call bis_fnc_relpos;
										//_planePos set [2,(_pos select 2) + _alt];
										_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
										_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
										_plane setvectordir _vectorDir;
										[_plane,-90 + atan (_dis / _alt),0] call bis_fnc_setpitchbank;
										_vectorUp = vectorup _plane;
										_plane move ([_pos,_dis,_dir] call bis_fnc_relpos);
									};

									_z="--- Set the plane approach vector";
									_plane setVelocityTransformation
									[
										_planePos, [_pos select 0,_pos select 1,(_pos select 2) + 15 + _fireProgress * 12],
										_velocity, _velocity,
										_vectorDir,_vectorDir,
										_vectorUp, _vectorUp,
										(time - _time) / _duration
									];

									_plane setvelocity velocity _plane;
						
									_z="--- Fire!";
									_fireDist = 2000 + 0;
									
									if (TRUE && {(getPosASL _plane) distance _pos < (_dis - 100)} && {damage _plane < 0.2} && {_fireNull} && {_tM1 != player OR _tAA != player} && {_plane getVariable["mdhMissileNotFired",true]}) then
									{
										_plane setVariable["mdhMissileNotFired",false];
										[_plane,_tM1,_tM2,_missilelauncherAT,_tAA,_missilelauncherAA] spawn
										{
											params["_plane","_tM1","_tM2","_missilelauncherAT","_tAA","_missilelauncherAA"];
											if (count _missilelauncherAA > 0 && {_tAA != player}) then
											{
												_m = [];
												{
													_w = _x;
													{
														if (_x in compatibleMagazines _w) then
														{
															_ammo = getText(configfile >> "CfgMagazines" >> _x >> "ammo");
															_ammoCount = getNumber(configFile >> "CfgMagazines" >> _x >> "count");
															if (_ammo isKindOf "MissileBase") then
															{
																for "_i2" from 1 to _ammoCount do {_m pushBack _w};
															};
														};
													} forEach magazines _plane;
												} foreach _missilelauncherAA;
												if (count _m > 0) then
												{
													_planeDriver = driver _plane;
													_tAA setVehicleTiPars [1, 1, 1];
													_planeDriver fireattarget [_tAA,_m#0];
													if (count _m > 1) then {_m deleteAt 0};
													_b = nearestObjects [_plane, ["MissileBase"], 30];
													if (count _b == 0) exitWith {};
													_b = _b#0;
													_b setMissileTarget _tAA;
													[_b, _tAA] spawn {params["_b","_tAA"];while{alive _b}do{sleep 0.1;_b setMissileTarget _tAA}};
													sleep 2;
													if (damage _plane < 0.2) then
													{
														_tAA setVehicleTiPars [1, 1, 1];
														_planeDriver fireattarget [_tAA,_m#0];
														_b = nearestObjects [_plane, ["MissileBase"], 30];
														if (count _b == 0) exitWith {};
														_b = _b#0;
														_b setMissileTarget _tAA;
														[_b, _tAA] spawn {params["_b","_tAA"];while{alive _b}do{sleep 0.1;_b setMissileTarget _tAA}};
													};
												};
											};
											if (_plane getVariable ["onlyAA",0] == 1) then {_plane setVariable ["onlyAA",2]};

											sleep 2;
											if (damage _plane > 0.2) exitWith {};
											if (count _missilelauncherAT == 0 OR damage _plane > 0.2 OR _tM1 == player) exitWith {};
											_m = [];
											{
												_w = _x;
												{
													_i = _x;
													{
														if (_x in compatibleMagazines _w) then
														{
															_ammo = getText(configfile >> "CfgMagazines" >> _x >> "ammo");
															_ammoCount = getNumber(configFile >> "CfgMagazines" >> _x >> "count");
															if (_ammo isKindOf "MissileBase") then
															{
																_laserLock = getNumber(configFile >> "CfgAmmo" >> _ammo >> "laserLock");
																if (_laserLock == _i) then {for "_i2" from 1 to _ammoCount do {_m pushBack _w}};
															};
														};
													} forEach magazines _plane;
												} forEach [0,1];
											} foreach _missilelauncherAT;
											//systemChat(str(count _m)+":"+str(_m));
											if (count _m == 0) exitWith {};
											
											_planeDriver = driver _plane;
											_tM1 setVehicleTiPars [1, 1, 1];
											_planeDriver fireattarget [_tM1,_m#0];
											if (count _m > 1) then {_m deleteAt 0};
											_b = nearestObjects [_plane, ["MissileBase"], 30];
											if (count _b == 0) exitWith {};
											_b = _b#0;
											_b setMissileTarget _tM1;
											[_b, _tM1] spawn {params["_b","_tM1"];while{alive _b}do{sleep 0.1;_b setMissileTarget _tM1}};
											sleep 2;
											if (damage _plane < 0.2) then
											{
												_tM2 setVehicleTiPars [1, 1, 1];
												_planeDriver fireattarget [_tM2,_m#0];
												_b = nearestObjects [_plane, ["MissileBase"], 30];
												if (count _b == 0) exitWith {};
												_b = _b#0;
												_b setMissileTarget _tM2;
												[_b, _tM2] spawn {params["_b","_tM2"];while{alive _b}do{sleep 0.1;_b setMissileTarget _tM2}};
											};
										};
									};
		
									if ((getposasl _plane) distance _pos < _fireDist && _fireNull) then
									{
										_z="--- Create laser target";
										private _targetType = if (_planeSide getfriend west > 0.6) then {"LaserTargetW"} else {"LaserTargetE"};
										_target = ((position _logic nearEntities [_targetType,250])) param [0,objnull];
										if (isnull _target) then {
											_target = createvehicle [_targetType,position _logic,[],0,"none"];
										};
										_target setPos getPos _t;
										//_target = _t;
										if (typeOf _target in ["LaserTargetW","LaserTargetE"]) then {_target attachTo [_t,[0,0,0]]};
										_plane reveal lasertarget _target;
										_plane dowatch lasertarget _target;
										_plane dotarget lasertarget _target;
		
										_fireNull = false;
										terminate _fire;
										_fire = [_plane,_weapons,_target] spawn
										{
											_plane = _this select 0;
											_planeDriver = driver _plane;
											_weapons = _this select 1;
											_target = _this select 2;
											_duration = 3;
											_duration = 99;
											_time = time + _duration;
											_startTime = 0;
											_bombDrop = 2;
											_bombCounter = 0;
											_bombDelay = 3;
											_machinegun = if (typeName(_weapons#0) == "ARRAY") then {_weapons#0} else {[]};
											_bomblauncher = if (typeName(_weapons#1) == "ARRAY") then {_weapons#1} else {[]};
											_rocketlauncher = if (typeName(_weapons#2) == "ARRAY") then {_weapons#2} else {[]};
											_napalmlauncher = if (typeName(_weapons#3) == "ARRAY") then {_weapons#3} else {[]};
											if (count _bomblauncher > 1) then {_bombDrop = count _bomblauncher};
											_hTarget = getTerrainHeightASL (getPosASL _target);
											_hMax = _hTarget;
											for "_i" from 1 to 15 do
											{
												_newPos = [getPosASL _target, _i*10, getDir _plane] call bis_fnc_relpos;
												if (getTerrainHeightASL _newPos > _hMax) then {_hMax = getTerrainHeightASL _newPos};
											};
											_pullUp = _hTarget + 250 + _hMax - _hTarget;
//systemChat ("_pullUp: "+str(_pullUp - _hTarget)+" / "+str(_pullUp));
											_specialWeapsGo = _pullUp + 150;
											_specialEH = 0;
											_rocketOffset = 1;
											if ("RHS_A10" in typeof _plane) then {_rocketOffset = 2.2};
											if ("SPE_P47" in typeof _plane) then {_rocketOffset = 2.2};
											if ("CUP_B_A10" in typeof _plane) then {_rocketOffset = 2.2};
											if ("I_Plane_Fighter_03_dynamicLoadout_F" in typeof _plane) then {_rocketOffset = 2.2};
											_plane setVariable["specialEHrocketsOffset",_rocketOffset];
											if (_rocketOffset > 1) then {_specialEH = 1};
											waituntil
											{
												{
													if (1>0) then
													{
														if ((_x#0) == "RHS_weap_gau8") exitWith {_planeDriver forceWeaponFire [(_x#0), "HighROF"]};
														if ((_x#0) == "CUP_Vacannon_GAU8_veh") exitWith {_planeDriver forceWeaponFire [(_x#0), "2sec"]};
														_planeDriver fireattarget [_target,(_x#0)];
													};
												} foreach _machinegun;
												if (count _rocketlauncher > 0 && {_specialEH == 1}) then
												{
													_specialEH = 2;
													_rlX = [];
													{_rlX pushBack _x#0} forEach _rocketlauncher;
													_plane setVariable["specialEHrockets",_rlX];
													_plane addEventHandler ["fired",
													{
														params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
														if (_weapon in (_unit getVariable["specialEHrockets",[]])) then
														{
															//systemChat (str(_weapon));
															_rocketOffset = _unit getVariable["specialEHrocketsOffset",1];
															_pitch = _projectile call BIS_fnc_getPitchBank;
															[_projectile, (_pitch#0)+_rocketOffset, 0] call BIS_fnc_setPitchBank;
														};
													}];
												};
												if ((getPosASL _plane)#2 < _specialWeapsGo) then {{_planeDriver fireattarget [_target,(_x#0)]} foreach _rocketlauncher};
												if ((getPosASL _plane)#2 < _specialWeapsGo) then {
												{
													_planeDriver fireattarget [_target,(_x#0)];
													_b = nearestObjects [_plane, ["BombCore"], 20];
													if (count _b != 0) then
													{
														{
															_b = _x;
															if !(_b getVariable ["mdhCASBombGuided",false]) then
															{
																_b setVariable ["mdhCASBombGuided",true];
																[_b,_plane] spawn
																{
																	params["_b","_plane"];
																	_v = velocity _plane;
																	while {alive _b} do
																	{
																		_b setVelocity [(_v#0),(_v#1),(_v#2)];
																		sleep 0.1;
																	};
																};
															};
														} forEach _b;
													};
												} foreach _napalmlauncher};

												{
													if (time > (_startTime + _bombDelay) && {_bombCounter < _bombDrop}) then
													{
														_bombCounter = _bombCounter + 1; _startTime = time; _planeDriver fireattarget [_target,(_x select 0)];
														//systemChat (str(time) + " " + (_x select 0));
														if (count _bomblauncher > 1) then {_bomblauncher deleteAt 0};

														_b = nearestObjects [_plane, ["BombCore"], 20];
														if (count _b != 0) then
														{
															{
																_b = _x;
																if !(_b getVariable ["mdhCASBombGuided",false]) then
																{
																	_b setVariable ["mdhCASBombGuided",true];
																	[_b,_target,_plane] spawn
																	{
																		params["_b","_target","_plane"];
																		_i = 0;
																		sleep 0.5;
																		_v = velocity _b;
																		_b setVelocity [(_v#0) * 1.05,(_v#1) * 1.05,(_v#2)];
																		while {alive _b && {(((getPosASL _b)#2) - ((getPosASL _target)#2)) > 50} && {_b distance _target > 200}} do
																		{
																			_t = getPosASL _target;
																			_t set [2,((getPosASL _target)#2) + ((_target distance _b)/10)];
																			_b setVectorDirAndUp ([getPosASL _b, _t] call BIS_fnc_findLookAt);
																			sleep 0.1;
																		};
			
																		while {alive _b && {_b distance _target > 150}} do
																		{
																			_b setVectorDirAndUp ([getPosASL _b, getPosASL _target] call BIS_fnc_findLookAt);
																			sleep 0.01;
																		};																
																	};
																	if (profileNameSpace getVariable ["mdhCASModDebug",false])then{_eh=addMissionEventHandler['Draw3D',{_b=_thisArgs#0;_t=_thisArgs#1;drawLine3D[getPos _b,getPos _t,[0,0,1,1],10]},[_b,_target]];[_eh,_b] spawn{params["_eh","_b"];_time = time + 30; waitUntil{sleep 1; time > _time or !alive _b};removeMissionEventHandler ['Draw3D',_eh]}};
																};
															} forEach _b;
														};
													};
												} forEach (if (count _bomblauncher > 0) then {[_bomblauncher#0]} else {[]});
												_plane setvariable ["fireProgress",(1 - ((_time - time) / _duration)) max 0 min 1];
												//sleep 0.1;
												time > _time || ((getPosASL _plane)#2) < _pullUp || isnull _plane || damage _plane > 0.2
											};
											sleep 1;
										};
									};
							
									//sleep 0.01;
									scriptdone _fire || isnull _logic || isnull _plane || damage _plane > 0.2 || (_plane getVariable ["onlyAA",0] == 2)
								};
								if (damage _plane > 0.2) then {_planeDriver setDamage 1};
								_plane setvelocity velocity _plane;
								_plane flyinheight _alt;
							
								_z="--- Fire CM";
								if (alive _planeDriver) then
								{
									for "_i" from 0 to 5 do
									{
										driver _plane forceweaponfire ["CMFlareLauncher","Burst"];
										_time = time + 1.1;
										waituntil {time > _time || isnull _logic || isnull _plane};
									};
								};

								if (profileNameSpace getVariable['mdhCASModCallMode',0] == 4) then {0 spawn {call (missionNameSpace getVariable["mdhCASCode",{systemChat "mdhCASCode not found!"}])}};

								if (damage _plane > 0.2) then {_planeDriver setDamage 1};
								if !(isnull _logic) then
								{
									sleep 1;
									deletevehicle _logic;
									waituntil {_plane distance _pos > _dis || damage _plane > 0.2};
									_planeDriver setDamage 1;
								};
							
								_z="--- Delete plane";
								if (alive _plane && damage _plane < 0.2) then {
									_group = group _plane;
									_crew = crew _plane;
									deletevehicle _plane;
									{deletevehicle _x} foreach _crew;
									deletegroup _group;
								};
							};
						};
						missionNameSpace setVariable["mdhCASCode",_hoschisCASCode];
						_hoschisBlackfishCode = missionNameSpace getVariable["mdhCASCodeBlackfish",{systemChat "mdhCASCodeBlackfish not found"}];

						[
							_b
							,_t
							,"mdhCAS\mdhCAS.paa"
							,"mdhCAS\mdhCAS.paa"
							,"
							alive _target 
							&& {profileNameSpace getVariable ['mdhCASModActionmenu',true]}
							&& {missionNameSpace getVariable['mdhCASModCallTime',time - 1] < time}
							&& {profileNameSpace getVariable['mdhCASModBlackfishSelected',0] == 0}
							&& {if (!isNil'mdhCASModNeededItemToCall') then
							{
								mdhCASModNeededItemToCall in
								(
									itemsWithMagazines player
									+ assignedItems [player, true, true]
									+ weapons player
									+ primaryWeaponItems player
									+ secondaryWeaponItems player
									+ handgunItems player
								)
							}
							else
							{
								true
							}}
							"
							,"true"
							,{}
							,{}
							,_hoschisCASCode
							,{}
							,[0]
							,2
							,-1
							,false
							,false
							,false
						] call mdhHoldActionAdd;
						
						if (!isNil"_hoschisBlackfishCode") then
						{
							[
								_b
								,"call MDH CAS Gunship"
								,"mdhCAS\mdhBlackfishSmall.paa"
								,"mdhCAS\mdhBlackfishSmall.paa"
								,"
								alive _target 
								&& {profileNameSpace getVariable ['mdhCASModActionmenu',true]}
								&& {profileNameSpace getVariable['mdhCASModBlackfishSelected',0] == 1}
								&& {missionNameSpace getVariable['mdhCASModCallTime',time - 1] < time}
								&& {missionNameSpace getVariable['mdhCASModBlackfishActive',0] == 0}
								&& {if (!isNil'mdhCASModNeededItemToCall') then
								{
									mdhCASModNeededItemToCall in
									(
										itemsWithMagazines player
										+ assignedItems [player, true, true]
										+ weapons player
										+ primaryWeaponItems player
										+ secondaryWeaponItems player
										+ handgunItems player
									)
								}
								else
								{
									true
								}}
								"
								,"true"
								,{}
								,{}
								,_hoschisBlackfishCode
								,{}
								,[0]
								,2
								,-1
								,false
								,false
								,false
							] call mdhHoldActionAdd;

							[
								_b
								,"cancel MDH CAS Gunship"
								,"a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_takeOff2_ca.paa"
								,"a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_takeOff2_ca.paa"
								,"
								alive _target 
								&& {profileNameSpace getVariable ['mdhCASModActionmenu',true]}
								&& {missionNameSpace getVariable['mdhCASModBlackfishActive',0] == 1}
								"
								,"true"
								,{}
								,{}
								,_hoschisBlackfishCode
								,{}
								,[0]
								,2
								,-1
								,false
								,false
								,false
							] call mdhHoldActionAdd;
						};
					};
				} forEach _a;
				
				_hoschisCASplaneChangeCode =
				{
					params ["_target", "_caller", "_actionId", "_arguments"];
					_v = _arguments#0;
					if (_v == 1) then {profileNameSpace setVariable ["mdhCASPlaneWest1",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 2) then {profileNameSpace setVariable ["mdhCASPlaneWest2",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 3) then {profileNameSpace setVariable ["mdhCASPlaneWest3",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 4) then {profileNameSpace setVariable ["mdhCASPlaneEast1",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 5) then {profileNameSpace setVariable ["mdhCASPlaneEast2",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 6) then {profileNameSpace setVariable ["mdhCASPlaneEast3",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 7) then {profileNameSpace setVariable ["mdhCASPlaneGuer1",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 8) then {profileNameSpace setVariable ["mdhCASPlaneGuer2",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 9) then {profileNameSpace setVariable ["mdhCASPlaneGuer3",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};

					_t = "West";
					if (_v > 3 && _v < 7) then {_t = "East"};
					if (_v > 6) then {_t = "Independent"};

					_t = "plane saved for MDH CAS side " + _t;
					if (_v == 0) then {_t = "MDH CAS all saved planes cleared"};
					if (_v == 0) then { {_n = _x; { profileNameSpace setVariable [("mdhCASPlane"+_x+_n),nil]} forEach ["West","East","Guer"]} forEach ["","1","2","3"] };
					systemChat _t;
				};

				{
					if (alive _x) then
					{
						if !(_x isKindOf "PLANE") exitWith {};
						if (_x getVariable ["mdhCASsaveActionSet",false]) exitWith {};

						_x setVariable ["mdhCASsaveActionSet",true];
						_b = _x;
						{
							_t = "MDH CAS save for side ";
							if (_x == 1) then {_t = _t + "west plane 1"};
							if (_x == 2) then {_t = _t + "west plane 2"};
							if (_x == 3) then {_t = _t + "west plane 3"};
							if (_x == 4) then {_t = _t + "east plane 1"};
							if (_x == 5) then {_t = _t + "east plane 2"};
							if (_x == 6) then {_t = _t + "east plane 3"};
							if (_x == 7) then {_t = _t + "Independent plane 1"};
							if (_x == 8) then {_t = _t + "Independent plane 2"};
							if (_x == 9) then {_t = _t + "Independent plane 3"};
							if (_x == 0) then {_t = "MDH CAS clear all saved planes"};

							[
								_b
								,_t
								,"a3\ui_f_oldman\Data\IGUI\Cfg\HoldActions\holdAction_sleep_ca.paa"
								,"a3\ui_f_oldman\Data\IGUI\Cfg\HoldActions\holdAction_sleep_ca.paa"
								,"
								alive _target 
								&& {profileNameSpace getVariable ['mdhCASModActionmenu2',true]}
								&& {_target isKindOf 'PLANE'}
								&& {_target distance player < 15}
								&&
								{
									_weapons = [];
									_planeClass = typeOf _target;
									_planeWeapons = weapons _target;
									_planeMagazines = magazines _target;
									call (missionNameSpace getVariable ['mdhFncCASweapons',{systemChat 'mdhFncCASweapons not found!'}]);
									count _weapons > 0
								}
								"
								,"true"
								,{}
								,{}
								,_hoschisCASplaneChangeCode
								,{}
								,[_x]
								,2
								,-99
								,false
								,false
								,false
							] call mdhHoldActionAdd;											
						} forEach [1,2,3,4,5,6,7,8,9,0];
					};
				} forEach vehicles;
			};
		};

		if (hasInterface) then
		{
			uiSleep 1.7;
			call _diary;
		};

		sleep (1 + random 2);
		while {missionNameSpace getVariable ["pMdhCAS",_defaultValue] == _valueCheck} do
		{
			if (_env) then {call _mdhFnc};
			sleep (7 + random 3);
			if (hasInterface) then {call _diary};
		};
	};
};

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// MDH HOLD ACTION ADD FUNCTION(by Moerderhoschi with massive help of GenCoder8) - v2025-03-27
// fixed version of BIS_fnc_holdActionAdd
///////////////////////////////////////////////////////////////////////////////////////////////////////////
if (hasInterface) then
{
	GenCoder8_fixHoldActTimer =
	{
		params["_title","_iconIdle","_hint"];
		private _frameProgress = "frameprog";
		if(time > (missionNamespace getVariable [_frameProgress,-1])) then
		{
			missionNamespace setVariable [_frameProgress,time + 0.065];
			bis_fnc_holdAction_animationIdleFrame = (bis_fnc_holdAction_animationIdleFrame + 1) % 12;
		};
		private _var = "bis_fnc_holdAction_animationIdleTime_" + (str _target) + "_" + (str _actionID);
		if (time > (missionNamespace getVariable [_var,-1]) && {_eval}) then
		{
			missionNamespace setVariable [_var, time + 0.065];
			if (!bis_fnc_holdAction_running) then
			{
				[_originalTarget,_actionID,_title,_iconIdle,bis_fnc_holdAction_texturesIdle,bis_fnc_holdAction_animationIdleFrame,_hint] call bis_fnc_holdAction_showIcon;
			};
		};
	};

	_origFNC = preprocessFileLineNumbers "a3\functions_f\HoldActions\fn_holdActionAdd.sqf";
	_newFNC = ([_origFNC, "bis_fnc_holdAction_animationTimerCode", true] call BIS_fnc_splitString)#0;
	_newFNC = _newFNC + "GenCoder8_fixHoldActTimer";
	_newFNC = _newFNC + ([_origFNC, "bis_fnc_holdAction_animationTimerCode", true] call BIS_fnc_splitString)#1;
	_newFNC = _newFNC + "GenCoder8_fixHoldActTimer";
	_newFNC = _newFNC + ([_origFNC, "bis_fnc_holdAction_animationTimerCode", true] call BIS_fnc_splitString)#2;
	mdhHoldActionAdd = compile _newFNC;
};

if (true) exitWith {};
// debug stuff
if (false) then {
_i=9;
if !(cursorObject isKindOf "plane")exitWith{};
_w=weapons cursorObject;
_m=magazines cursorObject;
_a=[];
if(count _w>_i)then{_i=(count _w)};
{if(_x in compatibleMagazines (_w#_i))then{_ammo=(configfile>>"CfgMagazines">>_x>>"ammo");
_ammo=(configfile>>"CfgAmmo">>getText _ammo);
_a pushBack [_x,[_ammo,true] call BIS_fnc_returnParents,
"airLock:"+str(getNumber(configFile>>"CfgAmmo">>configname _ammo>>"airLock")),
"lockType:"+str(getNumber(configFile>>"CfgAmmo">>configname _ammo>>"lockType")),
"autoSeekTarget:"+str(getNumber(configFile>>"CfgAmmo">>configname _ammo>>"autoSeekTarget")),
"irLock:"+str(getNumber(configFile>>"CfgAmmo">>configname _ammo>>"irLock")),
"laserLock:"+str(getNumber(configFile>>"CfgAmmo">>configname _ammo>>"laserLock")),
"newSensors:"+(configName(configFile>>"CfgAmmo">>configname _ammo>>"Components">>"SensorsManagerComponent">>"Components")),
"<-"+str(count _a)+"/"]}}forEach _m;[_w#_i,"canLock:"+str(getNumber(configfile>>"CfgWeapons">>_w#_i>>"canLock")),
(_w#_i)call bis_fnc_itemType,getarray(configfile>>"cfgweapons">>_w#_i>>"modes"),_a]
};