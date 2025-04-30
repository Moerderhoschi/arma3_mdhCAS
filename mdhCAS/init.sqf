///////////////////////////////////////////////////////////////////////////////////////////////////
// MDH CAS MOD(by Moerderhoschi) - v2025-04-30
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
							+ 'If you have any question you can contact me at the steam workshop page.<br/>'
							+ '<br/>'
							+ '<img image="'+(if(isNil"_path")then{""}else{_path})+'\mdhCAS.paa"/>'
							+ '<br/>'
							+ 'Credits and Thanks:<br/>'
							+ 'Armed-Assault.de Crew  for many great ArmA moments in many years<br/>'
							+ 'BIS For ArmA3<br/>'
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
				if (count _a == 0) then
				{
					_a = [player];
				};

				{
					_f = false;
					_b = _x;
					{
						if ((_b actionParams _x select 0) find _t >= 0) then
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
		
								_debug = true;
								_debug = false;
								//localNameSpace setVariable['mdhCASModCallTime',time + 120];
								localNameSpace setVariable['mdhCASModCallTime',time + 60];
								if (_debug) then {localNameSpace setVariable['mdhCASModCallTime',time + 1]};
								_r = selectRandom [0,1,2];
								_r = str(_r);
								playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\01_CasRequested\mp_groundsupport_01_casrequested_BHQ_"+_r+".ogg"];
								systemChat "Close Air Support called";
								if (_debug) then
								{
									sleep 5;
									//setAccTime 0.1;
								}
								else
								{
									sleep (10 + random 5);
								};

								_t = player;
								_tM1 = player;
								_tM2 = player;
								_enemySides = [];
								{if ((side group player) getFriend _x < 0.6) then {_enemySides pushBack _x}} forEach [east,west,resistance];
								_v = if (viewDistance > 1500) then {1500} else {viewDistance};
								_min = 25;
								if (_debug) then {_min = 0};
								_AA = [];
								_mbt = [];
								_cars = [];
								_tanks = [];
								_AAmoving = [];
								_mbtMoving = [];
								_carsMoving = [];
								_tanksMoving = [];
								{
									if (alive _x && {side _x in _enemySides} && {_x distance vehicle player > _min} && {_x distance vehicle player < _v }) then
									{
										_isAA = (getnumber(configFile >> "cfgVehicles" >> (typeOf _x) >> "irScanRangeMin") > 600);
										_isArty = (getnumber(configFile >> "cfgVehicles" >> (typeOf _x) >> "artilleryScanner") > 0);
										_isMBT = (toLowerANSI(typeOf _x) find "mbt") != -1;
		
										if (_x isKindOf "LAND" && {_isAA} && {speed _x == 0}) exitWith {_AA pushBack [_x distance vehicle player, _x]};
										if (_x isKindOf "LAND" && {_isAA} && {speed _x >  0}) exitWith {_AAmoving pushBack [_x distance vehicle player, _x]};
		
										if (_x isKindOf "TANK" && {!_isArty} && {_isMBT} && {speed _x == 0}) exitWith {_mbt pushBack [_x distance vehicle player, _x]};
										if (_x isKindOf "TANK" && {!_isArty} && {_isMBT} && {speed _x >  0}) exitWith {_mbtMoving pushBack [_x distance vehicle player, _x]};
		
										if (_x isKindOf "TANK" && {speed _x == 0}) exitWith {_tanks pushBack [_x distance vehicle player, _x]};
										if (_x isKindOf "TANK" && {speed _x >  0}) exitWith {_tanksMoving pushBack [_x distance vehicle player, _x]};
		
										if (_x isKindOf "CAR" && {speed _x == 0}) exitWith {_cars pushBack [_x distance vehicle player, _x]};
										if (_x isKindOf "CAR" && {speed _x == 0}) exitWith {_carsMoving pushBack [_x distance vehicle player, _x]};
									};
								} forEach vehicles;
								
								if (count _tanks > 0) then {_tanks sort true; _t = _tanks#0#1; _tanks deleteAt 0};
								if (_t == player && {count _cars > 0}) then {_cars sort true; _t = _cars#0#1; _cars deleteAt 0};
								if (_t == player) then
								{
									_units = [];
									{
										if (alive _x && {side _x in _enemySides} && {_x distance vehicle player > _min} && {_x distance vehicle player < _v }) then
										{
											_units pushBack [_x distance vehicle player, _x];
										}
									} forEach allUnits;
		
									if (count _units > 0) then
									{
										_units sort true;
										_t = _units#0#1;
									};
								};
		
								if (_t == player && {count _AA > 0}) then {_AA sort true; _t = _AA#0#1};
								if (_t == player && {count _mbt > 0}) then {_mbt sort true; _t = _mbt#0#1};
								if (_t == player && {count _AAmoving > 0}) then {_AAmoving sort true; _t = _AAmoving#0#1};
								if (_t == player && {count _mbtMoving > 0}) then {_mbtMoving sort true; _t = _mbtMoving#0#1};
								if (_t == player && {count _tanksMoving > 0}) then {_tanksMoving sort true; _t = _tanksMoving#0#1};
								if (_t == player && {count _carsMoving > 0}) then {_carsMoving sort true; _t = _carsMoving#0#1};
		
								_AAmoving = _AAmoving + _AA;
								_mbtMoving = _mbtMoving + _mbt;
								_dist = 500;
								if (count _AAmoving > 0) then {_AAmoving sort true; if((_AAmoving#0#1) distance _t < _dist*2 )then{_tM1 = _AAmoving#0#1}; _AAmoving deleteAt 0};
								if (_tM1 == player && {count _mbtMoving > 0}) then {_mbtMoving sort true; if((_mbtMoving#0#1) distance _t < _dist )then{_tM1 = _mbtMoving#0#1}; _mbtMoving deleteAt 0};
								if (_tM1 == player && {count _tanksMoving > 0}) then {_tanksMoving sort true; if((_tanksMoving#0#1) distance _t < _dist )then{_tM1 = _tanksMoving#0#1}; _tanksMoving deleteAt 0};
								if (_tM1 == player && {count _carsMoving > 0}) then {_carsMoving sort true; if((_carsMoving#0#1) distance _t < _dist )then{_tM1 = _carsMoving#0#1}; _carsMoving deleteAt 0};
								if (_tM1 == player && {count _tanks > 0}) then {if((_tanks#0#1) distance _t < _dist )then{_tM1 = _tanks#0#1}; _tanks deleteAt 0};
								if (_tM1 == player && {count _cars > 0}) then {if((_cars#0#1) distance _t < _dist )then{_tM1 = _cars#0#1}; _cars deleteAt 0};
								if (_tM1 == player && {_t isKindOf "TANK" OR _t isKindOf "CAR"}) then {_tM1 = _t};
		
								if (count _AAmoving > 0) then {_AAmoving sort true; if((_AAmoving#0#1) distance _t < _dist )then{_tM2 = _AAmoving#0#1}; _AAmoving deleteAt 0};
								if (_tM2 == player && {count _mbtMoving > 0}) then {_mbtMoving sort true; if((_mbtMoving#0#1) distance _t < _dist )then{_tM2 = _mbtMoving#0#1}; _mbtMoving deleteAt 0};
								if (_tM2 == player && {count _tanksMoving > 0}) then {_tanksMoving sort true; if((_tanksMoving#0#1) distance _t < _dist )then{_tM2 = _tanksMoving#0#1}; _tanksMoving deleteAt 0};
								if (_tM2 == player && {count _carsMoving > 0}) then {_carsMoving sort true; if((_carsMoving#0#1) distance _t < _dist )then{_tM2 = _carsMoving#0#1}; _carsMoving deleteAt 0};
								if (_tM2 == player && {count _tanks > 0}) then {if((_tanks#0#1) distance _t < _dist )then{_tM2 = _tanks#0#1}; _tanks deleteAt 0};
								if (_tM2 == player && {count _cars > 0}) then {if((_cars#0#1) distance _t < _dist )then{_tM2 = _cars#0#1}; _cars deleteAt 0};
								if (_tM2 == player && {_t isKindOf "TANK" OR _t isKindOf "CAR"}) then {_tM2 = _t};
		
								if (_t == player) exitWith
								{
									playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\05_CasAborted\mp_groundsupport_05_casaborted_BHQ_"+_r+".ogg"];
									systemChat "Close Air Support canceled, no valid targets found (not to close and not to far from caller)";
									localNameSpace setVariable['mdhCASModCallTime',time + 5];
								};
		
								_logic = "logic" createVehicleLocal getPos _t;
								_logic setPos getPos _t;
								_logic attachTo [_t,[0,0,0]];
							
								_planeClass = "B_Plane_CAS_01_F";
								if (side group player == east) then {_planeClass = "O_Plane_CAS_02_F"};
								if (side group player == resistance) then {_planeClass = "I_Plane_Fighter_03_CAS_F"};
								_planeCfg = configfile >> "cfgvehicles" >> _planeClass;
								if !(isclass _planeCfg) exitwith {["Vehicle class '%1' not found",_planeClass] call bis_fnc_error; false};
							
								_weaponTypes = ["machinegun","bomblauncher"];
								_weapons = [];
								{
									if (tolower ((_x call bis_fnc_itemType) select 1) in _weaponTypes) then
									{
										_modes = getarray (configfile >> "cfgweapons" >> _x >> "modes");
										if (count _modes > 0) then
										{
											_mode = _modes select 0;
											if (_mode == "this") then {_mode = _x;};
											_weapons set [count _weapons,[_x,_mode]];
										};
									};
		
								} foreach (_planeClass call bis_fnc_weaponsEntityType);
								if (count _weapons == 0) exitwith {["No weapon of types %2 wound on '%1'",_planeClass,_weaponTypes] call bis_fnc_error; false};
							
								_posATL = getposATL _logic;
								_pos = +_posATL;
								//_pos set [2,(_pos select 2) + getterrainheightasl _pos];
								_pos set [2,(getPosASL _t)#2];
								_dir = direction _logic;
								_dis = 3000;
								_alt = 1000;
					
								_pitch = atan (_alt / _dis);
								_speed = 400 / 3.6;
								_duration = ([0,0] distance [_dis,_alt]) / _speed;
							
								_h = 1;
								_planePos = [_pos,_dis,_dir + 180] call bis_fnc_relpos;
								
								//setAccTime 0.1;
								//if (_debug) then {_eh2 = addMissionEventHandler[ 'Draw3D',{_t=_thisArgs#0;_logic=_thisArgs#1;drawLine3D[_planepos,getpos _t,[0,0,1,1],10]},[_t,_logic]]};
		
								_h = 0;
								if (true) then
								{
									_a = 1;
									_c = 0;
									for "_i" from 1 to 10000 do
									{
										_a = _i;
										_h = _i/10;
										//_dir = selectRandom[0,30,60,90,120,150,180,210,240,270,300,330];
										_dir = random 360;
										_planePos = [eyePos _t,_dis,_dir + 180] call bis_fnc_relpos;
										_planePos set [2, _h];
										_tmpPos = eyePos _t;
										_tmpPos set [2,(_tmpPos#2)+1];
										_c = [_t,"VIEW"] checkVisibility [_planePos, _tmpPos];
										if (_debug) then {systemChat str(_planePos)};
										if (_c > 0) exitWith {};
									};
									//if (_debug) then {systemChat ("randomDirCounter: "+str(_a)+", checkVisibility: "+str(_c))};
								};
								//if (_debug) then {systemChat ("_planePosH: "+str(_planePos#2)+" , _tPosH: "+str((eyepos _t)#2))};
								_planePos set [2,(_pos#2) + _alt];
								_logic setDir _dir;
								//_logic setPos ([getPos _logic, 3, direction _logic] call bis_fnc_relpos);
		
		
								playSoundUI ["a3\dubbing_f_heli\mp_groundsupport\50_Cas\mp_groundsupport_50_cas_BHQ_"+_r+".ogg"];
								systemChat "Close Air Support incomming";
		
								_z="--- Create plane";
								_planeSide = side group player;
								_planeArray = [_planePos,_dir,_planeClass,_planeSide] call bis_fnc_spawnVehicle;
								_plane = _planeArray select 0;
								_planeDriver = driver _plane;
								_plane setposasl _planePos;
								_plane move ([_pos,_dis,_dir] call bis_fnc_relpos);
								_plane disableai "move";
								_plane disableai "target";
								_plane disableai "autotarget";
								_plane setcombatmode "blue";
		
								if (_debug) then
								{
									//setAccTime 0.1;
									_eh = addMissionEventHandler[ 'Draw3D',
									{
										_t = _thisArgs#0;
										_tM1 = _thisArgs#1;
										_tM2 = _thisArgs#2;
										_plane = _thisArgs#3;
										_planePos = _thisArgs#4;
										_logic = _thisArgs#5;
										_h = _thisArgs#6;
										
										//drawLine3D [getPos _plane, getPos _t, [1,0,0,1],10];
										drawLine3D [getPos _plane, getPos _logic, [1,0,0,1],10];
										_tmpPos = +_planePos;
										_tmpPos set [2, _h];
										//drawLine3D [_tmpPos, getPos _t, [0,1,0,1],10];
										drawLine3D [_tmpPos, getPos _logic, [0,1,0,1],10];
										{
											if (alive _x) then
											{
												_color = [1,0,0,1];
												_tSize = 0.032;
												_pos = unitAimPositionVisual _x;
												_t = "_t";
												if (_x == _tM1) then {_t = "_tM1"};
												if (_x == _tM2) then {_t = "_tM2"};
												if (_x == _plane) then {_t = "_plane"; _color = [0,0,0.5,1]};
												drawIcon3D ["\a3\ui_f\data\Map\VehicleIcons\iconExplosiveGP_ca.paa", _color, _pos, 1, 1, 0,_t, 1, _tSize];
											}
										} forEach [_t,_tM1,_tM2,_plane];
									},[_t,_tM1,_tM2,_plane,_planePos,_logic,_h]];
									[_eh]spawn{params["_eh"];sleep 35;removeMissionEventHandler["Draw3D",_eh]};
								};
		
								_vectorDir = [_planePos,_pos] call bis_fnc_vectorFromXtoY;
								_velocity = [_vectorDir,_speed] call bis_fnc_vectorMultiply;
								_plane setvectordir _vectorDir;
								[_plane,-90 + atan (_dis / _alt),0] call bis_fnc_setpitchbank;
								_vectorUp = vectorup _plane;
							
								_z="--- Remove all other weapons";
								_currentWeapons = weapons _plane;
								{
									if !(tolower ((_x call bis_fnc_itemType) select 1) in (_weaponTypes + ["countermeasureslauncher"])) then {
										_plane removeweapon _x;
									};
								} foreach _currentWeapons;
		
								//_plane setvariable ["logic",_logic];
								//_logic setvariable ["plane",_plane];
							
								_z="--- Approach";
								_fire = [] spawn {waituntil {false}};
								_fireNull = true;
								_time = time;
								
								//setAccTime 0.4;
								//if (_debug) then {[_plane] spawn{params["_plane"];for "_i" from 1 to 10 do {sleep 0.1;player setDir ([player, _plane] call BIS_fnc_dirTo)}}};
		
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
										_planePos, [_pos select 0,_pos select 1,(_pos select 2) + 0 + _fireProgress * 12],
										_velocity, _velocity,
										_vectorDir,_vectorDir,
										_vectorUp, _vectorUp,
										(time - _time) / _duration
									];
		
									_plane setvelocity velocity _plane;
						
									_z="--- Fire!";
									_fireDist = 2000;
									
									if ((getposasl _plane) distance _pos < (_fireDist + 900) && {damage _plane < 0.2} && {_fireNull} && {_tM1 != player} && {_plane getVariable["mdhMissileNotFired",true]}) then
									{
										_plane setVariable["mdhMissileNotFired",false];
										[_plane,_tM1,_tM2] spawn
										{
											params["_plane","_tM1","_tM2"];
											_tM1 setVehicleTiPars [1, 1, 1];
											_tM2 setVehicleTiPars [1, 1, 1];
											//setAccTime 0.03;
											_b = "Missile_AGM_02_F" createVehicle (_plane modelToWorld [3,-1,0]);
											_b setDir getDir _plane;
											_b setMissileTarget _tM1;
											_b setVelocity [(velocity _plane#0)*1.5,(velocity _plane#1)*1.5,(velocity _plane#2)*1.5];
											[_b, _tM1] spawn {params["_b","_tM1"];while{alive _b}do{sleep 0.1;_b setMissileTarget _tM1}};
											sleep 3;
											if (damage _plane < 0.2) then
											{
												//setAccTime 0.03;
												_b = "Missile_AGM_02_F" createVehicle (_plane modelToWorld [-3,-1,0]);
												_b setDir getDir _plane;
												_b setMissileTarget _tM2;
												_b setVelocity [(velocity _plane#0)*1.5,(velocity _plane#1)*1.5,(velocity _plane#2)*1.5];
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
										_target = _t;
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
											_machinegun = [_weapons#0];
											_bomblauncher = [_weapons#1];
											waituntil
											{
												{_planeDriver fireattarget [_target,(_x select 0)]} foreach _machinegun;
												{if (time > (_startTime + _bombDelay) && {_bombCounter < _bombDrop}) then {_bombCounter = _bombCounter + 1; _startTime = time; _planeDriver fireattarget [_target,(_x select 0)]}} foreach _bomblauncher;
												_plane setvariable ["fireProgress",(1 - ((_time - time) / _duration)) max 0 min 1];
												sleep 0.1;
												time > _time || (getPos _plane #2) < 250 || isnull _plane || damage _plane > 0.2
											};
											sleep 1;
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
			
						[
							_b
							,_t
							,"mdhCAS\mdhCAS.paa"
							,"mdhCAS\mdhCAS.paa"
							,"
							alive _target 
		
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
							&& {localNameSpace getVariable['mdhCASModCallTime',time - 1] < time}
							"
							,"true"
							,{}
							,{}
							,_hoschisCASCode
							,{}
							,[0]
							//,3
							,1
							,-1
							,false
							,false
							,false
						] call mdhHoldActionAdd;
					};
				} forEach _a;
			};
		};

		if (hasInterface) then
		{
			uiSleep 1.9;;
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