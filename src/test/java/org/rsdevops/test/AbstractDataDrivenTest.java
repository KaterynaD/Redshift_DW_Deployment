package org.rsdevops.test;

import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;

import java.sql.*;

public abstract class AbstractDataDrivenTest {
    private static Connection conn = null;




    @AfterAll
    public static void tearDown() throws SQLException {
        conn.close();
    }


    protected static Connection getOrCreateConnection() throws SQLException, ClassNotFoundException {
        if (conn == null || conn.isClosed()) {
            conn = ConnectionManager.createConnection();
        }

        return conn;
    }
}
