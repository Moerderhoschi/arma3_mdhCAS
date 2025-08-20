class CfgPatches 
{
	class mdhCAS
	{
		author = "Moerderhoschi";
		name = "mdhCAS";
		url = "https://steamcommunity.com/sharedfiles/filedetails/?id=3473212949";
		units[] = {};
		weapons[] = {};
		requiredVersion = 1.0;
		requiredAddons[] = {};
		version = "1.20160815";
		versionStr = "1.20160815";
		versionAr[] = {1,20160816};
		authors[] = {};
	};
};

class CfgFunctions
{
	class mdh
	{
		class mdhFunctions
		{
			class mdhCAS
			{
				file = "mdhCAS\mdhCAS.sqf";
				postInit = 1;
			};
		};
	};
};

class CfgMods
{
	class mdhCAS
	{
		dir = "@mdhCAS";
		name = "mdhCAS";
		picture = "mdhCAS\mdhCAS.paa";
		hidePicture = "true";
		hideName = "true";
		actionName = "Website";
		action = "https://steamcommunity.com/sharedfiles/filedetails/?id=3473212949";
	};
};
