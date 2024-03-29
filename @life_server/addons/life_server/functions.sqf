life_fnc_sidechat =
compileFinal "
	if(life_sidechat) then {life_sidechat = false;} else {life_sidechat = true;};
	[[player,life_sidechat,playerSide],""TON_fnc_managesc"",false,false] spawn life_fnc_MP;
	[] call life_fnc_settingsMenu;
";

publicVariable "life_fnc_sidechat";

fnc_index =
compileFinal "
	private[""_find"",""_limit"",""_select"",""_array"",""_return""];
	_find = _this select 0;
	_array = _this select 1;

	_limit = (count _array)-1;
	for ""_i"" from 0 to _limit do
	{
		_select = _array select _i;
		if((_find in _select) && (isNil {_return})) then
		{
			_return = _i;
		};
	};

	if(isNil {_return}) then {_return = -1;};
	_return;
";

fnc_player_query =
compileFinal "
	private[""_ret""];
	_ret = _this select 0;
	if(isNull _ret) exitWith {};
	if(isNil ""_ret"") exitWith {};
	
	[[life_atmcash,life_cash,owner player,player],""life_fnc_admininfo"",_ret,false] spawn life_fnc_MP;
";
publicVariable "fnc_player_query";

fnc_player_adminquery =
compileFinal "
	private[""_ret""];
	_ret = _this select 0;
	if(isNull _ret) exitWith {};
	if(isNil ""_ret"") exitWith {};
	
	[[player,life_cash, life_atmCash, owner player, player],""stslap_fnc_admininfo"",_ret,false] spawn life_fnc_MP;
";
publicVariable "fnc_player_adminquery";

/*
fnc_player_query =
compileFinal "
	private[""_req"",""_packet"",""_ret""];
	_ret = _this select 0;
	_req = _this select 1;
	_req = call compile format[""%1"", _req];
	if(isNull _req) exitWith {admin_query_info = [];(owner _ret) publicVariableClient ""admin_query_info""; sleep 0.5; admin_query_info = nil};
	[[],""admin_is_querying"",_req,false] spawn life_fnc_MP;
	waitUntil {!isNil {serv_query_info}};
	admin_query_info = [(owner _req)];
	admin_query_info set[count admin_query_info,(serv_query_info select 0)];
	admin_query_info set[count admin_query_info,(serv_query_info select 1)];
	admin_query_info set[count admin_query_info,_req];
	(owner _ret) publicVariableClient ""admin_query_info"";
	sleep 0.5;
	admin_query_info = nil;
	serv_query_info = nil;
";
*/

