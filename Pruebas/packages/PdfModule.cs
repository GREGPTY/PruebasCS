using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
using System.Text;
using System.Threading.Tasks;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.parser;
using iTextSharp.text;
using System.IO;
using System.Runtime.ConstrainedExecution;
using System.Reflection;
using Pruebas.exceptiones;
using Pruebas.convertTo;


namespace Pruebas.packages
{
    public class PdfModule
    {
        public void saludo()
        {
            Console.WriteLine("Hola Mundo, desde PdfModule");
            
        }
        public string extractTextFromPdf(string PdfPath)
        {
            //string PdfPath = "D:\\Documents\\Curriculum\\Greg\\DevCodes\\C#\\PruebasCS\\Pruebas\\Files\\";
            //string PdfPath = System.IO.Path.Combine(System.IO.Directory.GetCurrentDirectory(), "aaa.pdf");
            Console.WriteLine("PDF Path: " + PdfPath); // Imprimimos la ruta del archivo de entrada
            StringBuilder sb = new StringBuilder();

            if (File.Exists(PdfPath)) // Se asegura que el documento exista
            {
                PdfReader reader = new PdfReader(PdfPath);
                for (int page = 1; page <= reader.NumberOfPages; page++)
                {
                    ITextExtractionStrategy strategy = new SimpleTextExtractionStrategy();
                    string currentText = PdfTextExtractor.GetTextFromPage(reader, page);

                    // Remove unnecessary encoding conversion
                    //currentText = Encoding.UTF8.GetString(ASCIIEncoding.Convert(Encoding.Default, Encoding.UTF8, Encoding.Default.GetBytes(currentText)));
                    sb.Append(currentText);
                }
                reader.Close();
            }
            else
            {
                throw new FileNotFoundException("The specified PDF file does not exist.");
            }
            return sb.ToString();
        }
        public void extractPagesFromOtherPdf(string InputRute,string OutputRute,string OutputName)
        {
            string OfficialOutputRute= System.IO.Path.Combine(OutputRute,OutputName);
            iTextSharp.text.Document document = new iTextSharp.text.Document();            
            
            int i = 0, Final = 0;
            //Documentos de entrada            
            PdfReader reader = new PdfReader(InputRute);
            ConvertTo convertTo = new ConvertTo();
            PdfCopy outputDocument;
            if (File.Exists(OfficialOutputRute))
            {
                OfficialOutputRute = convertTo.convertReplaceNamePdf(OutputRute, OutputName);
                Console.WriteLine("PRESENTE DOC.: " + OfficialOutputRute);
            }
            outputDocument = new PdfCopy(document, new FileStream(OfficialOutputRute, FileMode.Create));
            
            document.Open();
            Exceptiones ex = new Exceptiones();
            //do {
            bool __iConvert = true;
            int totalPages = reader.NumberOfPages;//total de paginas
            Console.WriteLine("Cuantos Capitulos desea extraer?: ");
            int Chapter= ex.toInt();
            int[,] ChaptersRange = new int[Chapter,2];
            for(int ActualChapter = 0; ActualChapter < Chapter;  ActualChapter += 1) {
                Console.WriteLine("El numero Maximo de Paginas del libro es: "+totalPages);
                Console.WriteLine("\nIntroduzca la pagina de inicio del Capitulo["+(ActualChapter+1)+"]: ");
                ChaptersRange[ActualChapter,0]= ex.toInt();
                do
                {
                    Console.WriteLine("Introduzca la pagina de final del Capitulo["+(ActualChapter+1)+"]: ");
                    ChaptersRange[ActualChapter, 1] = ex.toInt();
                    if (ChaptersRange[ActualChapter,0] > ChaptersRange[ActualChapter,1])
                    {
                        __iConvert = true;
                        Console.WriteLine("El final no puede ser una pagina anterior a la del inicio");
                    }
                    else if (ChaptersRange[ActualChapter, 0] <= ChaptersRange[ActualChapter, 1])
                    {
                        __iConvert= false;
                    }
                } while (__iConvert);
                Console.WriteLine("\n");
            }

            //} while (); este se usara cuando sea necesario añadir mas de un capítulo y es necesario usar un array[]
            for (int ActualChapter = 0;ActualChapter < Chapter;ActualChapter+=1) {
                i = ChaptersRange[ActualChapter, 0];
                do
                {
                    if (i <= totalPages) {
                        PdfImportedPage page = outputDocument.GetImportedPage(reader, i);
                        outputDocument.AddPage(page);
                        Console.WriteLine("Pagina: " + i);
                        i += 1;
                    }
                    else
                    {
                        Console.WriteLine("Cantidad insuficiente de Paginas");
                    }
                } while (i <= ChaptersRange[ActualChapter, 1]); 
            }
            reader.Close();
            outputDocument.Close();
        }
    }
}
