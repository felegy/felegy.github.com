---

layout: post
title: "Jenkins Verziószám kezelés"
date: 2013-03-06 05:52
comments: true
published: false
categories: 
- jenkins
- java

---

{% codeblock DAYS_SINCE_PROJECT_START lang:java %}
if ("DAYS_SINCE_PROJECT_START".equals(expressionKey)) {
	Date today = Calendar.getInstance().getTime();
	int daysSinceStart = daysBetween(projectStartDate,today);
	replaceValue = sizeTo(Integer.toString(daysSinceStart), argumentString.length());
} 
                
private static int daysBetween(Date d1, Date d2) {
	return (int)( (d2.getTime() - d1.getTime()) / (1000 * 60 * 60 * 24));
}

{% endcodeblock %}