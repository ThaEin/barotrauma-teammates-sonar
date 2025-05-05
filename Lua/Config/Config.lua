return function (basepath, confFileName)
    local ConfigDir = Game.SaveFolder .. "/ModConfigs";
    local ConfigFile = ConfigDir .. "/" .. confFileName .. ".json";
    local Migration = dofile(basepath .. "/Lua/Config/Migration.lua");
    local Default = dofile(basepath .. "/Lua/Config/Default.lua");
    local Config = {};

    local function Read()
        return json.parse(File.Read(ConfigFile))
    end

    function Config.Save(config)
        File.CreateDirectory(ConfigDir);
        File.Write(
            ConfigFile,
            json.serialize(config)
        )
    end

    function Config.Load()
        -- default config if config.json not exists
        if not File.Exists(ConfigFile) then
            Config.Save(Default.Config())
        end

        local migrated, config = Migration(Read());

        -- update file if config changed
        if migrated then
            Config.Save(config);
        end

        return config;
    end

    return Config;
end