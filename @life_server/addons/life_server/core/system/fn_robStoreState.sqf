/*
	File: fn_robberyState.sqf
	Author: Bryan "Tonic" Boardwine
	
	Description:
	Determines the robbery state?
*/
private["_vault","_state","_funds"];
_cash = [_this,0,ObjNull,[ObjNull]] call BIS_fnc_param;
_state = [_this,1,-1,[0]] call BIS_fnc_param;
_funds = [_this,2,-1,[0]] call BIS_fnc_param;

if(isNull _vault) exitWith {}; //Bad data passed?

switch(_state) do
{
	case -1: {_vault setVariable["store_rob_ip",false,true]; _vault setVariable["store_locked",false,true];};
	case 0:
	{
		[[2,"The robbery has failed due to unknown reasons"],"life_fnc_broadcast",nil,false] spawn life_fnc_MP;
		_vault setVariable["store_locked",true,true];
		sleep (5 * 60); //Wait 5 minutes
		_vault setVariable["store_locked",false,true];
		_vault setVariable["store_rob_ip",false,true];
	};
	
	case 1:
	{
		[[1,format["$%1 was stolen from the robbery on the federal reserve.",[_funds] call life_fnc_numberText]],"life_fnc_broadcast",nil,false] spawn life_fnc_MP;
		_vault setVariable["store_locked",true,true];
		sleep (20 * 60); //Wait 20 minutes
		_vault setVariable["store_locked",false,true];
		_vault setVariable["store_rob_ip",false,true];
	
		if(_funds > life_store_funds) then
		{
			life_store_funds = 0;
		}
			else
		{
			life_store_funds = life_store_funds - _funds;
		};
		
		_funds = round(_funds / (count playableUnits) * 3);
		[[_funds],"life_fnc_robSuccess",true,false] spawn life_fnc_MP;
	};
};