/*
	File: fn_robReserve.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Server-side part of the robbing process, runs checks and makes sure that
	two people aren't trying to both rob the same safe at the same time.
*/
private["_cash","_unit"];
_cash = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
_unit = [_this,1,ObjNull,[ObjNull]] call BIS_fnc_param;

if(isNull _cash OR isNull _unit) exitWith {}; //Bad data was passed.
if(!alive _unit) exitWith {}; //He's dead?
_unit = owner _unit;

if((_cash getVariable["store_rob_ip",false])) exitWith
{
	[[1,"This vault is already being robbed by someone else."],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
};

if((_cash getVariable["store_locked",false])) exitWith
{
	[[1,"This vault was already robbed recently."],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
};

if(_unit < 1) exitWith {}; //Bad unit number passed?!
_cash setVariable["store_rob_ip",true,true];
[[_cash,life_store_funds],"life_fnc_robStore",_unit,false] spawn life_fnc_MP;

