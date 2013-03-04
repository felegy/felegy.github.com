---

layout: post
title: "ElasticSearch Windows Service Windows Server x64"
date: 2013-03-04 06:30
comments: true
categories: ElasticSearch Windows Java

---

A github-on van hozzá egy service wrapper
[link](https://github.com/elasticsearch/elasticsearch-servicewrapper), de a winX64 változat valahogy hiányzik, nekem az x86 sem ment, de az ES szerintem nagyon jó cucc és nyilván ha már van akkor fusson 64 biten. Tehát megidéztem régi tanítómesterem szellemét meg azt a kb. 12 éves tudásmorzsát, hogy csináltam én már ilyet … :-)
A legfrissebb verziót raktam össze `0.20.3`.

Hozzávalók:
-----------

* JDK 7 x64 [link](http://www.oracle.com/technetwork/java/javase/downloads/java-se-jdk-7-download-432154.html)
* Apache Commons [link](http://xenia.sote.hu/ftp/mirrors/www.apache.org//commons/daemon/binaries/windows/commons-daemon-1.0.12-bin-windows.zip) 
* JAVA_HOME rendszer környezeti változó `C:\Progra~1\Java\jdk1.7.0_11`

Telepítés:
----------

1. A letöltött `ES 0.20.3` -at kicsomagoljuk a `D:\\elasricsearch` alá (azért a oda mert a `C:\` alatt a `Program Files` -ba tenném, de ott minden féle jogosultsági bukfenc miatt nem megy)
2. `D:\\elasricsearch\bin\elasricsearch.bat` elindításával le kell ellenőrizni, hogy megy-e. (ha nem akkor csak a JAVA_HOME-al lehet a bibi, pontosan úgy kell beállítani ahogyan írtam)
3. `D:\\elasricsearch\service` alá kicsomagolni a `commons-daemon-1.0.12-bin-windows.zip` csomagot és az `amd64/prunsrv.exe` -vel felülírni a kintebbit (mert alapból az x86 van kint).
4. Át kell nevezni a file-okat, hogy a feladat kezelőben a host-olt nevet lássuk 		`prunsvr.exe => ElasticSearch.exe` `prunmgr.exe => ElasticSearchw.exe` (ezt a nyolcvan hat nemműködő leírás egyikében láttam, de jó ötlet)
5. Kell csinálni egy `create-service.cmd` -t és a lenti kódot bele kell pakolni, majd futtatni kell a scriptet. 

{% include_code lang:bat elasticsearch.cmd %}
		
<!--more-->

Beállítás
---------

El kell indítani a `ElasticSearchw.exe` -t és végig kell menni a beállításokon.

**1. Generál panel** ([kép](http://captaincodeman.files.wordpress.com/2012/04/1-general.png) csak a látvány kedvéért, a beállítások rosszak a képeken)  


Beállítás		| Érték		
------------ 	| -------------
Display name 	| Elastic Search
Strtup type  	| Automatic  

**2. Log On** ([kép](http://captaincodeman.files.wordpress.com/2012/04/2-logon.png))

Beállítás				| Érték		
------------ 			| -------------
Log on as	 			| This account
Account		  		| NT AUTHORITY \ NETWORK SERVICE
Password	  			| `üres`
Confirm Password	  	| `üres`  

**3. Logging** ([kép](http://captaincodeman.files.wordpress.com/2012/04/3-logging.png))

Beállítás		| Érték			
------------ 	| ------------- 	
Level		 	| Info (amíg először indítjuk lehet `debug` is )
Log Path	  	| `D:\elasticsearch\logs`
Pid File	  	| `üres`
Redirect Stdout	| `auto`
Redirect Stderror | `auto`  

**4. Java** ([kép](http://captaincodeman.files.wordpress.com/2012/04/4-java.png))

Java Virtual Machine: `C:\Program Files\Java\jre7\bin\server\jvm.dll`  
Java Classpath: `;D:\elasticsearch/lib/elasticsearch-0.20.3.jar;D:\elasticsearch/lib/*;D:\elasticsearch/lib/sigar/*`  
Java Options:  

	-Xms256m	-Xmx1g	-XX:+UseCompressedOops	-Xss128k	-XX:+UseParNewGC	-XX:+UseConcMarkSweepGC	-XX:+CMSParallelRemarkEnabled	-XX:SurvivorRatio=8	-XX:MaxTenuringThreshold=1	-XX:CMSInitiatingOccupancyFraction=75	-XX:+UseCMSInitiatingOccupancyOnly	-XX:+HeapDumpOnOutOfMemoryError	-Djline.enabled=false	-Delasticsearch	-Des-foreground=yes	-Des.path.home=D:elasticsearch
Initial memory pool: 25  
Maximum memory pool: 1024  
Thread stack size: `üres`

**5. Startup** ([kép](http://captaincodeman.files.wordpress.com/2012/04/5-startup.png))

  
Beállítás		| Érték			
------------ 	| -------------------------------------------
Class		 	| `org.elasticsearch.bootstrap.ElasticSearch`
Image		  	| `üres`
Working Path	| `üres`
Method		  	| `üres`
Arguments		| `üres`
Timeout		| `üres`
Mode		  	| `jvm`   

**6. Shutdown** ([kép](http://captaincodeman.files.wordpress.com/2012/04/6-shutdown.png))

Beállítás		| Érték		
------------ 	| ------------- 
Class		 	| `org.elasticsearch.bootstrap.ElasticSearch`
Image		  	| `üres`
Working Path	| `üres`
Method		  	| `üres`
Arguments		| `üres`
Timeout		  	| 0		 
Mode		  		| `jvm`   


**Log:** (ha minden ok ilyet kell látnunk, ha a service-t elindítjuk):

{% include_code lang:text es.log %}