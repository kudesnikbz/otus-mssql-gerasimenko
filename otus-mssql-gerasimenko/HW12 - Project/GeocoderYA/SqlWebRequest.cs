using Microsoft.SqlServer.Server;
using System;
using System.Data.SqlTypes;
using System.IO;
using System.Net;
using System.Text;

namespace SqlWebRequest
{
    public partial class Functions
    {
        [SqlFunction(DataAccess = DataAccessKind.Read)]
        public static SqlString GET(SqlString key, SqlString geocode/*SqlString uri, SqlString username, SqlString passwd*/)
        {
            //SqlPipe pipe = SqlContext.Pipe;
            //SqlString key;
            //SqlString geocode;
            SqlString document;            

            WebRequest req = WebRequest.Create(Convert.ToString("https://geocode-maps.yandex.ru/1.x/?apikey=" + key + "&format=json&geocode=" + geocode + "&results=5"));
            //if (Convert.ToString(username) != null & Convert.ToString(username) != "")
            //{
            //    req.Credentials = new NetworkCredential(
            //        Convert.ToString(username),
            //        Convert.ToString(passwd));
            //}
            ((HttpWebRequest)req).UserAgent = "CLR web client";

            WebResponse resp = req.GetResponse();
            Stream dataStream = resp.GetResponseStream();
            StreamReader rdr = new StreamReader(dataStream);
            document = rdr.ReadToEnd();

            rdr.Close();
            dataStream.Close();
            resp.Close();

            return (document);
        }
    }

}
