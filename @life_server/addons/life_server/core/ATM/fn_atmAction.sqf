/*
	@file Version: 1
	@file name: fn_atmAction.sqf
	@file Author: DysAlan
	@file edit: 4/10/2014
	
	Adds ATM action
*/

fnc_nearATM =
compileFinal "
STS_ATMS = [""ATM_01_F.P3D"",""ATM_02_F.P3D""];
ASCII_COLON = 58;

private [""_position"", ""_radius"", ""_atms"", ""_objects"", ""_objInfo"", ""_lenInfo"", ""_objName"", ""_i"",""_dis""];

_position = _this select 0; 
_radius   = _this select 1;

assert (_radius <= 20);
if (typeName _position == ""OBJECT"") then { _position = getPos _position };

_atms   = [];
_objects = [];

{
	if ("""" == typeOf _x) then { _objects = _objects + [_x] };
} forEach nearestObjects [_position, [], _radius];

{
	_objInfo = toArray(str(_x));
	_lenInfo = (count _objInfo) - 1;
	_objName = [];

	_i = 0;

	{
		if (ASCII_COLON == _objInfo select _i) exitWith {};
		_i = _i + 1;
	} forEach _objInfo;
	_i = _i + 2; 

	for ""_k"" from _i to _lenInfo do {
		_objName = _objName + [_objInfo select _k];
	};

	_objName = toUpper(toString(_objName));
	_dis = [(position player) select 0, (position player) select 1,0] distance [(position _x) select 0, (position _x) select 1,0];
	if (_objName in STS_ATMS && floor(_dis) < 5) then { _atms = _atms + [_x] };

} forEach _objects;
_atms;
";
publicVariable "fnc_nearAtm";

fnc_atmAction = 
compileFinal "
	life_actions = life_actions + [player addAction[""<t color='#ADFF2F'>ATM</t>"",life_fnc_atmMenu,"""",0,false,false,"""",' count([player,3] call fnc_nearATM) > 0 && (vehicle player) == player ']];
	life_actions = life_actions + [player addAction[""Banking Insurance ($1,000)"",{if(life_atmcash > 1000) then {life_has_insurance = true; life_atmcash = life_atmcash - 1000};},"""",0,false,false,"""",' !life_has_insurance && count([player,3] call fnc_nearATM) > 0 && (vehicle player) == player ']];
";
publicVariable "fnc_atmAction";
