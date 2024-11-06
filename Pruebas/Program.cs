using iTextSharp.text.pdf;
using Pruebas.packages;
using Pruebas.exceptiones;
using System.Reflection;
using Pruebas.convertTo;
using System.Text;
using Pruebas.BackEndTest.ForWebPage;
using Pruebas.BackEndTest.OnlyTest;
using System.ComponentModel.DataAnnotations;
//Hola

//// See https://aka.ms/new-console-template for more information

/*System.Random random = new System.Random();
System.Console.WriteLine(random.Next(34));
Type type = typeof(Random);
System.Console.WriteLine(type.Namespace);

Byte[] b = new Byte[1];
Random r = new Random();

r.NextBytes(b);
foreach (byte byteValue in b)
    Console.WriteLine("El numero generado es: " + byteValue);
*/
// Load the iTextSharp assembly
/*string namespaceName = "iTextSharp";
Assembly assembly = Assembly.Load("itextsharp");

foreach (Type type in assembly.GetTypes())
{
    if (type.Namespace != null && type.Namespace.StartsWith(namespaceName))
    {
        if (type.FullName.StartsWith("iTextSharp.text.pdf"))
        {
            Console.WriteLine(type.FullName);
        }
    }
}*/
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*            PdfModule pdfPodule = new PdfModule();
            ConvertTo convertTo = new ConvertTo();
            pdfPodule.saludo();
            string pdfRuteInput = @"D:\Documents\Aurora\";
            string pdfFileInput = "Medicina Interna Harrison 21º Edición Tomo I";
            string pdfFullInputPath = Path.Combine(pdfRuteInput,pdfFileInput+".pdf");
            string pdfRuteOutput = @"D:\Documents\Aurora\CapSacados\";
            string pdfFileOutput = "DocuemntoResumido.pdf";
            pdfPodule.extractPagesFromOtherPdf(pdfFullInputPath, pdfRuteOutput, pdfFileOutput);//*/
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*Console.WriteLine("Ruta de salida: " +pdfRuteOutput);
string c = "(1)";
Console.WriteLine("Es un Numero?\n Answer: " + convertTo.isInteger(c));
Console.WriteLine("El numero que le sigue a " + c + ", es:" + convertTo.countIntegerWithParenthesis(c));
pdfPodule.extractPagesFromOtherPdf(pdfFullInputPath, pdfRuteOutput, pdfFileOutput);*/


/*Console.WriteLine(convertTo.convertInverseString(")Hola("));
Console.WriteLine(convertTo.convertInverseStringWithPharentesis("(Hola)"));

Console.WriteLine("La ruta anterior es: ["+pdfRuteOutput+ pdfFileOutput + "].");
string ruta =convertTo.convertReplaceNamePdf(pdfRuteOutput, pdfFileOutput);
Console.WriteLine("La ruta nueva es: ["+ruta+"].");
c = ")3(";
Console.WriteLine("\n\n\n");
ruta = convertTo.convertInverseString(c);//primero debemos invertir los datos actuales porque tenemos )1( y debe ser puesto a (1)
Console.WriteLine("1. "+ruta);                                     //
ruta = convertTo.countIntegerWithParenthesis(ruta);//y luego aumentamos el numero dentro de '(',')'
Console.WriteLine("2. "+ruta);


//Console.WriteLine("Este caracter es un numero?\nAnswer:"+convertTo.isIntegerOneToOne(number));
char number = '7';
Console.WriteLine("Es entero completo?: "+convertTo.isIntegerOneToOne(number));*/
//string hello = Console.ReadLine();
//int b = Convert.ToInt32(number);
//List<char> listchar = new List<char> {'a','b','c','d','e' };
/*do { 
    Console.WriteLine("Primero en la cola: "+listchar[0]);
    listchar.RemoveAt(0); 
} while (listchar.Count>0);//*/

//Console.WriteLine(pdfPodule.extractTextFromPdf());*/
/*
//Module 2 Modulo 2
Console.WriteLine("Hello World");
string word = null;
word = "Hola " +
        "Hola 2";
Console.WriteLine("La variable word tiene la palabra [" + word +"] y esta tiene un tamaño de "+word.Length);

//Console.WriteLine(word[1:2]);//no funciona

//en python se puede imprimir la respuesta multiples veces solo añadiendo *, ej 'a'*3 = aaa, aqui no funciona 
char caracter = 'a';
Console.WriteLine("tenemos la letra a y su codigo ascii es: "+((int)caracter));
//python: alphabet = "abcdefghijklmnopqrstuvwxyz"
//print("f" in alphabet)
string alphabet = "abcdefghijklmnopqrstuvwxyz";
//Console.WriteLine(alphabet.Contains("d"));//.contains() es la contraparte en c#
alphabet.Insert(5,"Hola");
Console.WriteLine(alphabet);
//Console.WriteLine("New String: "+alphabet.Insert(2," HELLO "));
Console.WriteLine("Index of \"f\" in string is: "+alphabet.IndexOf("f"));
*/
/*Console.Write("Introduce un carácter: ");
char caracter = Console.ReadKey().KeyChar;
int codigoAscii = (int)caracter;

Console.WriteLine($"\nEl código ASCII de '{caracter}' es {codigoAscii}");*/

