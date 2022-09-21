<%@ page import="java.sql.*"%>

<%
 String userName = request.getParameter("userName");

 String password = request.getParameter("password");

 Class.forName("org.postgresql.Driver");
 Connection con = DriverManager.getConnection("jdbc:postgresql://13.235.254.117:5432/mydb", "root", "1234");
 Statement st = con.createStatement();
 ResultSet rs;
 rs = st.executeQuery("select * from public.user where username='" + userName + "' and password='" + password + "'");
        if (rs.next())
                {
                        session.setAttribute("userid", userName);
                        response.sendRedirect("success.jsp");
                }
        else
                {
                        out.println("Invalid password <a href='index.jsp'>try again</a>");
}
%>