fnc_bank_deposit =
compileFinal "
	private[""_val""];
	_val = parseNumber(ctrlText 2702);
	if(_val > 999999) exitWith {hint ""You can't deposit more then $999,999"";};
	if(_val < 0) exitwith {};
	if(!([str(_val)] call fnc_isnumber)) exitWith {hint ""That isn't in an actual number format.""};
	if(_val > life_cash) exitWith {hint ""You don't have that much on you!""};
	
	life_cash = life_cash - _val;
	life_atmcash = life_atmcash + _val;
	hint format[""You have deposited $%1 into your bank account"",[_val] call life_fnc_numberText];
	[] call life_fnc_atmMenu;
	[1,false] call life_fnc_sessionHandle;
	[[player,position player],""life_fnc_wantedTrack"",false,false] spawn life_fnc_MP;
";

fnc_bank_withdraw =
compileFinal "
	private[""_val""];
	_val = parseNumber(ctrlText 2702);
	if(_val > 999999) exitWith {hint ""You can't withdraw more then $999,999"";};
	if(_val < 0) exitwith {};
	if(!([str(_val)] call fnc_isnumber)) exitWith {hint ""That isn't in an actual number format.""};
	if(_val > life_atmcash) exitWith {hint ""You don't have that much in your bank account!""};
	
	life_cash = life_cash + _val;
	life_atmcash = life_atmcash - _val;
	hint format [""You have withdrawn $%1 from your bank account"",[_val] call life_fnc_numberText];
	[] call life_fnc_atmMenu;
	[1,false] call life_fnc_sessionHandle;
	[[player,position player],""life_fnc_wantedTrack"",false,false] spawn life_fnc_MP;
";

fnc_bank_transfer =
compileFinal "
	private[""_val"",""_unit"",""_tax""];
	_val = parseNumber(ctrlText 2702);
	_unit = call compile format[""%1"",(lbData[2703,(lbCurSel 2703)])];
	if(isNull _unit) exitWith {};
	if((lbCurSel 2703) == -1) exitWith {hint ""You need to select someone to transfer to""};
	if(isNil ""_unit"") exitWith {hint ""The player selected doesn't seem to exist?""};
	if(_val > 999999) exitWith {hint ""You can't transfer more then $999,999"";};
	if(_val < 0) exitwith {};
	if(!([str(_val)] call fnc_isnumber)) exitWith {hint ""That isn't in an actual number format.""};
	if(_val > life_atmcash) exitWith {hint ""You don't have that much in your bank account!""};
	_tax = [_val] call life_fnc_taxRate;
	if((_val + _tax) > life_atmcash) exitWith {hint format[""You do not have enough money in your bank account, to transfer $%1 you will need $%2 as a tax fee."",_val,_tax]};
	
	life_atmcash = life_atmcash - (_val + _tax);
	
	bank_addfunds = _tax;
	publicVariableServer ""bank_addfunds"";
	[[_val,name player,format[""ATM Transfer: %1 sent %2 to %3"",name player, [_val] call life_fnc_numberText, name _unit]],""clientWireTransfer"",_unit,false] spawn life_fnc_MP;
	[] call life_fnc_atmMenu;
	hint format[""You have transfered $%1 to %2.\n\nA tax fee of $%3 was taken for the wire transfer."",[_val] call life_fnc_numberText,name _unit,[_tax] call life_fnc_numberText];
	[1,false] call life_fnc_sessionHandle;
	[[player,position player],""life_fnc_wantedTrack"",false,false] spawn life_fnc_MP;
";

publicVariable "fnc_bank_deposit";
publicVariable "fnc_bank_withdraw";
publicVariable "fnc_bank_transfer";
publicVariable "fnc_index";

clientWireTransfer =
compileFinal "
	private[""_unit"",""_val"",""_from""];
	_val = _this select 0;
	_from = _this select 1;
	if(!([str(_val)] call fnc_isnumber)) exitWith {};
	if(_from == """") exitWith {};
	life_atmcash = life_atmcash + _val;
	hint format[""%1 has wire transferred $%2 to you."",_from,[_val] call life_fnc_numberText];
	
";
publicVariable "clientWireTransfer";

fnc_isnumber =
compileFinal "
	private[""_valid"",""_value"",""_compare""];
	_value = _this select 0;
	_valid = [""0"",""1"",""2"",""3"",""4"",""5"",""6"",""7"",""8"",""9""];
	_array = [_value] call KRON_StrToArray;
	_return = true;
	
	{
		if(_x in _valid) then	
		{}
		else
		{
			_return = false;
		};
	} foreach _array;
	_return;
";

publicVariable "fnc_isnumber";

clientGangKick =
compileFinal "
	private[""_unit"",""_group""];
	_unit = _this select 0;
	_group = _this select 1;
	if(isNil ""_unit"" OR isNil ""_group"") exitWith {};
	if(player == _unit && (group player) == _group) then
	{
		life_my_gang = ObjNull;
		[player] joinSilent (createGroup civilian);
		hint ""You have been kicked out of the gang."";
		
	};
";
publicVariable "clientGangKick";

clientGetKey =
compileFinal "
	private[""_vehicle"",""_unit"",""_giver""];
	_vehicle = _this select 0;
	_unit = _this select 1;
	_giver = _this select 2;
	if(isNil ""_unit"" OR isNil ""_giver"") exitWith {};
	if(player == _unit && !(_vehicle in life_vehicles)) then
	{
		_name = getText(configFile >> ""CfgVehicles"" >> (typeOf _vehicle) >> ""displayName"");
		hint format[""%1 has gave you keys for a %2"",_giver,_name];
		life_vehicles set[count life_vehicles, _vehicle];
	};
";

publicVariable "clientGetKey";

clientGangLeader =
compileFinal "
	private[""_unit"",""_group""];
	_unit = _this select 0;
	_group = _this select 1;
	if(isNil ""_unit"" OR isNil ""_group"") exitWith {};
	if(player == _unit && (group player) == _group) then
	{
		player setRank ""COLONEL"";
		_group selectLeader _unit;
		hint ""You have been made the new leader."";
	};
";

publicVariable "clientGangLeader";


//Cell Phone Messaging
/*
	-fnc_cell_textmsg
	-fnc_cell_textcop
	-fnc_cell_textadmin
	-fnc_cell_adminmsg
	-fnc_cell_adminmsgall
*/

//To Medics
fnc_cell_textmedic =
compileFinal "
	private[""_msg"",""_to""];
	ctrlShow[3020,false];
	_msg = ctrlText 3003;
	_to = ""The Medics"";
	if(_msg == """") exitWith {hint ""You must enter a message to send!"";ctrlShow[3020,true];};

	[[_msg,name player,5,position player],""clientMessage"",true,false] spawn life_fnc_MP;
	[] call life_fnc_cellphone;
	hint format[""You sent %1 a message: %2"",_to,_msg];
	ctrlShow[3020,true];
";
//To One Person
fnc_cell_textmsg =
compileFinal "
	private[""_msg"",""_to""];
	ctrlShow[3015,false];
	_msg = ctrlText 3003;
	if(lbCurSel 3004 == -1) exitWith {hint ""You must select a player you are sending the text to!""; ctrlShow[3015,true];};
	_to = call compile format[""%1"",(lbData[3004,(lbCurSel 3004)])];
	if(isNull _to) exitWith {ctrlShow[3015,true];};
	if(isNil ""_to"") exitWith {ctrlShow[3015,true];};
	if(_msg == """") exitWith {hint ""You must enter a message to send!"";ctrlShow[3015,true];};

	[[_msg,name player,0],""clientMessage"",_to,false] spawn life_fnc_MP;
	[] call life_fnc_cellphone;
	hint format[""You sent %1 a message: %2"",name _to,_msg];
	ctrlShow[3015,true];
";
//To All Cops
fnc_cell_textcop =
compileFinal "
	private[""_msg"",""_to""];
	ctrlShow[3016,false];
	_msg = ctrlText 3003;
	_to = ""The Police"";
	if(_msg == """") exitWith {hint ""You must enter a message to send!"";ctrlShow[3016,true];};

	[[_msg,name player,1,position player],""clientMessage"",true,false] spawn life_fnc_MP;
	[] call life_fnc_cellphone;
	hint format[""You sent %1 a message: %2"",_to,_msg];
	ctrlShow[3016,true];
";
//To All Admins
fnc_cell_textadmin =
compileFinal "
	private[""_msg"",""_to"",""_from""];
	ctrlShow[3017,false];
	_msg = ctrlText 3003;
	_to = ""The Admins"";
	if(_msg == """") exitWith {hint ""You must enter a message to send!"";ctrlShow[3017,true];};

	[[_msg,name player,2],""clientMessage"",true,false] spawn life_fnc_MP;
	[] call life_fnc_cellphone;
	hint format[""You sent %1 a message: %2"",_to,_msg];
	ctrlShow[3017,true];
";
//Admin To One Person
fnc_cell_adminmsg =
compileFinal "
	if(isServer) exitWith {};
	if((call life_adminlevel) < 1) exitWith {hint ""You are not an admin!"";};
	private[""_msg"",""_to""];
	_msg = ctrlText 3003;
	_to = call compile format[""%1"",(lbData[3004,(lbCurSel 3004)])];
	if(isNull _to) exitWith {};
	if(_msg == """") exitWith {hint ""You must enter a message to send!"";};

	[[_msg,name player,3],""clientMessage"",_to,false] spawn life_fnc_MP;
	[] call life_fnc_cellphone;
	hint format[""Admin Message Sent To: %1 - Message: %2"",name _to,_msg];
";

fnc_cell_adminmsgall =
compileFinal "
	if(isServer) exitWith {};
	if((call life_adminlevel) < 1) exitWith {hint ""You are not an admin!"";};
	private[""_msg"",""_from""];
	_msg = ctrlText 3003;
	if(_msg == """") exitWith {hint ""You must enter a message to send!"";};

	[[_msg,name player,4],""clientMessage"",true,false] spawn life_fnc_MP;
	[] call life_fnc_cellphone;
	hint format[""Admin Message Sent To All: %1"",_msg];
";

publicVariable "fnc_cell_textmsg";
publicVariable "fnc_cell_textcop";
publicVariable "fnc_cell_textadmin";
publicVariable "fnc_cell_adminmsg";
publicVariable "fnc_cell_adminmsgall";
publicVariable "fnc_cell_textmedic";

//Client Message
/*
	0 = private message
	1 = police message
	2 = message to admin
	3 = message from admin
	4 = admin message to all
	5 = medic message
*/
clientMessage =
compileFinal "
	private[""_msg"",""_from"", ""_type"", ""_pos"", ""_posx"", ""_posy"", ""_loc""];
	_msg = _this select 0;
	_from = _this select 1;
	_type = _this select 2;
	_pos = _this select 3;
	if(_from == """") exitWith {};
	switch (_type) do
	{
		case 0 :
		{
			private[""_message""];
			_message = format["">>>MESSAGE FROM %1: %2"",_from,_msg];
			hint parseText format [""<t color='#FFCC00'><t size='2'><t align='center'>New Message<br/><br/><t color='#33CC33'><t align='left'><t size='1'>To: <t color='#ffffff'>You<br/><t color='#33CC33'>From: <t color='#ffffff'>%1<br/><br/><t color='#33CC33'>Message:<br/><t color='#ffffff'>%2"",_from,_msg];

			[""TextMessage"",[format[""You Received A New Private Message From %1"",_from]]] call bis_fnc_showNotification;
			systemChat _message;
		};

		case 1 :
		{
			if(side player != west) exitWith {};
			private[""_message""];
			_message = format[""---911 DISPATCH FROM %1: %2"",_from,_msg];
			_posx = _pos select 0;
			_posx = floor(_posx / 100);
			switch (true) do {
				case (_posx < 100): { _posx = format[""0%1"",_posx]; };
				case (_posx < 10): { _posx = format[""00%1"",_posx]; };
			};
			_posy = _pos select 1;
			_posy = floor(_posy / 100);
			switch (true) do {
				case (_posy < 100): { _posy = format[""0%1"",_posy]; };
				case (_posy < 10): { _posy = format[""00%1"",_posy]; };
			};
			_loc = format[""%1%2"",_posx,_posy];
			hint parseText format [""<t color='#316dff'><t size='2'><t align='center'>New Dispatch<br/><br/><t color='#33CC33'><t align='left'><t size='1'>To: <t color='#ffffff'>All Officers<br/><t color='#33CC33'>From: <t color='#ffffff'>%1<br/><t color='#33CC33'>Message: <t color='#ffffff'>%2<br/><br/><t color='#33CC33'>Location: <br/><t color='#ffffff'>%3"",_from,_msg,_loc];

			[""PoliceDispatch"",[format[""A New Police Report From: %1"",_from]]] call bis_fnc_showNotification;
			systemChat _message;
		};

		case 2 :
		{
			if((call life_adminlevel) < 1) exitWith {};
			private[""_message""];
			_message = format[""???ADMIN REQUEST FROM %1: %2"",_from,_msg];
			hint parseText format [""<t color='#ffcefe'><t size='2'><t align='center'>Admin Request<br/><br/><t color='#33CC33'><t align='left'><t size='1'>To: <t color='#ffffff'>Admins<br/><t color='#33CC33'>From: <t color='#ffffff'>%1<br/><br/><t color='#33CC33'>Message:<br/><t color='#ffffff'>%2"",_from,_msg];

			[""AdminDispatch"",[format[""%1 Has Requested An Admin!"",_from]]] call bis_fnc_showNotification;
			systemChat _message;
		};

		case 3 :
		{
			private[""_message""];
			_message = format[""!!!ADMIN MESSAGE: %1"",_msg];
			_admin = format[""Sent by admin: %1"", _from];
			hint parseText format [""<t color='#FF0000'><t size='2'><t align='center'>Admin Message<br/><br/><t color='#33CC33'><t align='left'><t size='1'>To: <t color='#ffffff'>You<br/><t color='#33CC33'>From: <t color='#ffffff'>An Admin<br/><br/><t color='#33CC33'>Message:<br/><t color='#ffffff'>%1"",_msg];

			[""AdminMessage"",[""You Have Received A Message From An Admin!""]] call bis_fnc_showNotification;
			systemChat _message;
			if((call life_adminlevel) > 0) then {systemChat _admin;};
		};

		case 4 :
		{
			private[""_message"",""_admin""];
			_message = format[""!!!ADMIN MESSAGE: %1"",_msg];
			_admin = format[""Sent by admin: %1"", _from];
			hint parseText format [""<t color='#FF0000'><t size='2'><t align='center'>Admin Message<br/><br/><t color='#33CC33'><t align='left'><t size='1'>To: <t color='#ffffff'>All Players<br/><t color='#33CC33'>From: <t color='#ffffff'>The Admins<br/><br/><t color='#33CC33'>Message:<br/><t color='#ffffff'>%1"",_msg];

			[""AdminMessage"",[""You Have Received A Message From An Admin!""]] call bis_fnc_showNotification;
			systemChat _message;
			if((call life_adminlevel) > 0) then {systemChat _admin;};
		};

		case 5 :
		{
			if(side player != independent) exitWith {};
			private[""_message""];
			_message = format[""---911 DISPATCH FROM %1: %2"",_from,_msg];
			_posx = _pos select 0;
			_posx = floor(_posx / 100);
			switch (true) do {
				case (_posx < 100): { _posx = format[""0%1"",_posx]; };
				case (_posx < 10): { _posx = format[""00%1"",_posx]; };
			};
			_posy = _pos select 1;
			_posy = floor(_posy / 100);
			switch (true) do {
				case (_posy < 100): { _posy = format[""%1"",_posy]; };
				case (_posy < 10): { _posy = format[""00%1"",_posy]; };
			};
			_loc = format[""%1%2"",_posx,_posy];
			hint parseText format [""<t color='#316dff'><t size='2'><t align='center'>New Dispatch<br/><br/><t color='#33CC33'><t align='left'><t size='1'>To: <t color='#ffffff'>All Medics<br/><t color='#33CC33'>From: <t color='#ffffff'>%1<br/><t color='#33CC33'>Message: <t color='#ffffff'>%2<br/><br/><t color='#33CC33'>Location: <br/><t color='#ffffff'>%3"",_from,_msg,_loc];

			[""PoliceDispatch"",[format[""A New Medic Request From: %1"",_from]]] call bis_fnc_showNotification;
			systemChat _message;
		};
	};
";
publicVariable "clientMessage";