using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using BCrypt.Net;
using Microsoft.VisualBasic.FileIO;
using Pruebas.BackEndTest.ForWebPage;

namespace Pruebas.BackEndTest.OnlyTest
{
    internal class verification
    {

        readonly private string connectionString = SQL_CONECTION.ConnectionStringName();

        public string NoSpaceSrting(string String = null)
        {
            string answer = "";
            String = String.Replace(" ", "");
            answer = String;
            return answer;
        }
        public string Lower_Username(string String = null)
        {
            string answer = "";
            String = String.ToLower();
            answer = String;
            return answer;
        }
        public static byte[] HashearContrasena(string contraseña = null)
        {
            string hashed = BCrypt.Net.BCrypt.HashPassword(contraseña);
            byte[] hashedbyte = Encoding.UTF8.GetBytes(hashed);
            return hashedbyte;
        }

        public static bool ItsDoubleWithTwoDecimal(string Money = null)
        {
            bool answer = false;
            Money = Money.Replace(" ", "");            
            if (!string.IsNullOrEmpty(Money)) {
                if (Money.Contains(".")) {
                    string[] MoneySplit = Money.Split('.');
                    int entero_p = 0, decimal_p = 0;
                    if (MoneySplit.Length == 2)
                    {
                        if (int.TryParse(MoneySplit[0], out entero_p) && int.TryParse(MoneySplit[1], out decimal_p))
                        {
                            if (MoneySplit[1].Length < 3)
                            {
                                answer = true;
                            }
                        }
                        else
                        {
                            int i = 0;
                            answer = !int.TryParse(Money, out i);
                        }
                    }
                }
                else
                {
                    int i = 0;
                    answer = int.TryParse(Money, out i);
                }
            }
            return answer;
        }
        public static double TransforToMoney(string Money = null)
        {
            double answer = 0;
            Money = Money.Replace(" ", "");
            if (!string.IsNullOrEmpty(Money))
            {
                answer = double.Parse(Money);
            }
            else
            {
                answer = 0.00;
            }
            return answer;
        }
        public List<string> DropDown(string querty = null)
        {
            List<string> answer = new List<string>();            
            if (string.IsNullOrEmpty(querty)) {
                answer.Add("No Hay Opciones Disponibles");
            }
            else {
                try
                {
                    using (SqlConnection cxnx = new SqlConnection(connectionString))
                    {
                        cxnx.Open();
                        using (SqlCommand cmd = new SqlCommand(querty,cxnx))
                        {
                            using (SqlDataReader reader = cmd.ExecuteReader())
                            {
                                if (reader.HasRows){ 
                                    while (reader.Read()) {
                                        if (reader.GetString(0) != "ghost".ToLower()) {
                                            answer.Add(reader.GetString(0)); 
                                        }
                                    }
                                }
                                else
                                {
                                    answer.Add("No Hay Datos Disponibles");
                                }
                            } 
                        }
                        cxnx.Close();
                    }
                }
                catch (Exception ex) {
                    answer.Add($"Error, No Se Cargaron los datos: {ex.Message}");
                }
               }
            return answer;
        }

        public string ValorDeLaTabla(SqlDataReader reader = null, int column = 0)
        {
            string answer = "";
            if (reader.IsDBNull(column))
            {
                return "NULL";
            }
            Type fieldType = reader.GetFieldType(column);
            if (fieldType == typeof(string))
            {
                return reader.GetString(column);
            }
            else if (fieldType == typeof(int))
            {
                return reader.GetInt32(column).ToString();
            }
            else if (fieldType == typeof(double))
            {
                return reader.GetDouble(column).ToString("F2");
            }
            else if (fieldType == typeof(bool))
            {
                return reader.GetBoolean(column).ToString();
            }
            else if (fieldType == typeof(DateTime))
            {
                return reader.GetDateTime(column).ToString("yyyy-MM-dd HH:mm:ss");
            }
            else
            {
                return reader.GetValue(column).ToString();
            }
            return answer;
        }
    }
    public class transformdata
    {
        //este metodo esta diseñado para agarrar los datos de una o datos en general y devolver una respuesta con su operacion
        //despues explico mejor esto

        public List<string> Data(List<List<string>> Usuarios = null, string Username = null)
        { //Esta funcion se dedica a leer una lista que contiene una lista y devolver una lista especifica,, ej lista 1, 2, 3, quiero que devuelva los valores de la 3era lista solamente
            List<string> answer = new List<string>();
            answer.Add("No Hay Datos");
            if (Usuarios.Any())
            {
                for (int i = 0; i < Usuarios.Count; i += 1)
                {
                    //if (Usuarios[i][0].Contains(Username))
                    if (Usuarios[i][0].Equals(Username,StringComparison.OrdinalIgnoreCase))
                    {
                        answer.Clear();
                        foreach (string data in Usuarios[i])
                        {
                            answer.Add(data);
                        }
                        return answer;
                    }
                }
            }
            return answer;
        }
    }
}
