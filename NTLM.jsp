<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.Calendar" %>

<%@ page import="jcifs.ntlmssp.Type1Message" %>
<%@ page import="jcifs.ntlmssp.Type2Message" %>
<%@ page import="jcifs.ntlmssp.Type3Message" %>
<%@ page import="jcifs.util.Base64" %>

<%@ page import="oracle.apps.fnd.common.WebAppsContext" %>
<%@ page import="oracle.apps.fnd.common.WebRequestUtil" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta http-equiv="Content-type" content="text/html; charset=utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <title>.:: NTLM & Session Information ::.</title>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/ua-parser-js@0/dist/ua-parser.min.js"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" 
          integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" 
          crossorigin="anonymous"></script>
  <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" 
        integrity="sha384-ggOyR0iXCbMQv3Xipma34MD+dH/1fQ784/j6cY/iJTQUOhcWr7x9JvoRxT2MZw1T" 
      crossorigin="anonymous"/>
</head>
<style>
  input { font-family:monospace; font-size:0.9rem; width: 100%;}
</style>
<body>
<div class="alert alert-danger" role="alert" id="beforeAuth">Authentication required</div> 
<%
response.setHeader("Cache-Control","no-cache");
response.setHeader("Pragma","no-cache");
response.setDateHeader ("Expires", 0);

String username    = "";
String domain      = "";
String workstation = "";
String clientIP    = "";
String serverTime  = "";
String cookieVal   = "";
String sessionID   = "";
String fndUser     = "";

String auth = request.getHeader("Authorization");

//no auth, request NTLM
if (auth == null) {
    response.setStatus(response.SC_UNAUTHORIZED);
    response.setHeader("WWW-Authenticate", "NTLM");
    response.flushBuffer();
    return;
}

if (auth.startsWith("NTLM ")) {
    byte[] msg = Base64.decode(auth.substring(5));

    if (msg[8] == 1) {
      Type1Message msg1 = new Type1Message(msg);
      Type2Message msg2 = new Type2Message(msg1);

      String context = "NTLM " + Base64.encode(msg2.toByteArray());

      response.setStatus(response.SC_UNAUTHORIZED);
      response.setHeader("WWW-Authenticate", context);
      response.flushBuffer();
      return;

    } else if (msg[8] == 3) {
        Type3Message msg3 = new Type3Message(msg);
        username    = msg3.getUser();
        workstation = msg3.getWorkstation();
        domain      = msg3.getDomain();
    } else {
      return;
    }

    clientIP = request.getRemoteAddr();

    String DATE_FORMAT = "yyyy/MM/dd HH:mm:ss";  
    Calendar cal = Calendar.getInstance();
    SimpleDateFormat timeFormat = new SimpleDateFormat(DATE_FORMAT);

    serverTime = timeFormat.format(cal.getTime());

    WebAppsContext wctx = null;
    wctx = WebRequestUtil.validateContext(request, response);
    sessionID = wctx.getSessionId();
    cookieVal = wctx.getSessionCookieValue();

    Connection conn = wctx.getJDBCConnection();
    String sql = "SELECT fu.USER_NAME FROM FND_USER fu, ICX_SESSIONS iss WHERE iss.SESSION_ID=? AND iss.USER_ID=fu.USER_ID";
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, Integer.valueOf(sessionID).intValue());
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
      fndUser = rs.getString(1);
    }
    rs.close();
    ps.close();
}
%>
 <div class="alert alert-primary" role="alert">Session Audit Info</div>
  <form id="auditInfoForm" name="auditInfoForm" action="#" method="post">
    <table class="table table-hover table-sm border border-secondary">
      <tr>
        <th scope="col">Parameter</th>
        <th scope="col">Value</th>
        <th scope="col">Source</th>
      </tr>
      <tr>
        <td>Username</td>
        <td><input type="text" name="username" id="username" value="<%=username%>"/></td>
        <td>NTLM</td>
      </tr>
      <tr>
       <td>Domain</td> 
       <td><input type="text" name="domain" id="domain" value="<%=domain%>"/></td>
       <td>NTLM</td>
      </tr>
      <tr>
        <td>Hostname</td>
        <td><input type="text" name="hostname" id="hostname" value="<%=workstation%>"/></td>
        <td>NTLM</td>
      </tr>
      <tr> 
        <td>IP Address</td>
        <td><input type="text" name="ip" id="ip" value="<%=clientIP%>"/></td>
        <td>HTTP Header</td>
      </tr>
      <tr>
        <td>Time (server)</td>
        <td><input type="text" name="serverTime" id="serverTime" value="<%=serverTime%>"/></td>
        <td>session</td>
      </tr>
      <tr>
        <td>Time (client)</td>
        <td><input type="text" name="clientTime" id="clientTime" value=""/></td>
        <td>browser / javascript</td>
      </tr>
      <tr>
        <td>Timezone (client)</td>
        <td><input type="text" name="timezone" id="timezone" value=""/></td>
        <td>browser / javascript</td>        
      </tr>
      <tr>
        <td>OS Name</td>
        <td><input type="text" name="osname" id="osname" value=""/></td>
        <td>browser / javascript</td>        
      </tr>
      <tr>
        <td>Session ID</td>
        <td><input type="text" name="sessionID" id="sessionID" value="<%=sessionID%>"/></td>
        <td>session</td>        
      </tr>
      <tr>
        <td>Cookie (XSID)</td>
        <td><input type="text" name="cookieVal" id="cookieVal" value="<%=cookieVal%>"/></td>
        <td>session</td>
      </tr>
      <tr>
        <td>FND Username</td>
        <td><input type="text" name="fndUser" id="fndUser" value="<%=fndUser%>"/></td>
        <td>session</td>
      </tr>
    </table>
  </form>
  <button type="button" class="btn btn-success" onClick="showAlert()">Submit</button>
</body>
<script language="javascript">
$(document).ready(function () {
  var uastring = navigator.userAgent;
  var parser = new UAParser();
  parser.setUA(uastring);
  var result = parser.getResult();
  $("#browser").val(result.browser.name + " " + result.browser.version);
  $("#osname").val(result.os.name + " " + result.os.version);

  var userDate = new Date();
  $("#clientTime").val(formateDate(userDate));

  var userTimeZone = ( userDate.getTimezoneOffset()/60 )*( -1 );
  var timezoneString = "GMT";
  if (userTimeZone >= 0) {
    timezoneString = timezoneString + "+" + userTimeZone;
  } else {
    timezoneString = timezoneString + userTimeZone;
  }
  
  $("#timezone").val(timezoneString);
  $("#beforeAuth").hide();
});

function formateDate(_date) {
  function pad(n){return n<10 ? '0'+n : n};
  return _date.getFullYear() + "/" + 
         pad((_date.getMonth()+1)) + "/" + 
         pad(_date.getDate())  + " " +
         pad(_date.getHours()) + ":" + 
         pad(_date.getMinutes()) + ":" + 
         pad(_date.getSeconds());
}

function showAlert() {
  alert("Function not implemented yet");
}
</script>
</html>