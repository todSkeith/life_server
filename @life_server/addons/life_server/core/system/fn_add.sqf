/*
	File: fn_add.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	This is a gateway to the SQF->MySQL Query function, it is sort of a 
	lazy blockage and adding untainable functions for the client to not take.
*/
private["_unit","_side","_uid","_money","_bank","_uid","_ownerID","_misc","_handle","_name"];
_unit = [_this,0,ObjNull,[Objnull]] call BIS_fnc_param;
_side = [_this,1,civilian,[sideUnknown]] call BIS_fnc_param;
_money = [_this,2,0,[0]] call BIS_fnc_param;
_bank = [_this,3,2500,[0]] call BIS_fnc_param;
_uid = [_this,4,"",[""]] call BIS_fnc_param;

//Error check
if(isNull _unit OR _uid == "") exitWith {if(_uid == "" && !isNull _unit) then {diag_log format["%1 had a invalid UID.",name _unit];};};

_ownerID = owner _unit;

switch (_side) do
{
	case west: {_misc = [_this,5,[],[[]]] call BIS_fnc_param;};
	case civilian: {_misc = [_this,5,false,[false]] call BIS_fnc_param;};
	case independent: {_misc = [_this,5,false,[false]] call BIS_fnc_param;};
};

//Is the headless client active? If so let him take over.
if(!isNil "hc_1" && {life_HC_isActive}) exitWith {
	private["_packet"];
	_packet = [_unit,_side,_money,_bank,_uid,_misc,_ownerID];
	[_packet,"HC_fnc_insert",(owner hc_1),FALSE] spawn BIS_fnc_MP;
};

_money = [_money] call DB_fnc_numberSafe;
_bank = [_bank] call DB_fnc_numberSafe;

_handle = [_uid,name _unit,_side,_money,_bank,_misc] spawn DB_fnc_insert;
waitUntil {scriptDone _handle};
_ret = [_uid,_side] call DB_fnc_query;
[_ret,"life_fnc_sessionReceive",_ownerID,false] spawn life_fnc_MP;