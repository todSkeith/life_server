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

_player = [_this,1,ObjNull,[ObjNull]] call BIS_fnc_param;
_station = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;


if(isNull _player OR isNull _station) exitWith {}; //Bad data was passed.


//FAIL SAFE SECTION
//Functions:
//	1. Creates markers at start of robbery and sleep timer provides fail safe measures in case of client crash or disconnect. 
//	2. Resets all global variables in case of client crash or disconnect.
//
//Parameters changeable:
//	1.Sleep time. Please ensure 10 - 20 seconds longer than progress timer in client side fn_robStation.sqf.

while {_station getVariable["robProgress",true]} do
{
	_stationPos = position _station;
	_marker = createMarker [format["mk_%1",_station], _stationPos];
	_marker setMarkerColor "ColorRed";
	_marker setMarkerText "Station is being robbed!";
	_marker setMarkerType "mil_warning";
	
	sleep 320;
	
	 deleteMarker format["mk_%1",_station];
	[[1,"A station robbery failed..."],"life_fnc_broadcast",west,false] spawn life_fnc_MP;
	_station setVariable["robFail",true,true];
	_station setVariable["robProgress",false,true];
};

//ROBBERY FAILURE SECTION
//Functions:
//	1. Starts the sleep timer after robbery failure. 
//	2. Resets variables and deletes marker.
//
//Parameters changeable:
//	1.Sleep time.

if (_station getVariable["robFail",true]) exitWith
{
	 _station setVariable["robProgress",false,true];
	 _station setVariable["gaswait",true,true];
	 
	 deleteMarker format["mk_%1",_station];
	 
	 sleep 1200;
	 
	 _station setVariable["gaswait",false,true];
	 _station setVariable["robFail",false,true];
};

//ROBBERY SUCCESS SECTION
//Functions:
//	1. Starts the sleep timer after robbery success. 
//	2. Resets variables and deletes marker.
//
//Parameters changeable:
//	1.Sleep time.

if (_station getVariable["robSuccess",true]) exitWith
{
	 
	 _station setVariable["robProgress",false,true];
	 _station setVariable["gaswait",true,true];
	 
	 deleteMarker format["mk_%1",_station];
	 
	 sleep 1800;
	 
	 _station setVariable["gaswait",false,true];
	 _station setVariable["robSuccess",false,true];	 
};