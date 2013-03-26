---

layout: post
title: "Native F1 live timing Mac-en"
date: 2013-03-24 09:29
comments: true
categories: 
- mac 

---

Régóta használom linuxon a live-f1 csomagot a hivatalos [formula1.com](http://formula1.com) livetiming klienseként. Sokkal jobb és gyorsabb mint böngészőből a java-s változat a hivatalos oldalon keresztül. Ezzel együtt régi vágyam, hogy mac-en is mennyen mert eddig mindíg a linux-os szerveremre ssh-ztam be és úgy használtam, de ez így nem túl kényelmes. Most így az új szezon elején nekiveselkedtem és összehoztam, forrásból lefordítottam mac-en és megy :).

<!--more-->

##Lépések:

1. Fel kell telepíteni a [brew](http://mxcl.github.com/homebrew/) csomagkezelőt
2. `brew install pkg-config` és `brew install pkg-config`
3. Le kell tölteni a [live-f1](https://launchpad.net/live-f1/+download) csomag forrását és ki kell csomagolni
4. `cd live-f1_0.2.11` álljunk bele a kitömörített forrás könyvtárába (persze a path-ban a verziószám változhat)
5. Kedvenc text editor-unkkal meg kell szerkeszteni a `configure` file-t és be kell szúrni az elejére a lenti két sort, természetesen itt is változhat a verzió szám

{% codeblock configure lang:bash %}
NEON_CFLAGS="-I /usr/local/Cellar/neon/0.29.6/include/neon"
NEON_LIBS="-L /usr/local/Cellar/neon/0.29.6/lib -lneon"
{% endcodeblock %}

Ezek után már csak le kell fordítanunk:

	make && make install
	
Ha sikerült akkor `live-f1` és meg kell adni a [formula1.com](http://formula1.com) -on regisztrált felhasználónk e-mail címét és jelszavát, ha elrontjuk akkor `~/.f1rc` könyvtárat le kell törölni és akkor újra megadhatjuk indításnál. Ha a `live-f1: insufficient lines on display` hibát kapjuk akkor a terminál betűméretét kell állítani a `cmd +` és `cmd -` kombinációkkal.