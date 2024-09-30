using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Pruebas.exceptiones
{
    public class Exceptiones
    {
        public int toInt()
        {
            int answer=0;
            try
            {
                answer = Convert.ToInt32(Console.ReadLine());
            }
            catch (Exception e)
            {
                Console.WriteLine("Introduzca un valor entero, Sin el punto decimal");
            }
            return answer;
        }
        public int toInt2() { 
            int answer=0;
            do
            {

            }while (true);
            return answer;
        }
    }
}
