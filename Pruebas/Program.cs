using iTextSharp.text.pdf;
using Pruebas.packages;
using Pruebas.exceptiones;
using System.Reflection;
using Pruebas.convertTo;


// See https://aka.ms/new-console-template for more information

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
PdfModule pdfPodule = new PdfModule();
ConvertTo convertTo = new ConvertTo();
pdfPodule.saludo();
string pdfRuteInput = @"D:\Documents\Curriculum\Greg\DevCodes\C#\Pruebas\Pruebas\packages\aaa.pdf";
string pdfFileInput = "aaa";
string pdfFullInputPath = Path.Combine(pdfRuteInput,pdfFileInput+".pdf");
string pdfRuteOutput = "D:\\Documents\\Curriculum\\Greg\\DevCodes\\C#\\Pruebas\\Pruebas\\packages\\";
string pdfFileOutput = "aab.pdf";
Console.WriteLine("Ruta de salida: " +pdfRuteOutput);
string c = "(1)";
Console.WriteLine("Es un Numero?\n Answer: " + convertTo.isInteger(c));
Console.WriteLine("El numero que le sigue a " + c + ", es:" + convertTo.countIntegerWithParenthesis(c));
pdfPodule.extractPagesFromOtherPdf(pdfRuteInput,pdfRuteOutput, pdfFileOutput);
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

//Console.WriteLine(pdfPodule.extractTextFromPdf());
