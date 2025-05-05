local Hsx = dofile(ItemFinderMod.Path .. "/Lua/Lib/Hsx.lua");

AutoSonarbeacon.Config = AutoSonarbeacon.ConfigLib.Load();
local Config = AutoSonarbeacon.Config;

local function ScaledSize(component)
    return component.RectTransform.ScaledSize;
end

local function CreateFrame(onCloseButton)
    GUI.GUI.PauseMenu.RemoveChild(GUI.GUI.PauseMenu.GetChild(Int32(1)));

    local mainFrame = GUI.Frame(GUI.RectTransform(Vector2(0.25, 0.3), GUI.GUI.PauseMenu.RectTransform, GUI.Anchor.Center));

    local innerFrame = GUI.LayoutGroup(GUI.RectTransform(Vector2(0.9, 0.75), mainFrame.RectTransform, GUI.Anchor.TopCenter));
    innerFrame.RectTransform.RelativeOffset = Vector2(0, 0.1);
    local frame = GUI.Frame(GUI.RectTransform(Vector2(1, 0.95), innerFrame.RectTransform, GUI.Anchor.TopCenter), "InnerFrame")

    local closeButton = GUI.Button(GUI.RectTransform(Vector2(1, 0.05), innerFrame.RectTransform, GUI.Anchor.BottomCenter), "Save and Close");
    closeButton.OnClicked = onCloseButton;

    return GUI.LayoutGroup(GUI.RectTransform(Vector2(0.97, 0.97), frame.RectTransform, GUI.Anchor.Center))
end

local function CreateTickBox(frame, configField, label)
    local tick = GUI.TickBox(
        GUI.RectTransform(Vector2(0.9, 0.85), frame.RectTransform),
        label
    );
    tick.Selected = Config[configField];
    tick.OnSelected = function ()
        Config[configField] = tick.Selected;
    end
end

local function CreateColorPicker(anchorComponent, color, onClose, onSelected)
    onClose = onClose or function () return; end
    onSelected = onSelected or function () return; end

    local colorPrickerContaner = GUI.Frame(
        GUI.RectTransform(Vector2.One, GUI.GUI.PauseMenu.RectTransform), 
        nil, 
        Color(0,0,0,0)
    );

    local backgoundBlocker = GUI.Button(GUI.RectTransform(Vector2.One, colorPrickerContaner.RectTransform, GUI.Anchor.Center), "", nil, "GUIBackgroundBlocker");
    backgoundBlocker.Color = Color(0,0,0,0);
    backgoundBlocker.HoverColor = Color(0,0,0,0);
    backgoundBlocker.SelectedColor = Color(0,0,0,0);
    backgoundBlocker.PressedColor = Color(0,0,0,0);
    backgoundBlocker.OnClicked = function ()
        onClose(color);
        colorPrickerContaner.Parent.RemoveChild(colorPrickerContaner);
    end
    
    local pickerFrame = GUI.Frame(GUI.RectTransform(Point(250, 150), colorPrickerContaner.RectTransform));
    local position = anchorComponent.RectTransform.TopLeft;
    position.X = position.X + ScaledSize(anchorComponent).X;
    pickerFrame.RectTransform.AbsoluteOffset = position;
    
    local pickerContainer = GUI.LayoutGroup(GUI.RectTransform(Vector2(0.8, 0.8), pickerFrame.RectTransform, GUI.Anchor.Center));
    local colorPricker = GUI.ColorPicker(GUI.RectTransform(Vector2(1, 0.7), pickerContainer.RectTransform, GUI.Anchor.TopCenter));
    colorPricker.RectTransform.RelativeOffset = Vector2(0, 1);

    -- i dunno why none of this works:
    --   colorPricker.Color = Color(123,123,123)
    --   colorPricker.CurrentColor = Color(123,123,123)
    --   colorPricker.DefaultColor = Color(123,123,123)
    --   colorPricker.SelectedColor = Color(123,123,123)
    --
    -- but work this:
    colorPricker.SelectedHue,
    colorPricker.SelectedSaturation,
    colorPricker.SelectedValue = Hsx.rgb2hsv(color);

    local newColor = color;
    colorPricker.OnColorSelected = function ( )
        newColor = {
            colorPricker.CurrentColor.r,
            colorPricker.CurrentColor.g,
            colorPricker.CurrentColor.b
        }
        onSelected(newColor);
    end

    local closeButton = GUI.Button(GUI.RectTransform(Vector2(1, 0.1), pickerContainer.RectTransform), "Done");
    closeButton.OnClicked = function ()
        onClose(newColor);
        colorPrickerContaner.Parent.RemoveChild(colorPrickerContaner);
    end
end

local function CreateColorPickerRow(frame, configField, label)

    local colorRaw = Config[configField];
    local color = Color(colorRaw[1], colorRaw[2], colorRaw[3]);

    local lineHeight = GUI.TickBox(GUI.RectTransform(Vector2(1,1))).RectTransform.ScaledSize.Y;
    local lineHeightSmall = GUI.Style.SmallFont.LineHeight;

    local row = GUI.LayoutGroup(
        GUI.RectTransform(
            Point(ScaledSize(frame).X, lineHeight),
            frame.RectTransform
        ),
        true
    );

    local colorButtonWrapper = GUI.Frame(
        GUI.RectTransform(Point(lineHeight, lineHeight), row.RectTransform), "", Color(0,0,0,0)
    )

    local colorButton = GUI.Button(
        GUI.RectTransform(Vector2(1, 0.8), colorButtonWrapper.RectTransform, GUI.Anchor.Center),
        nil,
        "GUIListBoxNoBorder",
        color
    );
    -- colorButton.RectTransform.AbsoluteOffset = Point(1000, 0); -- it doesnt work for some reason
    colorButton.SelectedColor = color;

    GUI.TextBlock(
        GUI.RectTransform(Point(ScaledSize(row).X - ScaledSize(colorButton).X, ScaledSize(row).Y), row.RectTransform, GUI.Anchor.Center),
        label
    );


    colorButton.OnClicked = function ()
        local function onSelected(selectedColor)
            color = Color(selectedColor[1], selectedColor[2], selectedColor[3]);
            colorButton.Color = color;
            colorButton.SelectedColor = color;
        end
        local function onDone(selectedColor)
            colorRaw = selectedColor;
            Config[configField] = colorRaw;
            color = Color(selectedColor[1], selectedColor[2], selectedColor[3]);
            onSelected(selectedColor);
        end
        CreateColorPicker(colorButton, colorRaw, onDone, onSelected)
    end

end

return function ()

    local frame = CreateFrame(function ()
        AutoSonarbeacon.Config = Config;
        AutoSonarbeacon.ConfigLib.Save(Config);
        GUI.GUI.TogglePauseMenu();
    end);

    CreateTickBox(frame, "OnlyTeammates", "Show only teammates");
    CreateTickBox(frame, "OnlyAlive", "Show only alive characters");
    CreateTickBox(frame, "UnlimitedRange", "Unlimited range (like mission marker)");
    CreateTickBox(frame, "DisableIfSonarBeaconActive", "Disable if sonar beacon active");
    CreateTickBox(frame, "OnlyOutside", "Show only in open water");

    CreateColorPickerRow(frame, "TeammatesColor", "Teammates marker color");
    CreateColorPickerRow(frame, "OtherColor", "Other marker color");


end
