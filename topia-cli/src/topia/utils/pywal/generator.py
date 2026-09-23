
def gen_scheme(scheme, pywal_colors: dict) -> dict[str, str]:
    is_light = scheme.mode == "light"

    c = {k: v.replace("#", "") for k, v in pywal_colors["colors"].items()}
    bg = pywal_colors["special"]["background"].replace("#", "")
    fg = pywal_colors["special"]["foreground"].replace("#", "")

    # Mathematical color shifts to create depth for container elements
    def tweak_hex(hex_str, factor):
        r, g, b = int(hex_str[0:2], 16), int(hex_str[2:4], 16), int(hex_str[4:6], 16)
        r = min(255, max(0, int(r * factor)))
        g = min(255, max(0, int(g * factor)))
        b = min(255, max(0, int(b * factor)))
        return f"{r:02x}{g:02x}{b:02x}"

    colours = {}

    # --- Base Backgrounds & Surfaces ---
    colours["background"] = bg
    colours["onBackground"] = fg
    colours["surface"] = tweak_hex(bg, 0.8)
    colours["surfaceDim"] = tweak_hex(bg, 0.7)
    colours["surfaceBright"] = tweak_hex(bg, 1.2)
    colours["surfaceContainerLowest"] = "000000"
    colours["surfaceContainerLow"] = tweak_hex(bg, 0.9)
    colours["surfaceContainer"] = bg
    colours["surfaceContainerHigh"] = tweak_hex(bg, 1.1)
    colours["surfaceContainerHighest"] = tweak_hex(bg, 1.3)
    colours["onSurface"] = fg
    colours["surfaceVariant"] = tweak_hex(bg, 1.1)
    colours["onSurfaceVariant"] = c["color7"]
    colours["outline"] = c["color8"]
    colours["outlineVariant"] = c["color0"]
    colours["inverseSurface"] = fg
    colours["inverseOnSurface"] = bg
    colours["shadow"] = "000000"
    colours["scrim"] = "000000"
    colours["surfaceTint"] = c["color4"]

    # --- Core UI Accents ---
    colours["primary"] = c["color4"]
    colours["primaryDim"] = c["color12"]
    colours["onPrimary"] = bg
    colours["primaryContainer"] = tweak_hex(c["color4"], 0.4)
    colours["onPrimaryContainer"] = fg
    colours["inversePrimary"] = c["color4"]
    colours["primaryFixed"] = c["color12"]
    colours["primaryFixedDim"] = c["color4"]
    colours["onPrimaryFixed"] = bg
    colours["onPrimaryFixedVariant"] = c["color8"]

    colours["secondary"] = c["color5"]
    colours["secondaryDim"] = c["color13"]
    colours["onSecondary"] = bg
    colours["secondaryContainer"] = tweak_hex(c["color5"], 0.4)
    colours["onSecondaryContainer"] = fg
    colours["secondaryFixed"] = c["color13"]
    colours["secondaryFixedDim"] = c["color5"]
    colours["onSecondaryFixed"] = bg
    colours["onSecondaryFixedVariant"] = c["color8"]

    colours["tertiary"] = c["color6"]
    colours["tertiaryDim"] = c["color14"]
    colours["onTertiary"] = bg
    colours["tertiaryContainer"] = tweak_hex(c["color6"], 0.4)
    colours["onTertiaryContainer"] = fg
    colours["tertiaryFixed"] = c["color14"]
    colours["tertiaryFixedDim"] = c["color6"]
    colours["onTertiaryFixed"] = bg
    colours["onTertiaryFixedVariant"] = c["color8"]

    # --- Error & Status Colors ---
    colours["error"] = c["color1"]
    colours["errorDim"] = tweak_hex(c["color1"], 0.8)
    colours["onError"] = "200000"
    colours["errorContainer"] = tweak_hex(c["color1"], 0.4)
    colours["onErrorContainer"] = fg
 
    colours["success"] = "B5CCBA"
    colours["onSuccess"] = "213528"
    colours["successContainer"] = "374B3E"
    colours["onSuccessContainer"] = "D1E9D6"

    # --- Palette Key Diagnostics ---
    colours["primaryPaletteKeyColor"] = c["color4"]
    colours["secondaryPaletteKeyColor"] = c["color5"]
    colours["tertiaryPaletteKeyColor"] = c["color6"]
    colours["neutralPaletteKeyColor"] = c["color7"]
    colours["neutralVariantPaletteKeyColor"] = c["color8"]
    colours["errorPaletteKeyColor"] = c["color1"]
 
    colours["primary_paletteKeyColor"] = c["color4"]
    colours["secondary_paletteKeyColor"] = c["color5"]
    colours["tertiary_paletteKeyColor"] = c["color6"]
    colours["neutral_paletteKeyColor"] = c["color7"]
    colours["neutral_variant_paletteKeyColor"] = c["color8"]

    # --- ANSI Terminal Slots ---
    for i in range(16):
        colours[f"term{i}"] = c[f"color{i}"]

    # --- Catppuccin Hybrid Theme Tokens ---
    colours["rosewater"] = fg
    colours["flamingo"] = c["color13"]
    colours["pink"] = c["color5"]
    colours["mauve"] = c["color13"]
    colours["red"] = c["color1"]
    colours["maroon"] = c["color9"]
    colours["peach"] = c["color3"]
    colours["yellow"] = c["color11"]
    colours["green"] = c["color2"]
    colours["teal"] = c["color6"]
    colours["sky"] = c["color14"]
    colours["sapphire"] = c["color12"]
    colours["blue"] = c["color4"]
    colours["lavender"] = c["color12"]

    # --- Engine Custom Extension Elements ---
    colours["klink"] = c["color4"]
    colours["klinkSelection"] = c["color12"]
    colours["kvisited"] = c["color5"]
    colours["kvisitedSelection"] = c["color13"]
    colours["knegative"] = c["color1"]
    colours["knegativeSelection"] = c["color9"]
    colours["kneutral"] = c["color3"]
    colours["kneutralSelection"] = c["color11"]
    colours["kpositive"] = c["color2"]
    colours["kpositiveSelection"] = c["color10"]

    # --- Modern-to-Legacy Fallback Layers ---
    colours["text"] = fg
    colours["subtext1"] = c["color7"]
    colours["subtext0"] = c["color8"]
    colours["overlay2"] = tweak_hex(bg, 1.4)
    colours["overlay1"] = tweak_hex(bg, 1.3)
    colours["overlay0"] = tweak_hex(bg, 1.2)
    colours["surface2"] = tweak_hex(bg, 1.3)
    colours["surface1"] = tweak_hex(bg, 1.2)
    colours["surface0"] = tweak_hex(bg, 1.1)
    colours["base"] = bg
    colours["mantle"] = tweak_hex(bg, 0.9)
    colours["crust"] = tweak_hex(bg, 0.8)

    # TODO: WTF is this
    # Extended material
    # if is_light:
    #     colours["success"] = "4F6354"
    #     colours["onSuccess"] = "FFFFFF"
    #     colours["successContainer"] = "D1E8D5"
    #     colours["onSuccessContainer"] = "0C1F13"
    # else:
    #     colours["success"] = "B5CCBA"
    #     colours["onSuccess"] = "213528"
    #     colours["successContainer"] = "374B3E"
    #     colours["onSuccessContainer"] = "D1E9D6"

    return colours
