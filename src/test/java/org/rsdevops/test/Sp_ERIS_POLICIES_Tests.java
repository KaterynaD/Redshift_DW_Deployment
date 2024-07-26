package org.rsdevops.test;

import org.junit.jupiter.api.Test;

import java.sql.*;
import static org.junit.jupiter.api.Assertions.assertEquals;

public class Sp_ERIS_POLICIES_Tests extends AbstractDataDrivenTest {

    @Test
    public void genTestTableTest() throws SQLException, ClassNotFoundException {
        
        int numOfRecords = 0;

        PreparedStatement ps = getOrCreateConnection().prepareStatement("select count(*) from reporting_test.veris_test_summary where pDiff>=10");
        ResultSet rs = ps.executeQuery();

        rs.next();

        int count = rs.getInt(1);

        assertEquals(numOfRecords, count, "No records should be return!");
    }


}
