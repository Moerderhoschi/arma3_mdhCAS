///////////////////////////////////////////////////////////////////////////////////////////////////
// MDH CAS MOD(by Moerderhoschi) - v2025-05-14
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

		_diary  = 0;
		_mdhFnc = 0;

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
							_code = localNameSpace getVariable["mdhCASCode",0];
							if (typename _code == "SCALAR") exitWith {systemChat "mdhCASCode not found"};
							if !(player in (localNameSpace getVariable ["mdhCASAllowedCaller",[]])) exitWith {systemChat "player not in allowed MDH CAS caller"};
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
							_t = localNameSpace getVariable['mdhCASModCallTime',time - 1];
							if (_t > time) exitWith
							{
								_t = round(_t - time);
								systemChat ("MDH CAS cooldown " + str(_t) + " sec" + (if (_t > 180) then {" / " + str(round((_t/60) * 100) / 100) + " min"} else {""}));
							};

							[player] call _code;
						};

						profileNameSpace setVariable[_this#0,_this#1];
						systemChat (_this#2);

						if (_this#0 == "mdhCASModTimeout") then
						{
							_t = localNameSpace getVariable['mdhCASModCallTime',time - 1];
							if (_t > time && {(time + (_this#1)) < _t}) then
							{
								_t = time + (_this#1);
								localNameSpace setVariable['mdhCASModCallTime', _t];
								_t = round(_t - time);
								systemChat ("MDH CAS cooldown " + str(_t) + " sec" + (if (_t > 180) then {" / " + str(round((_t/60) * 100) / 100) + " min"} else {""}));
							};
						};

						if (_this#0 == "mdhCASModPlaneType") then
						{
							_a = (profileNameSpace getVariable [("mdhCASPlane" + str(side group player) + str(_this#1)),0]);
							if (typename _a == "SCALAR") exitWith {systemChat "no saved planeconfig found!"; systemChat "using Arma 3 standard plane!"};

							_t = getText(configfile >> "CfgVehicles" >> (_a#0) >> "displayName");
							if (_t == "") exitWith {systemChat ((_a#0)+" not found in current loaded mods!"); systemChat "using Arma 3 standard plane!"};

							_weapons = [];
							{
								if (configname(configfile >> "CfgWeapons" >> _x) == "") then {systemChat (_x + " not found in current loaded mods!")};
								_type = toLowerANSI((_x call bis_fnc_itemType)#1);
								if(_type in ["machinegun","bomblauncher","missilelauncher","rocketlauncher","vehicleweapon","horn"]) then
								{
									_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
									if (count _modes > 0) then
									{
										if (_type in ["machinegun","bomblauncher","rocketlauncher"]) exitWith {_weapons pushBackUnique _x};
										if (_type == "missilelauncher") exitWith
										{
											_w = _x;
											{
												if (configname(configfile >> "CfgMagazines" >> _x) == "" && {!("flare" in toLowerANSI(_x))} && {!("chaff" in toLowerANSI(_x))}) then
												{
													systemChat (_x + " not found in current loaded mods!")
												};

												if (_x in compatibleMagazines _w) then
												{
													_ammo = gettext(configfile >> "CfgMagazines" >> _x >> "ammo");
													_airLock  = getNumber(configFile >> "CfgAmmo" >> _ammo >> "airLock");
													if (_ammo isKindOf "MissileBase" && {_airLock < 2}) exitWith {_weapons pushBackUnique _w};													
												};
											} forEach (_a#4);
										};

										_w = _x;
										{
											if (_x in compatibleMagazines _w) then
											{
												_ammo = gettext(configfile >> "CfgMagazines" >> _x >> "ammo");
												if (_ammo isKindOf "BulletCore") exitWith
												{
													_weapons pushBackUnique _w;
												};

												if (_ammo isKindOf "BombCore") exitWith
												{
													_weapons pushBackUnique _w;
												};

												if (_ammo isKindOf "MissileBase") exitWith
												{
													_airLock  = getNumber(configFile >> "CfgAmmo" >> _ammo >> "airLock");
													_lockType = getNumber(configFile >> "CfgAmmo" >> _ammo >> "lockType");
													if (_airLock < 2) then {_weapons pushBackUnique _w};
												};
											};
										} forEach (_a#4);
									};
								};
							} foreach (_a#3);

							_w = [];
							{
								_tx = getText(configfile >> "CfgWeapons" >> _x >> "displayName");							
								_w pushBackUnique _tx;
							} forEach _weapons;

							{
								if (_x != "") then {_t = _t + " , " + _x};
							} forEach _w;
							systemChat _t;
						};
					};

					player createDiaryRecord
					[
						"MDH Mods",
						[
							_t,
							(
								'<br/>MDH CAS is a mod created by Moerderhoschi for Arma 3.<br/>'
							+ '<br/>'
							+ 'you are able to call in an CAS Strike.<br/>'
							+ '<br/>'
							+ 'MDH CAS Modoptions:'
							+ '<br/><br/>'
							+ 'Set Voicelanguage for CAS Strike: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModVoicelanguage'',1,''MDH CAS Voicelanguage always BLUFOR english activated''] call mdhCASBriefingFnc">BLUFOR english</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModVoicelanguage'',2,''MDH CAS Voicelanguage Arma 3 side standard activated''] call mdhCASBriefingFnc">Arma 3 side standard</execute></font color>'
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
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',60,''MDH CAS Timeout set to 1 min''] call mdhCASBriefingFnc"> 1 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',180,''MDH CAS Timeout set to 3 min''] call mdhCASBriefingFnc"> 3 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',300,''MDH CAS Timeout set to 5 min''] call mdhCASBriefingFnc"> 5 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',600,''MDH CAS Timeout set to 10 min''] call mdhCASBriefingFnc"> 10 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',900,''MDH CAS Timeout set to 15 min''] call mdhCASBriefingFnc"> 15 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',1200,''MDH CAS Timeout set to 20 min''] call mdhCASBriefingFnc"> 20 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeout'',1800,''MDH CAS Timeout set to 30 min''] call mdhCASBriefingFnc"> 30</execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS arrival time in sec: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',15,''MDH CAS arrival time set to 15 sec''] call mdhCASBriefingFnc"> 15 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',30,''MDH CAS arrival time set to 30 sec''] call mdhCASBriefingFnc"> 30 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',45,''MDH CAS arrival time set to 45 sec''] call mdhCASBriefingFnc"> 45 </execute></font color>'
							+ ' / in min: '
							+ '<font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',60,''MDH CAS arrival time set to 1 min''] call mdhCASBriefingFnc"> 1 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',120,''MDH CAS arrival time set to 2 min''] call mdhCASBriefingFnc"> 2 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',180,''MDH CAS arrival time set to 3 min''] call mdhCASBriefingFnc"> 3 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',240,''MDH CAS arrival time set to 4 min''] call mdhCASBriefingFnc"> 4 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModTimeArrival'',300,''MDH CAS arrival time set to 5 min''] call mdhCASBriefingFnc"> 5 </execute></font color>'
							+ '<br/><br/>'
							+ 'Set minDistance to player for CAS target: '
							+    '<font color="#CC0000"><execute expression = "[''mdhCASModMinDistance'',25,''MDH CAS min distance set to 25 meter''] call mdhCASBriefingFnc"> 25m </execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModMinDistance'',50,''MDH CAS min distance set to 50 meter''] call mdhCASBriefingFnc"> 50m </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',75,''MDH CAS min distance set to 75 meter''] call mdhCASBriefingFnc"> 75m </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModMinDistance'',100,''MDH CAS min distance set to 100 meter''] call mdhCASBriefingFnc"> 100m</execute></font color>'
							+ '<br/><br/>'
							+ 'Set behaviour when no red smoke found: '
							+    '<font color="#CC0000"><execute expression = "[''mdhCASModNoRedSmokeThenAbort'',1,''MDH CAS no red smoke abort CAS activated''] call mdhCASBriefingFnc"> abort CAS </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModNoRedSmokeThenAbort'',0,''MDH CAS no red smoke attack nearest taget activated''] call mdhCASBriefingFnc"> attack near target </execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS planetype: '
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModPlaneType'',1,''MDH CAS planeType 1 activated''] call mdhCASBriefingFnc"> PLANE 1 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModPlaneType'',2,''MDH CAS planeType 2 activated''] call mdhCASBriefingFnc"> PLANE 2 </execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModPlaneType'',3,''MDH CAS planeType 3 activated''] call mdhCASBriefingFnc"> PLANE 3</execute></font color>'
							+ '<br/><br/>'
							+ 'Set CAS call mode: <br/>'
							+    '<font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',0,''MDH CAS callmode near caller activated''] call mdhCASBriefingFnc">near caller</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',1,''MDH CAS callmode CAS mapMarker activated''] call mdhCASBriefingFnc">CAS mapMarker</execute></font color>'
							+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModCallMode'',2,''MDH CAS callmode cas red smoke activated''] call mdhCASBriefingFnc">near target red smoke</execute></font color>'
							+ ' / <font color="#CC0000"><execute expression = "[''mdhCASModCallMode'',3,''MDH CAS callmode cas red smoke activated''] call mdhCASBriefingFnc">direct at red smoke</execute></font color>'
							//+ '<br/><br/>'
							//+ 'Set CAS item for call: '
							//+    '<font color="#33CC33"><execute expression = "[''mdhCASModCallitem'',0,''MDH CAS item to call set none''] call mdhCASBriefingFnc">none</execute></font color>'
							//+ ' / <font color="#33CC33"><execute expression = "[''mdhCASModCallitem'',1,''MDH CAS item to call set UAV Terminal''] call mdhCASBriefingFnc">UAV Terminal</execute></font color>'
							+ '<br/>'
							+ '<br/>'
							+ '---------------------------------------------------------------------------------------------------------'
							+ '<br/>'
							+ '<font color="#CC0000" size="40"><execute expression = "[''mdhCASModCallOverModTab'',true,''''] call mdhCASBriefingFnc">&gt;&gt;&gt; CALL MDH CAS &lt;&lt;&lt;</execute></font color>'
							+ '<br/>'
							+ '---------------------------------------------------------------------------------------------------------'
							+ '<br/>'
							+ 'If you have any question you can contact me at the steam workshop page.'
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
				_t = "call MDH CAS";
				_a = [];
				if (!isNil"mdhCASModCallerObj1" && {alive mdhCASModCallerObj1}) then {_a pushBackUnique mdhCASModCallerObj1};
				if (!isNil"mdhCASModCallerObj2" && {alive mdhCASModCallerObj2}) then {_a pushBackUnique mdhCASModCallerObj2};
				if (!isNil"mdhCASModCallerObj3" && {alive mdhCASModCallerObj3}) then {_a pushBackUnique mdhCASModCallerObj3};
				if (!isNil"mdhCASModCallerObj4" && {alive mdhCASModCallerObj4}) then {_a pushBackUnique mdhCASModCallerObj4};
				if (!isNil"mdhCASModCallerObj5" && {alive mdhCASModCallerObj5}) then {_a pushBackUnique mdhCASModCallerObj5};
		
				_f = false;
				if (count _a == 0) then {_a = [player]};
				{
					localNameSpace setVariable ["mdhCASAllowedCaller",_a];
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
								if (time < 3) exitWith {};
								_debug = profileNameSpace getVariable ["mdhCASModDebug",false];
								if (_debug) then {systemChat "MDH CAS Debug mode active"};
								_timeout = profileNameSpace getVariable['mdhCASModTimeout',60];
								_arrival = profileNameSpace getVariable['mdhCASModTimeArrival',15];
								localNameSpace setVariable['mdhCASModCallTime',time + _timeout + _arrival];
								if (_debug && {name player == "Moerderhoschi"}) then {localNameSpace setVariable['mdhCASModCallTime',time + 1]};
								if (_debug && {name player == "Moerderhoschi"}) then {_arrival = 5};
								_r = selectRandom [0,1,2];
								_r = str(_r);
								_l = "B";
								if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] == 2) then
								{
									if (side group player == east) then {_l = "O"};
									if (side group player == resistance) then {_l = "I"};
								};

								playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\01_CasRequested\mp_groundsupport_01_casrequested_"+_l+"HQ_"+_r+".ogg"];
								_counter = 99;
								for "_i" from 0 to _arrival do
								{
									_arrival = profileNameSpace getVariable['mdhCASModTimeArrival',15];
									_limit = if (_arrival > 60 && {_arrival - _i > 60}) then {60} else {15};
									if (_counter >= _limit && {_arrival - _i > 0}) then
									{
										systemChat ("Close Air Support called ETA " + (if (_arrival - _i > 59) then {str((_arrival - _i)/60) + " min"} else {str(_arrival - _i) + " sec"}));
										_counter = 0;
									};
									if (_i > _arrival) exitWith {};
									_counter = _counter + 1;
									sleep 1;
								};

								_t = player;
								_tM1 = player;
								_tM2 = player;
								_enemySides = [];
								{if ((side group player) getFriend _x < 0.6) then {_enemySides pushBack _x}} forEach [east,west,resistance];
								_v = [];
								for "_i" from 4 to 30 do {_v pushBack (_i*50)};
								_min = profileNameSpace getVariable ["mdhCASModMinDistance",25];
								_callMode = profileNameSpace getVariable ["mdhCASModCallMode",0];
								if (_debug && {name player == "Moerderhoschi"}) then {_min = 1};
								_AA = [];
								_mbt = [];
								_cars = [];
								_tanks = [];
								_AAmoving = [];
								_mbtMoving = [];
								_carsMoving = [];
								_tanksMoving = [];

								_strikePos = getPos vehicle player;

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
												_min = 0;
											};
										};
									} forEach allMapMarkers;

									if (_min != 0) then
									{
										{
											if ("cas" in toLowerANSI(markerText _x)) exitWith
											{
												_MapLocation = 2;
												_markerText = markerText _x;
												_strikePos = getmarkerPos _x;
												_min = 0;
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
											_min = 0;
											//_v = [];
											//for "_i" from 1 to 6 do {_v pushBack (_i*50)};
										};
									} forEach _n;
								};

								_dist = _v;
								{
									_AA = [];
									_mbt = [];
									_cars = [];
									_tanks = [];
									_AAmoving = [];
									_mbtMoving = [];
									_carsMoving = [];
									_tanksMoving = [];
									_v = _x;
									{
										if (alive _x && {side _x in _enemySides} && {_x distance _strikePos > _min} && {_x distance _strikePos < _v }) then
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
									} forEach vehicles;

									{
										if (_t == player && {count _x > 0}) then {_x sort true; _t = _x#0#1};
									} forEach [_mbt, _AA, _tanks, _cars, _mbtMoving, _AAmoving, _tanksMoving, _carsMoving];									

									if (_t == player && {_v >= 300 && _redSmoke == 2 or _v >= 500}) then
									{
										_units = [];
										{
											if (alive _x && {side _x in _enemySides} && {_x distance _strikePos > _min} && {_x distance _strikePos < _v }) then
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
									if (_redSmoke == 2 && {_v >= 300}) exitWith {};
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

								if (_t == player or (_redSmoke == 1 && (profileNameSpace getVariable ["mdhCASModNoRedSmokeThenAbort",0] == 1)) or _MapLocation == 1) exitWith
								{
									playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\05_CasAborted\mp_groundsupport_05_casaborted_"+_l+"HQ_"+_r+".ogg"];
									systemChat "Close Air Support canceled no valid targets found";
									_s = "(to close or to far from caller)";
									if (_MapLocation == 1) then {_s = ("(no map marker with CAS in name found)")};
									if (_MapLocation == 2) then {_s = ('(no targets found at map marker "' + _markerText + '")')};
									if (_redSmoke == 1) then {_s = "(no red smoke around 1000 meter of caller found)"};
									systemChat _s;
									localNameSpace setVariable['mdhCASModCallTime',time + 5];
								};

								if (_redSmoke == 1) then {systemChat "no red smoke around 1000 meter of caller found"; systemChat "(Attacking nearest Target)"};

								_logic = "logic" createVehicleLocal getPos _t;
								_logic setPos getPos _t;
								_logic attachTo [_t,[0,0,0]];

								_side = "West";
								if (side group player == east) then {_side = "East"};
								if (side group player == resistance) then {_side = "Inde"};
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
									_planePylon = [];
									_planeWeapons = [];
									_planeMagazines = [];
									_planeClass = "B_Plane_CAS_01_F";
									if (side group player == east) then {_planeClass = "O_Plane_CAS_02_F"};
									if (side group player == resistance) then {_planeClass = "I_Plane_Fighter_03_CAS_F"};
								};

								_planeCfg = configfile >> "cfgvehicles" >> _planeClass;
								if !(isclass _planeCfg) exitwith {["Vehicle class '%1' not found",_planeClass] call bis_fnc_error; false};

								_weaponTypes = ["machinegun","bomblauncher","missilelauncher","rocketlauncher","vehicleweapon","horn"];
								_weapons = [];
								_missilelauncher = [];
								_weaponsSorted = [0,0,0,0];
								{
									_type = toLowerANSI((_x call bis_fnc_itemType) select 1);
									if(_type in _weaponTypes) then
									{
										_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
										if (count _modes > 0) then
										{
											_mode = _modes select 0;
											if (_mode == "this") then {_mode = _x};
											if (_type in ["machinegun","bomblauncher","missilelauncher","rocketlauncher"]) then {_weapons set [count _weapons,[_x,_mode]]};

											if (_type == "machinegun" && {typename(_weaponsSorted#0)=="SCALAR"}) exitWith {_weaponsSorted set [0,[[_x,_mode]]]};
											if (_type == "machinegun") exitWith {(_weaponsSorted#0) pushBackUnique [_x,_mode]};

											if (_type == "bomblauncher" && {_x in ["vn_bomb_blu1b_500_fb_launcher","vn_bomb_blu1b_750_fb_launcher"]} && {typename(_weaponsSorted#3)=="SCALAR"}) exitWith {_weaponsSorted set [3,[[_x,_mode]]]};
											if (_type == "bomblauncher" && {_x in ["vn_bomb_blu1b_500_fb_launcher","vn_bomb_blu1b_750_fb_launcher"]}) exitWith {(_weaponsSorted#3) pushBackUnique [_x,_mode]};
											
											if (_type == "bomblauncher" && {typename(_weaponsSorted#1)=="SCALAR"}) exitWith {_weaponsSorted set [1,[[_x,_mode]]]};
											if (_type == "bomblauncher") exitWith {(_weaponsSorted#1) pushBackUnique [_x,_mode]};

											if (_type == "rocketlauncher" && {typename(_weaponsSorted#2)=="SCALAR"}) exitWith {_weaponsSorted set [2,[[_x,_mode]]]};
											if (_type == "rocketlauncher") exitWith {(_weaponsSorted#2) pushBackUnique [_x,_mode]};

											if (_type == "missilelauncher") exitWith {_missilelauncher pushBackUnique _x};

											_w = _x;
											{
												if (_x in compatibleMagazines _w) then
												{
													_ammo = gettext(configfile >> "CfgMagazines" >> _x >> "ammo");
													_irLock = getNumber(configFile >> "CfgAmmo" >> _ammo >> "irLock");
													_airLock  = getNumber(configFile >> "CfgAmmo" >> _ammo >> "airLock");
													_canLock = getNumber(configfile >> "CfgWeapons" >> _w >> "canLock");
													_laserLock = getNumber(configFile >> "CfgAmmo" >> _ammo >> "laserLock");
													_lockType = getNumber(configFile >> "CfgAmmo" >> _ammo >> "lockType");
													_autoSeekTarget = getNumber(configFile >> "CfgAmmo" >> _ammo >> "autoSeekTarget");
													_newSensors = configName(configfile >> "CfgAmmo" >> _ammo >> "Components" >> "SensorsManagerComponent" >> "Components");

													if (_ammo isKindOf "BulletCore") exitWith
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
														if (typename(_weaponsSorted#1)=="SCALAR") then
														{
															_weaponsSorted set [1,[[_w,_mode]]];
														}
														else
														{
															(_weaponsSorted#1) pushBackUnique [_w,_mode];
														};
													};

													if (_ammo isKindOf "MissileBase" && {_airLock == 0} && {_autoSeekTarget == 0} && {_laserLock == 0} && {_irLock == 0} && {_newSensors == ""}) exitWith
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

													if (_ammo isKindOf "MissileBase" && {_airLock < 2} && {_lockType == 0} && {_autoSeekTarget == 1 OR _laserLock == 1 OR _irLock == 1 OR _newSensors != ""}) exitWith
													{
														_weapons set [count _weapons,[_w,_mode]];
														_missilelauncher pushBackUnique _w;
													};
												};
											} forEach _planeMagazines;
										};
									};
								} foreach (if (count _planeWeapons == 0) then {(_planeClass call bis_fnc_weaponsEntityType)} else {_planeWeapons});
								if (count _weapons == 0) exitwith {["No weapon of types %2 found on '%1'",_planeClass,_weaponTypes] call bis_fnc_error; false};

								//systemChat str(_weapons);
								_weapons = _weaponsSorted;
								//systemChat str(_weapons + _missilelauncher);

								_posATL = getposATL _logic;
								_pos = +_posATL;
								_pos set [2,(getPosASL _t)#2];
								_dir = direction _logic;
								_dis = 3000;
								_alt = 1000;
					
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
		
								playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\50_Cas\mp_groundsupport_50_cas_"+_l+"HQ_"+_r+".ogg"];
								_s = "Close Air Support incomming";
								if (_MapLocation == 2) then {_s = ('Close Air Support incomming on map marker "' + _markerText + '"')};
								if (_redSmoke == 2) then {_s = "Close Air Support incomming on red smoke"};
								systemChat _s;
		
								_z="--- Create plane";
								_planeSide = side group player;
								if (_planeSide == CIVILIAN) then
								{
									if !(resistance in _enemySides) then {_planeSide = resistance; _planeClass = "I_Plane_Fighter_03_CAS_F"};
									if !(east in _enemySides)       then {_planeSide = east;       _planeClass = "O_Plane_CAS_02_F"};
									if !(west in _enemySides)       then {_planeSide = west;       _planeClass = "B_Plane_CAS_01_F"};
								};
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
								//player setDir (player getDir _plane);
		
								if (_debug) then
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
										
										drawLine3D [getPos _plane, getPos _logic, [1,0,0,1],10];
										_tmpPos = +_planePos;
										_tmpPos set [2, _h];
										if (name player == "Moerderhoschi") then {drawLine3D [_tmpPos, getPos _logic, [0,1,0,1],10]};
										{
											if (alive _x) then
											{
												_color = [1,0,0,1];
												_tSize = 0.032;
												_pos = unitAimPositionVisual _x;
												_s = "";
												if (_x == _t) then {_s = _s + "Bomb"};
												if (_x == _tM1) then {_s = _s + " AGM1"};
												if (_x == _tM2) then {_s = _s + " AGM2"};
												if (_x == _plane) then {_s = "CAS Plane"; _color = [0,0,0.5,1]};
												drawIcon3D ["\a3\ui_f\data\Map\VehicleIcons\iconExplosiveGP_ca.paa", _color, _pos, 1, 1, 0,_s, 1, _tSize];
											}
										} forEach [_t,_tM1,_tM2,_plane];
									},[_t,_tM1,_tM2,_plane,_planePos,_logic,_h]];
									[_eh,_plane]spawn{params["_eh","_plane"];_time = time + 35; waitUntil{sleep 1; time > _time or !alive _plane};removeMissionEventHandler["Draw3D",_eh]};
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
									_fireDist = 2000;
									
									if (TRUE && {(getposasl _plane) distance _pos < (_fireDist + 900)} && {damage _plane < 0.2} && {_fireNull} && {_tM1 != player} && {_plane getVariable["mdhMissileNotFired",true]}) then
									{
										_plane setVariable["mdhMissileNotFired",false];
										[_plane,_tM1,_tM2,_missilelauncher] spawn
										{
											params["_plane","_tM1","_tM2","_missilelauncher"];
											if (count _missilelauncher == 0) exitWith {};
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
																_irLock = getNumber(configFile >> "CfgAmmo" >> _ammo >> "irLock");
																_airLock  = getNumber(configFile >> "CfgAmmo" >> _ammo >> "airLock");
																_canLock = getNumber(configfile >> "CfgWeapons" >> _w >> "canLock");
																_laserLock = getNumber(configFile >> "CfgAmmo" >> _ammo >> "laserLock");
																_lockType = getNumber(configFile >> "CfgAmmo" >> _ammo >> "lockType");
																_autoSeekTarget = getNumber(configFile >> "CfgAmmo" >> _ammo >> "autoSeekTarget");
																_newSensors = configName(configfile >> "CfgAmmo" >> _ammo >> "Components" >> "SensorsManagerComponent" >> "Components");
																if (_airLock < 2 && {_lockType == 0} && {_laserLock == _i} && {_autoSeekTarget == 1 OR _irLock == 1 OR _newSensors != ""}) then
																{
																	for "_i2" from 1 to _ammoCount do {_m pushBack _w};
																};
															};
														};
													} forEach magazines _plane;
												} forEach [0,1];
											} foreach _missilelauncher;
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
											sleep 3;
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

											waituntil
											{
												{
													if (true) then
													{
														if ((_x#0) == "RHS_weap_gau8") exitWith {_planeDriver forceWeaponFire [(_x#0), "HighROF"]};
														if ((_x#0) == "CUP_Vacannon_GAU8_veh") exitWith {_planeDriver forceWeaponFire [(_x#0), "2sec"]};
														_planeDriver fireattarget [_target,(_x#0)];
													};
												} foreach _machinegun;
												_specialWeapsGo = 400;
												_pullUp = 250;
												if (count _rocketlauncher > 0 && {"RHS_A10" in typeof _plane OR "CUP_B_A10" in typeof _plane}) then {_specialWeapsGo = 200; _pullUp = 130};
												if ((getPos _plane #2) < _specialWeapsGo) then {{_planeDriver fireattarget [_target,(_x#0)]} foreach _rocketlauncher};
												//if (count _napalmlauncher > 0) then {_specialWeapsGo = 200; _pullUp = 130};
												if ((getPos _plane #2) < _specialWeapsGo) then {
												{
													_planeDriver fireattarget [_target,(_x#0)];
													_b = nearestObjects [_plane, ["BombCore"], 20];
													if (count _b != 0) then
													{
														{
//setAccTime 0.3;
															_b = _x;
															if !(_b getVariable ["mdhCASBombGuided",false]) then
															{
																_b setVariable ["mdhCASBombGuided",true];
																[_b,_plane] spawn
																{
																	params["_b","_plane"];
																	//_time = time;
																	//while {alive _plane && {_time+2 > time}} do
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
												sleep 0.1;
												time > _time || (getPos _plane #2) < _pullUp || isnull _plane || damage _plane > 0.2
											};
											sleep 1;
//[_planeDriver,_target,_napalmlauncher]spawn{params["_planeDriver","_target","_napalmlauncher"];sleep 1.5;for "_i" from 1 to 20 do{{_planeDriver fireattarget [_target,(_x#0)]} foreach _napalmlauncher;sleep 0.1}};
										};
									};
							
									sleep 0.01;
									scriptdone _fire || isnull _logic || isnull _plane || damage _plane > 0.2
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
						localNameSpace setVariable["mdhCASCode",_hoschisCASCode];

						[
							_b
							,_t
							,"mdhCAS\mdhCAS.paa"
							,"mdhCAS\mdhCAS.paa"
							,"
							alive _target 
							&& {profileNameSpace getVariable ['mdhCASModActionmenu',true]}
							&& {localNameSpace getVariable['mdhCASModCallTime',time - 1] < time}
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
					};
				} forEach _a;
				
				//if (isMultiplayer OR {worldName != "VR"}) exitWith {};
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
					if (_v == 7) then {profileNameSpace setVariable ["mdhCASPlaneInde1",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 8) then {profileNameSpace setVariable ["mdhCASPlaneInde2",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};
					if (_v == 9) then {profileNameSpace setVariable ["mdhCASPlaneInde3",[typeof _target, getObjectTextures _target, getAllPylonsInfo _target, weapons _target, magazines _target]]};

					_t = "West";
					if (_v > 3 && _v < 7) then {_t = "East"};
					if (_v > 6) then {_t = "Independent"};

					_t = "plane saved for MDH CAS side " + _t;
					if (_v == 0) then {_t = "MDH CAS all saved planes cleared"};
					if (_v == 0) then { {_n = _x; { profileNameSpace setVariable [("mdhCASPlane"+_x+_n),nil]} forEach ["West","East","Inde"]} forEach ["","1","2","3"] };
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
							if (_x == 7) then {_t = _t + "independent plane 1"};
							if (_x == 8) then {_t = _t + "independent plane 2"};
							if (_x == 9) then {_t = _t + "independent plane 3"};
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
									_weaponTypes = ['machinegun','bomblauncher','missilelauncher','rocketlauncher','vehicleweapon','horn'];
									_weapons = [];
									{
										_type = toLowerANSI((_x call bis_fnc_itemType) select 1);
										if(_type in _weaponTypes) then
										{
											_modes = getarray (configfile >> 'cfgweapons' >> _x >> 'modes');
											if (count _modes > 0) then
											{
												_mode = _modes select 0;
												if (_mode == 'this') then {_mode = _x};
												if (_type in ['machinegun','bomblauncher','missilelauncher','rocketlauncher']) then {_weapons set [count _weapons,[_x,_mode]]};
	
												_w = _x;
												{
													if (_x in compatibleMagazines _w) then
													{
														_ammo = gettext(configfile >> 'CfgMagazines' >> _x >> 'ammo');
														_irLock = getNumber(configFile >> 'CfgAmmo' >> _ammo >> 'irLock');
														_airLock  = getNumber(configFile >> 'CfgAmmo' >> _ammo >> 'airLock');
														_canLock = getNumber(configfile >> 'CfgWeapons' >> _w >> 'canLock');
														_laserLock = getNumber(configFile >> 'CfgAmmo' >> _ammo >> 'laserLock');
														_lockType = getNumber(configFile >> 'CfgAmmo' >> _ammo >> 'lockType');
														_autoSeekTarget = getNumber(configFile >> 'CfgAmmo' >> _ammo >> 'autoSeekTarget');
														_newSensors = configName(configfile >> 'CfgAmmo' >> _ammo >> 'Components' >> 'SensorsManagerComponent' >> 'Components');
	
														if (_ammo isKindOf 'BulletCore') exitWith {_weapons set [count _weapons,[_w,_mode]]};
	
														if (_ammo isKindOf 'BombCore') exitWith {_weapons set [count _weapons,[_w,_mode]]};
	
														if (_ammo isKindOf 'MissileBase' && {_airLock == 0} && {_autoSeekTarget == 0} && {_laserLock == 0} && {_irLock == 0} && {_newSensors == ''}) exitWith
														{_weapons set [count _weapons,[_w,_mode]]};
	
														if (_ammo isKindOf 'MissileBase' && {_airLock < 2} && {_lockType == 0} && {_autoSeekTarget == 1 OR _laserLock == 1 OR _irLock == 1 OR _newSensors != ''}) exitWith
														{_weapons set [count _weapons,[_w,_mode]]};
													};
												} forEach magazines _target;;
											};
										};
									} foreach (weapons _target);
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