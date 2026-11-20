"""Générateur des ressources graphiques pixel art du jeu.

Ce script est un outil de développement conservé pour pouvoir modifier et
régénérer les nouveaux visuels à partir des formes, couleurs et caractères
définis ci-dessous. Il produit les SVG des murs en pierre, du repère de limite,
de la brique runique, de la raquette et de la boule de feu dans assets/sprites/.
Il crée également la police bitmap dans assets/ui/ : arcane_pixel.png contient
les images des caractères et arcane_pixel.fnt décrit leurs positions et leur
espacement. Les minuscules reprennent volontairement le dessin des majuscules.

Pour l'utiliser, installer Pillow dans un environnement Python de développement,
puis exécuter « python3 tools/create_visual_assets.py » depuis la racine du dépôt.
Les chemins de sortie sont calculés à partir de l'emplacement de ce fichier.
Attention : chaque exécution écrase les ressources générées correspondantes ;
pour conserver une modification, la reporter ici plutôt que dans ces fichiers.
Le fond et l'orbe existants, les scènes et le thème d'interface ne sont pas modifiés.

Godot importe directement les SVG et la police déjà présents dans le dépôt et
réimporte les ressources après leur régénération. Ce script n'est jamais exécuté
par le jeu : Python et Pillow ne sont nécessaires que pour régénérer les visuels.
"""
from pathlib import Path
from PIL import Image, ImageDraw
ROOT = Path(__file__).resolve().parents[1]
SPRITES = ROOT / 'assets/sprites'

