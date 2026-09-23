-- Hyprglass
--
--
if hl.plugin.hyprglass then
    local hg = hl.plugin.hyprglass

    hg.config({
        enabled = false,
        default_theme = "light",
        default_preset = "glass",
        tint_color = 0x8899aa22,

        brightness = 0.9,
        dark = { brightness = 0.7 },
        light = {
          brightness = 1.2,
          adaptive_boost = 0.5,
        },

        layers = { enabled = true },
    })

    -- Layer surfaces: each call whitelists the namespace and configures it
    -- hg.layer("waybar", { preset = "subtle", mask_threshold = 0.05 })
    -- hg.layer("swaync")
    -- hg.layer("quickshell:bezel", { preset = "ui", mask_threshold = 0.3 })
    -- hg.layer("debug-panel", { exclude = true })

    -- Presets
    hg.preset("clear", {
        glass_opacity = 0.8,
        blur_strength = 1.5,
        dark = { brightness = 0.7 },
        light = { brightness = 1.2 },
    })

    hg.preset("contrasted", {
        inherits = "high_contrast",
        contrast = 1.2,
        adaptive_dim = 1.5,
        dark = { tint_color = 0x02142aa9 },
    })

    hg.preset("glass", {
      glass_opacity = 0.98,
      -- blur_strength = 2.0,
      -- blur_iterations = 3,
      chromatic_aberration = 0.3,
      fresnel_strength = 0.8,
      edge_thickness = 0.04,
    })
end
