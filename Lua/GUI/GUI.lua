
-- local OpenConfigGUI = dofile( AutoSonarbeacon.Path .. "Lua/GUI/Config.lua");

Hook.Patch("Barotrauma.GUI", "TogglePauseMenu", {}, function ()
    if GUI.GUI.PauseMenuOpen then

        local pauseMenuInner  = GUI.GUI.PauseMenu.GetChild(Int32(1));
        local buttonContainer = pauseMenuInner.GetChild(Int32(0));

        local button = GUI.Button(
            GUI.RectTransform(Vector2(1, 0.1), buttonContainer.RectTransform), 
            "Auto Sonar Beacon",
            GUI.Alignment.Center
        );

        button.OnClicked = function ()
            dofile( AutoSonarbeacon.Path .. "/Lua/GUI/Config.lua")()
        end;
    end
end, Hook.HookMethodType.After);
