///////////////////////////////////////////////////////////////////////////////////////////////////
// MDH CAS MOD(by Moerderhoschi) - v2025-08-20
// github: https://github.com/Moerderhoschi/arma3_mdhCAS
// steam mod version: https://steamcommunity.com/sharedfiles/filedetails/?id=3473212949
///////////////////////////////////////////////////////////////////////////////////////////////////
_hoschisBlackfishCode =
{
	params ["_target"];
	_target spawn 
	{
		if !(hasInterface) exitWith {};
		scriptName "mdhSpawnCASGunship";

		if (time < 3) exitWith {systemChat "try again in 3 sek"};
		if (isNil"mdhCASModBlackfishSpawned") then {mdhCASModBlackfishSpawned = []};
		_debug = profileNameSpace getVariable ["mdhCASModDebug",false];
		if (_debug) then {systemChat "MDH CAS Debug mode active"};
		_timeout = profileNameSpace getVariable['mdhCASModTimeout',60];
		_arrival = profileNameSpace getVariable['mdhCASModTimeArrival',15];
		_callMode = profileNameSpace getVariable ["mdhCASModCallMode",0];
		missionNameSpace setVariable['mdhCASModCallTime',time + _timeout + _arrival];
		//if (_debug && {name player == "Moerderhoschi"}) then {missionNameSpace setVariable['mdhCASModCallTime',time + 1]};
		//if (_debug && {name player == "Moerderhoschi"}) then {_arrival = 5};
		_r = selectRandom [0,1,2];
		_r = str(_r);
		_l = "B";
		if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] == 2) then
		{
			if (side group player == east) then {_l = "O"};
			if (side group player == resistance) then {_l = "I"};
		};

		if (missionNameSpace getVariable['mdhCASModBlackfishActive',0] == 1) exitWith
		{
			if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] != 0) then
			{
				playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\05_CasAborted\mp_groundsupport_05_casaborted_"+_l+"HQ_"+_r+".ogg"];
			};
			systemChat "Close Air Support canceled";

			missionNameSpace setVariable['mdhCASModBlackfishActive',0];
			{_x setVariable["mdhAc130End",true]} forEach mdhCASModBlackfishSpawned;
			mdhCASModBlackfishSpawned = [];
		};

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

		missionNameSpace setVariable['mdhCASModBlackfishActive',1];

		if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] != 0) then
		{
			playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\01_CasRequested\mp_groundsupport_01_casrequested_"+_l+"HQ_"+_r+".ogg"];
		};
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
			if (_i > _arrival or (missionNameSpace getVariable['mdhCASModBlackfishActive',0] == 0)) exitWith {};
			_counter = _counter + 1;
			sleep 1;
		};

		if (missionNameSpace getVariable['mdhCASModBlackfishActive',0] == 0) exitWith {};
		_t = player;
		_safeDistance = 1;

		_strikePosMode = 1;
		if !(_callMode in [6,7]) then {_strikePos = getPos vehicle player};

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
						_strikePosMode = 2;
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
						_strikePosMode = 2;
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
					_strikePosMode = 2;
					_redSmokeShell = _x;
					_safeDistance = 0;
				};
			} forEach _n;
		};

		_redSmokeLogic = player;
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

		if (_callMode in [6,7]) then {_strikePosMode = 2};
		if (_callMode == 7) then
		{
			_t = "logic" createVehicleLocal _strikepos;
			_redSmokeLogic = _t;
			_t spawn {sleep 60; deleteVehicle _this};
		};

		if (_redSmoke == 1 && (profileNameSpace getVariable ["mdhCASModNoRedSmokeThenAbort",0] == 1) or _MapLocation == 1) exitWith
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
			missionNameSpace setVariable['mdhCASModBlackfishActive',0];
		};

		if (profileNameSpace getVariable ["mdhCASModVoicelanguage",1] != 0) then
		{
			playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\50_Cas\mp_groundsupport_50_cas_"+_l+"HQ_"+_r+".ogg"];
		};
		_s = "Close Air Support incomming";
		if (_MapLocation == 2) then {_s = ('Close Air Support incomming on map marker "' + _markerText + '"')};
		if (_redSmoke == 2) then {_s = "Close Air Support incomming on red smoke"};
		systemChat _s;

		_pos = _strikePos;
		_side = side group player;
		_pos = [_pos#0, _pos#1, 1];
		_planeClass = "B_T_VTOL_01_armed_F";
		if (isclass(configfile >> "cfgvehicles" >> "USAF_AC130U")) then {_planeClass = "USAF_AC130U"};
		if (isclass(configfile >> "cfgvehicles" >> "vnx_b_air_ac119_01_01")) then {_planeClass = "vnx_b_air_ac119_01_01"};
		_v = [[(0 + (ceil random 20)*10),(0 + (ceil random 20)*10), (2000+(ceil random 20)*10)], 0, _planeClass, _side] call BIS_fnc_spawnVehicle;
		_v = _v#0;
		_v setpos [(_pos#0 + (ceil random 20)*10), (_pos#1 + (ceil random 20)*10), (2000+(ceil random 20)*10)];
		mdhCASModBlackfishSpawned pushBack _v;
		_v setVelocityModelSpace [0, 100, 0];
		sleep 0.1;
		{_x setSkill 1; _x disableAI "WEAPONAIM"; _x disableAI "RADIOPROTOCOL"} forEach crew _v;
		sleep 0.1;
		_v engineOn true;
		_h = 800;
		_v flyInHeight 200;
		_v flyInHeightASL [_h,_h,_h];
		_g = group driver _v;
		_d = driver _v;
		sleep 0.2;
		_g setBehaviour "CARELESS";
		_w = _g addWaypoint [_pos, 5];
	
		while {sleep 0.1 ; waypointLoiterType _w != "CIRCLE_L"} do
		{
			_w setWaypointBehaviour "CARELESS";
			_w setWaypointType "LOITER";
			_w setWaypointLoiterAltitude _h;
			_w setWaypointLoiterRadius 1500;
			_w setWaypointLoiterType "CIRCLE_L";
			_w setWaypointSpeed "NORMAL";
			_v flyInHeight 200;
			_v flyInHeightASL [_h,_h,_h];
		};
	
		_v setVehicleLock "LOCKED";
		_grp = createGroup _side;
	
		_u  = _v turretUnit [1];
		_u2 = _v turretUnit [2];
		[_u, _u2] joinSilent _grp;
		_u setCombatBehaviour "AWARE";
		_u2 setCombatBehaviour "AWARE";
		_grp setCombatMode "YELLOW";
		_u setCombatMode "YELLOW";
		_u2 setCombatMode "YELLOW";
	
		_es = [];
		if (_side getFriend east < 0.6) then {_es pushBack east};
		if (_side getFriend west < 0.6) then {_es pushBack west};
		if (_side getFriend resistance < 0.6) then {_es pushBack resistance};
	
		if (1>0) then
		{
			[_g, 1] setwaypointLoiterRadius 1000;
			[_g, 1] setWaypointPosition [_strikePos, 20];
	
			_v setVariable["mdhAc130StartTime",time];
			_lg = 240;
			_rg = 300;

			if (_debug) then
			{
				_eh = addMissionEventHandler[ "Draw3D",
				{
					_v = _thisArgs#0;
					_wPos = (WaypointPosition[group driver _v,1]);
					if (alive _v) then
					{
						{
							if (_x != player) then
							{
								_distX = 5000;
								_dist = vehicle player distance _x;
								if (_dist < _distX)then
								{
									_color = [0.5,0,0.5,1 - (_dist / _distX)];
									if (side _x == WEST) then {_color = [0,0,1,1 - (_dist / _distX)]};
									if (side _x == EAST) then {_color = [1,0,0,1 - (_dist / _distX)]};
									if (side _x == Independent) then {_color = [0,1,0,1 - (_dist / _distX)]};
									_tSize=0.032;
									_pos = unitAimPositionVisual _x;
									_t = "mdhGunshipTarget";
									if (alive _x) then {drawIcon3D ["\a3\ui_f\data\Map\VehicleIcons\iconExplosiveGP_ca.paa", _color, _pos, 1, 1, 0,_t, 1, _tSize]};
									drawIcon3D ["\a3\ui_f\data\Map\VehicleIcons\iconExplosiveGP_ca.paa", [0,0,1,1], getPos _v, 1, 1, 0,"mdhGunship", 1, _tSize];
									drawIcon3D ["\a3\ui_f\data\Map\VehicleIcons\iconExplosiveGP_ca.paa", [0,0,1,1], _wPos, 1, 1, 0,"_wPos", 1, _tSize];
								}
							}
						} forEach [(_v getVariable ["mdhAc130Target",(_v findNearestEnemy _v)])];
					};
				},[_v]];
				[_eh,_v]spawn{params["_eh","_v"];_time = time + 600; waitUntil{sleep 1; time > _time or _v getVariable["mdhAc130End",false] or !alive _v};removeMissionEventHandler["Draw3D",_eh]};
			};

			while{((_v getVariable["mdhAc130StartTime",0])+600) > time && !(_v getVariable["mdhAc130End",false]) && {alive _v} && {damage _v < 0.2}} do
			{
				if (1>0) then
				{
					if ((_v getVariable ["mdhAc130LastFired",-1]) == -1) then
					{
						_v setVariable["mdhAc130LastFired",time];
						_v addEventHandler ["fired",
						{
							params ["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_gunner"];
							_v = _unit;
							_u = gunner _v;
							_p = _projectile;
							_v setVehicleAmmo 1;
							_v setVariable["mdhAc130LastFired",time];

							_e = _v getVariable ["mdhAc130Target",(_v findNearestEnemy _v)];
							_random = {random 10 - random 10};
							_r = (_v getRelDir _e) + getDir _v;
							if (_r > 360) then {_r = _r - 360};
							_p setDir _r;

							if (1>0) then
							{
								_object = _p;
								_speed = speed _p;
								
								_origin = getPosASL _object;
								_target = getPosASL _e;
								
								_vdir = _origin vectorFromTo _target;
								_vlat = vectorNormalized (_vdir vectorCrossProduct [0,0,1]);
								_vup = _vlat vectorCrossProduct _vdir;
								
								_object setVectorDirAndUp [_vdir, _vup];
								
								_vel = _vdir vectorMultiply _speed;
								_object setVelocity _vel;
							};
	
							if (1>0) then
							{
								if (_ammo == "B_20mm_Tracer_Red") then {_random = {random 20 - random 20}};
								if (_ammo == "USAF_PGU_25_HEI") then {_random = {random 20 - random 20}};
								_p setVelocity
								[
									(velocity _p#0) + (call _random),
									(velocity _p#1) + (call _random),
									(velocity _p#2) + (call _random)
								];
							};
						}];
					};
				};
				
				if (1>0 && {!(_v getVariable["mdhAc130CheckASL",false])}) then
				{
					_v setVariable["mdhAc130CheckASL",true];
					[_v] spawn
					{
						params["_v"];
						_a = [];
						sleep 35;
						while {sleep 3; alive _v && {!(_v getVariable["mdhAc130End",false])}} do
						{
							_h = (_v getVariable ["mdhAc130FlyInHeight",500]);
							_p = (getPos _v#2);
							_a pushBack _p;
							if (count _a > 25) then {_a deleteAt 0};
							_m = selectMin _a;
							if (_p < 300) then {_h = _h + 30};
							if (_p < 250) then {_h = _h + 30};
							if (_p < 200) then {_h = _h + 30};
							if (_p < 150) then {_h = _h + 30};
							if (_p < 100) then {_h = _h + 30};
							if (_m > 400) then {_h = _h - 5};
							if (_m > 450) then {_h = _h - 5};
							if (_m > 500) then {_h = _h - 5};
							if (_h < 500) then {_h = 500};
							_v setVariable ["mdhAc130FlyInHeight",_h];
							_v flyInHeightASL [_h,_h,_h];
							if (profileNameSpace getVariable ["mdhCASModDebug",false]) then 
							{
								systemChat
								(
									"mdhAc130"
									+"  SetASL: "+str(_v getVariable ["mdhAc130FlyInHeight",0])
									+", ASL: "+str(round(getPosASL _v#2))
									+", AGL: "+str(round(getPos _v#2))
									+", minAGL: "+str(round(_m))
								);
							}							
						};
					};
				};
	
				if(alive _v) then
				{
					_safeDistance = 50;
					sleep 3;
					if (alive _v && {((_v getVariable ["mdhAc130StartTime",0])+5) < time} && {((_v getVariable ["mdhAc130LastFired",0])-5) < time}) then
					{
						_units = [];
						_units200 = [];
						_units400 = [];
						_units600 = [];
						_units800 = [];
						_units999 = [];

						if (profileNameSpace getVariable['mdhCASModCallMode',0] in [3,7]) then
						{
							if (!isNil "_redSmokeLogic" && {alive _redSmokeLogic} && {_redSmokeLogic != player}) then
							{
								_units = [_redSmokeLogic]
							};
						};

						if (count _units == 0) then 
						{
							_wPos = (WaypointPosition[_g,1]);
							{
								_w = _x;
								{
									_j = _x distance2D _wPos;
									if
									(
										alive _x 
										&& {alive _v}
										&& {_j < 1000} 
										&& {_x distance2D _v > 500} 
										&& {speed _x < 16}
										&& {(_v getRelDir _x)>_lg} 
										&& {(_v getRelDir _x)<_rg} 
										&& {_t1 = _x; allPlayers findIf {side group _x getFriend side group player > 0.5 && {vehicle _x distance _t1 < _safeDistance}} == -1} 
										&& {([_v, "VIEW", vehicle _x] checkVisibility [eyePos _u, eyePos _x]) > 0}
									)
									then
									{
										_k = false;
										if (!_k && {_j < 200}) then {_k = true; _units200 pushBackUnique _x};
										if (!_k && {_j < 400}) then {_k = true; _units400 pushBackUnique _x};
										if (!_k && {_j < 600}) then {_k = true; _units600 pushBackUnique _x};
										if (!_k && {_j < 800}) then {_k = true; _units800 pushBackUnique _x};
										if (!_k && {_j < 999}) then {_k = true; _units999 pushBackUnique _x};
									};
								} forEach units _w
							} forEach _es;
							
							_k = false;
							if (!_k && {count _units200 > 0}) then {_k = true; _units = _units200};
							if (!_k && {count _units400 > 0}) then {_k = true; _units = _units400};
							if (!_k && {count _units600 > 0}) then {_k = true; _units = _units600};
							if (!_k && {count _units800 > 0}) then {_k = true; _units = _units800};
							if (!_k && {count _units999 > 0}) then {_k = true; _units = _units999};
						};

						if (count _units > 0 && {alive _v}) then
						{
							_e = vehicle(selectRandom (_units));
							if (_t != player && {alive _t}) then {_e = _t};
							_v setVariable ["mdhAc130Target",_e];

							sleep 0.1;
							if (1>0 && {alive _v}) then
							{
								if (1>0 && {alive _v}) then
								{
									for "_i" from 1 to 2 do
									{
										_j = if (alive _e) then {true} else {false};
										_k = if (_i < 2) then {1} else {random 1};
										if (_j && {_k > 0.5}) then
										{
											for "_i2" from 1 to (20 + ceil(random 10)) do
											{
												if (alive _v) then
												{
													sleep (1/15);
													if (_planeClass == "B_T_VTOL_01_armed_F") then {_v action ["useWeapon", _v, _u, 5]};
													if (_planeClass == "USAF_AC130U") then {_v action ["useWeapon", _v, _v turretUnit[2], 2]};
													if (_planeClass == "vnx_b_air_ac119_01_01") then {_v action ["useWeapon", _v, _v turretUnit[1], 5]};
													if (_planeClass == "vnx_b_air_ac119_01_01") then {_v action ["useWeapon", _v, _v turretUnit[1], 8]};
												}
											}
										};
									};
									sleep 1;
								};

								if (_planeClass == "vnx_b_air_ac119_01_01") exitWith {};
								_j = if (alive _e && {alive _v}) then {true} else {false};
								
								for "_i" from 1 to (7 + ceil(random 7)) do
								{
									if (vehicle _e == _e && {_j}) then
									{
										sleep 0.35;
										if (_planeClass == "B_T_VTOL_01_armed_F") then {_v action ["useWeapon", _v, _u2, 0]};
										if (_planeClass == "USAF_AC130U") then {_v action ["useWeapon", _v, _v turretUnit[2], 3]};
									}
								};
								sleep 0.6;
								
								for "_i" from 1 to (10 + ceil(random 5)) do
								{
									if (vehicle _e != _e && {_j}) then
									{
										sleep 0.35;
										if (_planeClass == "B_T_VTOL_01_armed_F") then {_v action ["useWeapon", _v, _u2, 5]};
										if (_planeClass == "USAF_AC130U") then {_v action ["useWeapon", _v, _v turretUnit[2], 3]};
									}
								};
								
								if (alive _e && {alive _v}) then
								{
									sleep 1;
									if (_planeClass == "B_T_VTOL_01_armed_F") then {_v action ["useWeapon", _v, _u, 0]};
									if (_planeClass == "USAF_AC130U") then {_v action ["useWeapon", _v, _v turretUnit[2], 4]};
								};
							}
							else
							{
								sleep 1
							};
						};
					};
				};
	
				if (_strikePosMode == 1 && {waypointPosition [_g, 1] distance2D vehicle player > 100}) then
				{
					if (1>0 && {vehicle player != _v}) then {[_g, 1] setWaypointPosition [position vehicle player, 20]};
				};
			};
		};

		sleep 1;
		missionNameSpace setVariable['mdhCASModBlackfishActive',0];
		if (alive _v) then
		{
			if (damage _v > 0.2) then {systemChat "Gunship taking Damage"};
			systemChat "Gunship Close Air Support finished";
			_v setVariable["mdhAc130End",true];
			[_g, 1] setWaypointSpeed "FULL";
			[_g, 1] setWaypointPosition [[0,0,0], 0];
			_v flyInHeight 2500;
			_v flyInHeightASL [2500,2500,2500];
			sleep 3;
			_v flyInHeight 2500;
			_v flyInHeightASL [2500,2500,2500];
			sleep 120;
			{deleteVehicle _x} forEach Crew _v;
			deleteVehicle _v;
		};
	};
};
missionNameSpace setVariable["mdhCASCodeBlackfish",_hoschisBlackfishCode];
