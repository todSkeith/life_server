/*
	File: fn_jailSys.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	I forget?
*/
private["_unit","_bad","_id","_ret"];
_unit = [_this,0,objNull,[objNull]] call BIS_fnc_param;
if(isNull _unit) exitWith {};
_bad = [_this,1,false,[false]] call BIS_fnc_param;
_jailTime = [_this,2,20,[0]] call BIS_fnc_param;
_id = owner _unit;

_ret = [_unit] call life_fnc_wantedPerson;
[[_ret,_bad,_jailTime],"life_fnc_jailMe",_id,false] spawn life_fnc_MP;