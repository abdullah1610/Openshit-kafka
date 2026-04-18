#!/bin/bash

# Test Oracle JDBC connection using sqlplus or Java

# Set environment
export ORACLE_HOME=/opt/oracle
export LD_LIBRARY_PATH=/opt/oracle/lib:$LD_LIBRARY_PATH
export PATH=/opt/oracle/bin:$PATH

# Try to connect with basic sqlplus first
echo "=== Testing Oracle Connection ==="
echo "Attempting connection to 192.168.102.25:1521 (ORCL)"

# Use Java to test JDBC directly if sqlplus not available
cat > /tmp/TestOracleConnection.java <<'EOF'
import java.sql.*;

public class TestOracleConnection {
    public static void main(String[] args) {
        String url = "jdbc:oracle:thin:test/test@192.168.102.25:1521:ORCL";
        
        try {
            Class.forName("oracle.jdbc.driver.OracleDriver");
            System.out.println("✓ Oracle JDBC Driver loaded");
            
            Connection conn = DriverManager.getConnection(url);
            System.out.println("✓ Connected to Oracle!");
            
            // Try to get database version
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM V$VERSION WHERE ROWNUM <= 1");
            
            if (rs.next()) {
                System.out.println("✓ Database Version: " + rs.getString(1));
            }
            
            rs.close();
            stmt.close();
            conn.close();
            System.out.println("✓ Connection test PASSED");
            
        } catch (Exception e) {
            System.out.println("✗ Connection test FAILED");
            System.out.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
EOF

# Compile and run if Java is available
if command -v javac &> /dev/null; then
    javac /tmp/TestOracleConnection.java 2>/dev/null
    if [ -f /tmp/TestOracleConnection.class ]; then
        java -cp /tmp:/opt/kafka/libs/ojdbc8.jar TestOracleConnection 2>&1
    fi
else
    echo "Java compiler not found, trying with pre-compiled..."
fi
