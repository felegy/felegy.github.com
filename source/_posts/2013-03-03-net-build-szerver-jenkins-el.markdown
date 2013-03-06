---

layout: post
title: "Első poszt: .NET build szerver Jenkins-el"
date: 2013-03-03 13:03
comments: true
categories: 
- dotnet
- jenkins

---

Első lépések
------------

1. Először is kell egy Windows 7 alap rendszer, érdemes 64 biteset használni (én elsőre XP-re gondoltam, mert nLight-al lebutítva virtuális gépnek kiváló, csak nincs már hozzá `.NET 4.5` támogtás)
2. Telepíteni kell a [Web Platform insaller](http://go.microsoft.com/fwlink/?LinkID=145505)-t és ezzel a `.NET 4.5`-t
3. Telepíteni kell a `Jenkins`-t (én az aktuális stabil verziót használom [Jenkins windows stable latest](http://mirrors.jenkins-ci.org/windows-stable/latest)) a `C:\CI\Jenkins` mappába, lehet más meghajtóra is tenni, a lényeg, hogy ne legyen space és semmi speciális karakter az útvonalban, ezért nem jó a `Program Files` mappa.
4. Meg kell szerkeszteni a `Jenkins.xml` -t pl. `--httpPort=6080` így a 6080-as portot fogja használni  
5. Fel kell venni egy local user-t, pl. `builder` és jelszót is be kell állítani neki és adjunk full jogot a `C:\CI\Jenkins` mappára.
6. Be kell állítani a service-ek között a `Jenkins`-t, hogy a fentebb létrehozott felhasználó nevében fusson
7. Indítsuk újra a service-t
``` xml Jenkins config
	<service>
  <id>jenkins</id>
  <name>Jenkins</name>
  <description>This service runs Jenkins continuous integration system.</description>
  <env name="JENKINS_HOME" value="%BASE%"/>
  <!--
    if you'd like to run Jenkins with a specific version of Java, specify a full path to java.exe.
    The following value assumes that you have java in your PATH.
  -->
  <executable>%BASE%\jre\bin\java</executable>
  <arguments>-Xrs -Xmx256m -Dhudson.lifecycle=hudson.lifecycle.WindowsServiceLifecycle -jar "%BASE%\jenkins.war" --httpPort=6080</arguments>
  <!--
    interactive flag causes the empty black Java window to be displayed.
    I'm still debugging this.
  <interactive />
  -->
  <logmode>rotate</logmode>
</service>
```
<!--more-->

Git beállítása
--------------

A build gép működéséhez kell repositoty kapcsolat is, ami a `Jenkins` esetében sokféle lehet, én `git`-et használok és szerintem ma már ez az egyik legáltalánosabb, de lehet akár `SVN` is.

1. Installálni kell a [Git Extensions](http://code.google.com/p/gitextensions/downloads/list)-t a `C:\CI\git` mappába 
	- a `MSysGit`-et az alapértelmezett mappába kell telepíteni `C:\Program Files (x86)\git`)
	- Open SSh-t érdemes választani `PuTTY` helyett
2. Telepíteni kell a `Jenkins GIT plugin`-t a `/pluginManager/available` listában be kell pipálni és indítani kell a `Download now and install after restart` gombbal.
3. SSh kulcsot kell generálni a build gépnek
	- be kell lépni a `build` felhasználóval
	- indítsuk el a `Git GUI` programot és a `Help/Show SSH Key` menüpont `Generate Key` gombjára kattintsunk
	- én nem adok meg passphrase-t mert egyszerűbb lesz automatizálni a kulcs használatát és a build gépnek a forrásra csak olvasási jogot szoktam adni
	- a `~/.ssh` mappába generál két file-t `id_rsa` és `id_rsa.pub` értelem szerűen a második a publikus kulcsunk
	- a publikus kulcs file tartalmát kell a repsitory szerveren megadni a build felhasználóhoz

Első build job
--------------

### Win SDK és NuGet

1. Fel kell telepíteni a gépre a [Windows 8 SDK](http://msdn.microsoft.com/en-us/windows/desktop/hh852363.aspx) -t
2. Ha a `NuGet` csomagokat nem tároljuk a repository-ban akkor a `build` felhasználóval be kell lépni a gépre és a `C:\Users\{user}\AppData\Roaming\NuGet` mappába be kell másolni a saját nuget konfigurációnkat  

{% include_code lang:xml NuGet.config %}

### MSBuld beállítása

Nem akarom az msbuild script készítés rejtelmeit hosszan ecsetelni, majd egy másik poszt (vagy posztok) alkalmával. Csak a build szerver szempontjából írom le a telepítést. [Fun](http://devopsreactions.tumblr.com/post/44210497845/visiting-the-guy-that-wrote-the-build-scripts)

1. `C:\Program Files (x86)\MSBuild` mappába be kell másolni a szükséges dolgokat, én a fejlesztői gépem teljes `MSBuild` mappájával felülmásoltam a build gépét
2. Visual Studio -ban a projektünkben installálni kell [MSBuildTasks](http://nuget.org/packages/MSBuildTasks/) `NuGet` csomagot
3. A solution mappánkban keletkezik egy `build.proj` file
4. A lentebb mellékelt `build.cmd` -t tegyük a repository-ba (a script feltételezi, hogy a forrás az `src` mappában van)

{% include_code lang:bat build.cmd %}

### Jenkins job felvétele

1. `New Job/Build a free-style software project` és adjuk meg a job nevét
2. `Source Code Management`, válaszunk `git`-et és a `Repository URL` mezőbe adjuk meg a repository-nkat (ssh url-t érdemes választan, de ehez rá kell látni a repository szerver 22-es portjára, ha ez nem lehetséges akkor a `https` url-t kell a következőképpen `https://{user}:{password}@{git server}/{repository}.git` )
3. `Branch Specifier` mezőbe a build branch-et kell megadni (én mindíg saját branch-ben dolgozom és csak a `master`-t fordíttatom a build géppel), ha üresen hagyjuk akkor az összes branch-et figyeli
4. `Build Triggers` részen a `Poll SCM` -et pipáljuk be és a `Schedule` mezőbe írjunk mondjuk: `*/1 * * * *` ez minden percben megnézi, hogy van-e változás a repository-ban

Ha most elindítjuk a job-ot akkor ki fogja szedni a repository-ból az aktuális forrást. A `/job/{job name}/{build number}/console` linken nézhetjük, hogy mi történik.

### Jenkins MSBuild

1. Telepíteni kell az `Jenkins MSBuild Plugin` -t és megint újra kell indítani a Jenkins-t
2. Be kell konfigurálni a `.net 4`-et	`/configure` `MSBuild` `MSBuild installations...` -re kell kattintani, majd `Add MSBuild`
	- `Name` mezőben mondjuk `.net 4`
	- `Path to MSBuild` -be: `C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe`
	- `Save` vagy `Apply`
3. Be kell állítan egy build step-et	
	- Job-unk konfigurációs oldalán `Add build step` és válasszuk `Build a Visual Studio project or solution using MSBuild`
	- `MSBuild Version` -nél az előbbi `.net 4`-et válasszuk
	- `MSBuild Build File` mezőbe pl. `src/Build.proj`
	- `Command Line Arguments` mezőben adjuk meg a szükséges paramétereket, itt kiindulhatunk a `build.cmd` paramétereiből, de elég csak a `/tv:4.0` paramétert megadni, ez a 4.0 target version (4.5 esetén is ezt kell megadni)

### Utolsó lépés

Már csak futtatni kell a job-ot és készen vagyunk, de a poén kedvéért telepítsük a `ChuckNorris Plugin`-t és tegyünk be a job-ba egy `post build action`-t `Add post-build action` és `Activate Chuck Norris`.

Indítsuk el a job-ot vagy `push`-oljunk a repository-ba. 
