if SERVER then return end

AutoSonarbeacon = {};
AutoSonarbeacon.Path = ...;
AutoSonarbeacon.ConfigLib = dofile(AutoSonarbeacon.Path .. "/Lua/Config/Config.lua")(AutoSonarbeacon.Path, "AutoSonarbeacon");
AutoSonarbeacon.Config = AutoSonarbeacon.ConfigLib.Load();

dofile( AutoSonarbeacon.Path .. "/Lua/GUI/GUI.lua" );

dofile( AutoSonarbeacon.Path .. "/Lua/sonar.lua" );