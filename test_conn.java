import java.sql.*;
public class test_conn {
    public static void main(String[] args) {
        String[] urls = {
            "jdbc:oracle:thin:dbzuser/dbzuser@192.168.102.25:1521:orcl2",
            "jdbc:oracle:thin:dbzuser/dbzuser@192.168.102.25:1521:orclpdb1",
            "jdbc:oracle:thin:dbzuser/dbzuser@192.168.102.35:1521:orcl2",
            "jdbc:oracle:thin:dbzuser/dbzuser@192.168.102.35:1521:orclpdb1"
        };
        for (String url : urls) {
            System.out.println("Trying: " + url);
            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");
                Connection conn = DriverManager.getConnection(url);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT * FROM V$VERSION WHERE ROWNUM <= 1");
                if (rs.next()) System.out.println("SUCCESS: Version: " + rs.getString(1));
                rs.close(); stmt.close(); conn.close();
                return;
            } catch (Exception e) {
                System.out.println("FAILED: " + e.getMessage());
            }
        }
    }
}