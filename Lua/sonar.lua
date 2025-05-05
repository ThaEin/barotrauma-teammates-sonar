
local SonarDescriptor = LuaUserData.RegisterType("Barotrauma.Items.Components.Sonar");
LuaUserData.MakeMethodAccessible(SonarDescriptor, "DrawSonar");
LuaUserData.MakeMethodAccessible(SonarDescriptor, "DrawMarker");
LuaUserData.MakeMethodAccessible(SonarDescriptor, "GetTransducerPos");
LuaUserData.MakeFieldAccessible(SonarDescriptor, "center");

local DrawRectangle_clr = nil;

local function DrawSonar_After(instance, ptable)
    local Config = AutoSonarbeacon.Config;

    local LocalPlayerChar = Character.Controlled;
    local myTeamID = LocalPlayerChar.TeamID;
    
    local currentSub = Submarine.MainSub;

    local spriteBatch = ptable["spriteBatch"];
    local rect = ptable['rect'];

    -- https://github.com/evilfactory/LuaCsForBarotrauma/blob/64faf5c9676f7868c8a0bdee966f1256c61d6339/Barotrauma/BarotraumaClient/ClientSource/Items/Components/Machines/Sonar.cs#L869
    local displayBorderSize = 0.2;
    local center = rect.Center.ToVector2();
    local DisplayRadius = (rect.Width / 2.0) * (1.0 - displayBorderSize);
    local DisplayScale = DisplayRadius / instance.range * instance.zoom;

    -- https://github.com/evilfactory/LuaCsForBarotrauma/blob/64faf5c9676f7868c8a0bdee966f1256c61d6339/Barotrauma/BarotraumaClient/ClientSource/Items/Components/Machines/Sonar.cs#L919
    -- DisplayOffset added because in this case "item.Submarine != null && !DetectSubmarineWalls" always true
    local transducerCenter = instance.GetTransducerPos() + instance.DisplayOffset;

    for char in Character.CharacterList do
        if char.Info ~= nil then

            local label = char.Info.Name;
            local position = char.WorldPosition;

            local isTeammate = myTeamID == char.TeamID;

            local inHull = char.CurrentHull ~= nil;
            local inSub = false;
            if inHull then
                inSub = char.CurrentHull.Submarine.ID == currentSub.ID;
            end

            local sonarBeacon = char.Inventory.FindItemByIdentifier("sonarbeacon");
            local isSonarBeaconActive = false;
            if sonarBeacon ~= nil then
                local component = sonarBeacon.GetComponentString("LightComponent");
                isSonarBeaconActive = component.SerializableProperties[Identifier("IsOn")].GetValue(component);
            end

            local markerActive = not inSub and char.ID ~= LocalPlayerChar.ID

            -- checks according to config
            if markerActive and Config.OnlyOutside then
                markerActive = not inHull;
            end

            if markerActive and Config.OnlyTeammates then
                markerActive = isTeammate;
            end

            if markerActive and not Config.UnlimitedRange then
                markerActive = Vector2.DistanceSquared(transducerCenter, position) < instance.range ^ 2;
            end

            if markerActive and Config.DisableIfSonarBeaconActive then
                markerActive = not isSonarBeaconActive;
            end

            if markerActive and Config.OnlyAlive then
                markerActive = not char.IsDead;
            end

            if markerActive then
                if isTeammate then
                    DrawRectangle_clr = Config.TeammatesColor
                else
                    DrawRectangle_clr = Config.OtherColor
                end
                -- https://github.com/evilfactory/LuaCsForBarotrauma/blob/64faf5c9676f7868c8a0bdee966f1256c61d6339/Barotrauma/BarotraumaClient/ClientSource/Items/Components/Machines/Sonar.cs#L1871
                instance.DrawMarker(
                    spriteBatch,
                    label,
                    "",
                    label,
                    position,
                    transducerCenter,
                    DisplayScale,
                    center,
                    instance.DisplayRadius
                );
            end
        end
    end

end

local function DrawRectangle_Before(instance, ptable)
    if DrawRectangle_clr ~= nil then
        ptable["clr"] = Color(DrawRectangle_clr[1], DrawRectangle_clr[2], DrawRectangle_clr[3]);
        DrawRectangle_clr = nil;
    end
end

Hook.Patch(
    "Barotrauma.Items.Components.Sonar", "DrawSonar",
    DrawSonar_After,
    Hook.HookMethodType.After
);


local DrawRectangle_params = {
    "Microsoft.Xna.Framework.Graphics.SpriteBatch",
    "Microsoft.Xna.Framework.Rectangle",
    "Microsoft.Xna.Framework.Color",
    "System.Boolean",
    "System.Single",
    "System.Single"
}
Hook.Patch(
    "Barotrauma.GUI", "DrawRectangle",
    DrawRectangle_params,
    DrawRectangle_Before,
    Hook.HookMethodType.Before
);
