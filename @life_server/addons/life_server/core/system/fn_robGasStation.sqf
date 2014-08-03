// /*
	// File: fn_robGasStation.sqf
	// Client side file: fn_robStation.sqf
	// Author: Morph
	
	// Description:
	// Server-side part of the gas station robbery process. The script does the following:
	// ----------------------------------------------------------------
	// 1.Verifies gas station state (ie. robbery in progress, failed etc.)
	// 2.Fail safe timer in case client crashes and interrupts process.
	// 3.Cleans up the markers in case of point 2 and throughout each stage.
	// ----------------------------------------------------------------
	
// */

private["_station","_player"];

_station = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
_player = [_this,1,ObjNull,[ObjNull]] call BIS_fnc_param;
_marker = [_this,2,"",[""]] call BIS_fnc_param;

if(isNull _player OR isNull _station) exitWith {}; //Bad data was passed.

_timer = 0;
while{(_station getVariable["inProgress", false])} do {

	if(_timer > 310) then {
		_station getVariable["inProgress", false];
		_failSafe = true;
	};

	_timer = _timer + 1;
	sleep 1;
};


[_station, _marker] spawn {
	//Our timers run out... so let's clean up!
	_station setVariable ["canBeRobbed", false, true];
	_station setVariable ["inProgress", false, true];
	_station setVariable["robFail",false,true];
	deleteMarker _marker;

	sleep (5*60);
	_station setVariable["canBeRobbed",true,true];	
}