/*
	@file Version: 1
	@file name: fn_atmAction.sqf
	@file Author: DysAlan
	@file edit: 4/10/2014
	
	Adds ATM action
*/
if(_this select 0) then
{
	life_actions = life_actions + [player addAction["<t color='#ADFF2F'>ATM</t>",life_fnc_atmMenu,"",0,false,false,"",' count([player,3] call STS_fnc_nearATM) > 0 && (vehicle player) == player ']];
	life_actions = life_actions + [player addAction["Banking Insurance ($1,000)",{if(life_atmcash > 1000) then {life_has_insurance = true; life_atmcash = life_atmcash - 1000};},"",0,false,false,"",' !life_has_insurance && count([player,3] call STS_fnc_nearATM) > 0 && (vehicle player) == player ']];
};