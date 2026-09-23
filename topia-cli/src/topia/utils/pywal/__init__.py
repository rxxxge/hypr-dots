import pywal
import json
from pathlib import Path

from topia.utils.paths import compute_hash, scheme_cache_dir, wallpaper_thumbnail_path

def get_pywal_colors_for_image(image: Path | str = wallpaper_thumbnail_path, scheme=None) -> dict[str, str]:
    if scheme is None:
        from topia.utils.scheme import get_scheme

        scheme = get_scheme()

    cache_base = scheme_cache_dir / compute_hash(image)
    cache = (cache_base / scheme.variant / scheme.flavour / scheme.mode / scheme.backend).with_suffix(".json")

    try:
        with cache.open("r") as f:
            return json.load(f)
    except (IOError, json.JSONDecodeError):
        pass

    from topia.utils.pywal.generator import gen_scheme

    pywal_image = pywal.image.get(image)
    # TODO: Pass arguments from cmd line
    pywal_colors = pywal.colors.get(pywal_image, backend="colorthief", c16="lighten", cst=2.5)
    scheme = gen_scheme(scheme, pywal_colors)

    cache.parent.mkdir(parents=True, exist_ok=True)
    with cache.open("w") as f:
        json.dump(scheme, f)

    return scheme
