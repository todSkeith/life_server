/*
	@file Version: 1
	@file name: nearATM.sqf
	@file Author: DysAlan
	@file edit: 4/10/2014
*/
#include <defines.h>
private ["_position", "_radius", "_atms", "_objects", "_objInfo", "_lenInfo", "_objName", "_i","_dis"];

_position = _this select 0; // can also be an object
_radius   = _this select 1;

assert (_radius <= 20); // 20m should be enough
if (typeName _position == "OBJECT") then { _position = getPos _position };

_atms   = [];
_objects = [];

// find all near objects but keep only those of unknown type
{
	if ("" == typeOf _x) then { _objects = _objects + [_x] };
} forEach nearestObjects [_position, [], _radius];

{
	// _x is something like "5150: ces_d10 100.p3d"

	_objInfo = toArray(str(_x));
	_lenInfo = (count _objInfo) - 1;
	_objName = [];

	_i = 0;

	// determine where the object name starts
	{
		if (ASCII_COLON == _objInfo select _i) exitWith {};
		_i = _i + 1;
	} forEach _objInfo;
	_i = _i + 2; // skip the ": " part

	for "_k" from _i to _lenInfo do {
		_objName = _objName + [_objInfo select _k];
	};

	// To stick with the example above: _objName now contains "ces_d10 100.p3d"

	_objName = toUpper(toString(_objName));
	_dis = [(position player) select 0, (position player) select 1,0] distance [(position _x) select 0, (position _x) select 1,0];
	if (_objName in STS_ATMS && floor(_dis) < 5) then { _atms = _atms + [_x] };

} forEach _objects;

_atms; // return value
