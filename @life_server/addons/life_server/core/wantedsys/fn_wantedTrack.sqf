/*
	File: fn_wantedTrack.sqf
	Author: Bobbus
	
	Description:
	Fetches a specific person from the wanted array.
*/
private["_unit","_index"];
_unit = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
_pos = [_this,0,[0,0,0],[[]]] call BIS_fnc_param;
if(isNull _unit) exitWith {[]};

_index = [getPlayerUID _unit,life_wanted_list] call fnc_index;

if(_index != -1) then
{
	[[_unit,_pos],"life_fnc_trackBounty",true,false] spawn life_fnc_MP;
};