SQL_CONECTION sql_test = new SQL_CONECTION();
verification ver = new verification();
Console.WriteLine($"Los datos que envio, debe saber que: {sql_test.SQL_CreateUser("a","a","a","a")}");
string oracion = "Primer Intento Con Espacios";
string oracion2 = "Primer Intento Con Espacios";
//string oracion3_mail = "greg@mail.test";
//string oracion3_mail = "ghosted1@mail";
//string oracion4_user = "ghost";

string oracion3_mail = "ghosted1@mail";
string oracion4_user = "Gho st ";
Console.WriteLine($"Su Oracion con Espacios es: {oracion} y sin espacios es: {ver.NoSpaceSrting(oracion)}");
oracion = ver.NoSpaceSrting(oracion);
Console.WriteLine($"Y sus mayusculas en minusculas: {ver.Lower_Username(oracion)}");
Console.WriteLine($"Ambas: {ver.NoSpaceSrting(ver.Lower_Username(oracion2))}");

//Console.WriteLine($"La variable {oracion3} contiene @mail.test u otro email? : {sql_test.MailExistOnList(oracion3)}");
Console.WriteLine($"El usuario no existe: [{sql_test.User_NotExist(oracion4_user)}], El email no existe: [{sql_test.Email_NotExist(oracion3_mail)}]");
//Console.WriteLine(sql_test.ChangingPassword("password","test1"));

string numero = "98 1 1 1. 4 6";
Console.WriteLine($"Es un Numero con 2 decimales o menos?: [{verification.ItsDoubleWithTwoDecimal(numero)}]");
if (verification.ItsDoubleWithTwoDecimal(numero))
{
    Console.WriteLine($"Numero Transformado: "+verification.TransforToMoney(numero));
}
string querty = "select Ranks from datos_pueden_ser_ranks;";
foreach (string q in ver.DropDown(querty))
{
    Console.WriteLine($"Dato en Rank: {q}");
}

string usuario = ver.NoSpaceSrting(ver.Lower_Username("greg"));
Console.WriteLine($"El Usuario '{usuario}' es parte del rango mas alto: '{sql_test.ItsHighRank(usuario)}'");

if (1>=0 && 1 <2)
{
    Console.WriteLine("Soy ese");
}

int esp = 0;
List<List<string>> list = new List<List<string>>();
list = sql_test.UsersAndMeData(usuario);
for (int i = 0; i < list.Count; i +=1)
{
    Console.WriteLine($"Datos del Usuario: [{list[i][0]}]: ");
    for (int j = 0; j < list[i].Count;j+=1)
    {
        Console.Write($"Dato[{j}]: [{list[i][j]}] ");
    }//*/   
}
/*
string datousuario = "Hela";
List<List<string>> Usuarios = new List<List<string>>();
List<string> usuario1 = new List<string> { "Thor", "Rodriguez", "25", "masculino" };
List<string> usuario2 = new List<string> { "Loki", "Laufeyson", "30", "masculino" };
List<string> usuario3 = new List<string> { "Hela", "Helasdottir", "28", "femenino" };
List<string> usuario4 = new List<string> { "Odin", "Borson", "60", "masculino" };
Usuarios.Add(usuario1);
Usuarios.Add(usuario2);
Usuarios.Add(usuario3);
Usuarios.Add(usuario4);
for (int i = 0; i < Usuarios.Count; i++)
{
    Console.WriteLine($"{Usuarios[i][0]}, {Usuarios[i][1]}, {Usuarios[i][2]} años, {Usuarios[i][3]}");
}

transformdata t = new transformdata();
List<string> UsuarioElegido = t.Data(Usuarios, datousuario);
for (int i = 0; i < UsuarioElegido.Count; i += 1)
{
    Console.WriteLine($"Los datos que contiene {datousuario} son: {UsuarioElegido[i]}");
}
//*//*
string txtUserNameOld = "test1";
string txtUserName = "test1";
string txtMail = "test2@mail.test";
string Dropdown_Rank_Selected = "master";
string txtPago = "0.14";
string Dropdown_Pago_Por_Hora_Selected = "semanal";
string txtNewPassword_One = "password";
int Chk5Int = 1;

Console.WriteLine($"\nCambiando los datos : {sql_test.EditUser_General(txtUserNameOld, txtUserName, txtNewPassword_One, Chk5Int, Dropdown_Rank_Selected, Dropdown_Pago_Por_Hora_Selected, txtPago, txtMail)}");
//*/
