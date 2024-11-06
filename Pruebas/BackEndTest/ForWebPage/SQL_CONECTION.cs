using System;
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
        private string connectionString = "tu conexion";
        
        public static string ConnectionStringName()
        {
            return "tu conexion";
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
        public bool ItsHighRank(string Username = null) //0,1
        {
            bool answer = false;
            int salida = 0;
            if (!string.IsNullOrEmpty(Username))
            {
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        string query = "select p.User_ControlGreg, p.Rank_Control, r.RankNumber from personal as p " +
                                       "inner join datos_pueden_ser_ranks as r on p.Rank_Control = r.Ranks " +
                                       "where p.User_ControlGreg = @username";

                        using (SqlCommand cmd = new SqlCommand(query, cxnx))
                        {
                            cmd.Parameters.AddWithValue("@username", Username);

                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.Read())
                                {
                                    int RankNumber = Convert.ToInt32(reader.GetInt32(2));
                                    salida = RankNumber;
                                    //Console.WriteLine($"El Rango Obtenido fue: {RankNumber} para el usuario [{Username}]");
                                    if (RankNumber >= 0 && RankNumber < 2)
                                    {
                                            answer = true;                                    
                                    }
                                    else
                                    {
                                        answer=false;
                                    }
                                }
                                else
                                {
                                    answer=false;
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


    }
}
