using Microsoft.SqlServer.Server;
using System;
using System.Data.SqlTypes;
using System.Globalization;

public class DATE
{

    [SqlFunction(Name = "Word_Date_Format", IsDeterministic = true, IsPrecise = true)]
    public static SqlString Format(SqlDateTime TheDate, SqlString DateTimeFormat, [SqlFacet(MaxSize = 10)] SqlString Culture)
    {
        string x = (!(Culture.Value == string.Empty)) ? TheDate.Value.ToString(DateTimeFormat.Value, CultureInfo.CreateSpecificCulture(Culture.Value)) : TheDate.Value.ToString(DateTimeFormat.Value);
        return x;
    }
}
