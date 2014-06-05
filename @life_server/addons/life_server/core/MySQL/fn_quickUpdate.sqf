/*
	Copyright © 2013 Bryan "Tonic" Boardwine, All rights reserved
	See http://armafiles.info/life/list.txt for servers that are permitted to use this code.
	File: fn_update.sqf
	Author: Bryan "Tonic" Boardwine"
	
	Description:
	Update the players information in the MySQL Database
*/
private["_uid","_name","_side","_query","_result","_array","_paramName","_param"];
_uid = [_this,0,"",[""]] call BIS_fnc_param;
_name = [_this,1,"",[""]] call BIS_fnc_param;
_side = [_this,2,civilian,[civilian]] call BIS_fnc_param;
_paramName = [_this,3,"",[""]] call BIS_fnc_param;
_param = [_this,4,[],[[]]] call BIS_fnc_param;



//Error checks
if((_uid == "") OR (_name == "")) exitWith {systemChat "MySQL: Query Request - Error uid or name is empty.";};
_query = format["SELECT name, aliases FROM players WHERE playerid='%1'",_uid];
_result = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query,(call LIFE_SCHEMA_NAME)];
_result = call compile format["%1", _result];
if(isNil {((_result select 0) select 0)}) exitWith {systemChat "MySQL: Query Request - No entries found";}; //Player not found?
_result = ((_result select 0) select 0);
//Check if the currently saved name doesn't match the playerUID and if it's not in the other used aliases.
_array = (_result select 1);
_array = [_array] call DB_fnc_mresToArray;
_array = call compile format["%1", _array];
if(!(_name in _array)) then
{
	private["_aliases"];
	_aliases = _array;
	_aliases set[count _aliases, _name];
	_aliases = [_aliases] call DB_fnc_mresArray;
	_query = format["UPDATE players SET aliases='%1' WHERE playerid='%2'",_aliases,_uid];
	_sql = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query,(call LIFE_SCHEMA_NAME)];
};

switch (_side) do
{
	case civilian:
	{
		_param = [_param] call DB_fnc_mresArray;
		_query = format["UPDATE players SET %1='%2' WHERE playerid='%3'", _paramName, _param, _uid];
	};
};

//Execute SQL Statement
_sql = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query,(call LIFE_SCHEMA_NAME)];