local Default = {};

function Default.Config()
	local config = {};

	config.version = "2";

	config.OnlyTeammates = true;
	config.UnlimitedRange = false;
	config.DisableIfSonarBeaconActive = true;
	config.OnlyOutside = true;
	config.ExcludeOwnSub = true;
	config.OnlyAlive = true;
	config.TeammatesColor = {255, 0, 0};
	config.OtherColor = {255, 0, 0};

	return config;
end

return Default;