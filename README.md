## Showing AD information in Oracle EBS Using NTLM passthrough from Browser

### About
This document descibes how to show Windows AD username and domain information in Oracle EBS environment when NTLM passthrough is configured in browsers.  A sample proof-of-concept code is provided to demostrate this feature.  If it's working, you can further customize it to fit your requirements.

This code is worked ONLY when
- Browser is set to use NTLM passthrough 
- The client browser is running under Windows 7/10 in corporate envrionment, i.e. An OS with AD user logged on under a domain through Corporate AD.
- NTLMv1 is used.  NTLMv2 does **not** work.

 This code is tested with IE11, Edge (Windows 10), Chrome, and Firefox.

### Deployment
- Put the file `NTLM.jsp` to `$OA_HTML_TOP` in app server.
- Download Java CIFS Client Library jar from `https://www.jcifs.org/src/jcifs-1.3.19.jar`
- Transfer jcifs-1.3.19.jar to app server, e.g. /tmp folder.  Extract folder jcifs to `$JAVA_TOP` by 
```
cd /tmp
jar xf jcifs-1.3.19.jar jcifs
mv jvcif $JAVA_TOP
```
- Bounce App server 

### Testing

- Log on to your EBS instance as usual
- The URL will become something like 
`https://hostname.com:8000/OA_HTML/OA.jsp?OAFunction=OAHomePage`. Change it to `/OA_HTML/NTLM.jsp`
- You should see a list of data collected from NTLM, client browser, and server session.


### Browser Setup
- For Internet Explorer, your EBS URL must be in zone "Local Intranet" or "Trusted sites". In such zone, the custom level must provide "set username and domain.
- Google Chrome browser can pick up this IE security setting.  No further configuration needed.
- For Firefox, change the following settings:
