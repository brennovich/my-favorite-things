#include <X11/XF86keysym.h>

/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 4;  /* border pixel of windows */
static const unsigned int snap      = 16; /* snap pixel */
static const int showbar            = 1;  /* 0 means no bar */
static const int topbar             = 1;  /* 0 means bottom bar */
static const unsigned int gappx     = 6;  /* gap pixel between windows */
static const char *fonts[]          = { "scientifica:size=9" };
static const char dmenufont[]       = "scientifica:size=9";
static const char col_gray1[]       = "#464646";
static const char col_gray2[]       = "#686868";
static const char col_gray3[]       = "#8e8e8e";
static const char col_gray4[]       = "#eeeeee";
static const char col_gray5[]       = "#fefefe";
static const char col_cyan[]        = "#252525";
static const char col_dark[]        = "#000000";
static const char *colors[][3]      = {
	/*               fg         bg        border   */
	[SchemeNorm] = { col_cyan, col_gray5, col_gray5 },
	[SchemeSel]  = { col_dark, col_gray4, col_gray4 },
};

/* tagging */
static const char *tags[] = { "code", "web", "media", "misc" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       1 << 2,       1,           -1 },
	{ "Firefox",  NULL,       NULL,       1 << 1,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = { /* first entry is default */
	/* symbol     arrange function */
	{ "[]=",      tile },
	{ "< >",      NULL },    /* no layout function means floating behavior */
	{ "[ ]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }
#define DISPLAYCMD(primary, disabled) { .v = (const char*[]) { "xrandr", "--output", primary, "--auto", "--primary", "--output", disabled, "--off", NULL } }
#define VOLUMECMD(action) { .v = (const char*[]) { "pulsemixer", "--change-colume", action, NULL} }
#define MPDCMD(action) { .v = (const char*[]) { "mpc", action, NULL} }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, NULL };
static const char *termcmd[]  = { "termite", NULL };
static const char *brightnessupcmd[]  = { "light", "-A", "10", NULL };
static const char *brightnessdowncmd[]  = { "light", "-U", "10", NULL };

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ 0,               XF86XK_MonBrightnessUp, spawn,          {.v = brightnessupcmd } },
	{ 0,             XF86XK_MonBrightnessDown, spawn,          {.v = brightnessdowncmd } },
	{ 0,                   XF86XK_ScreenSaver, spawn,          SHCMD("xautolock -locknow") },
	{ 0,                     XF86XK_AudioPlay, spawn,          MPDCMD("toggle") },
	{ 0,                     XF86XK_AudioPrev, spawn,          MPDCMD("prev") },
	{ 0,                     XF86XK_AudioNext, spawn,          MPDCMD("next") },
	{ 0,                     XF86XK_AudioStop, spawn,          MPDCMD("stop") },
	{ 0,              XF86XK_AudioRaiseVolume, spawn,          VOLUMECMD("+5") },
	{ 0,              XF86XK_AudioLowerVolume, spawn,          VOLUMECMD("-5") },
	{ 0,                       XF86XK_Display, spawn,          DISPLAYCMD("LVDS1", "VGA1") },
	{ MODKEY,                  XF86XK_Display, spawn,          DISPLAYCMD("VGA1", "LVDS1") },

	{ 0,                            XK_Print,  spawn,          SHCMD("maim ~/$(date +%Y-%m-%d-%H:%M:%S).png") },
	{ ShiftMask,                    XK_Print,  spawn,          SHCMD("maim -s ~/$(date +%Y-%m-%d-%H:%M:%S).png") },
	{ ControlMask,                  XK_Print,  spawn,          SHCMD("maim | xclip -selection clipboard -t image/png") },
	{ ControlMask|ShiftMask,        XK_Print,  spawn,          SHCMD("maim -s | xclip -selection clipboard -t image/png") },
	{ MODKEY,                       XK_d,      spawn,          {.v = dmenucmd } },
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_o,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY|ShiftMask,             XK_Return, zoom,           {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	{ MODKEY|ControlMask|Mod1Mask,  XK_q,      quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

