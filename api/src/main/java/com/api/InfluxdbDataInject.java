package racing.data.api;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Enumeration;

public class InfluxdbDataInject extends HttpServlet {

    private static final String BEARER_TOKEN = "<input your created bearer token generate a UUID or it can be a secret key whater>";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().println("Unauthorized: Bearer token missing or invalid.");
            return;
        }

        String token = authHeader.substring("Bearer ".length()).trim();
        if (!BEARER_TOKEN.equals(token)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().println("Unauthorized: Invalid Bearer token.");
            return;
        }

        String session = request.getParameter("session");
        String id = request.getParameter("id");

        // Build the InfluxDB data string
        StringBuilder influxData = new StringBuilder("racing_import,session=");
        influxData.append(session).append(",eml=\"unknown\",id=\"").append(id).append("\"");

        boolean firstField = true;

        // Append the fields to the data string
        Enumeration<String> parameterNames = request.getParameterNames();
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (!paramName.equals("session") && !paramName.equals("id") && !paramName.equals("time") && !paramName.equals("eml")) {
                if (firstField) {
                    influxData.append(" ");
                    firstField = false;
                } else {
                    influxData.append(",");
                }
                String paramValue = request.getParameter(paramName);
                influxData.append(paramName).append("=").append(paramValue);
            }
        }

        URL url = new URL("http://influxdb:8086/api/v2/write?org=Racing&bucket=track-data&precision=ns");

        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Authorization", "Token <Influxdb Token generated specific to the bucket write/read>");
        connection.setRequestProperty("Content-Type", "text/plain; charset=utf-8");
        connection.setDoOutput(true);

        try (OutputStream os = connection.getOutputStream()) {
            os.write(influxData.toString().getBytes("UTF-8"));
        }

        int responseCode = connection.getResponseCode();
        response.getWriter().println("InfluxDB response code: " + responseCode);
    }
}
