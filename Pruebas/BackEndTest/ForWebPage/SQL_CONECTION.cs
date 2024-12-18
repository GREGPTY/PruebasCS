﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SqlClient;
using Pruebas.BackEndTest.OnlyTest;
using static Org.BouncyCastle.Asn1.Cmp.Challenge;
using System.Reflection;
using System.Data;
using System.ComponentModel;

namespace Pruebas.BackEndTest.ForWebPage
{
    internal class SQL_CONECTION
    {
        verification v = new verification();
        //tuconexion
        
        public static string ConnectionStringName()
        {
            //tunexion
        }
        public string SQL_CreateUser(string User = null, string Password = null, string Email = null, string autorization = null)
        {
            string answer = "";
            if (!((User == null || User == "") || (Password == null || Password == "") ||
                (Email == null || Email == "") || (autorization == null || autorization == "")))
            {
                try
                {
                    answer = "Exito, usted se encuentra";
                }catch(Exception ex)
                {
                    answer = "Error: "+ex.Message;
                }
            }
            else
            {
                answer = "No Pueden haber espacios vacios";
            }

            return answer;
        }
        public string ChangingPassword(string Password = null, string Username = null)
        {
            string answer = "";
            try
            {
                using (SqlConnection cxnx = new SqlConnection(connectionString))
                {
                    cxnx.Open();
                    string querty = "update personal set Password_Control = @password where User_ControlGreg = @username;";
                    using (SqlCommand cmd = new SqlCommand(querty, cxnx))
                    {
                        cmd.Parameters.AddWithValue("@password", verification.HashearContrasena(Password));
                        cmd.Parameters.AddWithValue("@username",Username);
                        int rowsAffected = cmd.ExecuteNonQuery();
                        if(rowsAffected > 0)
                        {
                            answer = "Exito, Se cambio la contraseña";
                        }
                        else
                        {
                            answer = "Error, No se enviaron los datos";
                        }
                    }
                        cxnx.Close();
                }
            }
            catch(Exception ex)
            {
                answer = $"Error: {ex}";
            }
            return answer;
        }
        public bool MailExistOnList(string UserEmail = null)
        {            
            bool answer = false;
            List<string> emailList = new List<string>();
            try
            {
                if (!string.IsNullOrEmpty(UserEmail))
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        string query = "SELECT correo FROM correo_puede_ser;";

                        using (SqlCommand cmd = new SqlCommand(query, cxnx))
                        {
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows)
                                {
                                    while (reader.Read())
                                    {
                                        if (!reader.IsDBNull(0))
                                        {
                                            emailList.Add(reader.GetString(0));
                                        }
                                    }
                                    foreach (string s in emailList)
                                    {
                                        if (UserEmail.EndsWith(s))
                                        {
                                            answer = true;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        cxnx.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }

            return answer;
        }
        public bool Email_NotExist( string Mail = null)
        {
            bool answer = false;
            verification v = new verification();            
            Mail = v.NoSpaceSrting(v.Lower_Username(Mail));
            try
            {
                if (!string.IsNullOrEmpty(Mail)) //Mail
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        string query = "select 1 from test_user where email = @email;";

                        using (SqlCommand cmd = new SqlCommand(query, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@email", Mail);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (!(reader.HasRows))
                                {
                                    answer = true;
                                }
                            }
                        }
                        cxnx.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }

            return answer;
        }
        public bool User_NotExist(string User = null)
        {
            bool answer = false;
            verification v = new verification();
            User = v.NoSpaceSrting(v.Lower_Username(User));
            try
            {
                if (!string.IsNullOrEmpty(User)) //si ninguno es null perfecto
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        string query = "select 1 from test_user where username_test = @username;";

                        using (SqlCommand cmd = new SqlCommand(query, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", User);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (!(reader.HasRows))
                                {
                                    answer = true;
                                }
                            }
                        }
                        cxnx.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error: " + ex.Message);
            }

            return answer;
        }
        public bool LowRank(string Username = null)
        {
            bool answer = false;
            return answer;
        }
        public bool ItsHighRank(string Username = null) //0,1
        {
            bool answer = false;
            if (!string.IsNullOrEmpty(Username))
            {
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        string query = "select p.User_ControlGreg, p.Rank_Control, r.RankNumber from personal as p inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks " +
                                       "where p.User_ControlGreg = @username";
                        using (SqlCommand cmd = new SqlCommand(query, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", Username);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    string RankNumber = reader.GetString(2);
                                    //Console.WriteLine($"El Rango Obtenido fue: {RankNumber} para el usuario [{Username}]");
                                    if (RankNumber.Length >= 1 && RankNumber.Length <= 2)
                                    {
                                        answer = true;
                                    }
                                    else
                                    {
                                        answer = false;
                                    }
                                }
                                else
                                {
                                    answer = false;
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                    answer = false;
                }
            }
            else
            {
                answer = false;
            }
            return answer;
        }
        public bool ItsSuperHighRank(string Username = null) //0,1
        {
            bool answer = false;
            if (!string.IsNullOrEmpty(Username))
            {
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        string query = "select p.User_ControlGreg, p.Rank_Control, r.RankNumber from personal as p inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks " +
                                       "where p.User_ControlGreg = @username";
                        using (SqlCommand cmd = new SqlCommand(query, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", Username);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    string RankNumber = reader.GetString(2);
                                    //Console.WriteLine($"El Rango Obtenido fue: {RankNumber} para el usuario [{Username}]");
                                    if (RankNumber.Length == 1 && RankNumber == "0")
                                    {
                                        answer = true;
                                    }
                                    else
                                    {
                                        answer = false;
                                    }
                                }
                                else
                                {
                                    answer = false;
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                    answer = false;
                }
            }
            else
            {
                answer = false;
            }
            return answer;
        }
        public List<List<string>> UsersAndMeData(string User = null)
        {
            verification v = new verification();
            List<List<string>> answer = new List<List<string>>();            
            bool b = false;
            if (!string.IsNullOrEmpty(User)) {
                string[] querty = {
            "select r.RankNumber  from (personal as p inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks) where p.User_ControlGreg = @username",

            "select p.User_ControlGreg,  p.Rank_Control,p.email, s.SalarioPorHora, s.TipoDePago "+
            "from ((personal as p inner join salario_de_usuario_por_dia as s on p.User_ControlGreg = s.User_ControlGreg)"+
            "inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks)"+
            " where r.RankNumber > @Rank OR p.User_ControlGreg = @username ;" };
                int UserRank = 9;
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        using (SqlCommand cmd = new SqlCommand(querty[0], cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", User);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows && reader.Read())
                                {
                                    UserRank = reader.GetInt32(0);
                                    Console.WriteLine($"El Rango es: {UserRank}");
                                    b = true;
                                }
                                else
                                {
                                    b = false;
                                    answer.Add(new List<string> { "No Hay Datos" });
                                }//*/
                            }

                        }
                        cxnx.Close();
                        if (b == true) { 
                        cxnx.Open();
                            using (SqlCommand cmd = new SqlCommand(querty[1], cxnx))
                            {
                                answer.Clear();
                                cmd.Parameters.AddWithValue("@username", User);
                                cmd.Parameters.AddWithValue("@Rank", UserRank);
                                using (SqlDataReader reader = cmd.ExecuteReader())
                                {
                                    if (reader.HasRows)
                                    {
                                        while (reader.Read())
                                        {
                                            List<string> listT = new List<string>();
                                            string userData = "";
                                            int readerColumnsSize = reader.FieldCount;
                                            for (int i = 0; i < readerColumnsSize; i += 1)
                                            {
                                                Type fieldType = reader.GetFieldType(i);
                                                /*
                                                if (i == 0)
                                                {
                                                    userData = v.ValorDeLaTabla(reader, i).ToString();
                                                }
                                                else
                                                {
                                                    //userData += $",{v.ValorDeLaTabla(reader, i).ToString()}";
                                                    userData += v.ValorDeLaTabla(reader, i).ToString();
                                                }//*/
                                                Console.WriteLine(v.ValorDeLaTabla(reader, i).ToString());
                                                listT.Add(v.ValorDeLaTabla(reader, i).ToString());
                                                //Console.WriteLine(userData);
                                                //listT.Add(userData);
                                            }
                                            answer.Add(listT);
                                        }
                                    }
                                    else
                                    {
                                        return answer;
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception ex) {
                    Console.WriteLine(ex.Message);
                }
            }
            else
            {
                answer.Clear ();
                answer.Add(new List<string> { "No Hay Datos" });
            }
            return answer;
        }
        public bool UserSessionIsBiggerThanUserEdit(string UserSession = null, string UserEdit = null)
        {
            bool answer = false;
            int esmayor = 0;
            if (UserSession == null || UserEdit == null)
            {
                return false;
            }
            string query = "exec SP_UserSessionIsBiggerThannUserEdit @usernameSession, @usernameEdit, @answer OUTPUT";
            try
            {
                using (SqlConnection cxnx = new SqlConnection(connectionString))
                {
                    cxnx.Open();
                    using (SqlCommand cmd = new SqlCommand(query, cxnx))
                    {
                        cmd.Parameters.AddWithValue("@usernameSession", UserSession);
                        cmd.Parameters.AddWithValue("@usernameEdit", UserEdit);
                        SqlParameter outParameter = new SqlParameter("@answer", SqlDbType.Int)
                        {
                            Direction = ParameterDirection.Output
                        };
                        cmd.Parameters.Add(outParameter);
                        cmd.ExecuteNonQuery();
                        esmayor = outParameter.Value != DBNull.Value ? (int)outParameter.Value : 0;
                        //answer = esmayor == 1? true : false;
                        answer = esmayor == 1;
                    }
                    cxnx.Close();
                }
            }
            catch (Exception)
            {
                answer = false;
            }
            return answer;
        }
        public bool VerificadorDeContrasena(string Username = null, string Password = null)
        {
            string query = "select Password_Control from personal where User_ControlGreg = @username;";
            bool answer = false;

            if (Username == null || Password == null)
            {
                return false;
            }

            try
            {
                using (SqlConnection cxnx = new SqlConnection(connectionString))
                {
                    cxnx.Open();
                    using (SqlCommand cmd = new SqlCommand(query, cxnx))
                    {
                        cmd.Parameters.AddWithValue("@username", Username);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows && reader.Read())
                            {
                                if (!reader.IsDBNull(0))
                                {
                                    byte[] PasswordHashedByte = (byte[])reader.GetValue(0);
                                    string PasswordHashed = Encoding.UTF8.GetString(PasswordHashedByte);
                                    if (BCrypt.Net.BCrypt.Verify(Password, PasswordHashed))
                                    {
                                        answer = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return false;
            }

            return answer;
        }
        public string EditUser_General(string User_ControlGreg_Old = null, string User_ControlGreg_New = null, string Password_Control_New = null,
        int Password_Confirmation = 0, string Rank_New = null, string TipoDePago_New = null, string SalarioPorHora_New = null,
        string Email_New = null)
        {
            verification v = new verification();
            string answer = "";
            string query = "exec SP_EDICION_GENERAL @User_ControlGreg_Old, @User_ControlGreg_New, @Password_Control_New, @Password_Confirmation, " +
                "@Rank_New, @TipoDePago_New, @SalarioPorHora_New, @Email_New, @EdicionCompletada OUTPUT";
            //Console.WriteLine($"Password Confirmation: {Password_Confirmation}");
            bool PasswordConfirmation_Bool = false;
            if (Password_Confirmation == 1 && !string.IsNullOrEmpty(Password_Control_New))
            {
                PasswordConfirmation_Bool = true;
            }
            else if (Password_Confirmation == 0)
            {
                PasswordConfirmation_Bool = false;
            }
            if (!(string.IsNullOrEmpty(User_ControlGreg_Old) || string.IsNullOrEmpty(User_ControlGreg_New) || PasswordConfirmation_Bool == true ||
                  string.IsNullOrEmpty(Rank_New) || string.IsNullOrEmpty(TipoDePago_New) || string.IsNullOrEmpty(SalarioPorHora_New) ||
                  string.IsNullOrEmpty(Email_New)))
            {
                if (User_NotExist(User_ControlGreg_New) && Email_NotExist(Email_New) && MailExistOnList(Email_New) && verification.ItsDoubleWithTwoDecimal(SalarioPorHora_New))
                {
                    try
                    {
                        Console.WriteLine("Procede a Enviar Los Datos");
                        using (SqlConnection cxnx = new SqlConnection(connectionString))
                        {
                            cxnx.Open();
                            using (SqlCommand cmd = new SqlCommand(query, cxnx))
                            {
                                cmd.Parameters.AddWithValue("@User_ControlGreg_Old", User_ControlGreg_Old);
                                cmd.Parameters.AddWithValue("@User_ControlGreg_New", User_ControlGreg_New);
                                cmd.Parameters.AddWithValue("@Password_Control_New", verification.HashearContrasena(Password_Control_New));
                                cmd.Parameters.AddWithValue("@Password_Confirmation", Password_Confirmation);
                                cmd.Parameters.AddWithValue("@Rank_New", Rank_New);
                                cmd.Parameters.AddWithValue("@TipoDePago_New", TipoDePago_New);
                                cmd.Parameters.AddWithValue("@SalarioPorHora_New", SalarioPorHora_New);
                                cmd.Parameters.AddWithValue("@Email_New", Email_New);
                                SqlParameter outParameter = new SqlParameter("@EdicionCompletada", SqlDbType.VarChar, 50)
                                {
                                    Direction = ParameterDirection.Output
                                };
                                cmd.Parameters.Add(outParameter);

                                cmd.ExecuteNonQuery();

                                if (outParameter.Value != DBNull.Value)
                                {
                                    answer = outParameter.Value.ToString();
                                }
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        answer = $"Error: {ex.ToString()}";
                    }
                }
            }
            else
            {
                answer = "Algun Dato Es Vacio o Null";
            }
            return answer;
        }
        public List<string> MyUserData(string Username = null)
        {
            List<string> answer = new List<string>();
            if (!string.IsNullOrEmpty(Username))
            {
                string querty = "select p.ID ,p.User_ControlGreg,  p.Rank_Control,p.email, s.SalarioPorHora, s.TipoDePago " +
                    "from (personal as p inner join salario_de_usuario_por_dia as s on p.User_ControlGreg = s.User_ControlGreg) " +
                    "where p.User_ControlGreg = @username ;";
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        using (SqlCommand cmd = new SqlCommand(querty, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", Username);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows && reader.Read())
                                {
                                    string Data = null;
                                    int columnSize = reader.FieldCount;
                                    for (int i = 0; i < columnSize; i += 1)
                                    {
                                        Type type = reader.GetFieldType(i);
                                        answer.Add(v.ValorDeLaTabla(reader, i).ToString());
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    answer.Add("No Data");
                }
            }
            return answer;
        }
        public List<List<string>> DataGridView_Data(string Username = null, string querty = null, DateTime DateStart = default, DateTime DateEnd = default)
        {
            List<List<string>> answer = new List<List<string>>();
            if ((!string.IsNullOrEmpty(Username)) && (!string.IsNullOrEmpty(querty)))
            {                
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        using (SqlCommand cmd = new SqlCommand(querty, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", Username);
                            if (!(DateStart == default || DateEnd==default))
                            {
                                cmd.Parameters.AddWithValue("@DateStart", DateStart);
                                cmd.Parameters.AddWithValue("@DateEnd", DateEnd);
                            }
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows)
                                {
                                    List<string> titlerow = new List<string>();
                                for (int i =0; i< reader.FieldCount;i+=1)
                                {
                                    titlerow.Add(reader.GetName(i));
                                }
                                answer.Add(titlerow);
                                    while (reader.Read())
                                    {
                                        List<string> rowElement = new List<string>();
                                        for (int i =0; i<reader.FieldCount;i+=1)
                                        {
                                            Type type = reader.GetFieldType(i);
                                            rowElement.Add(v.ValorDeLaTabla(reader,i));
                                        }
                                        answer.Add(rowElement);
                                    }                                   
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    answer.Add(new List<string> { "No hay datos" });
                }
            }
            return answer;
        }
        public DateTime[] GetDateRange(string username = null, string queryDateRange = null)
        {
            //@"SELECT TOP 1 DATEFROMPARTS(AnoInicio, MesInicio, DiaIncio) AS DateStart, DATEFROMPARTS(AnoFinal, MesFinal, DiaFinal) AS DateEnd FROM salario_a_la_semana WHERE User_ControlGreg_Salario = @username ORDER BY Movimiento DESC"
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(queryDateRange)) { return null; }
            DateTime dateStart, dateEnd;
            using (SqlConnection connection = new SqlConnection(connectionString))
            {
                connection.Open();
                using (SqlCommand cmd = new SqlCommand(queryDateRange, connection))
                {
                    cmd.Parameters.AddWithValue("@username", username);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            dateStart = reader.GetDateTime(0);
                            dateEnd = reader.GetDateTime(1);
                            return new DateTime[] { dateStart, dateEnd };
                        }
                    }
                }
            }
            return null;
        }
        public List<List<string>> GetDataBetweenDays(string Username = null, string querty = null, DateTime dateStart = default, DateTime dateEnd = default)
        {
            List<List<string>> answer = new List<List<string>>();
            if (!(string.IsNullOrEmpty(Username) || string.IsNullOrEmpty(querty) || dateStart == default || dateEnd == default))
            {
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        using (SqlCommand cmd = new SqlCommand(querty, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", Username);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows)
                                {
                                    List<string> titlerow = new List<string>();
                                    for (int i = 0; i < reader.FieldCount; i += 1)
                                    {
                                        titlerow.Add(reader.GetName(i));
                                    }
                                    answer.Add(titlerow);
                                    while (reader.Read())
                                    {
                                        List<string> rowElement = new List<string>();
                                        for (int i = 0; i < reader.FieldCount; i += 1)
                                        {
                                            Type type = reader.GetFieldType(i);
                                            rowElement.Add(v.ValorDeLaTabla(reader, i));
                                        }
                                        answer.Add(rowElement);
                                    }
                                }
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    answer.Add(new List<string> { "No hay datos" });
                }
            }
            return answer;
        }


        public List<List<string>> DropDownsRanks(string RankNumber = null)
        {
            List<List<string>> answer = new List<List<string>>();
            if (string.IsNullOrEmpty(RankNumber)) {
                answer.Add(new List<string> { "No Hay Opciones Disponibles" });
                return answer;
            }
            else
            {
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        string querty = "select Ranks, RankNumber from datos_pueden_ser_ranks where RankNumber like @RankNumber+'%' order by RankNumber asc";
                        using (SqlCommand cmd = new SqlCommand(querty, cxnx))
                        {
                            RankNumber = RankNumber == "0" ? "" : RankNumber;
                            cmd.Parameters.AddWithValue("@RankNumber", RankNumber);
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows)
                                {
                                    while (reader.Read())
                                    {
                                        List<string> row = new List<string>();
                                        if (reader.GetString(1).Length > RankNumber.Length)
                                        {
                                            //0 String Rank Name, 1 String Rank Number
                                            row.Add(reader.GetString(0));
                                            row.Add(reader.GetString(1));
                                        }
                                        answer.Add(row);
                                    }
                                }
                                else
                                {

                                }
                            }
                        }
                        cxnx.Close();
                    }
                }
                catch (Exception ex)
                {
                    answer.Add(new List<string> { $"Error, No Se Cargaron los datos: {ex.Message}" });
                }
            }
            return answer;
        }
        public string GetMyRankNumber(string Username = null) {
            string answer = "";
            if (string.IsNullOrEmpty(Username)) { return null; }
            using (SqlConnection cxnx = new SqlConnection(connectionString))
            {
                cxnx.Open();
                string querty = "select r.RankNumber from (personal as p inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks) where p.User_ControlGreg = @username";
                using (SqlCommand cmd = new SqlCommand(querty, cxnx))
                {
                    cmd.Parameters.AddWithValue("@username", Username);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows && reader.Read())
                        {
                            answer = reader.GetString(0);
                        }
                        else
                        {
                            return null;
                        }
                    }
                }
            }
            return answer;
        }
        public string Get_RankName(string username = null)
        {
            string answer = null;
            if (string.IsNullOrEmpty(username)) { return null; }
            using (SqlConnection cxnx = new SqlConnection(connectionString))
            {
                cxnx.Open();
                string querty = "select Rank_Control from personal where User_ControlGreg = @username ;";
                using (SqlCommand cmd = new SqlCommand(querty, cxnx))
                {
                    cmd.Parameters.AddWithValue("@username", username);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.HasRows && reader.Read())
                        {
                            answer = reader.GetString(0);
                        }
                        else
                        {
                            return null;
                        }
                    }
                }
            }
            return answer;
        }



        //CONSULTAS
        public string Load_DGV_Weekly_RankDates()
        {
            return "SELECT TOP 1 " +
                " CONVERT(DATE, DATEFROMPARTS(AnoInicio, MesInicio, DiaIncio)) AS DateStart, " +
                "CONVERT(DATE, DATEFROMPARTS(AnoFinal, MesFinal, DiaFinal)) AS DateEnd " +
                "FROM salario_a_la_semana \r\nWHERE User_ControlGreg_Salario = @username " +
                "ORDER BY Movimiento DESC;";
        }

        public string Load_DGV_Weekly_Between_Querty(int quantity = 0)
        {
            return $"select top {quantity} Movimiento, User_ControlGreg_Salario as Username, Monto, HorasTrabajadas as \"Hours Worked\", MinutosTrabajados as \"Minutes Worked\", " +
            "CONVERT(DATE, DATEFROMPARTS(AnoInicio, MesInicio, DiaIncio)) AS \"Date Start\"," +
            "CONVERT(DATE, DATEFROMPARTS(AnoFinal, MesFinal, DiaFinal)) AS \"Date End\" " +
            "from salario_a_la_semana where User_ControlGreg_Salario = @username and " +
            "  AND DATEFROMPARTS(AnoFinal, MesFinal, DiaFinal) BETWEEN @DateStart AND @DateEnd " +
            " order by Movimiento desc";
        }
        public string Load_DGV_Last_Weekly_Querty(int quantity = 0)
        {
            return $"select top {quantity} Movimiento, User_ControlGreg_Salario as Username, Monto, HorasTrabajadas as \"Hours Worked\", MinutosTrabajados as \"Minutes Worked\", " +
            "CONVERT(DATE, DATEFROMPARTS(AnoFinal, MesFinal, DiaFinal)) AS \"Date End\" " +
            "from salario_a_la_semana where User_ControlGreg_Salario = @username "+
            " order by Movimiento desc";
        }
        public string Load_DGV_Days_Between_Querty(int top = 0)
        {
            return $"SELECT TOP {top}" +
                    $"User_ControlGreg_Salario AS \"Username\", DATEFROMPARTS(Ano, Mes, Dia) AS \"Date\", Monto, " +
                    $"RIGHT('00' + CAST(HoraInicio AS VARCHAR), 2) + ':' + RIGHT('00' + CAST(MinutoInicio AS VARCHAR), 2) AS \"Check-in Time\", " +
                    $"RIGHT('00' + CAST(HoraFinal AS VARCHAR), 2) + ':' + RIGHT('00' + CAST(MinutoFinal AS VARCHAR), 2) AS \"Check-out Time\", " +
                    $"RIGHT('00' + CAST(HorasTrabajadas AS VARCHAR), 2) + ':' + RIGHT('00' + CAST(MinutosTrabajados AS VARCHAR), 2) AS \"Hours Worked\" " +
                    $"FROM salario_al_dia " +
                    $"WHERE User_ControlGreg_Salario = @username " +
                    $"AND DATEFROMPARTS(Ano, Mes, Dia) BETWEEN @DateStart AND @DateEnd order by DATEFROMPARTS(Ano, Mes, Dia) asc;";
        }
    }
    }



/* string Data = null;
                                    int columnSize = reader.FieldCount;
                                    for (int i = 0; i < columnSize; i += 1)
                                    {
                                        Type type = reader.GetFieldType(i);
                                        answer.Add(v.ValorDeLaTabla(reader, i).ToString());
                                    }*/