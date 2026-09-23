-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- Mouse cursor 
-- hl.env("XCURSOR_THEME", "MyCursorTheme")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Nvidia
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
-- VA-API hardware video acceleration 
hl.env("NVD_BACKEND", "direct")

-- To enable native Wayland support for most Electron apps
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Qt
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
-- hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")

-- GUI toolkits’ backend 
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland")
-- hl.env("CLUTTER_BACKEND", "wayland")
