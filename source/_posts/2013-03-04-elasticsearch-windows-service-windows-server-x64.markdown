---

layout: post
title: "ElasticSearch Windows Service Windows Server x64"
date: 2013-03-04 05:45
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
		

Beállítás
---------

El kell indítani a `ElasticSearchw.exe` -t és végig kell menni a beállításokon.

**1. Generál panel** ([kép](http://captaincodeman.files.wordpress.com/2012/04/1-general.png) csak a látvány kedvéért, a beállítások rosszak a képeken)  


| Beállítás		| Érték			 	|
| ------------ 	| ------------- 		|
| Display name 	| Elastic Search		|
| Strtup type  	| Automatic			|

**2. Log On** ([kép](http://captaincodeman.files.wordpress.com/2012/04/2-logon.png))

| Beállítás				| Érték			|
| ------------ 			| ------------- 	|
| Log on as	 			| This account	|
| Account		  			| NT AUTHORITY \ NETWORK SERVICE |
| Password	  			| `üres` |
| Confirm Password	  	| `üres` |

**3. Logging** ([kép](http://captaincodeman.files.wordpress.com/2012/04/3-logging.png))

| Beállítás		| Érték			 	|
| ------------ 	| ------------- 		|
| Level		 	| Info (amíg először indítjuk lehet `debug` is )|
| Log Path	  	| `D:\elasticsearch\logs`|
| Pid File	  	| `üres` 				|
| Redirect Stdout	| `auto` 			|
| Redirect Stderror | `auto` 			|

**4. Java** ([kép](http://captaincodeman.files.wordpress.com/2012/04/4-java.png))

Java Virtual Machine: `C:\Program Files\Java\jre7\bin\server\jvm.dll`  
Java Classpath: `;D:\elasticsearch/lib/elasticsearch-0.20.3.jar;D:\elasticsearch/lib/*;D:\elasticsearch/lib/sigar/*`  
Java Options:  

	-Xms256m	-Xmx1g	-XX:+UseCompressedOops	-Xss128k	-XX:+UseParNewGC	-XX:+UseConcMarkSweepGC	-XX:+CMSParallelRemarkEnabled	-XX:SurvivorRatio=8	-XX:MaxTenuringThreshold=1	-XX:CMSInitiatingOccupancyFraction=75	-XX:+UseCMSInitiatingOccupancyOnly	-XX:+HeapDumpOnOutOfMemoryError	-Djline.enabled=false	-Delasticsearch	-Des-foreground=yes	-Des.path.home=D:elasticsearch
Initial memory pool: 25  
Maximum memory pool: 1024  
Thread stack size: `üres`

**5. Startup** ([kép](http://captaincodeman.files.wordpress.com/2012/04/5-startup.png))
| Beállítás		| Érték			 	|
| ------------ 	| ------------- 		|
| Class		 	| `org.elasticsearch.bootstrap.ElasticSearch` |
| Image		  	| `üres`|
| Working Path	| `üres`|
| Method		  	| `üres`|
| Arguments		| `üres`|
| Timeout		  	| `üres`|
| Mode		  		| `jvm` |

**5. Shutdown** ([kép](http://captaincodeman.files.wordpress.com/2012/04/6-shutdown.png))

| Beállítás		| Érték			 	|
| ------------ 	| ------------- 		|
| Class		 	| `org.elasticsearch.bootstrap.ElasticSearch` |
| Image		  	| `üres`|
| Working Path	| `üres`|
| Method		  	| `üres`|
| Arguments		| `üres`|
| Timeout		  	| 0		 |
| Mode		  		| `jvm` |


**Log:** (ha minden ok ilyet kell látnunk, ha a service-t elindítjuk):

	[2013-01-29 00:50:29] [debug] ( prunsrv.c:1672) [ 3756] Commons Daemon procrun log initialized	[2013-01-29 00:50:29] [info]  ( prunsrv.c:1676) [ 3756] Commons Daemon procrun (1.0.12.0 64-bit) started	[2013-01-29 00:50:29] [info]  ( prunsrv.c:1589) [ 3756] Running 'ElasticSearch' Service...	[2013-01-29 00:50:29] [debug] ( prunsrv.c:1370) [ 3612] Inside ServiceMain...	[2013-01-29 00:50:29] [debug] ( prunsrv.c:843 ) [ 3612] reportServiceStatusE: 2, 0, 3000, 0	[2013-01-29 00:50:29] [info]  ( prunsrv.c:1125) [ 3612] Starting service...	[2013-01-29 00:50:29] [debug] ( javajni.c:220 ) [ 3612] loading jvm 'C:\Program Files\Java\jre7\bin\server\jvm.dll'	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[0] -Xms256m	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[1] -Xmx1g	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[2] -XX:+UseCompressedOops	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[3] -Xss128k	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[4] -XX:+UseParNewGC	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[5] -XX:+UseConcMarkSweepGC	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[6] -XX:+CMSParallelRemarkEnabled	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[7] -XX:SurvivorRatio=8	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[8] -XX:MaxTenuringThreshold=1	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[9] -XX:CMSInitiatingOccupancyFraction=75	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[10] -XX:+UseCMSInitiatingOccupancyOnly	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[11] -XX:+HeapDumpOnOutOfMemoryError	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[12] -Djline.enabled=false	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[13] -Delasticsearch	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[14] -Des-foreground=yes	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[15] -Des.path.home=D:elasticsearch	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[16] -Djava.class.path=;D:\elasticsearch/lib/elasticsearch-0.20.3.jar;D:\elasticsearch/lib/elasticsearch-0.20.3.jar;D:\elasticsearch/lib/jna-3.3.0.jar;D:\elasticsearch/lib/jts-1.12.jar;D:\elasticsearch/lib/log4j-1.2.17.jar;D:\elasticsearch/lib/lucene-analyzers-3.6.2.jar;D:\elasticsearch/lib/lucene-core-3.6.2.jar;D:\elasticsearch/lib/lucene-highlighter-3.6.2.jar;D:\elasticsearch/lib/lucene-memory-3.6.2.jar;D:\elasticsearch/lib/lucene-queries-3.6.2.jar;D:\elasticsearch/lib/snappy-java-1.0.4.1.jar;D:\elasticsearch/lib/spatial4j-0.3.jar;D:\elasticsearch/lib/sigar/sigar-1.6.4.jar	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[17] exit	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[18] -Xms25m	[2013-01-29 00:50:29] [debug] ( javajni.c:690 ) [ 4404] Jvm Option[19] -Xmx1024m	[2013-01-29 00:50:29] [debug] ( javajni.c:927 ) [ 4404] Java Worker thread started org/elasticsearch/bootstrap/ElasticSearch:main	[2013-01-29 00:50:30] [debug] ( prunsrv.c:1184) [ 3612] Java started org/elasticsearch/bootstrap/ElasticSearch	[2013-01-29 00:50:30] [info]  ( prunsrv.c:1280) [ 3612] Service started in 1273 ms.	[2013-01-29 00:50:30] [debug] ( prunsrv.c:843 ) [ 3612] reportServiceStatusE: 4, 0, 0, 0	[2013-01-29 00:50:30] [debug] ( prunsrv.c:1524) [ 3612] Waiting for worker to finish...	[2013-01-29 00:50:36] [debug] ( javajni.c:948 ) [ 4404] Java Worker thread finished org/elasticsearch/bootstrap/ElasticSearch:main with status=0	[2013-01-29 00:50:36] [debug] ( prunsrv.c:1529) [ 3612] Worker finished.	[2013-01-29 00:50:36] [debug] ( prunsrv.c:1552) [ 3612] Waiting for all threads to exit	[2013-01-29 03:15:31] [info]  ( prunsrv.c:1343) [ 2376] Console SHUTDOWN event signaled	[2013-01-29 03:15:31] [info]  ( prunsrv.c:942 ) [ 2376] Stopping service...	[2013-01-29 03:15:31] [debug] ( javajni.c:927 ) [  308] Java Worker thread started org/elasticsearch/bootstrap/ElasticSearch:main	[2013-01-29 03:15:32] [debug] ( prunsrv.c:988 ) [ 2376] Waiting for java jni stop worker to finish...	[2013-01-29 03:15:35] [debug] ( javajni.c:948 ) [  308] Java Worker thread finished org/elasticsearch/bootstrap/ElasticSearch:main with status=0	[2013-01-29 03:15:35] [debug] ( prunsrv.c:990 ) [ 2376] Java jni stop worker finished.	[2013-01-29 03:15:35] [debug] ( prunsrv.c:843 ) [ 2376] reportServiceStatusE: 3, 0, 12000, 0	[2013-01-29 03:15:35] [debug] ( prunsrv.c:1091) [ 2376] Waiting for worker to die naturally...	[2013-01-29 03:15:35] [debug] ( prunsrv.c:1102) [ 2376] Worker finished gracefully in 0 ms.	[2013-01-29 03:15:35] [info]  ( prunsrv.c:1112) [ 2376] Service stopped.	[2013-01-29 03:15:35] [debug] ( prunsrv.c:843 ) [ 2376] reportServiceStatusE: 1, 0, 0, 0	[2013-01-29 03:15:35] [info]  ( prunsrv.c:1591) [ 3756] Run service finished.	[2013-01-29 03:15:35] [info]  ( prunsrv.c:1757) [ 3756] Commons Daemon procrun finished


