/*
	File: fn_update.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	This is a gateway to the SQF->MySQL Query function, it is sort of a 
	lazy blockage and adding untainable functions for the client to not take.
*/
private["_unit","_side","_uid","_paramName", "_param"];
_unit = [_this,0,ObjNull,[Objnull]] call BIS_fnc_param;
_name = [_this,1,"",[""]] call BIS_fnc_param;
_side = [_this,2,civilian,[sideUnknown]] call BIS_fnc_param;
_uid = [_this,3,"",[""]] call BIS_fnc_param;
_paramName = [_this,4,"",[""]] call BIS_fnc_param;
_param = [_this,5,[],[[]]] call BIS_fnc_param;


//Error check
if(isNull _unit OR _uid == "") exitWith {if(_uid == "" && !isNull _unit) then {diag_log format["%1 had a invalid UID.",name _unit];};};
[_uid,_name,_side,_paramName, _param] call DB_fnc_quickUpdate;