----------------------
------- LAYOUT -------
----------------------
---

local vars = require("variables")

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    general = {
        layout = "dwindle",

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

        col = {
            active_border   = vars.activeWindowBorderColour,
            inactive_border = vars.inactiveWindowBorderColour,
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,
    },

    dwindle = {
        preserve_split = true, -- You probably want this
        smart_split    = false,
        smart_resizing = true,
    },

    -- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
    scrolling = {
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        column_width             = 0.5,
        follow_focus             = true,
        follow_min_visible       = 0.0,
        explicit_column_widths   = "0.35, 0.5, 0.65, 1.0",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

