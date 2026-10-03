--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

-- Tags an array of window matches. If `field` is given, matches should be an
-- array of strings. Otherwise, it should be an array of tables.
local function tagged_rule(tag, matches, field)
    for _, match in ipairs(matches) do
        if field then
            local table = {}
            table[field] = match
            match = table
        end
        hl.window_rule({ match = match, tag = "+" .. tag })
    end
end

-- All tags
local opaque_tag = "opaque"

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

-- Hyprland-run windowrule
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name  = "gtk-run",
    match = { class = "^([Tt]hunar|org.pulseaudio.pavucontrol)$" },

    -- move  = "20 monitor_h-120",
    center = true,
    size = {"(monitor_w*0.5)", "(monitor_h*0.5)"},
    float = true,
})

hl.window_rule({
    name  = "nnn-run",
    match = { class = "nnn" },

    -- move  = "20 monitor_h-120",
    center = true,
    size = {"(monitor_w*0.5)", "(monitor_h*0.5)"},
    float = true
})

hl.window_rule({
    name  = "term-run-floating",
    match = { class = "floating-term" },

    -- move  = "20 monitor_h-120",
    center = true,
    size = {"(monitor_w*0.75)", "(monitor_h*0.75)"},
    float = true,
})


hl.layer_rule({
    match = { namespace = "quickshell:bar" },
    blur = true,
    ignore_alpha = 0.4

})

tagged_rule(opaque_tag, {
    -- "equibop",                       -- Discord client
    "org.quickshell",                -- Quickshell
    -- "feh|imv|swappy",                -- Image viewers
    -- "krita|gimp|inkscape|darktable", -- Image editors
    -- "resolve|kdenlive|shotcut",      -- Video editors
    -- "blender|godot",                 -- 3D editors
}, "class")