def svg(name, w, h, body):
    (SPRITES / name).write_text(f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" shape-rendering="crispEdges">{body}</svg>\n')

def rect(x, y, w, h, c):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{c}"/>'

def stone(w, h):
    body = rect(0, 0, w, h, '#151b30')
    for row, y in enumerate(range(0, h, 12)):
        for x in range(-12 if row % 2 else 0, w, 24):
            color = ['#414b65', '#35405a', '#49516b'][(row + x // 24) % 3]
            body += rect(x+1, y+1, 22, 10, color)
            body += rect(x+2, y+1, 20, 1, '#68728a')
            body += rect(x+2, y+9, 20, 2, '#242c45')
            body += rect(x+5, y+4, 3, 1, '#515e76')
    return body
svg('wall_horizontal.svg', 432, 16, stone(432,16) + rect(0,14,432,2,'#9c875d'))
# Both walls use the same local engraving, positioned at the computed gameplay limit.
# Its center is at y=0 in wall coordinates; 76 is the top of the walls in the scene.
for name, inward in [('left', 1), ('right', -1)]:
    body = stone(16,504)
    body += rect(14 if inward == 1 else 0,0,2,504,'#7b7180')
    svg(f'wall_{name}.svg',16,504,body)
svg('limit_stone.svg',16,16, stone(16,16) + rect(0,6,16,4,'#151b30') + rect(0,7,16,2,'#db8051') + '<path d="M8 2H10V4H12V6H10V10H12V12H10V14H6V12H4V10H6V6H4V4H6V2Z" fill="#efbb72"/>' + rect(7,5,2,6,'#8b443e'))
body = rect(0,0,72,24,'#131b30') + rect(2,0,68,22,'#68718b') + rect(2,2,68,18,'#394861') + rect(4,4,64,14,'#28364f') + rect(4,20,64,2,'#1c263d')
body += rect(6,5,12,2,'#51617a') + rect(54,16,10,2,'#18263d')
body += '<path d="M23 6H25V10H29V6H31V18H29V12H25V18H23Z M35 4H37V8H41V10H37V14H41V16H37V20H35Z M45 6H49V8H47V16H49V18H43V16H45V8H43V6Z" fill="#69d5e4"/>'
svg('runic_brick.svg',72,24,body)
svg('arcane_paddle.svg',96,16, '<path d="M0 4H4V0H92V4H96V12H92V16H4V12H0Z" fill="#141c32"/>' + rect(4,2,88,12,'#7d7d91') + rect(8,4,80,8,'#35445d') + rect(8,3,80,2,'#c0a16c') + rect(8,12,80,2,'#655379') + rect(2,5,6,6,'#bfa374') + rect(88,5,6,6,'#bfa374') + '<path d="M40 4H44V2H52V4H56V12H52V14H44V12H40Z" fill="#182b51"/><path d="M44 4H52V6H54V10H50V12H44V10H42V6H44Z" fill="#57c7e2"/>' + rect(46,4,4,4,'#c4faff') + rect(16,7,12,2,'#6b91ac') + rect(68,7,12,2,'#6b91ac'))
svg('fireball.svg',16,24, '<path d="M3 0H5V5H7V2H9V7H11V4H13V10H15V14H16V20H13V23H4V21H1V17H0V12H2V8H3Z" fill="#702d3c"/><path d="M4 3H5V8H8V5H9V11H12V8H13V14H15V19H12V22H5V20H2V14H4Z" fill="#e35c33"/><path d="M6 9H8V12H10V10H11V15H13V19H11V21H6V19H4V15H6Z" fill="#ffb64b"/>' + rect(7,15,4,5,'#fff1b3') + rect(8,13,2,2,'#fff1b3'))
# Original 5x7 glyphs; lowercase shares uppercase to keep a consistent rune-like face.
patterns = {
'A':'01110/10001/10001/11111/10001/10001/10001','B':'11110/10001/10001/11110/10001/10001/11110','C':'01111/10000/10000/10000/10000/10000/01111','D':'11110/10001/10001/10001/10001/10001/11110','E':'11111/10000/10000/11110/10000/10000/11111','F':'11111/10000/10000/11110/10000/10000/10000','G':'01111/10000/10000/10111/10001/10001/01111','H':'10001/10001/10001/11111/10001/10001/10001','I':'111/010/010/010/010/010/111','J':'00111/00010/00010/00010/10010/10010/01100','K':'10001/10010/10100/11000/10100/10010/10001','L':'10000/10000/10000/10000/10000/10000/11111','M':'10001/11011/10101/10101/10001/10001/10001','N':'10001/11001/10101/10011/10001/10001/10001','O':'01110/10001/10001/10001/10001/10001/01110','P':'11110/10001/10001/11110/10000/10000/10000','Q':'01110/10001/10001/10001/10101/10010/01101','R':'11110/10001/10001/11110/10100/10010/10001','S':'01111/10000/10000/01110/00001/00001/11110','T':'11111/00100/00100/00100/00100/00100/00100','U':'10001/10001/10001/10001/10001/10001/01110','V':'10001/10001/10001/10001/10001/01010/00100','W':'10001/10001/10001/10101/10101/11011/10001','X':'10001/10001/01010/00100/01010/10001/10001','Y':'10001/10001/01010/00100/00100/00100/00100','Z':'11111/00001/00010/00100/01000/10000/11111',
'0':'01110/10001/10011/10101/11001/10001/01110','1':'010/110/010/010/010/010/111','2':'01110/10001/00001/00010/00100/01000/11111','3':'11110/00001/00001/01110/00001/00001/11110','4':'00010/00110/01010/10010/11111/00010/00010','5':'11111/10000/10000/11110/00001/00001/11110','6':'01110/10000/10000/11110/10001/10001/01110','7':'11111/00001/00010/00100/01000/01000/01000','8':'01110/10001/10001/01110/10001/10001/01110','9':'01110/10001/10001/01111/00001/00001/01110',
' ':'000/000/000/000/000/000/000',':':'0/1/1/0/1/1/0','-':'000/000/000/111/000/000/000','.':'0/0/0/0/0/1/1',"'":'1/1/0/0/0/0/0','!':'1/1/1/1/1/0/1','?':'11110/00001/00010/00100/00100/00000/00100'}
for char in 'abcdefghijklmnopqrstuvwxyz': patterns[char] = patterns[char.upper()]
for char, base, accent in [('é','E','00100/01000'),('è','E','01000/00100'),('ê','E','00100/01010'),('à','A','01000/00100'),('É','E','00100/01000'),('ç','C','00000/00000')]:
    patterns[char] = accent + '/00000/' + patterns[base]
patterns['—'] = patterns['-']
atlas = Image.new('RGBA',(256,256))
draw = ImageDraw.Draw(atlas)
lines = ['info face="Arcane Pixel" size=16 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=0,0', 'common lineHeight=24 base=20 scaleW=256 scaleH=256 pages=1 packed=0', 'page id=0 file="arcane_pixel.png"', f'chars count={len(patterns)}']
for index,(char,pattern) in enumerate(patterns.items()):
    rows=pattern.split('/'); width=max(map(len, rows))*2
    x=(index%16)*16; y=(index//16)*28
    offset=0 if len(rows)>7 else 6
    for yy,row in enumerate(rows):
        for xx,pixel in enumerate(row):
            if pixel=='1': draw.rectangle((x+xx*2,y+offset+yy*2,x+xx*2+1,y+offset+yy*2+1),fill='white')
    lines.append(f'char id={ord(char)} x={x} y={y} width={width} height=22 xoffset=0 yoffset=0 xadvance={width+2} page=0 chnl=15')
atlas.save(ROOT/'assets/ui/arcane_pixel.png')
(ROOT/'assets/ui/arcane_pixel.fnt').write_text('\n'.join(lines)+'\n')
