using iTextSharp.text.pdf.parser.clipper;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Pruebas.convertTo
{
    public class ConvertTo
    {
        readonly int __empty = 0;
        public string convertReplaceNamePdf(string OutputRute,string OutputFile) {            
            string NewOutputFile = "";
            List<char> TemporalRute = new List<char>();
            //do{
                foreach (char page in OutputFile)
                {
                    TemporalRute.Add(page);
                   /* if (page == '\\')
                    {
                    NewOutputRute += "\\";
                    }*/
                    if (page == '.')
                    {
                    //int PageQuantity = NewOutputRute.Length;
                    if (TemporalRute[TemporalRute.Count - 2] == ')')
                    {
                        bool NumberInsideParenthesis = false,ParenteSis=false;
                        //Stack pharentesis = new Stack();
                        string TemporalString = ")";
                        //pharentesis.Push(")");
                        for (int i = TemporalRute.Count - 3; i >= __empty; i -= 1)
                        {
                            if ((TemporalRute[i] == '(') || isIntegerOneToOne(TemporalRute[i]))
                            {
                                //pharentesis.Push(TemporalRute[i]);
                                TemporalString += TemporalRute[i];
                                if (isIntegerOneToOne(TemporalRute[i])) { NumberInsideParenthesis = true; }//debe activarse para luego
                                else if (TemporalRute[i] == '(') { i = __empty - 1; ParenteSis = true; }//si detecta que llego a '(' termina el ciclo for
                                                                                     //si detecta el '(' pero no el numero dentro porque no hay entonces sale y no activa esta variable
                            }
                            else if (TemporalRute[i] == ')')
                            {
                                Console.WriteLine("Ruta del Archivo 2: " + TemporalRute.Count);
                                i = __empty - 1;
                                NewOutputFile += "(1)";
                                NumberInsideParenthesis = false;
                                string existDocumentRuteName = System.IO.Path.Combine(OutputRute, NewOutputFile + ".pdf");
                                if (File.Exists(existDocumentRuteName))
                                {
                                    Console.WriteLine("Existe el documento Nuevo");
                                    return convertReplaceNamePdf(OutputRute, NewOutputFile + ".pdf");//de ser necesario hacer esto recursivo activar
                                }
                            }
                            else {
                                NumberInsideParenthesis = false;
                                i = __empty - 1;
                                NewOutputFile += "(1)";
                                string existDocumentRuteName = System.IO.Path.Combine(OutputRute, NewOutputFile + ".pdf");
                                if (File.Exists(existDocumentRuteName))
                                {
                                    Console.WriteLine("Existe el documento Nuevo");
                                    return convertReplaceNamePdf(OutputRute, NewOutputFile + ".pdf");//de ser necesario hacer esto recursivo activar
                                }
                            }
                        }
                        if (NumberInsideParenthesis) //si de alguna manera no se activo el numero entnces saldra de inmediato
                        {                           //pero si se activo entonces
                            for (int i = TemporalRute.Count - 2; i >= __empty; i -= 1)
                            {
                                if ((TemporalRute[TemporalRute.Count - 2] == '('))
                                {
                                    i = __empty - 1;
                                }
                                //TemporalRute.Take(1);
                                TemporalRute.RemoveAt(TemporalRute.Count - 2);
                            } NewOutputFile = "";
                            do {
                                NewOutputFile += TemporalRute[0];
                                TemporalRute.RemoveAt(0);
                            } while (TemporalRute.Count > 1);//*/
                            TemporalString = convertInverseString(TemporalString);//primero debemos invertir los datos actuales porque tenemos )1( y debe ser puesto a (1)                              
                            TemporalString = countIntegerWithParenthesis(TemporalString);//y luego aumentamos el numero dentro de '(',')'
                            NewOutputFile += TemporalString;
                            string existDocumentRuteName = System.IO.Path.Combine(OutputRute, NewOutputFile+".pdf");
                            Console.WriteLine("Que ocurre: "+existDocumentRuteName);
                            if (File.Exists(existDocumentRuteName)) {
                                Console.WriteLine("Existe el documento Nuevo");
                                return convertReplaceNamePdf(OutputRute,NewOutputFile+".pdf");//de ser necesario hacer esto recursivo activar
                            }//*/                            
                        } else if (ParenteSis) { NewOutputFile += "(1)";
                            string existDocumentRuteName = System.IO.Path.Combine(OutputRute, NewOutputFile + ".pdf");
                            if (File.Exists(existDocumentRuteName))
                            {
                                Console.WriteLine("Existe el documento Nuevo");
                                return convertReplaceNamePdf(OutputRute, NewOutputFile + ".pdf");//de ser necesario hacer esto recursivo activar
                            }
                        }
                        //} while(numberInsideParenthesis);
                    }
                        else
                        {
                        NewOutputFile += "(1)";
                        string existDocumentRuteName = System.IO.Path.Combine(OutputRute, NewOutputFile + ".pdf");
                        if (File.Exists(existDocumentRuteName))
                        {
                            Console.WriteLine("Existe el documento Nuevo");
                            return convertReplaceNamePdf(OutputRute, NewOutputFile + ".pdf");//de ser necesario hacer esto recursivo activar
                        }
                    }
                        }
                        NewOutputFile += page;
                }
                NewOutputFile = Path.Combine(OutputRute,NewOutputFile);

            //}while(false);
            //return NewOutputRute;
            //Console.WriteLine("Ruta del Archivo 2: " + TemporalRute.Count);
            return NewOutputFile;
        }

        

       

        public string convertInverseStringWithPharentesis(string reverse)
        {
            string answer = "";
            Stack<char> stack = new Stack<char>();
            for (int i = reverse.Length-1;i>=__empty; i-=1)
            {
                if (!((reverse[i] == '(') || (reverse[i] == ')'))) {
                    answer = answer + reverse[i];
                }
                else if (reverse[i] == ')')
                {
                    stack.Push(reverse[i]);
                }
                else if(reverse[i] == '(')
                {
                    stack.Push(reverse[i]);
                }
            }
            while (stack.Count > 0)
            {
                char topStack = stack.Pop();
                if (topStack == '('){
                    answer = topStack+answer;                    
                }else if (topStack ==')')
                {
                    answer = answer+topStack;                    
                }                    
            }            
            return answer;

        }public string convertInverseString(string reverse)
        {
            string answer = "";
            for (int i = reverse.Length-1;i>=__empty; i-=1)
            {                
                 answer = answer + reverse[i];             
            }
            return answer;
        }

        public int convertToInteger(string cadena)
        {
            int answer = __empty; 
            try {
            answer = Convert.ToInt32(cadena); 
            }catch{ 
            return answer; }
            
            return answer;

        }
        public string countIntegerWithParenthesis(string a)
        {
            string answer = null,temporalStringNumber=null;
            int number = __empty;
            foreach (char c in a)
            {
                if ((c == '(') || (c == ')'))
                {
                }
                else
                {
                    temporalStringNumber = temporalStringNumber + c;
                }
                number =  Convert.ToInt32(temporalStringNumber);
                number = number + 1;
            }           
            answer = number.ToString();
            return "("+answer+")";
        }
        public bool isInteger(string a)
        {
            bool answer = true;

            foreach (char number in a)
            {
                if ((number == '(') || (number == ')'))
                {
                }
                // else if (!(isIntegerOneToOne(number)))
                else if(!isIntegerOneToOne(number))
                {
                    answer = false;
                }
            }
            return answer;
        }
        public bool isIntegerOneToOne(char a)
        {
            bool answer = false;
            try
            {
                if (char.IsDigit(a))
                {
                    answer = true;
                    /*int b = (int)char.GetNumericValue(a);                
                        if (int.IsEvenInteger(b))
                        {
                        answer = true;
                        }
                        else
                        {
                        answer = false;
                        }*/
                 }
            }catch { return false; }
            return answer;
        }
    }
}
