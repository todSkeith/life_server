/*
	File: fn_spawnVehicle.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Sends the query request to the database, if an array is returned then it creates
	the vehicle if it's not in use or dead.
*/
private["_vid","_sp","_pid","_query","_sql","_vehicle","_nearVehicles","_name","_side"];
_vid = [_this,0,-1,[0]] call BIS_fnc_param;
_pid = [_this,1,"",[""]] call BIS_fnc_param;
_sp = [_this,2,[],[[]]] call BIS_fnc_param;
_unit = [_this,3,ObjNull,[ObjNull]] call BIS_fnc_param;
_price = [_this,4,0,[0]] call BIS_fnc_param;
_name = name _unit;
_side = side _unit;
_unit = owner _unit;

if(_vid == -1 OR _pid == "" OR count _sp == 0) exitWith {};
if(_vid in serv_sv_use) exitWith {};
serv_sv_use set[count serv_sv_use,_vid];

_vInfo = [_vid,_pid] call DB_fnc_queryVehicle;
if(isNil "_vInfo") exitWith {serv_sv_use = serv_sv_use - [_vid];};
if(count _vInfo == 0) exitWith {serv_sv_use = serv_sv_use - [_vid];};

if((_vInfo select 5) == "False") exitWith
{
	serv_sv_use = serv_sv_use - [_vid];
	[[_unit,_price,_unit,true],"life_fnc_receiveMoney",_unit,false] spawn life_fnc_MP;
	[[1,format["Sorry but %1 was classified as a destroyed vehicle and was sent to the scrap yard.",_vInfo select 2]],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
};

if((_vInfo select 6) == "True") exitWith
{
	serv_sv_use = serv_sv_use - [_vid];
	[[_unit,_price,_unit,true],"life_fnc_receiveMoney",_unit,false] spawn life_fnc_MP;
	[[1,format["Sorry but %1 is already active somewhere in the map and cannot be spawned.",_vInfo select 2]],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
};

_nearVehicles = nearestObjects[_sp,["Car","Air","Ship"],10];
if(count _nearVehicles > 0) exitWith
{
	serv_sv_use = serv_sv_use - [_vid];
//	[[_price,{life_atmcash = life_atmcash + _this;}],"BIS_fnc_spawn",_unit,false] spawn life_fnc_MP;
	[[_unit,_price,_unit,true],"life_fnc_receiveMoney",_unit,false] spawn life_fnc_MP;
	[[1,"There is a vehicle on the spawn point. You will be refunded the cost of getting it out."],"life_fnc_broadcast",_unit,false] spawn life_fnc_MP;
};

_query = format["UPDATE vehicles SET active='1' WHERE pid='%1' AND id='%2'",_pid,_vid];
_sql = "Arma2Net.Unmanaged" callExtension format ["Arma2NETMySQLCommand ['%2', '%1']", _query,(call LIFE_SCHEMA_NAME)];
_vehicle = _vInfo select 2 createVehicle (_sp);
_vehicle setVariable["vehicle_info_owners",[[_pid,_name]],true];
_vehicle setVariable["dbInfo",[(_vInfo select 4),(call compile format["%1", _vInfo select 7])]];
_vehicle addEventHandler["Killed","_this spawn TON_fnc_vehicleDead"];
[_vehicle] call life_fnc_clearVehicleAmmo;
_vehicle lock 2;

//Send keys over the network.
[[_vehicle],"TON_fnc_addVehicle2Chain",_unit,false] spawn life_fnc_MP;

//Reskin the vehicle 
[[_vehicle,(call compile format["%1",_vInfo select 8])],"life_fnc_colorVehicle",true,false] spawn life_fnc_MP;

//Sets of animations
if((_vInfo select 1) == "civ" && (_vInfo select 2) == "B_Heli_Light_01_F" && (call compile format["%1",_vInfo select 8]) != 13) then
{
	[_vehicle,"civ_littlebird",true] call life_fnc_vehicleAnimate;
};

if((_vInfo select 1) == "cop" && (_vInfo select 2) == "C_Offroad_01_F") then
{
	[_vehicle,"cop_offroad",true] call life_fnc_vehicleAnimate;
};

if((_vInfo select 1) == "cop" && (_vInfo select 2) in ["B_MRAP_01_F","C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F"]) then {
	_vehicle setVariable["lights",false,true];
};

if((_vInfo select 1) == "med" && (_vInfo select 2) in ["C_SUV_01_F","C_Hatchback_01_F","C_Hatchback_01_sport_F"]) then {
	_vehicle setVariable["lights",false,true];
};

if((_vInfo select 1) == "med" && (_vInfo select 2) in ["O_Heli_Light_02_unarmed_F"]) then {
	//[_vehicle,"EMS_Heli",true] call life_fnc_vehicleAnimate; No LONGER USING
};

serv_sv_use = serv_sv_use - [_vid];