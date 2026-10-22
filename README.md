<div align="center">

# Counter-Strike 1.6 ZBots

**Condition Zero bots, smarter hostages and a cleaner menu for Steam Counter-Strike 1.6 in one installer**

![Game](https://img.shields.io/badge/Counter--Strike-1.6%20(Steam)-orange?style=for-the-badge)
![ReGameDLL](https://img.shields.io/badge/ReGameDLL__CS-5.30.0.814-blue?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey?style=for-the-badge)
![Installer](https://img.shields.io/badge/built%20with-Inno%20Setup%206-264b99?style=for-the-badge)

[**Download the latest installer**](../../releases/latest)

</div>

---

## ✨ What you get

| | Feature | Details |
|---|---|---|
| 🤖 | **ZBots** | The official Condition Zero bots with all their profiles, chatter and 487 radio voice lines |
| 🧠 | **ReGameDLL_CS 5.30.0.814** | The game library that brings the bots back to Steam CS 1.6 after the 25th Anniversary update |
| 🗺️ | **Tuned nav files** | Hand-fixed navigation meshes so bots stop getting stuck (see [Nav files](#️-nav-files)) |
| 🧍 | **HostageImprov** | CZ hostages that follow you, crouch, flinch and react to gunfire, with their own models and voices |
| 🎛️ | **Bot options in the menu** | *Create Server* gets bot quota and difficulty settings plus the full **CPU Player Options** tab |
| 📋 | **Bot command menu** | *ADD/REMOVE BOTS*, *BOT CONTROL* and *BOT BEHAVIOUR* menus in the in-game command menu |
| 🎨 | **Blue-grey menu colors** *(optional)* | Swaps the green Steam-style menus for a calmer blue-grey theme |
| ♻️ | **Clean uninstall** | Your original files are backed up and restored when you uninstall |
| 🔔 | **Update check** | When a newer ReGameDLL_CS is out, the finish page offers to open its release page |

---

## 🐛 Fixes included

Problems found while putting this together, and how the installer handles them:

| Problem | Fix |
|---|---|
| Bots get stuck on **cs_assault** with the official CZ nav | Uses Ghost1744683's fixed nav instead |
| The official **de_cbble** nav has 18 walkable areas buried inside walls, because the map changed in the April 28, 2004 update | Uses papaschlange's nav, made for the current map |
| The official **de_nuke** nav is from before the same update and shows *"AI navigation data is from a different version of this map"* | Uses Ghost1744683's nav, which matches the current map |
| shanie's bot menu has the **Rogues** options reversed: *Allow* turned rogues off and *Disallow* turned them on | Swapped back, so *Allow* → `bot_allow_rogues 1` and *Disallow* → `bot_allow_rogues 0` |
| While bots learn a map without a nav file, the progress window is a tiny *"Learn.."* box with a title bar and close button | Adds CZ's `CSProgressBar.res`, so it shows the proper progress bar |
| The CZ Create Server page shows a **Tutor** checkbox that does nothing in CS 1.6 | Hidden |
| Steam's **Verify integrity** silently turns everything off | The installer warns about it and can simply be run again |
| The game turns on Windows' **Enhance pointer precision** every time it starts | Can't be fixed from game files. See [Recommended launch options](#️-recommended-launch-options) |

---

## 📦 Installation

1. Install **Counter-Strike** on Steam and launch it once.
2. Download `CS16_ZBots_Setup.exe` from the [**Releases**](../../releases/latest) page.
3. Run it. It finds your Half-Life folder automatically, including other Steam library drives.
4. Choose whether you want the blue-grey menu colors, then click through.
5. Start the game, open **Create Server**, and add some bots.

> [!IMPORTANT]
> Steam's **Verify integrity of game files** restores the original `mp.dll`, `delta.lst`, `liblist.gam` and `commandmenu.txt`, which turns the bots off.
> **Run the installer again** after every verify.

### 🖱️ Recommended launch options

The game turns on Windows' *Enhance pointer precision* (mouse acceleration) every time it starts, and `m_rawinput 1` doesn't stop it.
In Steam, right-click **Counter-Strike → Properties → General → Launch Options** and add:

```
-noforcemparms -noforcemaccel -noforcemspd
```

---

## 🎮 Using it

### Adding bots
- **Create Server** has **Bot quota** and difficulty (**Easy / Normal / Hard / Expert**) settings, and the **CPU Player Options** tab has everything else.
- In game, open the **command menu** for the bot menus. If it isn't bound yet, use `bind h +commandmenu`.
- You can also use the console: `bot_add`, `bot_add_ct`, `bot_add_t`, `bot_kick`, `bot_difficulty 0-3`, `bot_quota 10`.

### Hostages
The improved hostages are on by default and work on any map with a `.nav` file.
To go back to the classic hostages, set this in `cstrike\game_init.cfg`:

```
hostage_ai_enable "0"
```

You can also type it in the console and then **reload the map** (`map cs_office`). The behavior switches right away, but the hostage models only change when a map loads.

---

## 🗺️ Nav files

Bots need a `.nav` file for each map. These are the ones that worked best in testing:

| Source | Maps |
|---|---|
| [**Original nav file fix packs v1.0**](https://gamebanana.com/mods/328479) by Ghost1744683 | cs_747, cs_assault, cs_backalley, cs_havana, cs_italy, cs_mansion, cs_militia, cs_office, cs_office_cz, de_dust, de_dust2, de_inferno, de_nuke, de_piranesi, de_tuscan |
| [**200+ fixed .nav files**](https://gamebanana.com/mods/40203) by papaschlange and friends | de_cbble |
| Counter-Strike: Condition Zero (official) | Everything else |

<details>
<summary><b>Why not just the official CZ navs?</b></summary>

<br>

- **cs_assault:** bots got stuck on the official nav; on Ghost's fixed one they don't.
- **de_cbble:** the April 28, 2004 update (released with CZ 1.1) changed the map. It added boxes in the middle and at bombsite B, plus other changes. The official CZ nav still has **18 walkable areas buried inside walls**. papa's nav was made for the current map.
- **de_nuke:** the same update changed it too. Ghost's version matches the current map, so you don't get the *"AI navigation data is from a different version of this map"* warning.

</details>

---

## ❌ Uninstalling

Open **Windows Settings → Apps → Installed apps**, then uninstall **Counter-Strike 1.6 ZBots**.

This removes everything the installer added and puts back your original `mp.dll`, `delta.lst`, `liblist.gam`, `commandmenu.txt`, Create Server page and menu colors from `cstrike\zbots_backup`.

---

## 🛠️ Building from source

You need [**Inno Setup 6**](https://jrsoftware.org/isinfo.php). With winget: `winget install JRSoftware.InnoSetup`.

```
ISCC.exe CS16ZBots.iss
```

The installer is written to `output\CS16_ZBots_Setup.exe`.

```
CS16BotInstaller/
├── CS16ZBots.iss        Installer script
├── CREDITS.txt          Shown in the installer
├── payload/
│   ├── core/            Always installed into cstrike\
│   └── colors/          Optional blue-grey menu colors
└── output/              Built installer
```

### Updating ReGameDLL_CS
1. Download the new release from [ReGameDLL_CS releases](https://github.com/rehlds/ReGameDLL_CS/releases).
2. Copy `mp.dll`, `delta.lst`, `game.cfg` and `game_init.cfg` from `bin/win32/cstrike` into `payload/core`, keeping the same folders.
3. In the new `game_init.cfg`, set `hostage_ai_enable "1"`.
4. Rebuild. The version shown in the installer is read from `mp.dll` automatically.

---

## 🙏 Credits

This project only packages other people's work. Full details and links are in [**CREDITS.txt**](CREDITS.txt).

- **[ReGameDLL_CS](https://github.com/rehlds/ReGameDLL_CS)** by the ReHLDS team: game library, ZBot profiles and HostageImprov files ([MIT license](LICENSE-ReGameDLL.txt))
- **Counter-Strike: Condition Zero** by Valve and Turtle Rock Studios: bots, voices, hostages, official navs and menu layouts
- **[Ghost1744683](https://gamebanana.com/mods/328479)**: nav fix packs
- **[papaschlange](https://gamebanana.com/mods/40203)**, Mr.Jeff, renf1ld, npocTo_LaM, Thinker, Karas': de_cbble nav
- **[shanie](https://steamcommunity.com/id/shanieboop/)**: bot command menu
- **[Hasan Merkit](https://steamcommunity.com/sharedfiles/filedetails/?id=3378754164)**: the 25th Anniversary bot pack and guide this project learned from
- **[Inno Setup](https://jrsoftware.org/isinfo.php)** by Jordan Russell and Martijn Laan

---

<div align="center">

<sub>Counter-Strike, Counter-Strike: Condition Zero and Half-Life are trademarks of Valve Corporation.<br>
This project is not affiliated with or endorsed by Valve.</sub>

</div>
