from PIL import Image, ImageDraw, ImageFilter
from pathlib import Path

# Project paths
PROJECT_DIR = Path(__file__).resolve().parent
ASSETS_DIR = PROJECT_DIR / "assets"
ASSETS_DIR.mkdir(exist_ok=True)

PNG_PATH = ASSETS_DIR / "network_doctor_1024.png"
ICO_PATH = ASSETS_DIR / "network_doctor.ico"

SIZE = 1024

# Transparent canvas
canvas = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

# Layers
glow_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
main_layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))

glow = ImageDraw.Draw(glow_layer)
draw = ImageDraw.Draw(main_layer)

# Colors
DARK_SLATE = (15, 23, 42, 255)
BORDER = (51, 65, 85, 255)
CYAN = (0, 210, 255, 255)
MINT = (0, 255, 163, 255)
WHITE = (255, 255, 255, 255)

# ---------------------------------------------------------
# Shield
# ---------------------------------------------------------

shield = [
    (512, 70),
    (880, 140),
    (880, 500),
    (512, 950),
    (144, 500),
    (144, 140),
]

draw.polygon(
    shield,
    fill=DARK_SLATE,
    outline=BORDER,
)

# ---------------------------------------------------------
# Network orbital ring
# ---------------------------------------------------------

draw.ellipse(
    [232, 200, 792, 760],
    outline=(0, 210, 255, 100),
    width=20,
)

# ---------------------------------------------------------
# Medical cross
# ---------------------------------------------------------

draw.rounded_rectangle(
    [428, 250, 596, 710],
    radius=40,
    fill=CYAN,
)

draw.rounded_rectangle(
    [250, 428, 774, 596],
    radius=40,
    fill=CYAN,
)

# ---------------------------------------------------------
# Network / heartbeat line
# ---------------------------------------------------------

ekg = [
    (190, 512),
    (350, 512),
    (420, 350),
    (480, 670),
    (540, 390),
    (600, 512),
    (834, 512),
]

# Glow
glow.line(
    ekg,
    fill=MINT,
    width=55,
    joint="curve",
)

# Main line
draw.line(
    ekg,
    fill=WHITE,
    width=30,
    joint="curve",
)

# ---------------------------------------------------------
# Network nodes
# ---------------------------------------------------------

nodes = [
    (512, 210),
    (512, 750),
    (210, 512),
    (814, 512),
]

for index, (x, y) in enumerate(nodes):

    color = MINT if index % 2 == 0 else CYAN

    # Glow
    glow.ellipse(
        [x - 55, y - 55, x + 55, y + 55],
        fill=color,
    )

    # Node
    draw.ellipse(
        [x - 30, y - 30, x + 30, y + 30],
        fill=WHITE,
        outline=color,
        width=8,
    )

# ---------------------------------------------------------
# Combine glow and main artwork
# ---------------------------------------------------------

glow = glow_layer.filter(
    ImageFilter.GaussianBlur(18)
)

final_image = Image.alpha_composite(
    canvas,
    glow,
)

final_image = Image.alpha_composite(
    final_image,
    main_layer,
)

# ---------------------------------------------------------
# Save PNG
# ---------------------------------------------------------

final_image.save(
    PNG_PATH,
    "PNG",
)

# ---------------------------------------------------------
# Save Windows ICO
# ---------------------------------------------------------

final_image.save(
    ICO_PATH,
    format="ICO",
    sizes=[
        (16, 16),
        (24, 24),
        (32, 32),
        (48, 48),
        (64, 64),
        (128, 128),
        (256, 256),
    ],
)

print()
print("Network Doctor icon created successfully!")
print()
print(f"PNG: {PNG_PATH}")
print(f"ICO: {ICO_PATH}")