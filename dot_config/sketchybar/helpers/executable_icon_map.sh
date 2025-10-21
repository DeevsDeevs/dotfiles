#!/usr/bin/env bash

### START-OF-ICON-MAP
function __icon_map() {
    case "$1" in
   "AirPort Utility")
        icon_result=":airport_utility:"
        ;;
   "calibre")
        icon_result=":calibre:"
        ;;
   "Nova")
        icon_result=":nova:"
        ;;
   "Tor Browser")
        icon_result=":tor_browser:"
        ;;
   "TradingView")
        icon_result=":trading_view:"
        ;;
   "Blitzit")
        icon_result=":blitzit:"
        ;;
   "EuDic")
        icon_result=":eudic:"
        ;;
   "Messages" | "信息" | "Nachrichten" | "メッセージ")
        icon_result=":messages:"
        ;;
   "Infuse")
        icon_result=":infuse:"
        ;;
   "WezTerm" | "wezterm-gui")
        icon_result=":wezterm:"
        ;;
   "superProductivity")
        icon_result=":superproductivity:"
        ;;
   "Affinity Photo")
        icon_result=":affinity_photo:"
        ;;
   "Logseq")
        icon_result=":logseq:"
        ;;
   "Sequel Pro")
        icon_result=":sequel_pro:"
        ;;
   "Telegram")
        icon_result=":telegram:"
        ;;
   "Caprine")
        icon_result=":caprine:"
        ;;
   "Plex")
        icon_result=":plex:"
        ;;
   "MAMP" | "MAMP PRO")
        icon_result=":mamp:"
        ;;
   "Double Commander")
        icon_result=":doublecmd:"
        ;;
   "TeamSpeak 3")
        icon_result=":team_speak:"
        ;;
   "微信" | "WeChat")
        icon_result=":wechat:"
        ;;
   "Zen" | "Zen Browser")
        icon_result=":zen_browser:"
        ;;
   "Creative Cloud")
        icon_result=":creative_cloud:"
        ;;
   "Adobe Illustrator"* | "Illustrator")
        icon_result=":illustrator:"
        ;;
   "Scribus")
        icon_result=":scribus:"
        ;;
   "Zulip")
        icon_result=":zulip:"
        ;;
   "Pearcleaner")
        icon_result=":pearcleaner:"
        ;;
   "Spotify")
        icon_result=":spotify:"
        ;;
   "Books" | "Calibre" | "Bücher")
        icon_result=":book:"
        ;;
   "DEVONthink 3")
        icon_result=":devonthink3:"
        ;;
   "카카오톡" | "KakaoTalk")
        icon_result=":kakaotalk:"
        ;;
   "WebStorm")
        icon_result=":web_storm:"
        ;;
   "MongoDB Compass"*)
        icon_result=":mongodb:"
        ;;
   "Joplin")
        icon_result=":joplin:"
        ;;
   "ChatGPT")
        icon_result=":openai:"
        ;;
   "Books" | "Apple Books")
        icon_result=":apple_books:"
        ;;
   "Quantumult X")
        icon_result=":quantumult_x:"
        ;;
   "Sketch")
        icon_result=":sketch:"
        ;;
   "LibreWolf")
        icon_result=":libre_wolf:"
        ;;
   "Microsoft Outlook")
        icon_result=":microsoft_outlook:"
        ;;
   "Android Messages")
        icon_result=":android_messages:"
        ;;
   "App Eraser")
        icon_result=":app_eraser:"
        ;;
   "Proton VPN" | "ProtonVPN")
        icon_result=":proton_vpn:"
        ;;
   "Godot")
        icon_result=":godot:"
        ;;
   "WhatsApp" | "‎WhatsApp")
        icon_result=":whats_app:"
        ;;
   "Emacs")
        icon_result=":emacs:"
        ;;
   "Jellyfin Media Player")
        icon_result=":jellyfin:"
        ;;
   "JetBrains Gateway")
        icon_result=":jetbrains_gateway:"
        ;;
   "Final Cut Pro")
        icon_result=":final_cut_pro:"
        ;;
   "KiCad")
        icon_result=":kicad:"
        ;;
   "mpv")
        icon_result=":mpv:"
        ;;
   "qutebrowser")
        icon_result=":qute_browser:"
        ;;
   "Bluetooth File Exchange")
        icon_result=":bluetooth_file_exchange:"
        ;;
   "Karabiner-Elements Settings")
        icon_result=":karabiner_elements:"
        ;;
   "Firefox Developer Edition" | "Firefox Nightly")
        icon_result=":firefox_developer_edition:"
        ;;
   "Clock")
        icon_result=":clock:"
        ;;
   "Orion" | "Orion RC")
        icon_result=":orion:"
        ;;
   "Blender")
        icon_result=":blender:"
        ;;
   "Maccy")
        icon_result=":maccy_clip:"
        ;;
   "Comet")
        icon_result=":comet:"
        ;;
   "Find My")
        icon_result=":find_my:"
        ;;
   "Bruno")
        icon_result=":bruno:"
        ;;
   "OmniFocus")
        icon_result=":omni_focus:"
        ;;
   "Pixelmator Pro")
        icon_result=":pixelmator_pro:"
        ;;
   "Microsoft Edge")
        icon_result=":microsoft_edge:"
        ;;
   "Airmail")
        icon_result=":airmail:"
        ;;
   "TextEdit")
        icon_result=":textedit:"
        ;;
   "Nimble Commander" | "NimbleCommander-Unsigned")
        icon_result=":nimble_commander:"
        ;;
   "Brave Browser")
        icon_result=":brave_browser:"
        ;;
   "Deezer")
        icon_result=":deezer:"
        ;;
   "nvALT")
        icon_result=":nvalt:"
        ;;
   "Foxit PDF Reader")
        icon_result=":foxit_reader:"
        ;;
   "UTM")
        icon_result=":utm:"
        ;;
   "Battle.net")
        icon_result=":battle_net:"
        ;;
   "Instapaper")
        icon_result=":instapaper:"
        ;;
   "Sublime Text")
        icon_result=":sublime_text:"
        ;;
   "LM Studio")
        icon_result=":lm_studio:"
        ;;
   "Yazi" | "yazi")
        icon_result=":yazi:"
        ;;
   "Raycast")
        icon_result=":raycast:"
        ;;
   "Noodl" | "Noodl Editor")
        icon_result=":noodl:"
        ;;
   "App Store")
        icon_result=":app_store:"
        ;;
   "iTerm" | "iTerm2")
        icon_result=":iterm:"
        ;;
   "Windows App")
        icon_result=":windows_app:"
        ;;
   "DBeaver")
        icon_result=":dbeaver:"
        ;;
   "Gemini" | "Google Gemini")
        icon_result=":gemini:"
        ;;
   "Figma")
        icon_result=":figma:"
        ;;
   "sioyek")
        icon_result=":sioyek:"
        ;;
   "Zed")
        icon_result=":zed:"
        ;;
   "Audacity")
        icon_result=":audacity:"
        ;;
   "Steam" | "Steam Helper")
        icon_result=":steam:"
        ;;
   "Home")
        icon_result=":home:"
        ;;
   "Finder" | "访达")
        icon_result=":finder:"
        ;;
   "Affinity Publisher")
        icon_result=":affinity_publisher:"
        ;;
   "NetNewsWire")
        icon_result=":netnewswire:"
        ;;
   "Plexamp")
        icon_result=":plexamp:"
        ;;
   "Games")
        icon_result=":games:"
        ;;
   "Pi-hole Remote")
        icon_result=":pihole:"
        ;;
   "1Password")
        icon_result=":one_password:"
        ;;
   "Craft")
        icon_result=":craft:"
        ;;
   "Alfred")
        icon_result=":alfred:"
        ;;
   "Xcode")
        icon_result=":xcode:"
        ;;
   "Raindrop.io")
        icon_result=":raindrop_io:"
        ;;
   "Anytype")
        icon_result=":anytype:"
        ;;
   "MacVim" | "Vim" | "VimR")
        icon_result=":vim:"
        ;;
   "Dash")
        icon_result=":dash:"
        ;;
   "Iris")
        icon_result=":iris:"
        ;;
   "Notability")
        icon_result=":notability:"
        ;;
   "Surfshark")
        icon_result=":surfshark:"
        ;;
   "Quip")
        icon_result=":quip:"
        ;;
   "AltTab")
        icon_result=":alttab:"
        ;;
   "Proton Mail" | "Proton Mail Bridge")
        icon_result=":proton_mail:"
        ;;
   "ClassIn")
        icon_result=":classin:"
        ;;
   "League of Legends")
        icon_result=":league_of_legends:"
        ;;
   "PrusaSlicer" | "SuperSlicer")
        icon_result=":prusaslicer:"
        ;;
   "Arc")
        icon_result=":arc:"
        ;;
   "Webull Desktop")
        icon_result=":webull:"
        ;;
   "Inkdrop")
        icon_result=":inkdrop:"
        ;;
   "Insomnia")
        icon_result=":insomnia:"
        ;;
   "TIDAL")
        icon_result=":tidal:"
        ;;
   "Google Chat")
        icon_result=":google_chat:"
        ;;
   "GIMP")
        icon_result=":gimp:"
        ;;
   "SF Symbols" | "SF Symbole" | "SF-Symbole")
        icon_result=":sf_symbols:"
        ;;
   "CotEditor")
        icon_result=":coteditor:"
        ;;
   "Canary Mail" | "HEY" | "Mail" | "Mailspring" | "MailMate" | "Superhuman" | "Spark" | "Spark Mail" | "邮件" | "メール")
        icon_result=":mail:"
        ;;
   "Feishu")
        icon_result=":feishu:"
        ;;
   "MacPass")
        icon_result=":macpass:"
        ;;
   "Notes" | "备忘录" | "メモ" | "Notizen")
        icon_result=":notes:"
        ;;
   "Cursor")
        icon_result=":cursor:"
        ;;
   "Affinity Designer")
        icon_result=":affinity_designer:"
        ;;
   "Keynote" | "Keynote 讲演")
        icon_result=":keynote:"
        ;;
   "Overleaf" | "ShareLaTeX")
        icon_result=":overleaf:"
        ;;
   "Yandex Browser"  | "Yandex Browser" | "Yandex")
        icon_result=":yandex_bower:"
        ;;
   "Adobe InDesign"* | "InDesign")
        icon_result=":indesign:"
        ;;
   "企业微信" | "WeCom")
        icon_result=":wecom:"
        ;;
   "QuickTime Player")
        icon_result=":quicktime:"
        ;;
   "Tabby")
        icon_result=":tabby:"
        ;;
   "Seafile")
        icon_result=":seafile:"
        ;;
   "Pine")
        icon_result=":pine:"
        ;;
   "Movist Pro")
        icon_result=":movist_pro:"
        ;;
   "CleanMyMac X")
        icon_result=":desktop:"
        ;;
   "Drafts")
        icon_result=":drafts:"
        ;;
   "FreeCAD")
        icon_result=":freecad:"
        ;;
   "OBS")
        icon_result=":obsstudio:"
        ;;
   "Keyboard Maestro")
        icon_result=":keyboard_maestro:"
        ;;
   "Passepartout")
        icon_result=":passepartout:"
        ;;
   "LocalSend")
        icon_result=":localsend:"
        ;;
   "Dropbox")
        icon_result=":dropbox:"
        ;;
   "Parallels Desktop")
        icon_result=":parallels:"
        ;;
   "FaceTime" | "FaceTime 通话")
        icon_result=":face_time:"
        ;;
   "Safari" | "Safari浏览器" | "Safari Technology Preview")
        icon_result=":safari:"
        ;;
   "PyCharm")
        icon_result=":pycharm:"
        ;;
   "TablePlus")
        icon_result=":tableplus:"
        ;;
   "zoom.us")
        icon_result=":zoom:"
        ;;
   "Thunderbird" | "Thunderbird Daily")
        icon_result=":thunderbird:"
        ;;
   "Neovim" | "neovim" | "nvim")
        icon_result=":neovim:"
        ;;
   "Alacritty")
        icon_result=":alacritty:"
        ;;
   "OrbStack")
        icon_result=":orbstack:"
        ;;
   "Citrix Workspace" | "Citrix Viewer")
        icon_result=":citrix:"
        ;;
   "NordVPN")
        icon_result=":nord_vpn:"
        ;;
   "Remind Faster")
        icon_result=":remind_me_faster:"
        ;;
   "Spark Desktop")
        icon_result=":spark:"
        ;;
   "Nvidia GeForce Now" | "GeForceNOW")
        icon_result=":nvidia_geforce_now:"
        ;;
   "VMware Fusion")
        icon_result=":vmware_fusion:"
        ;;
   "QQ音乐" | "QQMusic")
        icon_result=":qqmusic:"
        ;;
   "Freeform")
        icon_result=":freeform:"
        ;;
   "T3 Chat")
        icon_result=":t3chat:"
        ;;
   "Phone")
        icon_result=":phone:"
        ;;
   "Tweetbot" | "Twitter")
        icon_result=":twitter:"
        ;;
   "iPhone Mirroring")
        icon_result=":iphone_mirroring:"
        ;;
   "Activity Monitor" | "Aktivitätsanzeige")
        icon_result=":activity_monitor:"
        ;;
   "Skype")
        icon_result=":skype:"
        ;;
   "FSNotes")
        icon_result=":fsnotes:"
        ;;
   "Calculator" | "Calculette" | "Rechner")
        icon_result=":calculator:"
        ;;
   "Karabiner-EventViewer")
        icon_result=":karabiner_elements_event_viewer:"
        ;;
   "Todoist")
        icon_result=":todoist:"
        ;;
   "Passwords" | "Passwörter")
        icon_result=":passwords:"
        ;;
   "JetBrains Toolbox")
        icon_result=":jetbrains_toolbox:"
        ;;
   "Toggl Track")
        icon_result=":toggl_track:"
        ;;
   "DataGrip")
        icon_result=":datagrip:"
        ;;
   "Image Playground")
        icon_result=":image_playground:"
        ;;
   "Numbers" | "Numbers 表格")
        icon_result=":numbers:"
        ;;
   "Ghostty")
        icon_result=":ghostty:"
        ;;
   "Atom")
        icon_result=":atom:"
        ;;
   "Cypress")
        icon_result=":cypress:"
        ;;
   "TV")
        icon_result=":tv:"
        ;;
   "OrcaSlicer")
        icon_result=":orcaslicer:"
        ;;
   "Kakoune")
        icon_result=":kakoune:"
        ;;
   "Notion Mail")
        icon_result=":notion_mail:"
        ;;
   "GoLand")
        icon_result=":goland:"
        ;;
   "Adobe Photoshop"*)
        icon_result=":photoshop:"
        ;;
   "Bambu Studio")
        icon_result=":bambu_studio:"
        ;;
   "Obsidian")
        icon_result=":obsidian:"
        ;;
   "PomoDone App")
        icon_result=":pomodone:"
        ;;
   "Capacities")
        icon_result=":capacities:"
        ;;
   "Tana")
        icon_result=":tana:"
        ;;
   "MoneyMoney")
        icon_result=":bank:"
        ;;
   "Setapp")
        icon_result=":setapp:"
        ;;
   "LINE")
        icon_result=":line:"
        ;;
   "Navicat Premium")
        icon_result=":navicat:"
        ;;
   "Mullvad Browser")
        icon_result=":mullvad_browser:"
        ;;
   "Default")
        icon_result=":default:"
        ;;
   "Journal")
        icon_result=":journal:"
        ;;
   "Moonlight")
        icon_result=":moonlight:"
        ;;
   "Microsoft PowerPoint")
        icon_result=":microsoft_power_point:"
        ;;
   "Timery")
        icon_result=":timery:"
        ;;
   "Nicotine+")
        icon_result=":nicotine_plus:"
        ;;
   "Mattermost")
        icon_result=":mattermost:"
        ;;
   "Bear")
        icon_result=":bear:"
        ;;
   "Vivaldi")
        icon_result=":vivaldi:"
        ;;
   "Microsoft To Do" | "Things")
        icon_result=":things:"
        ;;
   "Warp")
        icon_result=":warp:"
        ;;
   "BusyCal")
        icon_result=":busycal:"
        ;;
   "Parsec")
        icon_result=":parsec:"
        ;;
   "Grayjay")
        icon_result=":grayjay:"
        ;;
   "Dexcom")
        icon_result=":dexcom:"
        ;;
   "Reminders" | "提醒事项" | "Rappels" | "リマインダー" | "Erinnerungen")
        icon_result=":reminders:"
        ;;
   "Session")
        icon_result=":session:"
        ;;
   "solidtime")
        icon_result=":solidtime:"
        ;;
   "Element")
        icon_result=":element:"
        ;;
   "Tips")
        icon_result=":tips:"
        ;;
   "PDF Expert")
        icon_result=":pdf_expert:"
        ;;
   "Sublime Merge")
        icon_result=":sublime_merge:"
        ;;
   "Chromium" | "Google Chrome" | "Google Chrome Canary")
        icon_result=":google_chrome:"
        ;;
   "Kiro")
        icon_result=":kiro:"
        ;;
   "Zotero")
        icon_result=":zotero:"
        ;;
   "Matlab" | "MATLAB" |"MATLABWindow" | "MATLAB_R2024b" | "MATLAB_R2024a" | "MATLAB_R2023b" | "MATLAB_R2023a" | "MATLAB_R2022b" | "MATLAB_R2022a" | "MATLAB_R2021b" | "MATLAB_R2021a")
        icon_result=":matlab:"
        ;;
   "Bitwarden")
        icon_result=":bit_warden:"
        ;;
   "Studio 3T")
        icon_result=":studio_3t:"
        ;;
   "DeepSeek")
        icon_result=":deepseek:"
        ;;
   "Helium")
        icon_result=":helium:"
        ;;
   "Affinity Publisher 2")
        icon_result=":affinity_publisher_2:"
        ;;
   "VLC")
        icon_result=":vlc:"
        ;;
   "VeraCrypt")
        icon_result=":veracrypt:"
        ;;
   "Parcel")
        icon_result=":parcel:"
        ;;
   "draw.io")
        icon_result=":draw_io:"
        ;;
   "Code" | "Code - Insiders")
        icon_result=":code:"
        ;;
   "Reeder")
        icon_result=":reeder5:"
        ;;
   "Spotlight")
        icon_result=":spotlight:"
        ;;
   "WireGuard")
        icon_result=":wireguard:"
        ;;
   "Rider" | "JetBrains Rider")
        icon_result=":rider:"
        ;;
   "Brain.fm")
        icon_result=":brainfm:"
        ;;
   "Yuque" | "语雀")
        icon_result=":yuque:"
        ;;
   "AFFiNE")
        icon_result=":affine:"
        ;;
   "DingTalk" | "钉钉" | "阿里钉")
        icon_result=":dingtalk:"
        ;;
   "LibreOffice")
        icon_result=":libreoffice:"
        ;;
   "Twingate")
        icon_result=":twingate:"
        ;;
   "OpenAI Translator")
        icon_result=":openai_translator:"
        ;;
   "Mimestream")
        icon_result=":mimestream:"
        ;;
   "Fusion")
        icon_result=":fusion:"
        ;;
   "Folx")
        icon_result=":folx:"
        ;;
   "Tower")
        icon_result=":tower:"
        ;;
   "rekordbox")
        icon_result=":rekordbox:"
        ;;
   "Inkscape")
        icon_result=":inkscape:"
        ;;
   "RustDesk")
        icon_result=":rustdesk:"
        ;;
   "GitHub Desktop")
        icon_result=":git_hub:"
        ;;
   "Notion")
        icon_result=":notion:"
        ;;
   "Apifox")
        icon_result=":apifox:"
        ;;
   "Evernote Legacy")
        icon_result=":evernote_legacy:"
        ;;
   "Microsoft Teams" | "Microsoft Teams (work or school)")
        icon_result=":microsoft_teams:"
        ;;
   "Pages" | "Pages 文稿")
        icon_result=":pages:"
        ;;
   "Shortcuts")
        icon_result=":shortcuts:"
        ;;
   "Affinity Photo 2")
        icon_result=":affinity_photo_2:"
        ;;
   "TickTick")
        icon_result=":tick_tick:"
        ;;
   "Affinity Designer 2")
        icon_result=":affinity_designer_2:"
        ;;
   "IntelliJ IDEA")
        icon_result=":idea:"
        ;;
   "Overcast")
        icon_result=":overcast:"
        ;;
   "DaVinci Resolve")
        icon_result=":davinciresolve:"
        ;;
   "Miro")
        icon_result=":miro:"
        ;;
   "Bilibili" | "哔哩哔哩")
        icon_result=":bilibili:"
        ;;
   "Tot")
        icon_result=":tot:"
        ;;
   "News")
        icon_result=":news:"
        ;;
   "Microsoft Remote Desktop")
        icon_result=":microsoft_remote_desktop:"
        ;;
   "kitty")
        icon_result=":kitty:"
        ;;
   "Cursor"*)
        icon_result=":cursor_ide:"
        ;;
   "Termius")
        icon_result=":termius:"
        ;;
   "Eagle")
        icon_result=":eagle:"
        ;;
   "Amazon Chime")
        icon_result=":chime:"
        ;;
   "System Preferences" | "System Settings" | "系统设置" | "Réglages Système" | "システム設定" | "Systemeinstellungen" | "System­einstellungen")
        icon_result=":gear:"
        ;;
   "Jane Reader")
        icon_result=":jane_reader:"
        ;;
   "Adobe Lightroom")
        icon_result=":lightroom:"
        ;;
   "Acrobat")
        icon_result=":acrobat:"
        ;;
   "Trello")
        icon_result=":trello:"
        ;;
   "BluOS Controller")
        icon_result=":bluos_controller:"
        ;;
   "deno")
        icon_result=":deno:"
        ;;
   "IINA")
        icon_result=":iina:"
        ;;
   "Postman")
        icon_result=":postman:"
        ;;
   "Home Assistant")
        icon_result=":home_assistant:"
        ;;
   "Photos" | "Fotos")
        icon_result=":photos:"
        ;;
   "Tiny RDM")
        icon_result=":tinyrdm:"
        ;;
   "QQ")
        icon_result=":qq:"
        ;;
   "Linear")
        icon_result=":linear:"
        ;;
   "Weather" | "Wetter")
        icon_result=":weather:"
        ;;
   "Opera")
        icon_result=":opera:"
        ;;
   "Podcasts" | "播客")
        icon_result=":podcasts:"
        ;;
   "Replit")
        icon_result=":replit:"
        ;;
   "FL Studio")
        icon_result=":flstudio:"
        ;;
   "Claude")
        icon_result=":claude:"
        ;;
   "Hammerspoon")
        icon_result=":hammerspoon:"
        ;;
   "Anki")
        icon_result=":anki:"
        ;;
   "Preview" | "预览" | "Skim" | "zathura" | "Aperçu" | "プレビュー" | "Vorschau")
        icon_result=":preview:"
        ;;
   "Repo Prompt")
        icon_result=":repo_prompt:"
        ;;
   "Phoenix Slides")
        icon_result=":phoenix_slides:"
        ;;
   "Rio")
        icon_result=":rio:"
        ;;
   "GoodLinks")
        icon_result=":goodlinks:"
        ;;
   "Calendar" | "日历" | "Fantastical" | "Cron" | "Amie" | "Calendrier" | "カレンダー" | "Notion Calendar" | "Kalender")
        icon_result=":calendar:"
        ;;
   "FreeTube")
        icon_result=":freetube:"
        ;;
   "Sequel Ace")
        icon_result=":sequel_ace:"
        ;;
   "Marta")
        icon_result=":marta:"
        ;;
   "Summoners War")
        icon_result=":summoners_war:"
        ;;
   "Min")
        icon_result=":min_browser:"
        ;;
   "Swift Playground")
        icon_result=":swift_playground:"
        ;;
   "Copilot")
        icon_result=":copilot:"
        ;;
   "Android Studio")
        icon_result=":android_studio:"
        ;;
   "Burp Suite"*)
        icon_result=":burp_suite:"
        ;;
   "QLMarkdown")
        icon_result=":qlmarkdown:"
        ;;
   "Perplexity" | "Perplexity AI")
        icon_result=":perplexity:"
        ;;
   "Messenger")
        icon_result=":messenger:"
        ;;
   "Choosy")
        icon_result=":choosy:"
        ;;
   "Zeplin")
        icon_result=":zeplin:"
        ;;
   "Granola")
        icon_result=":granola:"
        ;;
   "Lightroom Classic")
        icon_result=":lightroomclassic:"
        ;;
   "Cisco AnyConnect Secure Mobility Client" | "Cisco Secure Client")
        icon_result=":cisco_anyconnect:"
        ;;
   "Neovide" | "neovide")
        icon_result=":neovide:"
        ;;
   "AmneziaVPN")
        icon_result=":amnezia_vpn:"
        ;;
   "Slack")
        icon_result=":slack:"
        ;;
   "Marked 2")
        icon_result=":marked_2:"
        ;;
   "Transmit")
        icon_result=":transmit:"
        ;;
   "YouTube")
        icon_result=":youtube:"
        ;;
   "ClickUp")
        icon_result=":click_up:"
        ;;
   "Discord" | "Discord Canary" | "Discord PTB")
        icon_result=":discord:"
        ;;
   "Fork")
        icon_result=":fork:"
        ;;
   "Live")
        icon_result=":ableton:"
        ;;
   "Raspberry Pi Imager" | "Raspberry Pi Connect")
        icon_result=":raspberry_pi:"
        ;;
   "ForkLift")
        icon_result=":forklift:"
        ;;
   "Nextcloud")
        icon_result=":nextcloud:"
        ;;
   "qBittorrent")
        icon_result=":qbittorrent:"
        ;;
   "VSCodium")
        icon_result=":vscodium:"
        ;;
   "Docker" | "Docker Desktop")
        icon_result=":docker:"
        ;;
   "YouTube Music")
        icon_result=":youtube_music:"
        ;;
   "Firefox")
        icon_result=":firefox:"
        ;;
   "Goodnotes")
        icon_result=":goodnotes:"
        ;;
   "Google Meet")
        icon_result=":meet:"
        ;;
   "Yandex Music")
        icon_result=":yandex_music:"
        ;;
   "LanguageTool for Desktop")
        icon_result=":languagetool_for_desktop:"
        ;;
   "Netflix")
        icon_result=":netflix:"
        ;;
   "Play")
        icon_result=":play:"
        ;;
   "Music" | "音乐" | "Musique" | "ミュージック" | "Musik" | "Chromatix")
        icon_result=":music:"
        ;;
   "Terminal" | "终端" | "ターミナル")
        icon_result=":terminal:"
        ;;
   "SnippetsLab")
        icon_result=":snippetslab:"
        ;;
   "Arduino" | "Arduino IDE")
        icon_result=":arduino:"
        ;;
   "DataSpell")
        icon_result=":dataspell:"
        ;;
   "Color Picker" | "数码测色计")
        icon_result=":color_picker:"
        ;;
   "OpenVPN Connect")
        icon_result=":openvpn_connect:"
        ;;
   "Hyper")
        icon_result=":hyper:"
        ;;
   "网易云音乐" | "NetEaseMusic")
        icon_result=":netease_music:"
        ;;
   "Open Video Downloader")
        icon_result=":open_video_downloader:"
        ;;
   "Dia")
        icon_result=":dia:"
        ;;
   "Royal TSX")
        icon_result=":royaltsx:"
        ;;
   "Microsoft Word")
        icon_result=":microsoft_word:"
        ;;
   "Hazel")
        icon_result=":hazel:"
        ;;
   "Bazecor")
        icon_result=":bazecor:"
        ;;
   "Actual")
        icon_result=":actual:"
        ;;
   "Maps" | "Google Maps" | "マップ" | "Karten")
        icon_result=":maps:"
        ;;
   "GrandTotal" | "Receipts")
        icon_result=":dollar:"
        ;;
   "Vorta")
        icon_result=":vorta:"
        ;;
   "Signal")
        icon_result=":signal:"
        ;;
   "balenaEtcher")
        icon_result=":balena_etcher:"
        ;;
   "Logic Pro")
        icon_result=":logicpro:"
        ;;
   "coconutBattery")
        icon_result=":coconut_battery:"
        ;;
   "BetterTouchTool")
        icon_result=":bettertouchtool:"
        ;;
   "Kodi")
        icon_result=":kodi:"
        ;;
   "Cold Turkey Blocker")
        icon_result=":cold_turkey_blocker:"
        ;;
   "Grammarly Editor")
        icon_result=":grammarly:"
        ;;
   "Downie 4")
        icon_result=":downie:"
        ;;
   "Microsoft Excel")
        icon_result=":microsoft_excel:"
        ;;
   "KeePassXC")
        icon_result=":kee_pass_x_c:"
        ;;
   "Voice Memos")
        icon_result=":voice_memos:"
        ;;
   "PhpStorm")
        icon_result=":php_storm:"
        ;;
   "Premiere" | "Adobe Premiere" | "Adobe Premiere Pro 2024")
        icon_result=":premiere:"
        ;;
   "Adobe Bridge"*)
        icon_result=":adobe_bridge:"
        ;;
   "Typora")
        icon_result=":text:"
        ;;
   "Automator")
        icon_result=":automator:"
        ;;
    *)
        icon_result=":default:"
        ;;
    esac
}
### END-OF-ICON-MAP
