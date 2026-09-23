----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,

        force_default_wallpaper = 0,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(

        on_focus_under_fullscreen    = 2,
        allow_session_lock_restore   = true,
        middle_click_paste           = false,
        focus_on_activate            = true,
        session_lock_xray            = true,

        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,

        background_color             = "#000000",
    },

    debug = {
        error_position = 1
    }
})
